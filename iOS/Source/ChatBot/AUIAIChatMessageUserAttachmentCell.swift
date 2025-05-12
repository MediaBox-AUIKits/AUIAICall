//
//  AUIAIChatMessageUserAttachmentCell.swift
//  AUIAICall
//
//  Created by Bingo on 2024/03/20.
//

import UIKit
import AUIFoundation
import ARTCAICallKit
import SDWebImage

@objcMembers open class AUIAIChatMessageUserAttachmentCell: AUIAIChatMessageTextCell {

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(self.attachmentsView)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onAttachmentViewLongPress(gesture:)))
        self.attachmentsView.addGestureRecognizer(longPressGesture)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if self.stateBtn.isHidden == true || self.bgView.isHidden == false {
            let itemCount: CGFloat = CGFloat(self.item?.message.attachmentList?.count ?? 0)
            var width = itemCount * 72.0 + (itemCount - 1) * 8.0 + 40
            width = min(width, self.av_width + 40)
            self.attachmentsView.frame = CGRect(x: self.av_width + 20 - width, y: 0, width: width, height: 72)
        }
        else {
            
            var minX: CGFloat = 0.0
            minX = 20 + self.stateBtn.av_width
            
            let itemCount: CGFloat = CGFloat(self.item?.message.attachmentList?.count ?? 0)
            var width = itemCount * 72.0 + (itemCount - 1) * 8.0 + 20
            width = min(width, self.av_width - minX + 20)
            self.attachmentsView.frame = CGRect(x: self.av_width - width, y: 0, width: width, height: 72)
            
            self.stateBtn.center = CGPoint(x: self.attachmentsView.av_left - 16, y: self.attachmentsView.av_centerY)
        }
    }
    
    open override func getBgViewFrame() -> CGRect {
        var rect = super.getBgViewFrame()
        if AUIAIChatMessageUserAttachmentCell.canShowBgView(self.item) == false {
            return rect
        }
        rect.origin.y = 72 + 8
        rect.size.height = rect.size.height - rect.origin.y
        return rect
    }
    
    open lazy var attachmentsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.register(AUIAIChatMessageAttachmentCell.self, forCellWithReuseIdentifier: "cell")
        
        return view
    }()
    
    open override var item: AUIAIChatMessageItem? {
        didSet {
            
            super.item = item
            self.attachmentsView.reloadData()
            self.bgView.isHidden = !AUIAIChatMessageUserAttachmentCell.canShowBgView(self.item)
        }
    }
    
    @objc private func onAttachmentViewLongPress(gesture: UILongPressGestureRecognizer) {
        guard let item = self.item else { return }
        if gesture.state == .began {
            var location = gesture.location(in: self.attachmentsView)
            location.y = 4
            self.onLongPressBlock?(item, self.attachmentsView, location)
        }
    }
}

extension AUIAIChatMessageUserAttachmentCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item?.message.attachmentList?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.attachmentsView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAIChatMessageAttachmentCell
        cell.attachment = self.item?.message.attachmentList?[indexPath.row]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.attachmentsView.cellForItem(at: indexPath) as? AUIAIChatMessageAttachmentCell else {
            return
        }
        
        guard let image = cell.imageView.image else {
            return
        }
        
        UIViewController.av_top().av_presentFullScreenViewController(AUIAIChatImageViewer(image: image), animated: true)
    }
}

extension AUIAIChatMessageUserAttachmentCell {
    
    public static func canShowBgView(_ item: AUIAIChatMessageItem?) -> Bool {
        return item?.message.text.isEmpty != true
    }
    
    // 计算item的占位大小
    public static func computeAttachmentSize(item: AUIAIChatMessageItem, maxWidth: CGFloat) {
        let attaHeight = 72.0
        if self.canShowBgView(item) == false {
            item.displaySize = CGSize(width: maxWidth, height: attaHeight)
            return
        }
        self.computeSize(item: item, maxWidth: maxWidth)
        var size = item.displaySize!
        size.height += attaHeight + 8
        item.displaySize = size
    }
}

@objcMembers open class AUIAIChatMessageAttachmentCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(self.imageView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
    }
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = AVTheme.fg_strong
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    open var attachment: ARTCAIChatAttachment? = nil {
        didSet {
            if let atta = self.attachment {
                let path = atta.path
                var url = URL(string: path)
                if path.hasPrefix("/var") {
                    url = URL(fileURLWithPath: atta.path)
                    if url != nil {
                        url = AUIAIChatViewController.getFileUrl(fileName: url!.lastPathComponent, subDir: "attaments")
                    }
                }
                self.imageView.sd_setImage(with: url, placeholderImage: nil)
            }
            else {
                self.imageView.image = nil
            }
        }
    }
    
}
