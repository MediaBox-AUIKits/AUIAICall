//
//  AUIAIChatMarkdownView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/03/12.
//

import UIKit
import AUIFoundation
import SwiftyMarkdown
import SafariServices
import SDWebImage

@objcMembers open class AUIAIChatMarkdownManager: NSObject {
    
    public static let shared = AUIAIChatMarkdownManager()
    
    
    open func toAttributedString(markdownString: String) -> NSAttributedString {
        let md = SwiftyMarkdown(string: markdownString)
        md.setFontNameForAllStyles(with: AVTheme.regularFont(14.0).fontName)
        md.setFontColorForAllStyles(with: AVTheme.text_strong)
        md.setFontSizeForAllStyles(with: 14.0)
        md.italic.fontName = UIFont.italicSystemFont(ofSize: 14.0).fontName
        md.h6.fontSize = 14
        md.h6.fontStyle = .bold
        md.h5.fontSize = 16
        md.h5.fontStyle = .bold
        md.h4.fontSize = 18
        md.h4.fontStyle = .bold
        md.h3.fontSize = 20
        md.h3.fontStyle = .bold
        md.h2.fontSize = 22
        md.h2.fontStyle = .bold
        md.h1.fontSize = 24
        md.h1.fontStyle = .bold
//        md.body.lineSpacing = 4.0
        md.link.color = UIColor.av_color(withHexString: "3295FBFF")

        let attributedText = md.attributedString()
        return attributedText
    }
    
    // 渲染富文本的图片，图片地址从原始的markdown里提取
    open func renderImage(attributedString: NSAttributedString, originMarkdownString: String, maxImageSize: CGSize, renderQueue: DispatchQueue? = nil, renderCompleted:((NSAttributedString) -> Void)? = nil) {
        let queue = renderQueue ?? DispatchQueue.main
        self.fetchImages(markdownString: originMarkdownString) { [weak self] images in
            queue.async {
                guard let self = self else {return}
                self.renderAttachmentImages(attributedString: attributedString, images: images, maxSize: maxImageSize)
                renderCompleted?(attributedString)
            }
        }
    }
    
    private func renderAttachmentImages(attributedString: NSAttributedString, images: [UIImage], maxSize: CGSize) {
        var attachmentIndex = 0
        // 遍历整个字符串的范围
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
            // 检查是否有 NSTextAttachment 属性
            if let attach = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment {
                // 确保附件列表中有足够的附件
                guard attachmentIndex < images.count else {
                    print("附件列表不足，无法完成替换")
                    return
                }
                
                // 获取新的附件
                let image = images[attachmentIndex]
                attachmentIndex += 1
                
                attach.image = image
                attach.bounds = self.calculateImageBounds(for: image, maxSize: maxSize)
            }
        }
    }
    
    /// 从markdown内容里生成图片附件
    private func fetchImages(markdownString: String, completed: (([UIImage]) -> Void)?) {
        let pattern = "!\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        var results: [(altText: String, url: String)] = []
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: markdownString, options: [], range: NSRange(location: 0, length: markdownString.utf16.count))
            
            for match in matches {
                // 提取替代文本
                if let altTextRange = Range(match.range(at: 1), in: markdownString) {
                    let altText = String(markdownString[altTextRange])
                    
                    // 提取图片 URL
                    if let urlRange = Range(match.range(at: 2), in: markdownString) {
                        let url = String(markdownString[urlRange])
                        
                        // 添加到结果数组
                        results.append((altText: altText, url: url))
                    }
                }
            }
        }
        
        if results.isEmpty {
            completed?([])
            return
        }
        
        var images: [UIImage] = []
        results.forEach { (altText: String, url: String) in
            images.append(UIImage())
        }
        
        for i in 0..<results.count {
            self.downloadImage(from: results[i].url) { image in
                if let image = image {
                    images[i] = image
                }
                completed?(images)
            }
        }
    }
    
    /// 计算图片的 bounds，使其限制在给定的 size 内并按比例缩放
    private func calculateImageBounds(for image: UIImage, maxSize: CGSize) -> CGRect {
        // 获取图片的原始尺寸
        let imageSize = image.size
        
        // 计算宽高比
        let aspectRatio = imageSize.width / imageSize.height
        
        // 初始化目标宽度和高度
        let scale = max(image.scale, UIScreen.main.scale)
        var targetWidth = imageSize.width / scale
        var targetHeight = imageSize.height / scale
        
        if targetWidth < maxSize.width && targetHeight < maxSize.height {
            return CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        }
        
        // 如果宽度超过最大宽度限制
        if targetWidth > maxSize.width {
            targetWidth = maxSize.width
            targetHeight = targetWidth / aspectRatio
        }
        
        // 如果高度超过最大高度限制
        if targetHeight > maxSize.height {
            targetHeight = maxSize.height
            targetWidth = targetHeight * aspectRatio
        }
        
        // 确保宽度和高度都不超过最大限制
        targetWidth = min(targetWidth, maxSize.width)
        targetHeight = min(targetHeight, maxSize.height)
        
        // 返回计算后的 bounds
        return CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
    }
    
    /// 使用 SDWebImage 下载图片
    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("无效的图片 URL: \(urlString)")
            completion(UIImage(named: urlString))
            return
        }
        
        // 使用 SDWebImage 下载图片
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            progress: nil
        ) { image, _, error, _, _, _ in
            if let error = error {
                print("下载错误：\(error.localizedDescription)")
                completion(UIImage(named: urlString))
            } else {
                completion(image)
            }
        }
    }
}

@objcMembers open class AUIAIChatMarkdownView: UITextView, UITextViewDelegate {

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.backgroundColor = .clear
        self.font = AVTheme.regularFont(14)
        self.textColor = AVTheme.text_strong
        
        self.isEditable = false
        self.bounces = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isScrollEnabled = false
        self.textContainerInset = UIEdgeInsets.zero
        self.textContainer.lineFragmentPadding = 0
        
        self.dataDetectorTypes = []
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let safari = SFSafariViewController(url: URL)
        UIViewController.av_top().present(safari, animated: true)
        return false
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let image = textAttachment.image {
            UIViewController.av_top().av_presentFullScreenViewController(AUIAIChatImageViewer(image: image), animated: true)
        }

        // 返回 false 表示不执行默认行为
        return false
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 移除默认的复制、粘贴等操作
        if action == #selector(copy(_:)) || action == #selector(selectAll(_:)) {
            return true
        }
        return false
    }
}

/*
@objcMembers open class AUIAIChatMarkdownView: UILabel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = AVTheme.regularFont(14)
        self.textColor = AVTheme.text_strong
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
*/

