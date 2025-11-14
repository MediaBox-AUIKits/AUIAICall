//
//  AUIAIChatMessageTextCell.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatMessageTextCell: UICollectionViewCell {

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.textLabel)
        self.contentView.addSubview(self.actionView)
        self.contentView.addSubview(self.stateBtn)
        
        self.bgView.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        self.bgView.addGestureRecognizer(longPressGesture)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = self.getContentViewFrame()
        let bgViewHeight = self.getBgViewHeight(contentHeight: contentFrame.height)
        let textLabelHeight = self.getTextLabelHeight(contentHeight: contentFrame.height)
        let actionViewHeight = self.getActionViewHeight()
        self.bgView.frame = CGRect(x: contentFrame.minX, y: contentFrame.minY, width: contentFrame.width, height: bgViewHeight)
        self.textLabel.frame = CGRect(x: 16, y: self.getTextLabelPositionY(), width: self.bgView.av_width - 32, height: textLabelHeight)
        self.actionView.frame = CGRect(x: 0, y: self.bgView.av_bottom, width: self.contentView.av_width, height: actionViewHeight)
        
        let x = self.item?.isLeft == true ? self.bgView.av_right : self.bgView.av_left - 32
        self.stateBtn.center = CGPoint(x: x + 16, y: self.bgView.av_bottom - 16)
    }
    
    internal func getTextLabelPositionY() -> CGFloat {
        return 8
    }
    
    internal func getContentViewFrame() -> CGRect {
        var displaySize = AUIAIChatMessageTextCell.minSize
        if self.item?.displaySize != nil {
            displaySize = (self.item?.displaySize)!
        }
        var height = displaySize.height
        if item?.isShowAction == true {
            height = height + 36.0
        }
        let x = self.item?.isLeft == true ? 0 : self.av_width - displaySize.width
        return  CGRect(x: x, y: 0, width: displaySize.width, height: height)
    }
    
    internal func getActionViewHeight() -> CGFloat {
        let actionViewHeight = self.actionView.isHidden ? 0.0 : 36.0
        return actionViewHeight
    }
    
    internal func getBgViewHeight(contentHeight: CGFloat) -> CGFloat {
        if self.actionView.isHidden == false {
            
        }
        // 总高度 - 操作栏高度
        return contentHeight - self.getActionViewHeight()
    }
    
    internal func getTextLabelHeight(contentHeight: CGFloat) -> CGFloat {
        // bg高度 - 顶部边距 - 底部边距高度
        return self.getBgViewHeight(contentHeight: contentHeight) - self.getTextLabelPositionY() - 8.0
    }

    open lazy var bgView: AUIAIChatMessageBgView = {
        let view = AUIAIChatMessageBgView()
        return view
    }()
    
    open lazy var stateBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_msg_resend"), for: .normal)
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_msg_loading"), for: .disabled)
        btn.tintColor = AUIAIChatBundle.color_icon
        btn.isHidden = true
        btn.clickBlock = { [weak self] btn in
            if let item = self?.item {
                self?.onResendBlock?(item)
            }
        }
        return btn
    }()
    
    open lazy var textLabel: AUIAIChatMarkdownView = {
        let label = AUIAIChatMarkdownView()
        return label
    }()
    
    open lazy var actionView: AUIAIChatMessageActionView = {
        let view = AUIAIChatMessageActionView()
        view.copyBtn.clickBlock = { [weak self] btn in
            if let item = self?.item {
                self?.onCopyBlock?(item)
            }
        }
        view.playBtn.clickBlock = { [weak self] btn in
            if let item = self?.item {
                self?.onPlayBlock?(item)
            }
        }
        return view
    }()
    
    open var item: AUIAIChatMessageItem? = nil {
        didSet {
            if let item = self.item {
                self.textLabel.attributedText = item.contentAttributeText
                self.bgView.isLeft = item.isLeft
                self.actionView.isLeft = item.isLeft
                self.actionView.isHidden = !item.isShowAction
            }
            else {
                self.textLabel.attributedText = nil
                self.bgView.isLeft = false
                self.actionView.isLeft = false
                self.actionView.isHidden = true
            }
            self.stopTransfering()
            self.refreshStateUI()
            self.setNeedsLayout()
        }
    }
    
    open func updateIsPlaying(isPlaying: Bool) {
        self.actionView.playBtn.isPlaying = isPlaying
    }
    
    open func refreshStateUI() {
        if let item = self.item {
            if item.isLeft == false {
                if item.message.messageState == .Init || item.message.messageState == .Transfering {
                    self.stateBtn.isHidden = false
                    self.stateBtn.isEnabled = false
                    self.startTransfering()
                    return
                }
                if item.message.messageState == .Failed {
                    self.stopTransfering()
                    self.stateBtn.isEnabled = true
                    self.stateBtn.isHidden = false
                    return
                }
            }
        }
        self.stopTransfering()
        self.stateBtn.isEnabled = false
        self.stateBtn.isHidden = true
    }
    
    open var onResendBlock: ((_ item: AUIAIChatMessageItem) -> Void)? = nil
    open var onCopyBlock: ((_ item: AUIAIChatMessageItem) -> Void)? = nil
    open var onPlayBlock: ((_ item: AUIAIChatMessageItem) -> Void)? = nil
    open var onLongPressBlock: ((_ item: AUIAIChatMessageItem, _ pressView: UIView, _ location: CGPoint) -> Void)? = nil
    
    @objc private func onLongPress(gesture: UILongPressGestureRecognizer) {
        guard let item = self.item else { return }
        if gesture.state == .began {
            var location = gesture.location(in: self.bgView)
            location.y = 4
            self.onLongPressBlock?(item, self.bgView, location)
        }
    }
    
    private var transfering = false
    private func startTransfering() {
        if self.transfering == true {
            return
        }
        debugPrint("AUIAIChatMessageTextCell: startTransfering")
        self.transfering = true
        self.stateBtn.imageView?.transform = .identity
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat.pi * 2 // 旋转360度
        rotationAnimation.duration = 1 // 动画持续时间
        rotationAnimation.isCumulative = true // 持续累积旋转
        rotationAnimation.repeatCount = .infinity // 无限重复
        self.stateBtn.imageView?.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopTransfering() {
        guard  self.transfering == true else {
            return
        }
        debugPrint("AUIAIChatMessageTextCell: stopTransfering")
        self.transfering = false
        self.stateBtn.imageView?.layer.removeAnimation(forKey: "rotationAnimation")
        self.stateBtn.imageView?.transform = .identity
    }
}

