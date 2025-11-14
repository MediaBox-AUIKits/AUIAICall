//
//  AUIAICallPushToTalkButton.swift
//  AUIAICall
//
//  Created by Bingo on 2025/9/16.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallPushToTalkButton: UIView {
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAICallBundle.color_fill_secondary
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 0.5
        self.av_setLayerBorderColor(AUIAICallBundle.color_border_secondary)
        self.layer.masksToBounds = true
        self.addSubview(self.titleLabel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopTimer()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = self.bounds
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.mediumFont(16.0)
        label.textColor = AUIAICallBundle.color_text
        label.textAlignment = .center
        label.text = AUIAICallBundle.getString("Push to Talk")
        return label
    }()
    
    private var longPressGesture: UILongPressGestureRecognizer? = nil
    private var longPressTimer: Timer? = nil
    private var startLongPressTime: TimeInterval = 0
    open var maxPressTime: TimeInterval = 60.0
    
    open weak var presentView: UIView? = nil
    open private(set) weak var pushToTalkView: AUIAICallPushToTalkView? = nil
    
    // state: 0(按下) 1(松开) 2(取消)
    open var longPressAction: ((_ btn: AUIAICallPushToTalkButton, _ state: Int32, _ elapsed: TimeInterval)->Void)? = nil {
        didSet {
            guard let _ = self.longPressAction else {
                return
            }
            if self.longPressGesture != nil {
                return
            }
            self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
            self.longPressGesture?.minimumPressDuration = 0.01
            self.addGestureRecognizer(self.longPressGesture!)
        }
    }
    
    open var pressTimeUpdate: ((_ time: TimeInterval) -> Void)? = nil
    
    @objc open func onLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if let presentView = self.presentView {
                self.pushToTalkView?.removeFromSuperview()
                let view = AUIAICallPushToTalkView(frame: presentView.bounds)
                presentView.addSubview(view)
                self.pushToTalkView = view
            }
            self.longPressAction?(self, 0, 0)
            self.startLongPressTime = Date().timeIntervalSince1970
            self.startTimer()
        }
        else if gesture.state == .ended {
            if self.pushToTalkView?.isCancel == true {
                self.checkLongPressRelease(cancel: true)
            }
            else {
                self.checkLongPressRelease(cancel: false)
            }
        }
        else if gesture.state == .cancelled {
            self.checkLongPressRelease(cancel: true)
        }
        else if gesture.state == .changed {
            if let presentView = self.presentView {
                let location = gesture.location(in: presentView)
                if self.pushToTalkView?.bottomView.frame.contains(location) == true {
                    self.pushToTalkView?.isCancel = false
                }
                else {
                    self.pushToTalkView?.isCancel = true
                }
                // debugPrint("location: \(location.x)  \(location.y)")
            }
        }
        else {
            // debugPrint("ptt: \(gesture.state)")
        }
    }
    
    func checkLongPressRelease(cancel: Bool) {
        if self.startLongPressTime > 0 {
            let t = Date().timeIntervalSince1970 - self.startLongPressTime
            self.pushToTalkView?.removeFromSuperview()
            self.longPressAction?(self, cancel ? 2 : 1, t)
            self.stopTimer()
            self.startLongPressTime = 0
        }
    }
    
    func onLongPressResult(state: Int, elapsed: TimeInterval) {
        
    }
    
    func startTimer() {
        self.stopTimer()
        self.longPressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }

    @objc func updateCounter() {
        let t = Date().timeIntervalSince1970 - self.startLongPressTime
        self.pressTimeUpdate?(t)
        if t >= self.maxPressTime - 0.5 {
            self.stopTimer()
            self.checkLongPressRelease(cancel: false)
            self.longPressGesture?.isEnabled = false // 临时禁用手势
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.longPressGesture?.isEnabled = true // 再重新启用手势
            }
        }
    }
    
    func stopTimer() {
        self.longPressTimer?.invalidate()
        self.longPressTimer = nil
    }
}

