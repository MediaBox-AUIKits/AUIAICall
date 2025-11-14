//
//  AUIAICallContentView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

let AUIAICallContentBottomViewHeight: CGFloat = 214.0
let AUIAICallContentTopViewHeight: CGFloat = 56.0

@objcMembers open class AUIAICallContentView: UIView {

    public init(frame: CGRect, agentType: ARTCAICallAgentType) {
        self.agentType = agentType
        super.init(frame: frame)
                
        self.addSubview(self.volumeAnimator)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.agentAni)

        self.setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let hei = self.av_bottom - 228 - 18
        self.agentAni.frame = CGRect(x: 0, y: UIView.av_safeTop + 44, width: self.av_width, height: hei - UIView.av_safeTop - 44)
        
        self.updateAgentLayout()
    }
    
    open lazy var volumeAnimator: AUIAICallVolumeBarAnimator = {
        var params = AUIAICallVolumeBarAnimator.Params()
        params.count = 7
        params.margin = 2
        params.width = 5
        params.minHeight = 5
        params.cornerRadius = 0
        params.barColor = AUIAICallBundle.color_fill
        let animator = AUIAICallVolumeBarAnimator(frame: CGRect(x: 0, y: 0, width: 200, height: 40), params: params)
        return animator
    }()
            
    open lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AUIAICallBundle.color_text
        label.textAlignment = .center
        label.font = AVTheme.regularFont(16)
        label.text = ""
        return label
    }()

    public let agentType: ARTCAICallAgentType!
    open lazy var agentAni: AUIAICallAgentAnimator = {
        let view = self.agentType == .VoiceAgent ? AUIAICallAgentAvatarAnimator() :  AUIAICallAgentSimpleAnimator()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    open private(set) var agentView: AUIAICallContentAgentView? = nil
    open private(set) var cameraView: AUIAICallContentCameraView? = nil
    
    private func setup() {
        if agentType == .VoiceAgent {
        }
        else if agentType == .AvatarAgent {
            let agentView = AUIAICallContentAgentView()
            agentView.layer.cornerRadius = 8
            agentView.clipsToBounds = true
            agentView.isHidden = true
            self.insertSubview(agentView, at: 0)
            self.agentView = agentView
        }
        else if agentType == .VisionAgent {
            let cameraView = AUIAICallContentCameraView()
            cameraView.layer.cornerRadius = 8
            cameraView.clipsToBounds = true
            cameraView.isHidden = true
            self.insertSubview(cameraView, at: 0)
            self.cameraView = cameraView
        }
        else if  agentType == .VideoAgent {
            let agentView = AUIAICallContentAgentView()
            agentView.layer.cornerRadius = 8
            agentView.clipsToBounds = true
            agentView.isHidden = true
            agentView.switchBtn.clickBlock = { [weak self] btn in
                self?.switchWindow()
            }
            self.insertSubview(agentView, at: 0)
            self.agentView = agentView
            
            let cameraView = AUIAICallContentCameraView()
            cameraView.layer.cornerRadius = 8
            cameraView.clipsToBounds = true
            cameraView.isHidden = true
            cameraView.switchBtn.clickBlock = { [weak self] btn in
                self?.switchWindow()
            }
            self.insertSubview(cameraView, aboveSubview: agentView)
            self.cameraView = cameraView
            self.cameraView?.isSmallWindow = true
            self.addGestureRecognizer(flowtView: self.cameraView!)
        }
    }
    
    var contentViewFrame: CGRect {
        get {
            let cx = 24.0
            let cy = UIView.av_safeTop + AUIAICallContentTopViewHeight
            let cw = self.av_width - 48
            let ch = self.av_height - UIView.av_safeBottom - AUIAICallContentBottomViewHeight - cy
            let crect = CGRect(x: cx, y: cy, width: cw, height: ch)
            return crect
        }
    }
    
    private func updateAgentLayout() {
        let y = self.contentViewFrame.maxY + 36
        self.tipsLabel.frame = CGRect(x: 0, y: y, width: self.av_width, height: 24)

        self.volumeAnimator.center = CGPoint(x: self.av_width / 2, y: y - 12)
        
        if agentType == .VoiceAgent {
        }
        else if agentType == .AvatarAgent {
            self.agentView?.frame = self.contentViewFrame
        }
        else if agentType == .VisionAgent {
            self.cameraView?.frame = self.contentViewFrame
        }
        else if agentType == .VideoAgent {
            self.updateVideoAgentLayout()
        }
    }
    
    private func switchWindow() {
        if self.agentView?.isSmallWindow == true {
            if CGRectIsEmpty(self.smallWindowFrame) == false {
                self.smallWindowFrame = self.agentView!.frame
            }
            self.removeGestureRecognizer(flowtView: self.agentView!)
            self.agentView?.isSmallWindow = false
            self.cameraView?.isSmallWindow = true
            self.insertSubview(self.cameraView!, aboveSubview: self.agentView!)
            self.addGestureRecognizer(flowtView: self.cameraView!)
        }
        else if self.cameraView?.isSmallWindow == true {
            if CGRectIsEmpty(self.smallWindowFrame) == false {
                self.smallWindowFrame = self.cameraView!.frame
            }
            self.removeGestureRecognizer(flowtView: self.cameraView!)
            self.agentView?.isSmallWindow = true
            self.cameraView?.isSmallWindow = false
            self.insertSubview(self.agentView!, aboveSubview: self.cameraView!)
            self.addGestureRecognizer(flowtView: self.agentView!)
        }
        self.setNeedsLayout()
    }
    
    private func updateVideoAgentLayout() {
        let size = CGSize(width: 105, height: 140.0)
        let contentViewFrame = self.contentViewFrame
        let defauleFrame = CGRect(x: contentViewFrame.maxX - size.width - 16, y: contentViewFrame.maxY - size.height - 16, width: size.width, height: size.height)
        if CGRectIsEmpty(self.smallWindowFrame) {
            self.smallWindowFrame = defauleFrame
        }
        
        if self.agentView?.isSmallWindow == true {
            self.cameraView?.frame = self.contentViewFrame
            self.agentView?.frame = self.smallWindowFrame
        }
        else if self.cameraView?.isSmallWindow == true {
            self.agentView?.frame = self.contentViewFrame
            self.cameraView?.frame = self.smallWindowFrame
        }
    }
    
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer? = nil
    private lazy var tapGestureRecognizer: UITapGestureRecognizer? = nil
    private lazy var smallWindowFrame: CGRect = CGRect.zero

    func removeGestureRecognizer(flowtView: UIView) {
        if let panGestureRecognizer = self.panGestureRecognizer {
            flowtView.removeGestureRecognizer(panGestureRecognizer)
        }
        if let tapGestureRecognizer = self.tapGestureRecognizer {
            flowtView.removeGestureRecognizer(tapGestureRecognizer)
        }
        self.panGestureRecognizer = nil
        self.tapGestureRecognizer = nil
    }
    
    func addGestureRecognizer(flowtView: UIView) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.panGestureRecognizer!.addTarget(self, action: #selector(panGesture(recognizer:)))
        flowtView.addGestureRecognizer(self.panGestureRecognizer!)
        
        self.tapGestureRecognizer = UITapGestureRecognizer()
        self.tapGestureRecognizer!.addTarget(self, action: #selector(tapGesture(recognizer:)))
        flowtView.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        let point: CGPoint = recognizer.translation(in: view)
        /*
        let center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        view.center = center
        recognizer.setTranslation(CGPoint.zero, in: view)
        
        // 拖拽停止/取消/失败
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            self.updateViewPosition(view: view)
        }
         */
        // 仅限智能体渲染区域内移动
        self.updateViewPosition(view: view, translation: point)
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func tapGesture(recognizer: UITapGestureRecognizer) {
        self.switchWindow()
    }
    
    
    // 更新位置
    open func updateViewPosition(view: UIView, translation: CGPoint) {
        let rect = self.contentViewFrame
        var frame = view.frame.offsetBy(dx: translation.x, dy: translation.y)
        if frame.minX < rect.minX {
            frame.origin.x = rect.minX
        }
        
        if frame.minY < rect.minY {
            frame.origin.y = rect.minY
        }
        
        if frame.maxX >= rect.maxX {
            frame.origin.x = rect.maxX - view.av_width
        }
        
        if frame.maxY >= rect.maxY {
            frame.origin.y = rect.maxY - view.av_height
        }

        view.frame = frame
    }
    
    // 更新位置
    open func updateViewPosition(view: UIView) {
        
        let rect = UIScreen.main.bounds
        var frame = view.frame
        if frame.minX < 16 {
            frame.origin.x = 16
        }
        
        if frame.minY < UIView.av_safeTop {
            frame.origin.y = UIView.av_safeTop
        }
        
        if frame.maxX >= rect.maxX - 16 {
            frame.origin.x = rect.maxX - 16 - view.av_width
        }
        
        if frame.maxY >= rect.maxY - UIView.av_safeBottom {
            frame.origin.y = rect.maxY - UIView.av_safeBottom - view.av_height
        }
        
        UIView.animate(withDuration: 0.3) {
            view.frame = frame
        } completion: { success in
            
        }
    }
}

@objcMembers open class AUIAICallContentCameraView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.addSubview(self.renderView)
        self.addSubview(self.muteView)
        self.addSubview(self.switchBtn)
        
        self.backgroundColor = AUIAICallBundle.color_bg_elevated
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.renderView.frame = self.bounds
        
        if self.isSmallWindow {
            self.muteView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            self.muteView.center = CGPoint(x: self.av_width / 2.0, y: (self.av_height - 30) / 2.0)
        }
        else {
            self.muteView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            self.muteView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height * 2.0 / 5.0)
        }
                
        self.switchBtn.center = CGPoint(x: self.av_width - self.switchBtn.av_width / 2 - 8, y: self.av_height - self.switchBtn.av_height / 2 - 8)
    }
    
    open private(set) var renderView: UIView = {
        let view = UIView()
        view.isHidden = false
        return view
    }()
    
    private var muteView: UIImageView = {
        let agentView = UIImageView()
        agentView.image = AUIAICallBundle.getImage("ic_camera_user")
        agentView.contentMode = .scaleAspectFit
        agentView.isHidden = true
        return agentView
    }()
    
    open var isMute = false {
        didSet {
            self.renderView.isHidden = self.isMute
            self.muteView.isHidden = !self.isMute
        }
    }
    
    open private(set) var switchBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.backgroundColor = AUIAICallBundle.color_fill_toast_identical
        btn.setImage(AUIAICallBundle.getTemplateImage("ic_video_switch"), for: .normal)
        btn.tintColor = AUIAICallBundle.color_icon_identical
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.av_size = CGSize(width: 28, height: 28)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 0.4
        btn.av_setLayerBorderColor(AUIAICallBundle.color_border_identical)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    open var isSmallWindow = false {
        didSet {
            self.switchBtn.isHidden = !self.isSmallWindow
            if self.isSmallWindow {
                self.layer.cornerRadius = 4
                self.layer.masksToBounds = true
            }
            else {
                self.layer.cornerRadius = 8
                self.layer.masksToBounds = true
            }
            self.setNeedsLayout()
        }
    }
}

