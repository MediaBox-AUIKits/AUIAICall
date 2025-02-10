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
        
        self.bgView.addSubview(self.loadingAniView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
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
                self.actionView.isHidden = !(item.message.messageState == .Interrupted || item.message.messageState == .Failed || item.message.messageState == .Finished)
            }
            else {
                self.loadingAniView.stop()
                self.loadingAniView.isHidden = true
                self.actionView.isHidden = false
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
    
    public static func getAgentSize(item: AUIAIChatMessageItem, maxWidth: CGFloat) -> CGSize {
        
        if item.message.messageState == .Transfering || item.message.messageState == .Init {
            return self.getAgentLoadingSize
        }
        
        if item.message.messageType != .Text {
            return self.minSize
        }
        
        let text = item.message.text
        let font = AVTheme.regularFont(14)
        let maxSize = CGSize(width: maxWidth - 12 - 12, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let boundingBox = (text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        let width = max(boundingBox.width + 24, self.minSize.width)
        var height = 12 + boundingBox.height + 12
        
        if item.message.messageState == .Printing {
            return CGSize(width: width, height: height)
        }
        
        // 加上Actionview
        height = 12 + boundingBox.height + 8
        return CGSize(width: width, height: height + 20 + 8)
    }
}
