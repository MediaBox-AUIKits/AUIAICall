//
//  AUIAICallViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallViewController: UIViewController {
    
    public init(_ controller: AUIAICallControllerInterface) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.start()
#endif
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit: \(self)")
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.finish()
#endif
    }
    
    // 延迟记录
    private var latencyData: [(id: Int32, latency: Int64)] = []
    private weak var latencyVC: AUIAICallLatencyRateViewController? = nil

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AVTheme.bg_medium
        
        self.callContentView.frame = self.view.bounds
        self.callContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContentViewClicked(recognizer:))))

        self.gradientlayer.frame = CGRect(x: 0, y: 0, width: self.view.av_width, height: UIView.av_safeTop + 44)
        
#if AICALL_ENABLE_FEEDBACK
        self.reportBtn = self.setupReportBtn()
#endif
        
        self.settingBtn.frame = CGRect(x: self.view.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44)
        
        self.subtitleBtn.sizeToFit()
        self.subtitleBtn.center = CGPoint(x: self.settingBtn.av_left - self.subtitleBtn.av_width / 2.0  - 4, y: self.settingBtn.av_centerY)
        self.subtitleListView.frame = self.view.bounds
        
        self.titleLabel.sizeToFit()
        self.titleLabel.center = CGPoint(x: self.view.av_width / 2.0, y: self.settingBtn.av_centerY)
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.av_height - 308, width: self.view.av_width, height: 308)
        self.bottomView.isHidden = false
        self.bottomView.enablePushToTalk = self.controller.config.agentConfig.enablePushToTalk
                
        UIViewController.av_setIdleTimerDisabled(true)
        
        if self.controller.config.agentType == .AvatarAgent {
            let agentViewConfig = ARTCAICallViewConfig(view: self.callContentView.agentView!.renderView)
            self.controller.setAgentViewConfig(viewConfig: agentViewConfig)
        }
        else if self.controller.config.agentType == .VisionAgent {
            let localViewConfig = ARTCAICallViewConfig(view: self.callContentView.cameraView!.renderView)
            self.controller.currentEngine.setLocalViewConfig(viewConfig: localViewConfig)
        }
        else if self.controller.config.agentType == .VideoAgent {
            let localViewConfig = ARTCAICallViewConfig(view: self.callContentView.cameraView!.renderView)
            self.controller.currentEngine.setLocalViewConfig(viewConfig: localViewConfig)
            
            let agentViewConfig = ARTCAICallViewConfig(view: self.callContentView.agentView!.renderView)
            self.controller.setAgentViewConfig(viewConfig: agentViewConfig)
        }
        
        self.controller.delegate = self
        self.controller.start()
        
        self.callContentView.agentAni.updateState(newState: self.controller.state)
    }
    
    public var onUserTokenExpiredBlcok: (()->Void)? = nil
    
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
    
    public let controller: AUIAICallControllerInterface
    public var enableVoiceprintSwitch: Bool = true
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.mediumFont(16)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitleLabelTap)))
        label.isUserInteractionEnabled = true
        
        var title = AUIAICallBundle.getString("AI Voice Call")
        if self.controller.config.agentType == .AvatarAgent {
            title = AUIAICallBundle.getString("AI Avatar Call")
        }
        else if self.controller.config.agentType == .VisionAgent {
            title = AUIAICallBundle.getString("AI Vision Call")
        }
        else if self.controller.config.agentType == .VideoAgent {
            title = AUIAICallBundle.getString("AI Video Call")
        }
        label.text = title
        
        self.view.addSubview(label)
        return label
    }()
    
    open lazy var callContentView: AUIAICallContentView = {
        let view = AUIAICallContentView(frame: CGRect.zero, agentType: self.controller.config.agentType)
        self.view.addSubview(view)
        return view
    }()
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        self.view.layer.addSublayer(layer)
        return layer
    }()
    
    open lazy var settingBtn: UIButton = {
        let btn = UIButton()
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_setting"), for: .normal)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_setting_selected"), for: .selected)
        btn.addTarget(self, action: #selector(onSettingBtnClicked), for: .touchUpInside)
        self.view.addSubview(btn)
        return btn
    }()
    
    open lazy var subtitleBtn: UIButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Subtitles"), for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setBackgroundColor(AVTheme.fill_medium, for: .normal)
        btn.setBackgroundColor(AVTheme.fill_infrared, for: .selected)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_infrared, for: .selected)
        btn.addTarget(self, action: #selector(onSubtitleBtnClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        self.view.addSubview(btn)
        return btn
    }()
    
    open lazy var subtitleListView: AUIAICallSubtitleListView = {
        let view = AUIAICallSubtitleListView(frame: self.view.bounds)
        view.contentInset = UIEdgeInsets(top: UIView.av_safeTop + 65, left: 0, bottom: UIView.av_safeBottom + 221, right: 0)
        return view
    }()
    
    open var reportBtn: UIButton? = nil
    private weak var settingPanel: AUIAICallSettingPanel? = nil
    
    open lazy var bottomView: AUIAICallBottomView = {
        let view = AUIAICallBottomView(agentType: self.controller.config.agentType)
        view.switchSpeakerBtn.isSelected = self.controller.config.enableSpeaker == false
        view.muteAudioBtn.isSelected = self.controller.config.muteMicrophone == true
        view.muteCameraBtn.isSelected = self.controller.config.muteLocalCamera == true
        view.handupBtn.tappedAction = { [weak self] btn in
            self?.controller.handup()
        }
        view.switchSpeakerBtn.tappedAction = { [weak self] btn in
            if self?.controller.state != .Connected {
                btn.isSelected = !btn.isSelected
                self?.controller.config.enableSpeaker = !btn.isSelected
                return
            }
            self?.controller.enableSpeaker(enable: btn.isSelected)
            btn.isSelected = self?.controller.config.enableSpeaker == false
        }
        view.muteAudioBtn.tappedAction = { [weak self] btn in
            self?.controller.muteMicrophone(mute: !btn.isSelected)
            btn.isSelected = self?.controller.config.muteMicrophone == true
        }
        view.muteCameraBtn.tappedAction = { [weak self] btn in
            self?.controller.muteLocalCamera(mute: !btn.isSelected)
            btn.isSelected = self?.controller.config.muteLocalCamera == true
            self?.callContentView.cameraView?.isMute = btn.isSelected
        }
        view.switchCameraBtn.clickBlock = { [weak self] btn in
            self?.controller.switchCamera()
        }
        view.pushToTalkBtn.longPressAction = { [weak self] btn, state, elapsed in
            if state == 1 {
                if elapsed <= 0.5 {
                    _ = self?.controller.cancelPushToTalk()
                    AVToastView.show(AUIAICallBundle.getString("The hold time is too short, sending has been canceled."), view: self!.view, position: .mid)
                }
                else {
                    _ = self?.controller.finishPushToTalk()
                }
                btn.isSelected = false
                debugPrint("ptt: finish elapsed \(elapsed)")
            }
            else if state == 2 {
                _ = self?.controller.cancelPushToTalk()
                AVToastView.show(AUIAICallBundle.getString("You have canceled to send you talk."), view: self!.view, position: .mid)
                btn.isSelected = false
                debugPrint("ptt: cancel elapsed: \(elapsed)")
            }
            else {
                _ = self?.controller.startPushToTalk()
                btn.isSelected = true
                debugPrint("ptt: start elapsed: \(elapsed)")
            }
        }
        self.view.addSubview(view)
        return view
    }()
    
    // 当前通话时间（单位：秒）
    public private(set) var callingSeconds = 0.0
    private lazy var countdownTimer: Timer = {
        let timer = Timer(timeInterval: 0.10, repeats: true) {[weak self] timer in
            if let self = self {
                self.callingSeconds = self.callingSeconds + 0.10
                let time = AVStringFormat.format(withDuration: Float(self.callingSeconds))
                self.bottomView.timeLabel.text = time
                
                self.printingAgentText()
                
                self.checkCallLimit()
            }
        }
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }()
    
    private var lastAgentSentenceId: Int? = nil
    private var currAgentSpeakingTokens: [String] = []
    private var nextAgentSpeakingTokenIndex: Int = 0
    
    private func printingAgentText(all: Bool = false) {
        if self.currAgentSpeakingTokens.count > self.nextAgentSpeakingTokenIndex {
            let toIndex = all ? self.currAgentSpeakingTokens.count - 1 : self.nextAgentSpeakingTokenIndex
            var currAgentPrintedText = ""
            for i in 0...toIndex {
                currAgentPrintedText.append(self.currAgentSpeakingTokens[i])
            }
            self.subtitleListView.updateSubtitle(sentenceId: self.lastAgentSentenceId ?? 0, isAgent: true, subtitle: currAgentPrintedText)
            self.nextAgentSpeakingTokenIndex = all ? self.currAgentSpeakingTokens.count : self.nextAgentSpeakingTokenIndex + 1
        }
    }
    
    private func checkCallLimit() {
        let limitSecond = self.controller.config.limitSecond
        if limitSecond == 0 {
            return
        }
        
        if Double(limitSecond) <= self.callingSeconds {
            self.controller.currentEngine.handup(true)
            self.countdownTimer.invalidate()
            AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("The call has ended. The agent can only be experienced for 5 minutes."), needCancel: false) { isCancel in
                self.controller.handup()
            }
        }
    }
    
    private var voiceprintTipsLabel: AUIVoiceprintTipsView? = nil
    private func showVoiceprintTips() {
        if self.voiceprintTipsLabel == nil {
            let voiceprintTipsLabel = AUIVoiceprintTipsView()
            voiceprintTipsLabel.clearBtn.clickBlock = { [weak self] btn in
                guard let self = self else { return }
                if self.controller.clearVoiceprint() == true {
                    self.voiceprintTipsLabel?.hideTips()
                }
                else {
                    AVToastView.show(AUIAICallBundle.getString("Failed to clear voiceprint's data"), view: self.view, position: .mid)
                }
            }
            voiceprintTipsLabel.isSelected = true
            voiceprintTipsLabel.layoutAt(frame: CGRect(x: 0, y: self.callContentView.tipsLabel.av_top - 40 - 10, width: self.view.av_width, height: 40))
            self.view.addSubview(voiceprintTipsLabel)
            self.voiceprintTipsLabel = voiceprintTipsLabel
        }
        self.voiceprintTipsLabel?.showTips()
    }
}