@objcMembers open class AUIAICallPushToTalkView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.blurView)
        self.addSubview(self.bottomView)
        self.addSubview(self.voiceBarView)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.cancelBtn)

        self.isUserInteractionEnabled = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.blurView.frame = self.bounds
        let bottomHeight = 140.0
        self.bottomView.frame = CGRect(x: 0, y: self.av_height - bottomHeight, width: self.av_width, height: bottomHeight)
        self.voiceBarView.av_centerX = self.av_width / 2.0
        self.voiceBarView.av_top = self.bottomView.av_top + 54
        self.tipsLabel.av_centerX = self.av_width / 2.0
        self.tipsLabel.av_bottom = self.bottomView.av_top - 12
        self.cancelBtn.av_centerX = self.av_width / 2.0
        self.cancelBtn.av_bottom = self.tipsLabel.av_top - 24
    }
    
    open lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()
    
    open lazy var bottomView: AUIAICallArcTopView = {
        let view = AUIAICallArcTopView(frame: CGRect.zero)
        view.backgroundColor = .clear
        return view
    }()
    
    open lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12.0)
        label.textColor = AUIAICallBundle.color_text_identical
        label.textAlignment = .center
        label.text = AUIAICallBundle.getString("Release to send, swipe up to cancel")
        label.sizeToFit()
        return label
    }()
    
    open lazy var voiceBarView: UIImageView = {
        let view = UIImageView()
        view.image = AUIAICallBundle.getTemplateImage("ic_voice_bar")
        view.tintColor = AUIAICallBundle.color_icon
        view.av_size = CGSize(width: 28, height: 28)
        return view
    }()
    
    open lazy var cancelBtn: UIButton = {
        let btn = AVBlockButton()
        btn.backgroundColor = AUIAICallBundle.color_fill_secondary
        btn.tintColor = AUIAICallBundle.color_icon
        btn.setImage(AUIAICallBundle.getTemplateImage("ic_handup"), for: .normal)
        btn.layer.cornerRadius = 30
        btn.layer.masksToBounds = true
        btn.av_size = CGSize(width: 60, height: 60)
        return btn
    }()
    
    open var isCancel: Bool = false {
        didSet {
            if self.isCancel {
                self.cancelBtn.backgroundColor = AUIAICallBundle.color_error
                self.cancelBtn.tintColor = AUIAICallBundle.color_icon_identical
            }
            else {
                self.cancelBtn.backgroundColor = AUIAICallBundle.color_fill_secondary
                self.cancelBtn.tintColor = AUIAICallBundle.color_icon
            }
        }
    }
}


@objcMembers open class AUIAICallArcTopView: UIView {
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setNeedsDisplay()
    }
    
    let arcHeight: CGFloat = 58.0
    open override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let arcHeight = self.arcHeight
        
        let radius = (width * width) / (8.0 * arcHeight) + arcHeight / 2.0  // 半径
        let angleRad = 2.0 * asin(width / (2.0 * radius))  // 圆心角弧度
        let startAngle = (.pi - angleRad) / 2.0
        
        let path = UIBezierPath()
        
        // 1、顶部弧形的闭合曲线
        path.move(to: CGPoint(x: 0, y: self.arcHeight))
        path.addArc(
            withCenter: CGPoint(x: width / 2, y: radius),
            radius: radius,
            startAngle: .pi - startAngle,
            endAngle: startAngle,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: width, y: height)) // 右下角
        path.addLine(to: CGPoint(x: 0, y: height))     // 左下角
        path.close() // 闭合路径
        UIColor.blue.setFill()
        AUIAICallBundle.color_bg_elevated.setFill()
        path.fill()
        
        // 2. 仅对顶部弧形部分描边
        let strokePath = UIBezierPath()
//        strokePath.move(to: CGPoint(x: 0, y: self.arcHeight))
        strokePath.addArc(
            withCenter: CGPoint(x: width / 2, y: radius),
            radius: radius,
            startAngle: .pi - startAngle,
            endAngle: startAngle,
            clockwise: true
        )
        AUIAICallBundle.color_border_tertiary.setStroke()
        strokePath.lineWidth = 1.0
        strokePath.stroke()
    }
}
