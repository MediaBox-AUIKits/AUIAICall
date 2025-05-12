//
//  AUIAIChatSendImagesView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/3/15.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatSendAttachmentItem: NSObject {
    
    public init(image: UIImage, attachment: ARTCAIChatAttachment) {
        self.image = image
        self.attachment = attachment
    }
    
    public let image: UIImage
    public let attachment: ARTCAIChatAttachment

    public static let addItem = AUIAIChatSendAttachmentItem(image: UIImage(), attachment: ARTCAIChatAttachment(attachmentId: "add"))
}


@objcMembers open class AUIAIChatSendAttachmentView: UIView {
    
    public init(frame: CGRect, attachmentUploader: ARTCAIChatAttachmentUploader) {
        self.attachmentUploader = attachmentUploader
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
        self.attachmentUploader.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    open lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.register(AUIAIChatSendingImageCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    public let attachmentUploader: ARTCAIChatAttachmentUploader
    open private(set) var itemList: [AUIAIChatSendAttachmentItem] = []

    open var willAddItemBlock: (() -> Void)? = nil
    open var willRemoveItemBlock: ((AUIAIChatSendAttachmentItem) -> Void)? = nil
    
    open var allUploadSuccess: Bool {
        get {
            return self.attachmentUploader.allUploadSuccess
        }
    }
    open var uploadFailure: Bool {
        get {
            var isFailure = false
            self.attachmentUploader.attachmentList.forEach { atta in
                if atta.state == .Failed {
                    isFailure = true
                }
            }
            return isFailure
        }
    }
    
    open var allUploadSuccessBlock: ((Bool) -> Void)? = nil
    open var uploadFailureBlock: ((AUIAIChatSendAttachmentItem) -> Void)? = nil
    
    open func addItem(item: AUIAIChatSendAttachmentItem) {
        if self.attachmentUploader.addAttachment(attachment: item.attachment) {
            self.itemList.insert(item, at: self.itemList.count)
            self.allUploadSuccessBlock?(self.allUploadSuccess)
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                let contentSize = self.collectionView.contentSize
                let contentInset = self.collectionView.contentInset
                let rect = CGRect(x: contentSize.width - contentInset.right - 10, y: 0, width: 10, height: contentSize.height)
                self.collectionView.scrollRectToVisible(rect, animated: false)
            }
        }
    }
    
    open func removeItem(item: AUIAIChatSendAttachmentItem) {
        self.attachmentUploader.removeAttachment(attachmentId: item.attachment.attachmentId)
        self.itemList.removeAll(where: { obj in
            obj == item
        })
        self.allUploadSuccessBlock?(self.allUploadSuccess)
        self.collectionView.reloadData()
    }
}

extension AUIAIChatSendAttachmentView: ARTCAIChatAttachmentUploadDelegate {
    public func onAttachmentUploadSuccess(attachment: ARTCAIChatAttachment) {
        self.collectionView.visibleCells.forEach { cell in
            if let cell = cell as? AUIAIChatSendingImageCell {
                if cell.item?.attachment == attachment {
                    cell.refreshState()
                }
            }
        }
        self.allUploadSuccessBlock?(self.allUploadSuccess)
    }
    
    public func onAttachmentUploadFailure(attachment: ARTCAIChatAttachment, error: NSError) {
        debugPrint("onAttachmentUploadFailure Error: \(error)")
        self.collectionView.visibleCells.forEach { cell in
            if let cell = cell as? AUIAIChatSendingImageCell {
                if cell.item?.attachment == attachment {
                    cell.refreshState()
                    self.uploadFailureBlock?(cell.item!)
                }
            }
        }
        self.allUploadSuccessBlock?(self.allUploadSuccess)
    }
    