extension AUIAICallViewController {
    
    @objc open func onSubtitleBtnClicked() {
        self.subtitleBtn.isSelected = !self.subtitleBtn.isSelected
        if self.subtitleBtn.isSelected {
            self.view.insertSubview(self.subtitleListView, belowSubview: self.subtitleBtn)
        }
        else {
            self.subtitleListView.removeFromSuperview()
        }
    }
    
    @objc open func onSettingBtnClicked() {
        if self.controller.state != .Connected {
            AVToastView.show(AUIAICallBundle.getString("Currently not connected"), view: self.view, position: .mid)
            return
        }
        let panel = AUIAICallSettingPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
        panel.voiceIdList = self.controller.agentVoiceIdList
        panel.enableVoiceprintSwitch = self.enableVoiceprintSwitch
        panel.config = self.controller.config
        panel.isVoiceprintRegisted = self.controller.isVoiceprintRegisted
        panel.applyPlayBlock = { [weak self] item in
            self?.controller.switchVoiceId(voiceId: item.voiceId, completed: { error in
                
            })
        }
        panel.interruptBlock = { [weak self, weak panel] isOn in
            self?.controller.enableVoiceInterrupt(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.interruptSwitch.switchBtn.isOn = self.controller.config.agentConfig.interruptConfig.enableVoiceInterrupt
                        AVToastView.show(AUIAICallBundle.getString("Failed to switch smart interruption"), view: self.view, position: .mid)
                        return
                    }
                    
                    if self.controller.config.agentConfig.interruptConfig.enableVoiceInterrupt {
                        AVToastView.show(AUIAICallBundle.getString("Smart interruption is turned on"), view: self.view, position: .mid)
                    }
                    else {
                        AVToastView.show(AUIAICallBundle.getString("Smart interruption is turned off"), view: self.view, position: .mid)
                    }
                }
            })
        }
        panel.pushToTalkBlock = { [weak self] isOn in
            self?.controller.enablePushToTalk(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        AVToastView.show(AUIAICallBundle.getString("Failed to enable/disable push to talk Mode"), view: self.view, position: .mid)
                        return
                    }
                }
            })
        }
        panel.voiceprintBlock = { [weak self, weak panel] isOn in
            self?.controller.useVoiceprint(isUse: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.voiceprintSettingView.voiceprintSwitch.switchBtn.isOn = self.controller.config.agentConfig.voiceprintConfig.useVoiceprint
                        AVToastView.show(AUIAICallBundle.getString("Failed to switch voiceprint"), view: self.view, position: .mid)
                        return
                    }
                    
                    if self.controller.config.agentConfig.voiceprintConfig.useVoiceprint {
                        AVToastView.show(AUIAICallBundle.getString("Voiceprint is turned on"), view: self.view, position: .mid)
                    }
                    else {
                        AVToastView.show(AUIAICallBundle.getString("Voiceprint is turned off"), view: self.view, position: .mid)
                    }
                }
            })
        }
        panel.clearVoiceprintBlock = { [weak self] sender in
            if let self = self {
                if self.controller.clearVoiceprint() == true {
                    sender.isVoiceprintRegisted = self.controller.isVoiceprintRegisted
                }
                else {
                    AVToastView.show(AUIAICallBundle.getString("Failed to clear voiceprint's data"), view: self.view, position: .mid)
                }
            }
        }
        // 暂时只有非数字人有延迟数据
        if self.controller.config.agentType != .VoiceAgent, self.controller.config.agentType != .VisionAgent {
            panel.hiddenLatencyView(true)
        }
        // 设置延迟率查看逻辑
        panel.onLatencyRateViewTapped = { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.latencyVC == nil {
                let newLatencyVC = AUIAICallLatencyRateViewController()
                newLatencyVC.latencyData = self.latencyData // 更新延迟率数据
                self.av_presentFullScreenViewController(newLatencyVC, animated: true)
                self.latencyVC = newLatencyVC
            }
        }
        
        panel.show(on: self.view, with: .clickToClose)
        self.settingPanel = panel
    }

    @objc open func onContentViewClicked(recognizer: UIGestureRecognizer) {
        self.controller.interruptSpeaking()
    }
    
    @objc func onTitleLabelTap() {
#if DEMO_FOR_DEBUG
        self.showAgentDebugInfo()
#endif
    }
    
}

