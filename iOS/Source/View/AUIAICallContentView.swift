//
//  AUIAICallContentView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallContentView: UIView {

    public init(frame: CGRect, agentType: ARTCAICallAgentType) {
        self.agentType = agentType
        super.init(frame: frame)
                
        self.addSubview(self.tipsLabel)
        self.addSubview(self.voiceprintTipsLabel)
        self.addSubview(self.agentAni)
        
        self.addSubview(self.subtitleIcon)
        self.addSubview(self.subtitleLabel)
        
        self.subtitleLabel.tappedAction = { [weak self] label in
            self?.openSubtileFullscreen()
        }
        
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
        
        self.subtitleIcon.frame = CGRect(x: 50, y: 121, width: 14, height: 14)
        self.subtitleLabel.frame = CGRect(x: self.subtitleIcon.av_right + 8, y: self.subtitleIcon.av_top - 3, width: self.av_width - self.subtitleIcon.av_right - 8 - 48, height: 0)
        self.subtitleLabel.text = self.subtitleLabel.originalText
    }
    
    open var subtileFullscreenView: AUISubtileFullscreenView? = nil
        
    open lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.regularFont(14)
        label.text = ""
        return label
    }()
    
    open lazy var subtitleLabel: AUISubtileReadMoreLabel = {
        let label = AUISubtileReadMoreLabel()
        label.textColor = AVTheme.text_weak
        label.textAlignment = .left
        label.font = AVTheme.regularFont(14)
        label.text = ""
        label.numberOfLines = 4
        label.isHidden = true
//        label.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        return label
    }()
    
    open lazy var subtitleIcon: UIButton = {
        let icon = UIButton()
        icon.setImage(AUIAICallBundle.getCommonImage("ic_sub_asr"), for: .normal)
        icon.setImage(AUIAICallBundle.getCommonImage("ic_sub_llm"), for: .selected)
        icon.isHidden = true
        icon.isUserInteractionEnabled = false
        return icon
    }()
    
    open lazy var voiceprintTipsLabel: AUIVoiceprintTipsView = {
        let label = AUIVoiceprintTipsView()
        return label
    }()

    public let agentType: ARTCAICallAgentType!
    open lazy var agentAni: AUIAICallAgentAnimator = {
        let view = self.agentType == .VoiceAgent ? AUIAICallAgentAvatarAnimator() :  AUIAICallAgentSimpleAnimator()
        return view
    }()
    
    open var avatarAgentView: UIView? = nil
    open var visionCameraView: UIView? = nil
    open var visionAgentView: UIView? = nil
    
    private func setup() {
        if agentType == .VoiceAgent {
            self.voiceprintTipsLabel.isSelected = false
        }
        else if agentType == .AvatarAgent {
            let view = UIView()
            // view.backgroundColor = UIColor.white
            view.isHidden = true
            self.insertSubview(view, at: 0)
            self.avatarAgentView = view
            self.voiceprintTipsLabel.isSelected = true
        }
        else if agentType == .VisionAgent {
            let cameraView = UIView()
            // view.backgroundColor = UIColor.white
            cameraView.isHidden = true
            self.insertSubview(cameraView, at: 0)
            self.visionCameraView = cameraView
            
            let agentView = UIImageView()
            agentView.image = AUIAICallBundle.getCommonImage("ic_agent")
            agentView.contentMode = .center
            agentView.isHidden = false
            self.visionCameraView?.addSubview(agentView)
            self.visionAgentView = agentView
            self.voiceprintTipsLabel.isSelected = true
        }
    }
    
    private func updateAgentLayout() {
        if agentType == .VoiceAgent {
            let hei = self.av_bottom - 228 - 18
            self.tipsLabel.frame = CGRect(x: 0, y: hei, width: self.av_width, height: 18)
        }
        else if agentType == .AvatarAgent {
            let hei = self.av_bottom - 228 - 18
            self.tipsLabel.frame = CGRect(x: 0, y: hei, width: self.av_width, height: 18)
            self.avatarAgentView?.frame = self.bounds
        }
        else if agentType == .VisionAgent {
            let hei = self.av_bottom - 240 - 18
            self.tipsLabel.frame = CGRect(x: 0, y: hei, width: self.av_width, height: 18)
            self.visionCameraView?.frame = self.bounds
            self.visionAgentView?.frame = CGRect(x: 0, y: UIView.av_safeTop + 44, width: self.av_width, height: hei - UIView.av_safeTop - 44)
        }
        self.voiceprintTipsLabel.layoutAt(frame: CGRect(x: 0, y: tipsLabel.av_top - 40 - 10, width: self.av_width, height: 40))
    }
    
    open func updateSubTitle(enable: Bool, isLLM: Bool, text: String, clear: Bool) {
        self.subtitleIcon.isHidden = !enable
        self.subtitleIcon.isSelected = isLLM
        self.subtitleLabel.isHidden = !enable
        self.subtitleLabel.text = text
        if clear {
//            self.exitSubtileFullscreen()
            
        }
        else {
            self.subtileFullscreenView?.updateSubtitle(subtitle: self.subtitleLabel.originalText)
        }
    }
    
    private func openSubtileFullscreen() {
        self.exitSubtileFullscreen()
        if let container = self.superview {
            
            let view = AUISubtileFullscreenView(frame: container.bounds)
            view.tappedAction = { [weak self] sender in
                self?.exitSubtileFullscreen()
            }
            view.updateSubtitle(subtitle: self.subtitleLabel.originalText)
            container.addSubview(view)
            self.subtileFullscreenView = view
        }
    }
    
    private func exitSubtileFullscreen() {
        self.subtileFullscreenView?.removeFromSuperview()
        self.subtileFullscreenView = nil
    }
}