@objcMembers open class AUIAICallContentAgentView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.addSubview(self.renderView)
        self.addSubview(self.switchBtn)
        
        self.backgroundColor = AUIAICallBundle.color_bg_elevated
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.renderView.frame = self.bounds
        
        self.switchBtn.center = CGPoint(x: self.av_width - self.switchBtn.av_width / 2 - 8, y: self.av_height - self.switchBtn.av_height / 2 - 8)
    }
    
    open private(set) var renderView: UIView = {
        let view = UIView()
        view.isHidden = false
        return view
    }()
    
    open private(set) var switchBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.backgroundColor = AUIAICallBundle.color_fill_toast_identical
        btn.setImage(AUIAICallBundle.getTemplateImage("ic_video_switch"), for: .normal)
        btn.tintColor = AUIAICallBundle.color_icon_identical
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.av_size = CGSize(width: 28, height: 28)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 0.4
        btn.av_setLayerBorderColor(AUIAICallBundle.color_border_identical)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    open var isSmallWindow = false {
        didSet {
            self.switchBtn.isHidden = !self.isSmallWindow
            if self.isSmallWindow {
                self.layer.cornerRadius = 4
                self.layer.masksToBounds = true
            }
            else {
                self.layer.cornerRadius = 8
                self.layer.masksToBounds = true
            }
        }
    }
}