    public func onAttachmentUploadProgress(attachment: ARTCAIChatAttachment, progress: Double) {
        self.collectionView.visibleCells.forEach { cell in
            if let cell = cell as? AUIAIChatSendingImageCell {
                if cell.item?.attachment == attachment {
                    cell.refreshProgress()
                }
            }
        }
    }
}

extension AUIAIChatSendAttachmentView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.itemList.count < 9 {
            return self.itemList.count + 1
        }
        return self.itemList.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 58, height: 58)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.getItem(row: indexPath.row)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAIChatSendingImageCell
        cell.item = item
        cell.addBtn.clickBlock = { [weak self] btn in
            self?.willAddItemBlock?()
        }
        cell.removeBtn.clickBlock = { [weak self] btn in
            self?.willRemoveItemBlock?(item)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.getItem(row: indexPath.row)
        guard item != AUIAIChatSendAttachmentItem.addItem else {
            return
        }
        
        UIViewController.av_top().av_presentFullScreenViewController(AUIAIChatImageViewer(image: item.image), animated: true)
    }
    
    private func getItem(row: Int) -> AUIAIChatSendAttachmentItem {
        var item = AUIAIChatSendAttachmentItem.addItem
        if row < self.itemList.count {
            item = self.itemList[row]
        }
        return item
    }
}

@objcMembers open class AUIAIChatSendingImageCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.removeBtn)
        self.contentView.addSubview(self.addBtn)

        self.imageView.addSubview(self.imageMaskView)
        self.imageMaskView.addSubview(self.progressView)
        self.imageMaskView.addSubview(self.imageFailedView)

        

    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = CGRect(x: 0, y: self.contentView.av_height - 52, width: 52, height: 52)
        self.removeBtn.frame = CGRect(x: self.contentView.av_width - 16, y: 0, width: 16, height: 16)
        self.addBtn.frame = self.imageView.frame
        self.imageMaskView.frame = self.imageView.bounds
        
        self.progressView.frame = CGRect(x: (self.imageMaskView.av_width - 20) / 2.0, y: (self.imageMaskView.av_height - 20) / 2.0, width: 20, height: 20)
        self.imageFailedView.frame = CGRect(x: (self.imageMaskView.av_width - 24) / 2.0, y: (self.imageMaskView.av_height - 24) / 2.0, width: 24, height: 24)
    }
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = AVTheme.fg_strong
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    open lazy var removeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_sending_delete"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    open lazy var addBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_sending_add"), for: .normal)
        btn.isHidden = false
        return btn
    }()
    
    open lazy var imageMaskView: UIView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()
    
    open lazy var progressView: AVCircularProgressView = {
        let view = AVCircularProgressView()
        view.backgroundColor = .clear
        view.lineWidth = 2
        view.trackTintColor = .white.withAlphaComponent(0.3)
        view.progressTintColor = .white
        view.isHidden = false
        return view
    }()
    
    open lazy var imageFailedView: UIView = {
        let view = UIImageView()
        view.image = AUIAIChatBundle.getImage("ic_sending_failed")
        view.isHidden = true
        return view
    }()
    
    private func update(image: UIImage, progress: Float, state: ARTCAIChatAttachmentState) {
        self.imageView.image = image
        self.addBtn.isHidden = true
        self.removeBtn.isHidden = false
        self.imageMaskView.isHidden = state == .Success
        self.imageFailedView.isHidden = state != .Failed
        self.progressView.isHidden = state != .Uploading
        self.progressView.progress = progress
    }
    
    private func reset() {
        self.imageView.image = nil
        self.addBtn.isHidden = false
        self.removeBtn.isHidden = true
        self.imageMaskView.isHidden = true
    }
    
    open func refreshProgress() {
        if let item = item {
            self.progressView.setProgress(Float(item.attachment.progress) / 100.0, animated: false)
        }
        else {
            self.progressView.setProgress(0.0, animated: false)
        }
    }
    
    open func refreshState() {
        if let item = item {
            if item == AUIAIChatSendAttachmentItem.addItem {
                self.reset()
            }
            else {
                self.update(image: item.image, progress: Float(item.attachment.progress) / 100.0, state: item.attachment.state)
            }
        }
        else {
            self.reset()
        }
    }
    
    open var item: AUIAIChatSendAttachmentItem? = nil {
        didSet {
            self.refreshState()
        }
    }
}
