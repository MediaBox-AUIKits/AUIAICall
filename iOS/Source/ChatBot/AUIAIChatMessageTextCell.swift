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
        self.bgView.addSubview(self.actionView)
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
        
        self.bgView.frame = self.getBgViewFrame()
        self.textLabel.frame = CGRect(x: 12, y: self.getTextLabelPositionY(), width: self.bgView.av_width - 24, height: self.getTextLabelHeight())
        self.actionView.frame = CGRect(x: 0, y: self.bgView.av_height - 36.0, width: self.bgView.av_width, height: 36.0)
        
        let x = self.item?.isLeft == true ? self.bgView.av_right : self.bgView.av_left - 32
        self.stateBtn.center = CGPoint(x: x + 16, y: self.bgView.av_bottom - 16)
    }
    
    internal func getTextLabelPositionY() -> CGFloat {
        return 12
    }
    
    internal func getBgViewFrame() -> CGRect {
        var displaySize = AUIAIChatMessageTextCell.minSize
        if self.item?.displaySize != nil {
            displaySize = (self.item?.displaySize)!
        }
        let x = self.item?.isLeft == true ? 0 : self.av_width - displaySize.width
        return  CGRect(x: x, y: 0, width: displaySize.width, height: displaySize.height)
    }
    
    internal func getTextLabelHeight() -> CGFloat {
        let actionViewHeight = self.actionView.isHidden ? 0.0 : 36.0
        let bottomMargin = self.actionView.isHidden ? 12.0 : 0
        // bg高度 - 顶部边距 - 操作栏高度 - 底部边距高度
        return self.bgView.av_height - 12 - actionViewHeight - bottomMargin
    }

    open lazy var bgView: AUIAIChatMessageBgView = {
        let view = AUIAIChatMessageBgView()
        return view
    }()
    
    open lazy var stateBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_msg_resend"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_msg_loading"), for: .disabled)
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
            }
            else {
                self.textLabel.attributedText = nil
                self.bgView.isLeft = false
                self.actionView.isLeft = false
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
            return CGSize(width: 80, height: 70)
        }
    }
    
    public static func computContentSize(attributeText: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        if attributeText.string.isEmpty {
            return CGSize(width: self.minSize.width, height: 22.0)
        }
        let maxSize = CGSize(width: maxWidth - 12 - 12, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let boundingBox = attributeText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let width = max(boundingBox.width + 24, self.minSize.width)
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
        let height = 12 + item.contentSize!.height + 8 + 20 + 8
        item.displaySize = CGSize(width: width, height: height)
    }
}


@objcMembers open class AUIAIChatMessageCellMenu: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.deleteBtn)
        self.deleteBtn.center = CGPoint(x: self.containerView.av_width / 2.0, y: self.containerView.av_height / 2.0)
        
        self.drawRoundedTriangle()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 62))
        view.backgroundColor = AVTheme.fill_medium
        view.layer.cornerRadius = 4
        
        return view
    }()
    
    open lazy var deleteBtn: AVBaseButton = {
        let btn = AVBaseButton.imageText(with: .bottom)
        btn.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        btn.font = AVTheme.regularFont(12)
        btn.title = AUIAIChatBundle.getString("Delete")
        btn.color = AVTheme.text_medium
        btn.image = AUIAIChatBundle.getImage("ic_msg_delete")
        return btn
    }()
    
    private func drawRoundedTriangle() {
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        let bounds = CGRect(x: (self.containerView.av_width - 17) / 2.0, y: self.containerView.av_height, width: 17, height: 9)
        let topPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
        let leftPoint = CGPoint(x: 0, y: 0)
        let rightPoint = CGPoint(x: bounds.width, y: 0)
        path.move(to: CGPoint(x: topPoint.x, y: topPoint.y))
        path.addLine(to: CGPoint(x: leftPoint.x, y: leftPoint.y))
        path.addLine(to: CGPoint(x: rightPoint.x, y: rightPoint.y))
        path.addLine(to: CGPoint(x: topPoint.x, y: topPoint.y))
        path.close()

        let shapeLayer = CAShapeLayer() // 创建图形层
        shapeLayer.frame = bounds
        shapeLayer.fillColor = AVTheme.fill_medium.cgColor
        self.containerView.layer.addSublayer(shapeLayer)
        shapeLayer.path = path.cgPath // 将路径设置到图形层
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            self.removeFromSuperview()
            return nil
        }
        return view
    }
}
