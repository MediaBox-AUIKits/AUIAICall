//
//  AUIAIChatMessageTextCell.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatMessageItem: NSObject {
    
    public init(message: ARTCAIChatMessage) {
        self.message = message
        self.contentOriginText = message.text
        self.contentAttributeText = NSAttributedString()
        self.needsUpdateContentInfo = true
    }
    
    open var message: ARTCAIChatMessage {
        didSet {
            if self.contentOriginText != self.message.text {
                self.contentOriginText = self.message.text
                self.needsUpdateContentInfo = true
            }
            if self.message.messageState == .Finished || self.message.messageState == .Failed || self.message.messageState == .Interrupted {
                self.needsUpdateContentInfo = true
            }
        }
    }
    
    // 整个cell的展示大小（由contentSize\reasonSize\底部操作栏size组成），为空时表示需要计算大小
    open var displaySize: CGSize? = nil
    open var isLeft: Bool = false
    open var error: NSError? = nil
    
    // 文本内容相关属性，包括原始文本、富文本、是否需要刷新、占位大小
    open private(set) var contentOriginText: String
    open private(set) var contentAttributeText: NSAttributedString
    private var needsUpdateContentInfo: Bool = false
    private var isUpdatingContentInfo: Bool = false
    open internal(set) var contentSize: CGSize? = nil  {
        didSet {
            // debugPrint("displaySize set to nil")
            self.displaySize = nil
        }
    }
    
    // 深度思考属性，包括是否展开、是否需要刷新、占位大小
    open var isExpandReasonText: Bool = true
    private var needsUpdateReasonInfo: Bool = false
    private var isUpdatingReasonInfo: Bool = false
    open internal(set) var reasonSize: CGSize? = nil   {
        didSet {
            self.displaySize = nil
        }
    }

    open var attachmentUploader: ARTCAIChatAttachmentUploader? = nil
}

extension AUIAIChatMessageItem {
    
    open func save() -> [String: Any] {
        return self.message.toData()
    }
    
    public static func load(dict: [String: Any]?, senderId: String) -> AUIAIChatMessageItem? {
        var msg = ARTCAIChatMessage(data: dict)
        if msg.messageState == .Transfering || msg.messageState == .Init {
            return nil
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
        return item
    }
}

extension AUIAIChatMessageItem {
    
    open func isSame(message: ARTCAIChatMessage, isLeft: Bool) -> Bool {
        let ret = self.isLeft == isLeft && self.message.requestId == message.requestId
        if ret == false {
            return false
        }
        if self.message.nodeId == nil && message.nodeId != nil {
            return true
        }
        if self.message.nodeId == message.nodeId {
            return true
        }
        return false
    }
    
    open func updateContentInfoSync(maxWidth: CGFloat) {
        guard self.needsUpdateContentInfo else {
            return
        }
        self.contentAttributeText = AUIAIChatMarkdownManager.shared.toAttributedString(markdownString: self.contentOriginText)
        if self.isLeft {
            self.contentSize = AUIAIChatMessageAgentTextCell.computAgentContentSize(attributeText: self.contentAttributeText, maxWidth: maxWidth)
        }
        else {
            self.contentSize = AUIAIChatMessageTextCell.computContentSize(attributeText: self.contentAttributeText, maxWidth: maxWidth)
        }
    }
    
    open func updateAgentContentInfo(computeQueue: DispatchQueue?, maxWidth: CGFloat, completed:(() -> Void)?) {
        guard self.needsUpdateContentInfo else {
            return
        }
        guard self.isUpdatingContentInfo == false else {
            return
        }
        self.needsUpdateContentInfo = false
        self.isUpdatingContentInfo = true
        let markdownString = self.contentOriginText
        let needsProcessContentImage = self.message.messageState == .Finished
        
        let updateSizeBlock: (NSAttributedString) -> Void = { [weak self] attributeText in
            let contentSize = AUIAIChatMessageAgentTextCell.computAgentContentSize(attributeText: attributeText, maxWidth: maxWidth)
//            debugPrint("originText: \(markdownString) contentSize:\(contentSize), attributeText:\(attributeText)")
            
            let isMain = Thread.isMainThread
            if isMain {
                self?.isUpdatingContentInfo = false
                self?.contentAttributeText = attributeText
                self?.contentSize = contentSize
                completed?()
                self?.updateAgentContentInfo(computeQueue: computeQueue, maxWidth: maxWidth, completed: completed)
            }
            else {
                DispatchQueue.main.async {
                    self?.isUpdatingContentInfo = false
                    self?.contentAttributeText = attributeText
                    self?.contentSize = contentSize
                    completed?()
                    self?.updateAgentContentInfo(computeQueue: computeQueue, maxWidth: maxWidth, completed: completed)
                }
            }
        }
        
        let doBlock = {
            let attributeText = AUIAIChatMarkdownManager.shared.toAttributedString(markdownString: markdownString)
            if needsProcessContentImage {
                let maxSize = CGSize(width: maxWidth - 24 , height: CGFloat.greatestFiniteMagnitude)
                AUIAIChatMarkdownManager.shared.renderImage(attributedString: attributeText, originMarkdownString: markdownString, maxImageSize: maxSize ,renderQueue: computeQueue) { attri in
                    updateSizeBlock(attributeText)
                }
            }
            else {
                updateSizeBlock(attributeText)
            }
        }
        
        if let computeQueue = computeQueue {
            computeQueue.async {
                doBlock()
            }
        }
        else {
            doBlock()
        }
    }
    
    open func updateAgentReasonInfo(computeQueue: DispatchQueue?, maxWidth: CGFloat, completed:(() -> Void)?) {
        guard self.isUpdatingReasonInfo == false else {
            self.needsUpdateReasonInfo = true
            return
        }
        self.needsUpdateReasonInfo = false
        self.isUpdatingReasonInfo = true
        
        let updateSizeBlock = { [weak self] in
            guard let self = self else {
                return
            }
            let reasonSize = AUIAIChatMessageReasonView.getHeight(item: self, maxWidth: maxWidth)

            let isMain = Thread.isMainThread
            if isMain {
                self.isUpdatingReasonInfo = false
                self.reasonSize = reasonSize
                completed?()
                if self.needsUpdateReasonInfo {
                    self.updateAgentReasonInfo(computeQueue: computeQueue, maxWidth: maxWidth, completed: completed)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.isUpdatingReasonInfo = false
                    self.reasonSize = reasonSize
                    completed?()
                    if self.needsUpdateReasonInfo {
                        self.updateAgentReasonInfo(computeQueue: computeQueue, maxWidth: maxWidth, completed: completed)
                    }
                }
            }
        }
        
        if let computeQueue = computeQueue {
            computeQueue.async {
                updateSizeBlock()
            }
        }
        else {
            updateSizeBlock()
        }
    }
    
}