extension AUIAICallViewController: AUIAICallControllerDelegate {
    
    public func onAICallRTCEngineCreated() {
#if DEMO_FOR_RTC
        self.registerAudioFrameData()
#endif
    }
    
    public func onAICallAIAgentStarted(agentInfo: ARTCAICallAgentInfo, elapsedTime: TimeInterval) {
        ARTCAICallEngineLog.WriteLog(.Info, "Agent Start Elapse Time: \(elapsedTime)")
    }
    
    public func onAICallBegin(elapsedTime: TimeInterval) {
        ARTCAICallEngineLog.WriteLog(.Info, "Call Begin Elapse Time: \(elapsedTime)")
#if DEMO_FOR_DEBUG
        self.printDebugInfo(AUIAICallBundle.getString("Connected Time: \(elapsedTime)s"))
#endif
        
    }
    
    public func onAICallStateChanged() {
        ARTCAICallEngineLog.WriteLog(.Debug, "Call State Changed: \(self.controller.state)")
        self.callContentView.agentAni.updateState(newState: self.controller.state)
        
        if self.controller.state == .Connected {
            self.callContentView.agentView?.isHidden = false
            self.callContentView.cameraView?.isHidden = false
            self.callContentView.cameraView?.isMute = self.controller.config.muteLocalCamera
            
            // 启动计时
            self.countdownTimer.fire()
        }
        else if self.controller.state == .Over {
            self.countdownTimer.invalidate()
        }
        
        // 更新提示语
        if self.controller.state == .None {
            self.callContentView.tipsLabel.text = nil
        }
        else if self.controller.state == .Connecting {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Connecting...")
        }
        else if self.controller.state == .Connected {
            self.onAICallAgentStateChanged()
        }
        else if self.controller.state == .Over {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Call Ended")
        }
        else if self.controller.state == .Error {
            ARTCAICallEngineLog.WriteLog(.Error, "Call Error: \(self.controller.errorCode)")
            var msg = AUIAICallBundle.getString("An Error Occurred During the Call")
            switch self.controller.errorCode {
            case .BeginCallFailed:
                msg = AUIAICallBundle.getString("Cannot Start Call, Service Issue Detected")
                break
            case .TokenExpired:
                msg = AUIAICallBundle.getString("Call Failed, Authorization Expired")
                break
            case .ConnectionFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .PublishFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .SubscribeFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .KickedByUserReplace:
                msg = AUIAICallBundle.getString("Call Failed, User May Be Logined Another Device")
                break
            case .KickedBySystem:
                msg = AUIAICallBundle.getString("Call Failed, Ended by System")
                break
            case .KickedByChannelTerminated:
                msg = AUIAICallBundle.getString("Call Failed, Ended by System")
                break
            case .LocalDeviceException:
                msg = AUIAICallBundle.getString("Call Failed, Local Device Error")
                break
            case .AgentLeaveChannel:
                msg = AUIAICallBundle.getString("Call Failed, Agent Stopped")
                break
            case .AgentPullFailed:
                msg = AUIAICallBundle.getString("Call Failed, Agent Failed to Pull Stream")
                break
            case .AgentASRFailed:
                msg = AUIAICallBundle.getString("Call Failed, The Third Party Service of ASR Failed to Start")
                break
            case .AvatarServiceFailed:
                msg = AUIAICallBundle.getString("Call Failed, Avatar Agent Service Failed to Start")
                break
            case .AvatarRoutesExhausted:
                msg = AUIAICallBundle.getString("Call Ended")
                break
            case .AgentSubscriptionRequired:
                msg = AUIAICallBundle.getString("Call Failed, Subscription Required")
                break
            case .AgentNotFound:
                msg = AUIAICallBundle.getString("Call Failed, Agent Not Found")
                break
            case .UnknowError:
                msg = AUIAICallBundle.getString("Call Failed, Unknow Error")
                break
            default:
                break
            }
            self.callContentView.tipsLabel.text = msg
            self.countdownTimer.invalidate()
            
            if self.controller.errorCode == .AvatarRoutesExhausted {
                AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("AI avatar calling is in high demand, please try again later or enjoy the new experience of AI voice calling first."), needCancel: false) { isCancel in
                    self.controller.handup()
                    
                }
            }
        }
        
