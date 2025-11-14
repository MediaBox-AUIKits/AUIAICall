//
//  AUIAIChatMessageAgentTextCell.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatMessageAgentTextCell: AUIAIChatMessageTextCell {

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.bgView.addSubview(self.reasonView)
        self.bgView.addSubview(self.interruptLabel)
        self.bgView.addSubview(self.loadingAniView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.interruptLabel.frame = CGRect(x: 16, y: self.bgView.av_height - 20 - 8, width: self.bgView.av_width - 32, height: 20)
    }
    
    override func getBgViewHeight(contentHeight: CGFloat) -> CGFloat {
        super.getBgViewHeight(contentHeight: contentHeight)
        
    }
    
    override func getTextLabelPositionY() -> CGFloat {
        if self.reasonView.isHidden {
            return super.getTextLabelPositionY()
        }
        return self.reasonView.av_bottom + 8.0
    }
    
    override func getTextLabelHeight(contentHeight: CGFloat) -> CGFloat {
        let interruptLabelHeight = self.interruptLabel.isHidden ? 0.0 : 20.0
        // bg高度 - 起点坐标 - 操作栏高度 - 打断提示词高度 - 底部边距高度
        return self.getBgViewHeight(contentHeight: contentHeight) - self.getTextLabelPositionY() - interruptLabelHeight - 8.0
    }
    
    open var onReasonExpandBlock: ((_ cell: AUIAIChatMessageAgentTextCell) -> Void)? = nil
    
    open lazy var reasonView: AUIAIChatMessageReasonView = {
        let view = AUIAIChatMessageReasonView()
        view.expandBtn.clickBlock = {[weak self] btn in
            guard let self = self else {
                return
            }
            self.onReasonExpandBlock?(self)
        }
        view.isHidden = true
        return view
    }()
    
    open lazy var interruptLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AUIAIChatBundle.color_text_tertiary
        label.text = AUIAIChatBundle.getString("User terminated this response")
        label.isHidden = true
        return label
    }()
    
    open lazy var loadingAniView: AUIAICallLoadingAnimator = {
        let view = AUIAICallLoadingAnimator(frame: CGRect(x: 0, y: 0, width: 68, height: 44), length: 8, margin: 8)
        view.isHidden = true
        return view
    }()
    
    open override var item: AUIAIChatMessageItem? {
        didSet {
            super.item = item
            if let item = self.item {
                self.loadingAniView.isHidden = !(item.message.messageState == .Transfering || item.message.messageState == .Init)
                if self.loadingAniView.isHidden == false {
                    self.loadingAniView.start()
                }
                self.interruptLabel.isHidden = item.message.messageState != .Interrupted
                
                self.reasonView.isHidden = !AUIAIChatMessageReasonView.isEnableReason(item: item)
                self.reasonView.expandBtn.isSelected = !item.isExpandReasonText
                self.reasonView.updateReasonType(type: AUIAIChatMessageReasonView.getReasonType(item: item))
                self.reasonView.frame = CGRect(x: 0, y: 8, width: item.reasonSize?.width ?? 0.0, height: item.reasonSize?.height ?? 0.0)
                self.reasonView.textLabel.text = item.message.reasoningText
            }
            else {
                self.loadingAniView.stop()
                self.loadingAniView.isHidden = true
                self.interruptLabel.isHidden = true
                
                self.reasonView.isHidden = true
                self.reasonView.frame = CGRect.zero
                self.reasonView.textLabel.text = nil
            }
            self.setNeedsLayout()
        }
    }
}

extension AUIAIChatMessageAgentTextCell {
    
    public static var getAgentLoadingSize: CGSize {
        get {
            return CGSize(width: 68, height: 44)
        }
    }
    
    static var _interruptedMinWidth: CGFloat = 0.0
    static func getInterruptedMinWidth() -> CGFloat {
        if _interruptedMinWidth == 0.0 {
            let text = AUIAIChatBundle.getString("User terminated this response")
            let font = AVTheme.regularFont(10)
            let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let boundingBox = (text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            _interruptedMinWidth = boundingBox.width + 32
        }
        return _interruptedMinWidth
    }
    
    public static func computAgentContentSize(attributeText: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        if attributeText.string.isEmpty {
            return CGSize.zero
        }
        let maxSize = CGSize(width: maxWidth - 16 - 16, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let boundingBox = attributeText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let width = max(boundingBox.width + 32, self.minSize.width)
        let height = ceil(boundingBox.height)
        return CGSize(width: width, height: height)
    }
    
    // 计算item的占位大小
    public static func computeAgentSize(item: AUIAIChatMessageItem, maxWidth: CGFloat) {
        
        if item.message.messageState == .Transfering || item.message.messageState == .Init {
            item.reasonSize = CGSize.zero
            item.contentSize = CGSize.zero
            item.displaySize = self.getAgentLoadingSize
            return
        }
        
        if item.message.messageType != .Text {
            item.reasonSize = CGSize.zero
            item.contentSize = CGSize.zero
            item.displaySize = self.minSize
            return
        }
        
        if item.reasonSize == nil  {
            item.reasonSize = AUIAIChatMessageReasonView.getHeight(item: item, maxWidth: maxWidth)
        }
        
        if item.contentSize == nil {
            item.contentSize = self.computAgentContentSize(attributeText: item.contentAttributeText, maxWidth: maxWidth)
        }
        
        let reasonSize = item.reasonSize!
        let contentSize = item.contentSize!
        
        var width = max(reasonSize.width, contentSize.width, self.minSize.width, self.getInterruptedMinWidth())
        width = min(width, maxWidth)
        
        var height = 8.0
        // 加上reasonView
        if reasonSize.height > 0.0 {
            height = height + reasonSize.height + 8.0
        }

        // 加上textLabel
        if contentSize.height > 0.0 {
            height = height + contentSize.height + 8.0
        }
        
        height = max(height, self.minSize.height)
        
        if item.message.messageState == .Printing {
            let printingHeight = height
            item.displaySize = CGSize(width: width, height: printingHeight)
            return
        }
        
        // 加上InterruptLabel
        if item.message.messageState == .Interrupted {
            height = height + 20.0 + 8.0
        }

        item.displaySize = CGSize(width: width, height: height)
    }
}