extension AUIAIChatMessageTextCell {
    
    public static var minSize: CGSize {
        get {
            return CGSize(width: 20, height: 40)
        }
    }
    
    public static func computContentSize(attributeText: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        if attributeText.string.isEmpty {
            return CGSize(width: self.minSize.width, height: 24.0)
        }
        let maxSize = CGSize(width: maxWidth - 16 - 16, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let boundingBox = attributeText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let width = max(boundingBox.width + 32, self.minSize.width)
        let height = ceil(boundingBox.height)
        return CGSize(width: width, height: height)
    }
    
    // 计算item的占位大小
    public static func computeSize(item: AUIAIChatMessageItem, maxWidth: CGFloat) {
        if item.message.messageType != .Text {
            item.displaySize = self.minSize
            return
        }
        
        if item.contentSize == nil {
            item.contentSize = self.computContentSize(attributeText: item.contentAttributeText, maxWidth: maxWidth)
        }
        
        let width = item.contentSize!.width
        let height = 8 + item.contentSize!.height + 8
        item.displaySize = CGSize(width: width, height: height)
    }
}


@objcMembers open class AUIAIChatMessageCellMenu: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.containerView)

        self.containerView.layer.addSublayer(self.rectLayer)
        self.containerView.layer.addSublayer(self.triangleLayer)
        
        self.containerView.addSubview(self.deleteBtn)
        self.deleteBtn.center = CGPoint(x: self.containerView.av_width / 2.0, y: self.containerView.av_height / 2.0)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.rectLayer.backgroundColor = AUIAIChatBundle.color_bg_elevated.cgColor
        self.rectLayer.borderColor = AUIAIChatBundle.color_border_secondary.cgColor

        self.triangleLayer.strokeColor = AUIAIChatBundle.color_border_secondary.cgColor
        self.triangleLayer.fillColor = AUIAIChatBundle.color_bg_elevated.cgColor
    }
    
    open var item: AUIAIChatMessageItem? = nil
    
    open func updatePosition(midx_bot: CGPoint) {
        let w = self.containerView.av_width / 2.0
        var midx = midx_bot.x
        if midx < w + 20 {
            midx = w + 20
        }
        else if midx > self.av_width - w - 20 {
            midx = self.av_width - w - 20
        }
        
        let h = self.containerView.av_height
        var bot = midx_bot.y
        if bot < h + UIView.av_safeTop {
            bot = h + UIView.av_safeTop
        }
        else if bot > self.av_height - UIView.av_safeBottom {
            bot = self.av_height - UIView.av_safeBottom
        }
        
        self.containerView.av_centerX = midx
        self.containerView.av_bottom = bot
    }
    
    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        return view
    }()
    
    private lazy var rectLayer: CALayer = {
        let layer = CALayer()
        layer.frame = self.containerView.bounds
        layer.backgroundColor = AUIAIChatBundle.color_bg_elevated.cgColor
        layer.cornerRadius = 4
        layer.borderWidth = 1.0
        layer.borderColor = AUIAIChatBundle.color_border_secondary.cgColor
        return layer
    }()
    
    private lazy var triangleLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        let bounds = CGRect(x: (self.containerView.av_width - 17) / 2.0, y: self.containerView.av_height - 1, width: 17, height: 10)
        let topPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
        let leftPoint = CGPoint(x: 0, y: 0)
        let rightPoint = CGPoint(x: bounds.width, y: 0)
        
        path.move(to: leftPoint)
        path.addLine(to: topPoint)
        path.addLine(to: rightPoint)

        let shapeLayer = CAShapeLayer() // 创建图形层
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = AUIAIChatBundle.color_border_secondary.cgColor
        shapeLayer.fillColor = AUIAIChatBundle.color_bg_elevated.cgColor
        shapeLayer.path = path.cgPath // 将路径设置到图形层
        return shapeLayer
    }()
    
    open lazy var deleteBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        
        let iconView = UIImageView(frame: CGRect(x: 26, y: 12, width: 20, height: 20))
        iconView.image = AUIAIChatBundle.getTemplateImage("ic_msg_delete")
        iconView.tintColor = AUIAIChatBundle.color_icon
        btn.addSubview(iconView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 36, width: btn.av_width, height: 18))
        titleLabel.text = AUIAIChatBundle.getString("Delete")
        titleLabel.font = AVTheme.regularFont(14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AUIAIChatBundle.color_text
        btn.addSubview(titleLabel)
        return btn
    }()
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            self.removeFromSuperview()
            return nil
        }
        return view
    }
}