        // 挂断处理
        if self.controller.state == .Over {
            #if AICALL_ENABLE_FEEDBACK
            self.showFeedback()
            #else
            self.dismiss(animated: true)
            #endif
        }
    }
    
    public func onAICallAgentStateChanged() {
        if self.controller.agentState == .Listening {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("You Talk, I'm Listening...")
        }
        else if self.controller.agentState == .Thinking {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Thinking...")
        }
        else if self.controller.agentState == .Speaking {
            if self.controller.config.agentConfig.interruptConfig.enableVoiceInterrupt && !self.controller.config.agentConfig.enablePushToTalk {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen or Speak to Interrupt Me")
            }
            else {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen to Interrupt Me")
            }
        }
        
        self.callContentView.agentAni.updateAgentAnimator(state: self.controller.agentState)
    }
    
    public func onAICallActiveSpeakerVolumeChanged(userId: String, volume: Int32) {
        
    }
    
    public func onAICallAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        var tokens: [String] = []
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text
        tagger.enumerateTags(in: NSRange(location: 0, length: text.utf16.count), scheme: .tokenType, options: []) { tag, tokenRange, _, _  in
            let word = (text as NSString).substring(with: tokenRange)
            tokens.append(word)
        }
        if userAsrSentenceId != self.lastAgentSentenceId {
            self.printingAgentText(all: true)
            self.lastAgentSentenceId = userAsrSentenceId
            self.nextAgentSpeakingTokenIndex = 0
            self.currAgentSpeakingTokens.removeAll()
        }
        self.currAgentSpeakingTokens.append(contentsOf: tokens)
    }
    
    public func onAICallUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult) {
#if DEMO_FOR_DEBUG
        let text = self.getUserSubtitle(text: text, voiceprintResult: voiceprintResult)
#endif
        
        if voiceprintResult == .UndetectedSpeaker || voiceprintResult == .UndetectedSpeakerWithAIVad {
            self.subtitleListView.removeSubtitle(sentenceId: sentenceId, isAgent: false)
        }
        else {
            self.subtitleListView.updateSubtitle(sentenceId: sentenceId, isAgent: false, subtitle: text)
        }
        
        if isSentenceEnd {
            if voiceprintResult == .UndetectedSpeaker {
                self.showVoiceprintTips()
            }
            else if (voiceprintResult == .UndetectedSpeakerWithAIVad) {
#if DEMO_FOR_DEBUG
                self.printDebugInfo(AUIAICallBundle.getString("VAD detected other speaking, stop responded this question."))
#endif
            }
        }
    }
    
    public func onAICallUserTokenExpired() {
        AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("Log in token expired, please try log in."), needCancel: false) { isCancel in
            self.controller.handup()
            self.onUserTokenExpiredBlcok?()
        }
    }
    
    public func onAICallAvatarFirstFrameDrawn() {
        
    }
    
    public func onAICallAgentPushToTalkChanged(enable: Bool) {
        self.settingPanel?.config = self.controller.config
        self.bottomView.enablePushToTalk = self.controller.config.agentConfig.enablePushToTalk
        if self.controller.config.agentConfig.enablePushToTalk {
            AVToastView.show(AUIAICallBundle.getString("Push to talk mode is turned on"), view: self.view, position: .mid)
        }
        else {
            AVToastView.show(AUIAICallBundle.getString("Push to talk mode is turned off"), view: self.view, position: .mid)
        }
    }
    
    public func onAICallAgentWillLeave(reason: Int32, message: String) {
        self.controller.handup()
        if let keyWindow = UIView.av_keyWindow {
            var toast = AUIAICallBundle.getString("The call has ended.")
            if reason == 2001 {
                toast = AUIAICallBundle.getString("Due to your prolonged inactivity, the call has ended.")
            }
            AVToastView.show(toast, view: keyWindow, position: .mid)
        }
    }
    
    public func onAICallHumanTakeoverWillStart(takeoverUid: String, takeoverMode: Int) {
        AVToastView.show(AUIAICallBundle.getString("The current call will soon be handled by a real person."), view: self.view, position: .mid)
    }
    
    public func onAICallHumanTakeoverConnected(takeoverUid: String) {
        AVToastView.show(AUIAICallBundle.getString("The current call is now being handled by a real person."), view: self.view, position: .mid)
    }
    
    public func onAICallAgentEmotionNotify(emotion: String, userAsrSentenceId: Int) {
        self.callContentView.agentAni.updateAgentAnimator(emotion: emotion)

#if DEMO_FOR_DEBUG
        self.printDebugInfo(String(format: AUIAICallBundle.getString("The agent seems to be %@"), emotion))
#endif
    }
    
    public func onAICallVisionCustomCapture(enable: Bool) {
        var text = AUIAICallBundle.getString("Exited custom frame capture inspection mode.")
        if enable {
            text = AUIAICallBundle.getString("Custom frame capture inspection mode has been enabled.")
        }
        AVToastView.show(text, view: self.view, position: .mid)
    }
    
    public func onAICallSpeakingInterrupted(reason: ARTCAICallSpeakingInterruptedReason) {
#if DEMO_FOR_DEBUG
        self.printDebugInfo(AUIAICallBundle.getString("Speaking interrupted") + ": \(reason.rawValue)")
#endif
        self.callContentView.agentAni.onAgentInterrupted()
    }
    
    public func onAICallReceivedAgentVcrResult(result: ARTCAICallAgentVcrResult) {
#if DEMO_FOR_DEBUG
        if let resultData = result.resultData {
            AVToastView.show("VCR Result: \(resultData.aicall_jsonString)", view: self.view, position: .mid)
        }
#endif
    }
    
    public func onAudioDelayInfo(sentenceId: Int32, delayMs: Int64) {
        latencyData.insert((sentenceId, Int64(delayMs)), at: 0)
        self.latencyVC?.updateLatencyData(newData: latencyData)
    }
}

