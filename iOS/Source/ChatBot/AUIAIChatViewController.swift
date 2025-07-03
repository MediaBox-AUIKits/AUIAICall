//
//  AUIAIChatViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit
import MJRefresh
import AVFoundation
import MobileCoreServices
import Photos
import PhotosUI

@objcMembers open class AUIAIChatViewController: AVBaseCollectionViewController {
    
    // 初始化
    public init(userInfo: ARTCAIChatUserInfo, agentInfo: ARTCAIChatAgentInfo) {
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start ChatBot")
        
        let engine = ARTCAICallEngineFactory.createChatEngine()
        self.engine = engine
        self.sessionId = "\(userInfo.userId)_\(agentInfo.agentId)"
        super.init(nibName: nil, bundle: nil)
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.start()
#endif
        
        self.engine.delegate = self
        self.engine.startChat(userInfo: userInfo, agentInfo: agentInfo, sessionId: self.sessionId)
        self.doLoadMessage()
    }
    
    // 初始化
    public init(userInfo: ARTCAIChatUserInfo, shareInfo: String) {
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start ChatBot")
        
        let engine = ARTCAICallEngineFactory.createChatEngine()
        self.engine = engine
        let agentShareConfig = self.engine.parseShareAgentChat(shareInfo: shareInfo)
        self.sessionId = "\(userInfo.userId)_\(agentShareConfig?.shareId ?? "")"
        super.init(nibName: nil, bundle: nil)
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.start()
#endif
        
        self.agentShareConfig = agentShareConfig
        let agentInfo = ARTCAIChatAgentInfo(agentId: self.agentShareConfig?.shareId ?? "invalid_agent_id")
        agentInfo.region = self.agentShareConfig?.region ?? "cn-shanghai"
        self.engine.delegate = self
        self.engine.startChat(userInfo: userInfo, agentInfo: agentInfo, sessionId: self.sessionId)
        self.doLoadMessage()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.finish()
#endif
        self.doSaveMessage()
        
        // TODO: 如果有多个消息对话的智能体，那么在结束当前对话时，无需进行登出，可以把needLogout设置为false
        let needLogout = true
        if needLogout {
            self.engine.endChat(needLogout: true)
            self.engine.destroy()
        }
        else {
            self.engine.endChat(needLogout: false)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AVTheme.bg_medium
        self.headerView.backgroundColor = AVTheme.bg_medium
        self.titleView.font = AVTheme.mediumFont(14)
        
        self.headerView.addSubview(self.agentBtn)
        self.agentBtn.sizeToFit()
        self.agentBtn.frame = CGRectMake(self.backButton.av_right + 12, UIView.av_safeTop,self.agentBtn.av_width, 44)
        
        self.menuButton.setImage(AUIAIChatBundle.getCommonImage("ic_setting"), for: .normal)
        self.menuButton.addTarget(self, action: #selector(onSettingBtnClicked), for: .touchUpInside)
        #if AICALL_ENABLE_FEEDBACK
         self.reportBtn = self.setupReportBtn()
        #endif
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.frame = CGRect(x: 0, y: self.contentView.av_height - (68 + UIView.av_safeBottom), width: self.contentView.av_width, height: 68 + UIView.av_safeBottom)
        
        self.collectionView.av_height = self.bottomView.av_top
        self.collectionView.register(AUIAIChatMessageTextCell.self, forCellWithReuseIdentifier: "TextCell")
        self.collectionView.register(AUIAIChatMessageUserAttachmentCell.self, forCellWithReuseIdentifier: "UserAttachmentCell")
        self.collectionView.register(AUIAIChatMessageAgentTextCell.self, forCellWithReuseIdentifier: "AgentTextCell")
        
        let mjHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(onFetchHistoryMessage))
        mjHeader.lastUpdatedTimeLabel?.isHidden = true
        mjHeader.stateLabel?.isHidden = true
        mjHeader.loadingView?.style = .white
        self.collectionView.mj_header = mjHeader
        
        self.view.sendSubviewToBack(self.contentView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.refreshEngineState()
        
        let maxWidth = self.getAgentCellMaxWidth()
        self.listMessage.forEach { item in
            if item.isLeft {
                item.updateAgentContentInfo(computeQueue: self.agentComputeQueue, maxWidth: maxWidth) { [weak self] in
                    self?.scrollToLast = 2
                    self?.collectionView.reloadData()
                }
            }
            else {
                item.updateContentInfoSync(maxWidth: maxWidth)
                self.scrollToLast = 2
                self.collectionView.reloadData()
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.doSaveMessage()
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override func disableInteractivePopGesture() -> Bool {
        // 有附件上传时，禁止右滑关闭
        return self.editingTextView.sendAttachmentsView != nil
    }
    
    open override func goBack() {
        self.hideEditingTextView(destroy: true)
        super.goBack()
    }
    
    open lazy var agentBtn: UIButton = {
        let btn = UIButton()
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        btn.titleLabel?.font = AVTheme.mediumFont(14)
        btn.setTitle(AUIAIChatBundle.getString("XiaoYun"), for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_avatar"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(onAgentBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    open lazy var bottomView: AUIAIChatBottomView = {
        let view = AUIAIChatBottomView()
        view.enableCall = self.agentShareConfig == nil
        view.voiceCallBtn.tappedAction = {[weak self] btn in
            self?.tryStartCall(agentType: .VoiceAgent)
            self?.bottomView.reset()
        }
        view.avatarCallBtn.tappedAction = {[weak self] btn in
            self?.tryStartCall(agentType: .AvatarAgent)
            self?.bottomView.reset()
        }
        view.visionCallBtn.tappedAction = {[weak self] btn in
            self?.tryStartCall(agentType: .VisionAgent)
            self?.bottomView.reset()
        }
        view.videoCallBtn.tappedAction = {[weak self] btn in
            self?.tryStartCall(agentType: .VideoAgent)
            self?.bottomView.reset()
        }
        view.addPhotoBtn.tappedAction = {[weak self] btn in
            self?.openPhotoLibrary()
            self?.bottomView.reset()
        }
        view.onClickedStop = { [weak self] bottomView in
            guard let self = self else { return }
            self.engine.interruptAgentResponse()
            self.showToast(AUIAIChatBundle.getString("User terminated this response"))
        }
        view.textView.onClickedInputText = { [weak self] textView in
            guard let self = self else { return }
            self.showEditingTextView(item: nil)
            self.bottomView.reset()
        }
        view.audioView.onTouchedRecordingArea = { [weak self] audioView in
            guard let self = self else { return }
            self.startRecordingAudio()
        }
        view.audioView.onTouchingRecordingAreaAndDrag = { [weak self] audioView, isExit in
            guard let self = self else { return }
            self.onRecordingAudio(inside: !isExit)
        }
        view.audioView.onTouchUpRecordingArea = { [weak self] audioView, isInside in
            guard let self = self else { return }
            self.finishRecordingAudio(isInside, false)
        }
        view.isStopped = self.engine.agentResponeState != .Listening
        return view
    }()
    
    open lazy var editingTextView: AUIAIChatEditingTextView = {
        let view = AUIAIChatEditingTextView()
        view.onClickedStop = { [weak self] in
            guard let self = self else { return }
            self.engine.interruptAgentResponse()
            self.showToast(AUIAIChatBundle.getString("User terminated this response"))
        }
        view.onSendBlock = { [weak self] text in
            guard let self = self else { return }
            if self.editingTextView.sendAttachmentsView?.uploadFailure == true {
                self.showToast(AUIAIChatBundle.getString("Some images failed to upload"))
                return
            }
            if self.editingTextView.sendAttachmentsView?.allUploadSuccess == false {
                return
            }
            
            self.sendTextMessage(text: text)
            self.bottomView.textView.updatePlaceholderText(text: nil)
        }
        view.onPositionYChangedBlock = { [weak self] value in
            guard let self = self else { return }
            if value != 0 {
                self.collectionView.av_height = self.contentView.av_height + value
            }
            else {
                self.collectionView.av_height = self.bottomView.av_top
            }
            debugPrint("collectionView frame:\(self.collectionView.frame)")
            self.canScrollToLast = true
            self.asyncScrollLastMessage(ani: true)
        }
        view.onInputTextChangedBlock = { [weak self] text in
            self?.bottomView.textView.updatePlaceholderText(text: text?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        view.inputAudioView.touchDownBlock = { [weak self] btn in
            self?.startRecordingAudio()
        }
        view.inputAudioView.touchUpBlock = { [weak self] btn, inside in
            self?.finishRecordingAudio(inside, false)
        }
        view.inputAudioView.touchDragBlock = { [weak self] btn, inside in
            self?.onRecordingAudio(inside: inside)
        }
        view.isStopped = self.engine.agentResponeState != .Listening
        return view
    }()
    
    open lazy var recordingAudioView: AUIAIChatRecordingAudioView = {
        let view = AUIAIChatRecordingAudioView()
        view.onTimeOutBlock = { [weak self] in
            self?.finishRecordingAudio(false, false)
        }
        return view
    }()
    
    open var reportBtn: UIButton? = nil
    
    open var menuView: AUIAIChatMessageCellMenu? = nil
    private func showMenuView(position: CGPoint, item: AUIAIChatMessageItem) {
        if self.menuView == nil {
            let menuView = AUIAIChatMessageCellMenu(frame: self.view.bounds)
            menuView.deleteBtn.action = { [weak self] btn in
                guard let self = self else { return }
                if let item = self.menuView?.item {
                    self.deleteMessage(item: item)
                }
                
                self.menuView?.removeFromSuperview()
                self.menuView = nil
            }
            self.menuView = menuView
        }
        
        self.view.addSubview(self.menuView!)
        self.menuView?.item = item
        self.menuView?.updatePosition(midx_bot: position)
    }
    
    open var playMessageLoadingView: UIView? = nil
    
    private func tryStartCall(agentType: ARTCAICallAgentType) {
        if self.engine.state != .Connected {
            self.showToast(AUIAIChatBundle.getString("Unable to start call because there is not connected"))
            return
        }
        let chatSyncConfig = ARTCAICallChatSyncConfig(sessionId: self.sessionId, agentId: self.engine.agentInfo?.agentId ?? "", receiverId: self.engine.userInfo?.userId ?? "")
        AUIAICallManager.defaultManager.startCall(agentType: agentType, chatSyncConfig: chatSyncConfig)
    }
    
    private func deleteMessage(item: AUIAIChatMessageItem) {
        AVAlertController.show(withTitle: AUIAIChatBundle.getString("Confirm delete message?"), message: AUIAIChatBundle.getString("Messages deleted cannot be recovered"), btn1: AUIAIChatBundle.getString("Delete"), btn1Destructive: true, btn2: AUIAIChatBundle.getString("Cancel"), btn2Destructive: false) { isCancel in
            if isCancel == false {
                self.engine.deleteMessage(message: item.message) { error in
                    if let error, error.aicall_code != .ChatLogNotFound {
                        self.showToast(AUIAIChatBundle.getString("Delete failed") + ": \(error.code)")
                    }
                    else {
                        self.listMessage.removeAll { remove in
                            return remove == item
                        }
                        self.collectionView.reloadData()
                        self.needSaveMessages = true
                    }
                }
            }
        }
    }
    
    private func startRecordingAudio() {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            let req = ARTCAIChatSendMessageRequest(.Voice)
            if let attachmentUploader =  self.editingTextView.sendAttachmentsView?.attachmentUploader {
                if attachmentUploader.allUploadSuccess == true {
                    req.attachmentUploader = attachmentUploader
                }
            }
            let pushEnabled = self.engine.startPushVoiceMessage(request: req)
            if pushEnabled {
                if self.editingTextView.viewOnShow {
                    self.recordingAudioView.presentOnView(parent: self.editingTextView, bottom: self.editingTextView.getSendingBarHeight())
                }
                else {
                    self.recordingAudioView.presentOnView(parent: self.bottomView, bottom: self.bottomView.av_height - UIView.av_safeBottom)
                }
            } else {
                self.showToast(AUIAIChatBundle.getString("Failed to push voice message"))
            }
        }
        else {
            AVDeviceAuth.checkMicAuth { _ in }
        }
    }
    
    private func finishRecordingAudio(_ needPushVoiceMessage: Bool, _ interrupt: Bool) {
        if !self.recordingAudioView.viewOnShow { return }
        self.recordingAudioView.dismiss()
        if interrupt {
            return
        }
        if needPushVoiceMessage {
            self.engine.finishPushVoiceMessage { [weak self] msg in
                guard let self = self else { return }
                if msg.text.isEmpty {
                    self.showToast(AUIAIChatBundle.getString("No text recognized"))
                }
                else {
                    let item = AUIAIChatMessageItem(message: msg)
                    item.isLeft = false
                    item.updateContentInfoSync(maxWidth: self.getAgentCellMaxWidth())
                    item.attachmentUploader = self.editingTextView.sendAttachmentsView?.attachmentUploader
                    self.addMessageToList(item: item)
                    if self.editingTextView.viewOnShow {
                        self.hideEditingTextView(destroy: false)
                    }
                }
            }
        } 
        else {
            self.engine.cancelPushVoiceMessage()
        }
    }
    
    private func onRecordingAudio(inside: Bool) {
        if !self.recordingAudioView.viewOnShow { return }
        if inside {
            self.recordingAudioView.viewState = .Recording
        } 
        else {
            self.recordingAudioView.viewState = .CancelRecord
        }
    }
    
    private func sendTextMessage(text: String) {
        var msg = ARTCAIChatMessage(sendText: text, requestId: "", senderId: self.engine.userInfo?.userId)
        if let attachmentUploader =  self.editingTextView.sendAttachmentsView?.attachmentUploader {
            if attachmentUploader.allUploadSuccess == false {
                return
            }
            msg = ARTCAIChatMessage(sendText: text, requestId: "", attachmentList: attachmentUploader.attachmentList)
        }
        else if msg.text.isEmpty == true {
            return
        }
        let item = AUIAIChatMessageItem(message: msg)
        item.isLeft = false
        item.updateContentInfoSync(maxWidth: self.getAgentCellMaxWidth())
        item.attachmentUploader = self.editingTextView.sendAttachmentsView?.attachmentUploader

        self.sendMessage(item: item)
        self.addMessageToList(item: item)
        if self.editingTextView.viewOnShow {
            self.hideEditingTextView(destroy: false)
        }
    }
    
    private func sendMessage(item: AUIAIChatMessageItem) {
        if item.isLeft == false, item.message.messageType == .Text {
            let req = ARTCAIChatSendMessageRequest(text: item.contentOriginText)
            if let attachmentUploader =  item.attachmentUploader {
                req.attachmentUploader = attachmentUploader
            }
            self.engine.sendMessage(request: req, completed: {[weak item, weak self] msg, error in
                guard let item = item else { return }
                if let msg = msg {
                    item.message = msg
                    self?.refreshMessageCellState(item: item)
                }
                if let _ = error {
                    let userMsg = msg ?? ARTCAIChatMessage(sendText: item.contentOriginText, requestId: item.message.requestId, senderId: self?.engine.userInfo?.userId, state: .Failed)
                    item.message = userMsg
                    self?.refreshMessageCellState(item: item)
                }
            })
            self.refreshMessageCellState(item: item)
        }
    }
    
    private func addMessageToList(item: AUIAIChatMessageItem) {
        
        self.listMessage.append(item)
        self.needSaveMessages = true

        self.scrollToLast = 1
        self.collectionView.reloadData()
    }
    
    private func playOrStopMessage(textCell: AUIAIChatMessageTextCell, item: AUIAIChatMessageItem) {
        let isPlaying = self.engine.isPlayingMessage(dialogueId: item.message.dialogueId)
        if isPlaying {
            self.engine.stopPlayMessage()
            self.setPlayMessageLoadingViewVisible(visible: false)
        }
        else {
            self.engine.startPlayMessage(message: item.message, voiceId: self.currentVoiceId) { [weak self] error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    self.showToast(AUIAIChatBundle.getString("Playback failed") + ": \(error.code)")
                }
                else {
                    self.setPlayMessageLoadingViewVisible(visible: true)
                }
            }
        }
    }
    
    private func setPlayMessageLoadingViewVisible(visible: Bool) {
        if visible {
            self.setPlayMessageLoadingViewVisible(visible: false)
            let toast = AVToastView.show(AUIAIChatBundle.getString("Generating speech reading..."), view: self.view, position: .mid)
            toast.backgroundColor = AVTheme.bg_weak
            self.playMessageLoadingView = toast
        }
        else {
            self.playMessageLoadingView?.removeFromSuperview()
            self.playMessageLoadingView = nil
        }
    }
    
    private func refreshEngineState() {
        if self.engine.state == .Init {
            self.titleView.text = AUIAIChatBundle.getString("Not Connected")
        }
        else if self.engine.state == .Connecting {
            self.titleView.text = AUIAIChatBundle.getString("Connecting")
        }
        else if self.engine.state == .Disconnect {
            self.titleView.text = AUIAIChatBundle.getString("Disconnected")
        }
        else {
            self.titleView.text = nil
        }
    }
    
    private func refreshMessageCellState(item: AUIAIChatMessageItem) {
        self.collectionView.visibleCells.forEach { cell in
            if let cell = cell as? AUIAIChatMessageTextCell {
                if cell.item == item {
                    cell.refreshStateUI()
                }
            }
        }
    }
    
    private func refreshMessagePlayState() {
        self.collectionView.visibleCells.forEach { cell in
            if let cell = cell as? AUIAIChatMessageTextCell {
                if let dialogueId = cell.item?.message.dialogueId {
                    cell.updateIsPlaying(isPlaying: self.engine.isPlayingMessage(dialogueId: dialogueId))
                }
            }
        }
    }
    
    private func showToast(_ text: String) {
        let toast = AVToastView.show(text, view: self.view, position: .mid)
        toast.backgroundColor = AVTheme.bg_weak
    }
    
    private func asyncScrollLastMessage(ani: Bool) {
        DispatchQueue.main.async {
            guard self.canScrollToLast else {
                return
            }
            let contentSize = self.collectionView.contentSize
            let contentInset = self.collectionView.contentInset
            let rect = CGRect(x: 0, y: contentSize.height - contentInset.bottom - 10, width: contentSize.width, height: 10)
            self.collectionView.scrollRectToVisible(rect, animated: ani)
        }
    }
    
    private func getAgentCellMaxWidth() -> CGFloat {
        return self.collectionView.av_width - 40.0
    }

    private var listMessage: [AUIAIChatMessageItem] = []

    private var scrollToLast: Int = 0  // 1: 动画  2：不用动画
    private var canScrollToLast: Bool = true
    private var needSaveMessages: Bool = false
    
    public var onUserTokenExpiredBlcok: (()->Void)? = nil
    public let engine: ARTCAIChatEngineInterface
    public let sessionId: String
    private var currentVoiceId: String = ""
    
    private var agentShareConfig: ARTCAIChatAgentShareConfig? = nil
    
    private lazy var agentComputeQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.auiaichat")
        return queue
    }()
}

// 处理附件
extension AUIAIChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    private func showEditingTextView(item: AUIAIChatSendAttachmentItem?) {
        if let item = item {
            if let sendAttachmentsView = self.editingTextView.sendAttachmentsView {
                sendAttachmentsView.addItem(item: item)
                if self.editingTextView.viewOnShow {
                    return
                }
            }
        }
        self.editingTextView.presentOnView(parent: self.view, isAudioMode: self.bottomView.isAudioMode, isEditing: item == nil)
    }
    
    private func hideEditingTextView(destroy: Bool) {
        if destroy == true, let attachmentUploader = self.editingTextView.sendAttachmentsView?.attachmentUploader {
            // 如果attachmentUploader没有被发送消息，那么该attachmentUploader的附件需要进行销毁
            attachmentUploader.attachmentList.forEach { [weak attachmentUploader] atta in
                attachmentUploader?.removeAttachment(attachmentId: atta.attachmentId)
            }
        }
        self.editingTextView.dismiss()
    }
    
    private func startUploadImage(item: AUIAIChatSendAttachmentItem?) {
        if self.editingTextView.sendAttachmentsView != nil {
            self.showEditingTextView(item: item)
            return
        }
        
        if let uploader = self.engine.createAttachmentUploader() {
            let sendAttachmentsView = AUIAIChatSendAttachmentView(frame: .zero, attachmentUploader: uploader)
            sendAttachmentsView.willAddItemBlock = { [weak self] in
                self?.openPhotoLibrary()
            }
            sendAttachmentsView.willRemoveItemBlock = { [weak self] item in
                if let editingTextView = self?.editingTextView {
                    editingTextView.sendAttachmentsView?.removeItem(item: item)
                    if editingTextView.sendAttachmentsView?.itemList.isEmpty == true {
                        self?.hideEditingTextView(destroy: true)
                    }
                }
            }
            sendAttachmentsView.uploadFailureBlock = { [weak self] item in
                guard let self = self else { return }
                AVToastView.show(AUIAIChatBundle.getString("Failed to upload image") , view: self.view, position: .mid)
            }
            self.editingTextView.sendAttachmentsView = sendAttachmentsView
            self.showEditingTextView(item: item)
            return
        }
        AVAlertController.show(AUIAIChatBundle.getString("Failed to upload image"), vc: self)
    }
    
    // 打开相册
    private func openPhotoLibrary() {
        if #available(iOS 14.0, *) {
            let count = self.editingTextView.sendAttachmentsView?.itemList.count ?? 0
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 9 - count
            configuration.filter = .images // 只选择图片

            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary // 设置为相册模式
            imagePicker.mediaTypes = [kUTTypeImage as String] // 仅允许选择图片
            imagePicker.delegate = self
            imagePicker.allowsEditing = false // 是否允许编辑（可选）
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // 控制分辨率不超过maxResolution，超过的话按比例进行缩放
    private func resizeImageIfNeeded(_ image: UIImage, maxResolution: CGSize) -> UIImage {
        let originalSize = image.size
        let maxWidth = maxResolution.width
        let maxHeight = maxResolution.height
        
        // 检查是否需要缩放
        if originalSize.width <= maxWidth && originalSize.height <= maxHeight {
            return image // 不需要缩放，直接返回原图
        }
        
        // 计算缩放比例
        let widthRatio = maxWidth / originalSize.width
        let heightRatio = maxHeight / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio) // 保持宽高比
        
        // 计算新的尺寸
        let newSize = CGSize(
            width: originalSize.width * scaleFactor,
            height: originalSize.height * scaleFactor
        )
        
        // 创建新的图片上下文
        UIGraphicsBeginImageContextWithOptions(newSize, true, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    private func onPickerImageResult(image: UIImage?) -> Bool {
        guard let image = image else { return false }
        let selectedImage = self.resizeImageIfNeeded(image, maxResolution: CGSize(width: 1080, height: 1920))
        let fileName = UUID().uuidString + ".png"
        let fileURL = AUIAIChatViewController.getFileUrl(fileName: fileName, subDir: "attaments")
        if let imageData = selectedImage.pngData() {
            do {
                try imageData.write(to: fileURL)
                debugPrint("图片已保存到临时路径: \(fileURL.path)")
                DispatchQueue.main.async {
                    let attachment = ARTCAIChatAttachment(localFilePath: fileURL.path, type: .Image)
                    let item = AUIAIChatSendAttachmentItem(image: selectedImage, attachment: attachment)
                    self.startUploadImage(item: item)
                }
                return true
            }
            catch {
                debugPrint("图片保存失败: \(error)")
            }
        }
        return false
    }
    
    // 处理用户选择的图片
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        if self.onPickerImageResult(image: selectedImage) == false {
            AVAlertController.show(AUIAIChatBundle.getString("Failed to load image"), vc: self)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // 用户取消选择
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let image = object as? UIImage {
                        if self?.onPickerImageResult(image: image) == false {
                            debugPrint("Failed to load image")
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AUIAIChatViewController {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listMessage.count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.listMessage[indexPath.row]
        if item.displaySize == nil {
            if item.isLeft {
                AUIAIChatMessageAgentTextCell.computeAgentSize(item: item, maxWidth: self.getAgentCellMaxWidth())
            }
            else if item.message.attachmentList?.isEmpty == false {
                AUIAIChatMessageUserAttachmentCell.computeAttachmentSize(item: item, maxWidth: self.getAgentCellMaxWidth())
            }
            else {
                AUIAIChatMessageTextCell.computeSize(item: item, maxWidth: self.getAgentCellMaxWidth())
            }
        }
        
        // 当前计算好所有的item高度是，进行异步滚动到底部（如果需要）
        if indexPath.row == self.listMessage.count - 1 {
            if self.scrollToLast > 0 {
                self.asyncScrollLastMessage(ani: self.scrollToLast == 1)
            }
            self.scrollToLast = 0
        }
        
        return CGSize(width: self.getAgentCellMaxWidth(), height: item.displaySize?.height ?? 0)
    }
        
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.listMessage[indexPath.row]
        if item.message.messageType == .Text {
            var textCell: AUIAIChatMessageTextCell? = nil
            if item.isLeft == true {
                let agentTextCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AgentTextCell", for: indexPath) as? AUIAIChatMessageAgentTextCell
                agentTextCell?.onReasonExpandBlock = {[weak self] cell in
                    cell.item?.isExpandReasonText = cell.item?.isExpandReasonText == false
                    cell.item?.reasonSize = nil
                    self?.collectionView.reloadData()
                }
                textCell = agentTextCell
            }
            else if item.message.attachmentList?.isEmpty == false {
                textCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "UserAttachmentCell", for: indexPath) as? AUIAIChatMessageUserAttachmentCell
            }
            else {
                textCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as? AUIAIChatMessageTextCell
            }
            if let textCell = textCell {
                textCell.item = item
                textCell.onResendBlock = { [weak self] item in
                    guard let self = self else { return }
                    self.sendMessage(item: item)
                }
                textCell.onCopyBlock = { [weak self] item in
                    guard let self = self, item.contentOriginText.isEmpty == false else { return }
                    UIPasteboard.general.string = item.contentOriginText
                    self.showToast(AUIAIChatBundle.getString("Message copied"))
                }
                textCell.onLongPressBlock = { [weak self] item, view, location in
                    guard let self = self else { return }
                    if item.message.messageState == .Init || item.message.messageState == .Transfering || item.message.messageState == .Printing {
                        return
                    }
                    // 触发反馈
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    // 弹出菜单
                    let locationInParentView = view.convert(location, to: self.view)
                    self.showMenuView(position: locationInParentView, item: item)
                }
                textCell.onPlayBlock = { [weak self, weak textCell] item in
                    guard item.contentOriginText.isEmpty == false else { return }
                    if item.message.messageState == .Init || item.message.messageState == .Transfering || item.message.messageState == .Printing {
                        return
                    }
                    guard let self = self, let textCell = textCell else { return }
                    self.playOrStopMessage(textCell: textCell, item: item)
                }
                textCell.updateIsPlaying(isPlaying: self.engine.isPlayingMessage(dialogueId: item.message.dialogueId))
                return textCell
            }
            
        }
        
        return UICollectionViewCell()
    }
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        debugPrint("scrollViewWillBeginDragging")
        self.canScrollToLast = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(enableScrollToLast), object: nil)
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        debugPrint("scrollViewDidEndDragging decelerate: \(decelerate)")
        self.perform(#selector(enableScrollToLast), with: nil, afterDelay: 3.0)
    }
    
    open override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        debugPrint("scrollViewWillBeginDecelerating")
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        debugPrint("scrollViewDidEndDecelerating")
    }
    
    @objc func enableScrollToLast() {
        self.canScrollToLast = true
    }
}

// Event
extension AUIAIChatViewController {
    
    @objc private func applicationWillResignActive() {
        self.doSaveMessage()
        self.finishRecordingAudio(false, false)
    }
    
    @objc private func applicationDidBecomeActive() {
    }
    
    @objc private func applicationDidEnterBackground() {
        self.finishRecordingAudio(false, false)
    }
        
    @objc open func onSettingBtnClicked() {
        let panel = AUIAIChatSettingPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
        panel.setup(voiceIdList: self.engine.voiceIdList, selectItemId: self.currentVoiceId)
        panel.applyPlayBlock = { [weak self] item in
            self?.currentVoiceId = item.voiceId
        }
        panel.show(on: self.view, with: .clickToClose)
    }
    
    @objc open func onAgentBtnClicked() {
#if DEMO_FOR_DEBUG
        self.showDebugInfo()
#endif
    }
    
    @objc private func onFetchHistoryMessage() {
        var endTime = Date().timeIntervalSince1970
        if let sendTime = self.listMessage.first?.message.sendTime {
            endTime = sendTime - 0.1
        }
        let req = ARTCAIChatMessageListRequest(startTime: 0, endTime: endTime, pageNumber: 1, pageSize: 10, isDesc: true)
        self.engine.queryMessageList(request: req) { [weak self] msgList, error in
            guard let self = self else {
                return
            }
            self.collectionView.mj_header?.endRefreshing()
            if let error = error {
                self.showToast(AUIAIChatBundle.getString("Failed to retrieve historical messages") + ": \(error.code)")
            }
            else {
                let isEmpty = self.listMessage.isEmpty
                if isEmpty {
                    self.needSaveMessages = true
                }
                let maxWidth = self.getAgentCellMaxWidth()
                msgList?.forEach({ msg in
                    let item = AUIAIChatMessageItem(message: msg)
                    item.isLeft = self.engine.userInfo?.userId != msg.senderId
                    self.listMessage.insert(item, at: 0)
                    
                    if item.isLeft {
                        item.updateAgentContentInfo(computeQueue: self.agentComputeQueue, maxWidth: maxWidth) { [weak self] in
                            self?.collectionView.reloadData()
                        }
                    }
                    else {
                        item.updateContentInfoSync(maxWidth: maxWidth)
                        self.collectionView.reloadData()
                    }
                })
            }
        }
    }
}

extension AUIAIChatViewController: ARTCAIChatEngineDelegate {
    
    public func onRequestAuthToken(userId: String, responseBlock: @escaping (ARTCAIChatAuthToken?, NSError?) -> Void) {
        self.fetchAuthToken(userId: userId) { authToken, error in
            responseBlock(authToken, error)
        }
    }
    
    public func onEngineStateChange(state: ARTCAIChatEngineState) {
        self.refreshEngineState()
    }
    
    public func onErrorOccurs(error: NSError, requestId: String?) {
        if let _ = requestId {
            // 处理文本消息出错
            if error.aicall_code == .ChatTextMessageReceiveFailed {
                self.showToast(AUIAIChatBundle.getString("An error occurred, unable to continue receiving replies from the agent") + ": \(error.code)")
                return
            }
            
            // 处理语音消息出错
            if error.aicall_code == .ChatVoiceMessageReceiveFailed {
                self.finishRecordingAudio(false, true)
                self.showToast(AUIAIChatBundle.getString("Failed to push voice message") + ": \(error.code)")
                return
            }
            
            // 处理播放出错
            if error.aicall_code == .ChatPlayMessageReceiveFailed {
                self.showToast(AUIAIChatBundle.getString("Playback failed") + ": \(error.code)")
                return
            }
            
            return
        }
        
        var msg = AUIAIChatBundle.getString("An error occurred, connection has been disconnected")
        if let code = error.aicall_code {
            if code == .TokenExpired {
                msg = AUIAIChatBundle.getString("Authentication token is invalid, connection has been disconnected")
            }
            else if code == .AgentNotFound {
                msg = AUIAIChatBundle.getString("Please check if the agent ID is correct")
            }
            else if code == .KickedBySystem {
                msg = AUIAIChatBundle.getString("The current user may have been disconnected by the system")
            }
            else if code == .KickedByUserReplace {
                msg = AUIAIChatBundle.getString("The current user may be logged in on another device, connection has been disconnected")
            }
        }
        self.titleView.text = AUIAIChatBundle.getString("Disconnected")
        self.titleView.textColor = AUIAIChatBundle.danger_strong
        
        if let navController = self.navigationController {
            if navController.visibleViewController == self {
                AVAlertController.show(msg, vc: self)
                return
            }
        }
        // 当前VC还未展示
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            AVAlertController.show(msg, vc: self)
        }
    }
    
    public func onUserMessageUpdated(message: ARTCAIChatMessage) {
        let item = self.listMessage.last { item in
            return item.isSame(message: message, isLeft: false)
        }
        if let item = item {
            item.message = message
            debugPrint("onUserMessageUpdated:\(item.message.toData())")
            self.needSaveMessages = true
        }
    }
    
    public func onReceivedMessage(message: ARTCAIChatMessage) {
        let isLeft = message.senderId == self.engine.agentInfo?.agentId
        
        let item = self.listMessage.last { item in
            return item.isSame(message: message, isLeft: isLeft)
        }
        
        let reloadBlock = { [weak self] in
            self?.scrollToLast = 1
            self?.collectionView.reloadData()
            self?.needSaveMessages = true
        }
        
        if let item = item {  // 处理智能体消息
            item.message = message
            
            // 当前智能体消息被打断或者失败，且消息为空，需要从列表中移除
            if (item.message.messageState == .Interrupted || item.message.messageState == .Failed)
                && item.contentOriginText.isEmpty && item.message.reasoningText?.isEmpty != false {
                self.listMessage.removeAll { remove in
                    return remove == item
                }
            }
            
            if message.reasoningText != nil && message.isReasoningEnd == false {
                // 子线程计算深度思考占位大小
                item.updateAgentReasonInfo(computeQueue: self.agentComputeQueue, maxWidth: self.getAgentCellMaxWidth()) {
                    reloadBlock()
                }
            }
            else {
                // 子线程计算回复内容占位大小
                item.updateAgentContentInfo(computeQueue: self.agentComputeQueue, maxWidth: self.getAgentCellMaxWidth()) {
                    reloadBlock()
                }
            }
        }
        else {               // 处理新消息
            let item = AUIAIChatMessageItem(message: message)
            item.isLeft = isLeft
            item.updateContentInfoSync(maxWidth: self.getAgentCellMaxWidth())
            self.listMessage.append(item)
        }
        reloadBlock()
    }
    
    public func onAgentResponeStateChange(state: ARTCAIChatAgentResponseState, requestId: String?) {
        self.bottomView.isStopped = state != .Listening
        self.editingTextView.isStopped = state != .Listening
    }
    
    public func onMessagePlayStateChange(message: ARTCAIChatMessage, state: ARTCAIChatMessagePlayState) {
        self.refreshMessagePlayState()
        if state != .Init {
            DispatchQueue.main.async {
                self.setPlayMessageLoadingViewVisible(visible: false)
            }
        }
    }
    
    public func onReceivedCustomMessage(text: String) {
        // 在这里处理自定义消息
        AVToastView.show(String(format: AUIAICallBundle.getString("Received Custom Message: %@"), text) , view: self.view, position: .mid)
    }
}

extension AUIAIChatViewController {
    
    // 获取 Documents 目录的 URL
    static func getFileUrl(fileName: String, subDir: String? = nil) -> URL {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = url.appendingPathComponent("aichat")
        if let subDir = subDir {
            url = url.appendingPathComponent(subDir)
        }
        // 检查子目录是否存在，如果不存在则创建
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                print("Created directory at \(url)")
            } catch {
                print("Creating directory failed: \(error)")
            }
        }
        if fileName.isEmpty == false {
            url = url.appendingPathComponent(fileName)
        }
        return url
    }
    
    // 加载保存的消息
    static func loadMessage(fileName: String, senderId: String) -> [AUIAIChatMessageItem] {
        var ret = [AUIAIChatMessageItem]()
        let fileURL = self.getFileUrl(fileName: fileName)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return ret
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedArray = try JSONDecoder().decode([String].self, from: data)
            loadedArray.forEach { jsonString in
                if let item = AUIAIChatMessageItem.load(dict: jsonString.aicall_jsonObj(), senderId: senderId) {
                    if item.message.messageState == .Finished || item.message.messageState == .Interrupted {
                        ret.append(item)
                    }
                }
            }
            debugPrint("loadMessage to \(fileURL)")
            return ret
        } catch {
            debugPrint("loadMessage failed: \(error)")
            return ret
        }
    }
    
    // 保存最近的10条
    static func saveMessage(fileName: String, listMessage: [AUIAIChatMessageItem]) {
        var list: [String] = []
        if listMessage.isEmpty == false {
            for i in 0...(listMessage.count - 1) {
                let index = listMessage.count - 1 - i
                list.insert(listMessage[index].save().aicall_jsonString, at: 0)
                if list.count >= 10 {
                    break
                }
            }
        }
        
        do {
            let fileURL = self.getFileUrl(fileName: fileName)
            let jsonData = try JSONEncoder().encode(list)
            try jsonData.write(to: fileURL)
            debugPrint("saveMessage to \(fileURL)")
        } catch {
            debugPrint("saveMessage failed: \(error)")
        }
    }

    func doSaveMessage() {
        if self.needSaveMessages {
            AUIAIChatViewController.saveMessage(fileName: self.sessionId, listMessage: self.listMessage)
        }
        self.needSaveMessages = false
    }
    
    func doLoadMessage() {
        self.listMessage = AUIAIChatViewController.loadMessage(fileName: self.sessionId, senderId: self.engine.userInfo!.userId)
    }
}

#if AICALL_ENABLE_FEEDBACK
extension AUIAIChatViewController {
    func setupReportBtn() -> UIButton? {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitle(AUIAIChatBundle.getString("Report Issues"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.clickBlock = { [weak self] btn in
            self?.navigationController?.pushViewController(AUIAICallReportViewController(), animated: true)
        }
        self.headerView.addSubview(btn)
        btn.sizeToFit()
        btn.center = CGPoint(x: self.menuButton.av_left - 24 - btn.av_width / 2, y: self.menuButton.av_centerY)
        return btn
    }
}
#endif

#if DEMO_FOR_DEBUG
extension AUIAIChatViewController {
    
    func showDebugInfo() {
        
        let info = ARTCAICallEngineDebuger.Debug_ExtendInfo.aicall_jsonString
        AVAlertController.show(withTitle: "Debug", message: info, cancelTitle: "Close", okTitle: "Copy") { isCancel in
            if !isCancel {
                UIPasteboard.general.string = info
            }
        }
         
    }
}
#endif


extension AUIAIChatViewController {
        
    open func fetchAuthToken(userId: String, completed: ((_ authToken: ARTCAIChatAuthToken?, _ error: NSError?) -> Void)?) {
        
        if let agentShareConfig = self.agentShareConfig {
            self.engine.generateShareAgentChat(shareConfig: agentShareConfig, userId: userId) { agentInfo, token, error, reqId in
                completed?(token, error)
            }
            return
        }
        
        AUIAIChatAuthTokenHelper.shared.fetchAuthToken(userId: userId, agentId: self.engine.agentInfo?.agentId, region: self.engine.agentInfo?.region) { [weak self] authToken, error in
            if error?.code == 403 {
                self?.onUserTokenExpiredBlcok?()
                completed?(authToken, NSError.aicall_create(code: .TokenExpired))
                return
            }
            completed?(authToken, error)
        }
    }
}