@objcMembers open class AUISubtileFullscreenView: UIView {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        self.addSubview(self.closeBtn)
        self.addSubview(self.titleLabel)
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked(recognizer:))))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var closeBtn: AVBlockButton = {
        let close = AVBlockButton(frame: CGRect(x: self.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44))
        close.setImage(AVTheme.getImage("ic_close"), for: .normal)
        close.clickBlock = { [weak self] btn in
            self?.tappedAction?(self!)
        }
        return close
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = AVTheme.regularFont(14)
        label.frame = CGRect(x: 25, y: self.closeBtn.av_bottom + 20, width: self.av_width - 50, height: 0)
        return label
    }()
    
    open func updateSubtitle(subtitle: String?) {
        self.titleLabel.text = subtitle
        self.titleLabel.sizeToFit()
        self.titleLabel.frame = CGRect(x: 25, y: self.closeBtn.av_bottom + 20, width: self.av_width - 50, height: min(self.titleLabel.av_height, self.av_height - self.closeBtn.av_bottom - 20 - UIView.av_safeBottom))
    }
    
    open var tappedAction: ((_ sender: AUISubtileFullscreenView)->Void)? = nil
    
    @objc open func onClicked(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self)
        if self.titleLabel.frame.contains(location) {
            return
        }
        self.tappedAction?(self)
    }
}

@objcMembers open class AUISubtileReadMoreLabel: UILabel {

    var originalText: String?
    var maximumNumberOfLines: Int = 3
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGesture()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.expandButton.frame = CGRect(x: self.av_width - 40, y: self.av_height - 40, width: 60, height: 60)
    }
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AUIAICallBundle.getCommonImage("ic_subtile_more"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private func setupGesture() {
        self.isUserInteractionEnabled = true
        self.addSubview(self.expandButton)
        self.expandButton.addTarget(self, action: #selector(toggleText), for: .touchUpInside)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked(recognizer:))))
    }
    
    open override var text: String? {
        didSet {
            self.originalText = self.text
            self.truncateTextIfNeeded()
            let width = self.av_width
            self.sizeToFit()
            self.av_width = width
        }
    }
    
    private func truncateTextIfNeeded() {
        self.expandButton.isHidden = true
        guard let originalText = originalText else { return }
        
        let nsText = originalText as NSString
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.font!]
        
        let boundingRect = nsText.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        if boundingRect.size.height / self.font.lineHeight > CGFloat(self.maximumNumberOfLines) {
            var truncatedEndIndex = nsText.length
            
            var truncatedText: String?
            
            while truncatedEndIndex > 0 {
                let candidateText = nsText.substring(to: truncatedEndIndex) + "...  >"
                let candidateBoundingRect = (candidateText as NSString).boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                if candidateBoundingRect.size.height / self.font.lineHeight <= CGFloat(maximumNumberOfLines) {
                    truncatedText = nsText.substring(to: truncatedEndIndex) + "..."
                    self.expandButton.isHidden = false
                    break
                }
                
                truncatedEndIndex -= 1
            }
            
            super.text = truncatedText
        }
    }
    
    open var tappedAction: ((_ label: AUISubtileReadMoreLabel)->Void)? = nil

    
    @objc private func toggleText() {
        self.tappedAction?(self)
    }
    
    @objc open func onClicked(recognizer: UIGestureRecognizer) {
        self.tappedAction?(self)
    }
}


@objcMembers open class AUIVoiceprintTipsView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.textLabel)
        self.addSubview(self.clearBtn)
        self.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func showTips() {
        self.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips(_:)), object: nil)
        self.perform(#selector(hideTips(_:)), with: nil, afterDelay: 8)
    }
    
    open func hideTips() {
        self.isHidden = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips(_:)), object: nil)
    }
    
    @objc func hideTips(_ myObject: Any?) {
        self.isHidden = true
    }
    
    open func layoutAt(frame: CGRect) {
        self.textLabel.sizeToFit()
        self.clearBtn.sizeToFit()
        self.clearBtn.av_size = CGSize(width: self.clearBtn.av_width + 18, height: 18)

        var width = self.textLabel.av_width + self.clearBtn.av_width + 24
        if width > frame.width {
            width = frame.width
        }
        self.textLabel.av_left = 8
        self.textLabel.av_height = 40
        self.clearBtn.av_left = self.textLabel.av_right + 8
        self.clearBtn.av_centerY = 20
        self.center = CGPoint(x: frame.midX, y: frame.midY)
        self.av_size = CGSize(width: self.clearBtn.av_right + 8, height: 40)
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
    open var isSelected = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = UIColor.av_color(withHexString: "#868686")
            }
            else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.font = AVTheme.regularFont(12)
        label.text = AUIAICallBundle.getString("Detected other speaking, stop responded this question.")
        label.numberOfLines = 0
        return label
    }()
    
    
    open lazy var clearBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Restore"), for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(10)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 9
        return btn
    }()
}