#if AICALL_ENABLE_FEEDBACK
extension AUIAICallViewController {
    
    func showFeedback() {
        if self.controller.errorCode == .AvatarRoutesExhausted ||
            self.controller.errorCode == .BeginCallFailed ||
            self.controller.errorCode == .TokenExpired{
            self.dismiss(animated: true)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
                self.dismiss(animated: true) {
                    AUIAICallFeedback.shared.tryToShowFeedback(controller: self.controller, vc: UIViewController.av_top())
                }
            }
        }
    }
    
    func setupReportBtn() -> UIButton {
        let btn = AVBlockButton()
        /*
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_report"), for: .normal)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_report_select"), for: .selected)
         */
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitle(AUIAICallBundle.getString("Report Issues"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        //btn.setTitleColor(UIColor.av_color(withHexString: "#3A3D48FF"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            self?.av_presentFullScreenViewController(AUIAICallReportViewController(), animated: true)
        }
        self.view.addSubview(btn)
        btn.sizeToFit()
        btn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: btn.av_width, height: 44)
        return btn
    }
}
#endif

#if DEMO_FOR_DEBUG
extension AUIAICallViewController {
    
    func showAgentDebugInfo() {
        AUIAICallDebugManager.shared.showAgentDebugInfo(vc: self, controller: self.controller)
    }
    
