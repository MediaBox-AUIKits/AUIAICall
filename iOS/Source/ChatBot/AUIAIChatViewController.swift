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
        
        self.listMessage = AUIAIChatViewController.loadMessage(fileName: self.sessionId, senderId: userInfo.userId)
        self.engine.delegate = self
        self.engine.startChat(userInfo: userInfo, agentInfo: agentInfo, sessionId: self.sessionId)
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
        self.listMessage = AUIAIChatViewController.loadMessage(fileName: self.sessionId, senderId: userInfo.userId)
        self.engine.delegate = self
        self.engine.startChat(userInfo: userInfo, agentInfo: agentInfo, sessionId: self.sessionId)
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
        self.asyncScrollLastMessage(ani: false)
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
        view.onClickedStop = { [weak self] bottomView in
            guard let self = self else { return }
            self.engine.interruptAgentResponse()
            self.showToast(AUIAIChatBundle.getString("用户终止了本次回答"))
        }
        view.textView.onClickedInputText = { [weak self] textView in
            guard let self = self else { return }
            self.editingTextView.frame = CGRect(x: 20, y: self.view.av_height - 40 - 12, width: self.view.av_width - 40, height: 40)
            self.view.addSubview(self.editingTextView)
            self.editingTextView.inputTextView.becomeFirstResponder()
        }
        view.audioView.onTouchedRecordingArea = { [weak self] audioView in
            guard let self = self else { return }
            self.startRecordingAudio()
        }
        view.audioView.onTouchingRecordingAreaAndDrag = { [weak self] audioView, isExit in
            guard let self = self else { return }
            if !self.recordingAudioView.viewOnShow { return }
            if isExit {
                self.recordingAudioView.viewState = .CancelRecord
            } else {
                self.recordingAudioView.viewState = .Recording
            }
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
            self.sendTextMessage(text: text)
            self.bottomView.textView.updatePlaceholderText(text: nil)
        }
        view.onPositionYChangedBlock = { [weak self] value in
            guard let self = self else { return }
            if value != 0 {
                self.collectionView.av_height = self.bottomView.av_top + value + UIView.av_safeBottom
            }
            else {
                self.collectionView.av_height = self.bottomView.av_top
            }
            self.canAutoScroll = true
            self.asyncScrollLastMessage(ani: true)
        }
        view.onInputTextChangedBlock = { [weak self] text in
            self?.bottomView.textView.updatePlaceholderText(text: text?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        view.isStopped = self.engine.agentResponeState != .Listening
        return view
    }()
    
    open lazy var recordingAudioView: AUIAIChatRecordingAudioView = {
        let view = AUIAIChatRecordingAudioView()
        view.onTimeOutBlock = { [weak self] in
            self?.finishRecordingAudio(true, false)
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
    
    private func deleteMessage(item: AUIAIChatMessageItem) {
        AVAlertController.show(withTitle: AUIAIChatBundle.getString("Confirm delete message?"), message: AUIAIChatBundle.getString("Messages deleted cannot be recovered"), btn1: AUIAIChatBundle.getString("Delete"), btn1Destructive: true, btn2: AUIAIChatBundle.getString("Cancel"), btn2Destructive: false) { isCancel in
            if isCancel == false {
                self.engine.deleteMessage(dialogueId: item.message.dialogueId) { error in
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
            let pushEnabled = self.engine.startPushVoiceMessage(request: req)
            if pushEnabled {
                var recordingAudioViewHeight = 144.0
                if UIView.av_safeBottom > 0 {
                    recordingAudioViewHeight += UIView.av_safeBottom
                }
                self.recordingAudioView.frame = CGRect(x: 0, y: self.view.av_height - recordingAudioViewHeight, width: self.view.av_width, height: recordingAudioViewHeight)
                self.view.addSubview(self.recordingAudioView)
                self.recordingAudioView.updateRecordingTime(0)
                self.recordingAudioView.viewState = .Recording
                self.recordingAudioView.viewOnShow = true
                self.recordingAudioView.startTiming()
                self.bottomView.isHidden = true
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
        self.recordingAudioView.updateRecordingTime(0)
        self.recordingAudioView .removeFromSuperview()
        self.bottomView.isHidden = false
        self.recordingAudioView.viewOnShow = false
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
                    self.addMessageToList(item: item)
                }
            }
        } else {
            self.engine.cancelPushVoiceMessage()
        }
    }
    
    private func sendTextMessage(text: String) {
        let msg = ARTCAIChatMessage(sendText: text, requestId: "")
        let item = AUIAIChatMessageItem(message: msg)
        item.isLeft = false

        self.sendMessage(item: item)
        self.addMessageToList(item: item)
    }
    
    private func sendMessage(item: AUIAIChatMessageItem) {
        if item.isLeft == false, item.message.messageType == .Text {
            let req = ARTCAIChatSendMessageRequest(text: item.message.text)
            self.engine.sendMessage(request: req, completed: {[weak item, weak self] msg, error in
                guard let item = item else { return }
                if let msg = msg {
                    item.message = msg
                    self?.refreshMessageCellState(item: item)
                }
                if let _ = error {
                    self?.refreshMessageCellState(item: item)
                }
            })
            self.refreshMessageCellState(item: item)
        }
    }
    
    private func addMessageToList(item: AUIAIChatMessageItem) {
        
        self.listMessage.append(item)
        self.collectionView.reloadData()
        
        self.canAutoScroll = true
        self.asyncScrollLastMessage(ani: true)
        self.needSaveMessages = true
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
            if self.isDraging {
                return
            }
            let contentSize = self.collectionView.contentSize
            let contentInset = self.collectionView.contentInset
            let rect = CGRect(x: 0, y: contentSize.height - contentInset.bottom - 10, width: contentSize.width, height: 10)
            self.collectionView.scrollRectToVisible(rect, animated: ani)
        }
    }

    private var listMessage: [AUIAIChatMessageItem] = []

    private var canAutoScroll: Bool = false
    private var isDraging: Bool = false
    private var needSaveMessages: Bool = false
    
    public var onUserTokenExpiredBlcok: (()->Void)? = nil
    public let engine: ARTCAIChatEngineInterface
    public let sessionId: String
    private var currentVoiceId: String = ""
    
    private var appserver: AUIAICallAppServer = {
        let appserver = AUIAICallAppServer()
        return appserver
    }()
    private var agentShareConfig: ARTCAIChatAgentShareConfig? = nil
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
        var size = item.displaySize
        if size == nil {
            if item.isLeft {
                size = AUIAIChatMessageAgentTextCell.getAgentSize(item: item, maxWidth: self.collectionView.av_width - 40)
            }
            else {
                size = AUIAIChatMessageTextCell.getSize(item: item, maxWidth: self.collectionView.av_width - 72)
            }
            item.displaySize = size
        }
        return CGSize(width: self.collectionView.av_width - 40, height: size!.height)
    }
        
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.listMessage[indexPath.row]
        if item.message.messageType == .Text {
            var textCell: AUIAIChatMessageTextCell? = nil
            if item.isLeft == true {
                textCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AgentTextCell", for: indexPath) as? AUIAIChatMessageAgentTextCell
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
                    guard let self = self else { return }
                    UIPasteboard.general.string = item.message.text
                    self.showToast(AUIAIChatBundle.getString("Message copied"))
                }
                textCell.onLongPressBlock = { [weak self] item, view, location in
                    guard let self = self else { return }
                    if item.message.messageState == .Init || item.message.messageState == .Transfering || item.message.messageState == .Printing {
                        return
                    }
                    let locationInParentView = view.convert(location, to: self.view)
                    self.showMenuView(position: locationInParentView, item: item)
                }
                textCell.onPlayBlock = { [weak self, weak textCell] item in
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
        self.canAutoScroll = false
        self.isDraging = true
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isDraging {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY + frameHeight >= contentHeight - 0.0 {
            // debugPrint("已滑动到底部")
            self.canAutoScroll = true
        }
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        debugPrint("scrollViewDidEndDragging decelerate: \(decelerate)")
        self.isDraging = false
    }
    
    open override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        debugPrint("scrollViewWillBeginDecelerating")
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        debugPrint("scrollViewDidEndDecelerating")
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
        panel.voiceIdList = self.engine.voiceIdList
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
                msgList?.forEach({ msg in
                    let item = AUIAIChatMessageItem(message: msg)
                    item.isLeft = self.engine.userInfo?.userId != msg.senderId
                    self.listMessage.insert(item, at: 0)
                })
                self.collectionView.reloadData()
                if isEmpty {
                    self.asyncScrollLastMessage(ani: false)
                }
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
            return item.isLeft == false && item.message.requestId == message.requestId
        }
        if let item = item {
            debugPrint("onUserMessageUpdated:\(item.message.toData())")
            self.needSaveMessages = true
        }
    }
    
    public func onReceivedMessage(message: ARTCAIChatMessage) {
        let item = self.listMessage.last { item in
            return item.isLeft == true && item.message.requestId == message.requestId
        }
        
        if let item = item {
            item.message = message
            item.displaySize = nil
            
            if (item.message.messageState == .Interrupted || item.message.messageState == .Failed)
                && item.message.text.isEmpty {
                // 当前智能体消息被打断或者失败，且消息为空，需要从列表中移除
                self.listMessage.removeAll { remove in
                    return remove == item
                }
            }
        }
        else {
            let agentItem = AUIAIChatMessageItem(message: message)
            agentItem.isLeft = true
            self.listMessage.append(agentItem)
            self.canAutoScroll = true
        }
        self.collectionView.reloadData()
        if self.canAutoScroll {
            self.asyncScrollLastMessage(ani: true)
        }
        self.needSaveMessages = true
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
}

extension AUIAIChatViewController {
    
    // 获取 Documents 目录的 URL
    static func getFileUrl(fileName: String) -> URL {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = url.appendingPathComponent("aichat")
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
                var msg = ARTCAIChatMessage(data: jsonString.aicall_jsonObj())
                if msg.messageState == .Transfering || msg.messageState == .Init {
                    return
                }
                if msg.messageState == .Printing {
                    msg = ARTCAIChatMessage(dialogueId: msg.dialogueId,
                                            requestId: msg.requestId,
                                            state: .Interrupted,
                                            type: msg.messageType,
                                            sendTime: msg.sendTime,
                                            text: msg.text,
                                            senderId: msg.senderId,
                                            isEnd: msg.isEnd)
                }
                let item = AUIAIChatMessageItem(message: msg)
                item.isLeft = senderId != msg.senderId
                ret.append(item)
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
                list.insert(listMessage[index].message.toData().aicall_jsonString, at: 0)
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

    @objc func doSaveMessage() {
        if self.needSaveMessages {
            AUIAIChatViewController.saveMessage(fileName: self.sessionId, listMessage: self.listMessage)
        }
        self.needSaveMessages = false
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
        
    func fetchAuthToken(userId: String, completed: ((_ authToken: ARTCAIChatAuthToken?, _ error: NSError?) -> Void)?) {
        if AUIAIChatAuthTokenHelper.isDebug {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                completed?(AUIAIChatAuthTokenHelper.GenerateAuthToken(userId: userId), nil)
            }
        }
        else {
            self.generateMessageChatToken(userId: userId) { agentInfo, authToken, error, reqId in
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: reqId)
                completed?(authToken, error)
            }
        }
    }
    
    func generateMessageChatToken(userId: String, completed: ((_ agentInfo: ARTCAIChatAgentInfo?, _ authToken: ARTCAIChatAuthToken?, _ error: NSError?, _ reqId: String) -> Void)?) {
        
        if let agentShareConfig = self.agentShareConfig {
            self.engine.generateShareAgentChat(shareConfig: agentShareConfig, userId: userId) { agentInfo, token, error, reqId in
                completed?(agentInfo, token, error, reqId)
            }
            return
        }
        
        let expire: Int = 1 * 60 * 60
        var body: [String: Any] = [
            "user_id": userId,
            "expire": expire,
        ]
        if let agentId = self.engine.agentInfo?.agentId {
            body.updateValue(agentId, forKey: "ai_agent_id")
        }
        if let region = self.engine.agentInfo?.region {
            body.updateValue(region, forKey: "region")
        }
        
        self.appserver.request(path: "/api/v2/aiagent/generateMessageChatToken", body: body) { [weak self] response, data, error in
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            if error == nil {
                debugPrint("generateMessageChatToken response: success")
                let authToken = ARTCAIChatAuthToken(data: data as? [String: Any])
                let agentInfo = self?.engine.agentInfo
                completed?(agentInfo, authToken, nil, reqId)
            }
            else {
                debugPrint("generateMessageChatToken response: failed, error:\(error!)")
                completed?(nil, nil, self?.handlerCallError(error: error, data: data), reqId)
            }
        }
    }
    
    private func handlerCallError(error: NSError?, data: [AnyHashable: Any]?) -> NSError? {
        if error?.code == 403 {
            self.onUserTokenExpiredBlcok?()
            return NSError.aicall_create(code: .TokenExpired)
        }
        return NSError.aicall_handlerErrorData(data: data) ?? error
    }
}
