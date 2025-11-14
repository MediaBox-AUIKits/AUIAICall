//
//  AUIAICallButton.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallButton: UIView {

    public override init(frame: CGRect) {
        self.isSelected = false
        super.init(frame: frame)
        
        self.addSubview(self.imageBgView)
        self.imageBgView.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.isSelected = false
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopTimer()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var iconWidth = self.av_width
        var iconHeight = self.av_height - 18 - 8
        if self.iconLength != CGFloat.leastNormalMagnitude {
            iconWidth = self.iconLength
            iconHeight = iconWidth
        }
        
        var iconCorner = iconHeight / 2.0
        if self.iconCorner != CGFloat.leastNormalMagnitude {
            iconCorner = self.iconCorner
        }
        
        self.imageBgView.frame = CGRect(x: (self.av_width - iconWidth) / 2.0, y: 0, width: iconWidth, height: iconHeight)
        self.imageBgView.layer.cornerRadius = iconCorner
        self.imageBgView.layer.masksToBounds = true
        self.imageBgView.layer.borderWidth = iconBorderWidth
        self.imageView.av_size = CGSize(width: iconHeight - self.iconMargin * 2, height: iconHeight - self.iconMargin * 2)
        self.imageView.center = CGPoint(x: iconWidth / 2.0, y: iconHeight / 2.0)
        
        self.titleLabel.sizeToFit()
        let width = max(self.av_width, self.titleLabel.av_width)
        self.titleLabel.frame = CGRect(x: (self.av_width - width) / 2.0, y: self.av_height - 18, width: width, height: 18.0)
    }
    
    open var iconLength: CGFloat = CGFloat.leastNormalMagnitude
    open var iconCorner: CGFloat = CGFloat.leastNormalMagnitude
    open var iconMargin: CGFloat = 12.0
    open var iconBorderWidth: CGFloat = 0
    
    open var normalBgColor: UIColor? = nil
    open var selectedBgColor: UIColor? = nil
    
    open var selectedTitle: String? = nil
    open var normalTitle: String? = nil
    
    open var selectedImage: UIImage? = nil
    open var normalImage: UIImage? = nil
    
    open var selectedTintColor: UIColor? = nil
    open var normalTintColor: UIColor? = nil
    
    open var selectedBorderColor: UIColor? = nil
    open var normalBorderColor: UIColor? = nil
    
    open var isSelected: Bool {
        didSet {
            self.imageBgView.backgroundColor = self.isSelected ? self.selectedBgColor : self.normalBgColor
            self.imageBgView.av_setLayerBorderColor(self.isSelected ? self.selectedBorderColor : self.normalBorderColor)
            self.imageView.image = self.isSelected ? self.selectedImage : self.normalImage
            self.imageView.tintColor = self.isSelected ? self.selectedTintColor : self.normalTintColor
            self.titleLabel.text = self.isSelected ? self.selectedTitle : self.normalTitle
            self.setNeedsLayout()
        }
    }
    
    open lazy var imageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    open lazy var imageBgView: UIView = {
        let bg = UIView()
        return bg
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12.0)
        label.textColor = AUIAICallBundle.color_text
        label.textAlignment = .center
        return label
    }()
    
    open var tappedAction: ((_ btn: AUIAICallButton)->Void)? = nil
    
    @objc open func onTapped() {
        self.tappedAction?(self)
    }
    
    
    private var longPressGesture: UILongPressGestureRecognizer? = nil
    private var longPressTimer: Timer? = nil
    private var startLongPressTime: TimeInterval = 0
    open var maxPressTime: TimeInterval = 60.0
    
    // state: 0(按下) 1(松开) 2(取消)
    open var longPressAction: ((_ btn: AUIAICallButton, _ state: Int32, _ elapsed: TimeInterval)->Void)? = nil {
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
            self.longPressAction?(self, 0, 0)
            self.startLongPressTime = Date().timeIntervalSince1970
            self.startTimer()
        }
        else if gesture.state == .ended {
            let location = gesture.location(in: self)
            if self.bounds.contains(location) {
                self.checkLongPressRelease(cancel: false)
            }
            else {
                self.checkLongPressRelease(cancel: true)
            }
        }
        else if gesture.state == .cancelled {
            self.checkLongPressRelease(cancel: true)
        }
        else {
            // debugPrint("ptt: \(gesture.state)")
        }
    }
    
    func checkLongPressRelease(cancel: Bool) {
        if self.startLongPressTime > 0 {
            let t = Date().timeIntervalSince1970 - self.startLongPressTime
            self.longPressAction?(self, cancel ? 2 : 1, t)
            self.stopTimer()
            self.startLongPressTime = 0
        }
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

extension AUIAICallButton {
    
    public static func create(title: String?, iconBgColor: UIColor?, normalIcon: UIImage?, selectedBgColor: UIColor? = nil, selectedTitle: String? = nil, selectedIcon: UIImage? = nil) -> AUIAICallButton {
        let btn = AUIAICallButton()
        btn.normalBgColor = iconBgColor
        btn.selectedBgColor = selectedBgColor ?? iconBgColor
        btn.normalTitle = title
        btn.selectedTitle = selectedTitle
        btn.normalImage = normalIcon
        btn.selectedImage = selectedIcon
        btn.isSelected = false
        return btn
    }
    
}