    func getUserSubtitle(text: String, voiceprintResult: ARTCAICallVoiceprintResult) -> String {
        if AUIAICallDebugManager.shared.enableDebugInfo == false {
            return text
        }
        
        if (self.controller.config.agentConfig.voiceprintConfig.voiceprintId != nil && self.controller.config.agentConfig.voiceprintConfig.useVoiceprint) || self.controller.config.agentConfig.asrConfig.vadLevel > 0 {
            return "[\(voiceprintResult.rawValue)]\(text)"
        }
        return text
    }
    
    func printDebugInfo(_ text: String) {
        if AUIAICallDebugManager.shared.enableDebugInfo {
            AVToastView.show(text, view: self.view, position: .mid)
        }
    }
}
#endif


#if DEMO_FOR_RTC

#if canImport(AliVCSDK_ARTC)
import AliVCSDK_ARTC
#elseif canImport(AliVCSDK_InteractiveLive)
import AliVCSDK_InteractiveLive
#elseif canImport(AliVCSDK_Standard)
import AliVCSDK_Standard
#endif
extension AUIAICallViewController: AliRtcAudioFrameDelegate {
    
    static let enableAudioFrameObserver = false
    
    func registerAudioFrameData() {
        guard AUIAICallViewController.enableAudioFrameObserver else { return }
        
        let rtc = self.controller.currentEngine.getRTCInstance() as? AliRtcEngine
        // 添加音频帧数据回调
        rtc?.registerAudioFrameObserver(self)
        // 监听采集到的裸数据，监听对应的类型，则需要实现它的回调接口并返回true，例如onCapturedAudioFrame
        rtc?.enableAudioFrameObserver(true, audioSource: .playback, config: nil)
    }
    
    public func onCapturedAudioFrame(_ frame: AliRtcAudioFrame) -> Bool {
        // 这里处理返回的音频采集裸数据
        debugPrint("onCapturedAudioFrame")
        return true
    }
    
    public func onProcessCapturedAudioFrame(_ frame: AliRtcAudioFrame) -> Bool {
        return false
    }
    
    public func onPublishAudioFrame(_ frame: AliRtcAudioFrame) -> Bool {
        return false
    }
    
    public func onPlaybackAudioFrame(_ frame: AliRtcAudioFrame) -> Bool {
        debugPrint("onPlaybackAudioFrame")
        return false
    }
    
    public func onMixedAllAudioFrame(_ frame: AliRtcAudioFrame) -> Bool {
        return false
    }
    
    public func onRemoteUserAudioFrame(_ uid: String?, frame: AliRtcAudioFrame) -> Bool {
        debugPrint("onRemoteUserAudioFrame")
        return false
    }
    
}
#endif
