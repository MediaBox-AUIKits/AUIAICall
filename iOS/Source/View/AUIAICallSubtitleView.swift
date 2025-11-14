//
//  AUIAICallSubtitleView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/5/6.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallSubtitleListView: UIView {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
        self.addSubview(self.subtitleBtn)

        self.isUserInteractionEnabled = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.subtitleBtn.sizeToFit()
        self.subtitleBtn.av_right = self.av_right - 24
        self.subtitleBtn.av_top = UIView.av_safeTop + 9
        
        self.blurView.frame = self.bounds
        
        let gradientMask = CAGradientLayer()
        gradientMask.frame = self.blurView.bounds
        gradientMask.colors = [
            UIColor.black.cgColor,  // 底部完全不透明
            UIColor.clear.cgColor, // 顶部完全透明
        ]
        gradientMask.startPoint = CGPoint(x: 0.5, y: (self.av_height - self.contentInset.bottom) / self.av_height)  // 从顶部开始
        gradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)    // 到底部结束
        self.blurView.layer.mask = gradientMask
        
        
        var rect = CGRect(x: 0, y: 0, width: self.av_width, height: self.av_height)
        rect = rect.inset(by: self.contentInset)
        self.collectionView.frame = rect
    }
    
    open var contentInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var listSubtitle: [AUIAICallSubtitleCellItem] = []
    
    open lazy var subtitleBtn: UIButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Subtitles"), for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(14)
        btn.setTitleColor(AUIAICallBundle.color_text_Inverse, for: .normal)
        btn.backgroundColor = AUIAICallBundle.color_fill
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.clickBlock = { [weak self] btn in
            self?.removeFromSuperview()
        }
        return btn
    }()
    
    open lazy var blurView: UIVisualEffectView = {
        var blurStyle: UIBlurEffect.Style = .dark
        var backcolor = UIColor.black
        if #available(iOS 12.0, *) {
            blurStyle = self.traitCollection.userInterfaceStyle == .dark ? .dark : .light
            backcolor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        } else {
            // Fallback on earlier versions
        }
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = backcolor.withAlphaComponent(0.6)
        blurView.isUserInteractionEnabled = false
        self.insertSubview(blurView, belowSubview: self.collectionView)
        return blurView
    }()
    
    open lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.register(AUIAICallSubtitleCell.self, forCellWithReuseIdentifier: "cell")
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    open func updateSubtitle(sentenceId: Int, isAgent: Bool, subtitle: String) {
        if let sub = self.listSubtitle.first(where: { item in
            return item.sentenceId == sentenceId && item.isAgent == isAgent
        }) {
            sub.subtitle = subtitle
            sub.size = CGSize.zero
            self.collectionView.reloadData()
            return
        }
        
        let sub = AUIAICallSubtitleCellItem()
        sub.sentenceId = sentenceId
        sub.subtitle = subtitle
        sub.isAgent = isAgent
        self.listSubtitle.append(sub)
        self.collectionView.reloadData()
    }
    
    open func removeSubtitle(sentenceId: Int, isAgent: Bool) {
        let ret = self.listSubtitle.contains { item in
            return item.sentenceId == sentenceId && item.isAgent == isAgent
        }
        if ret {
            self.listSubtitle.removeAll { item in
                return item.sentenceId == sentenceId && item.isAgent == isAgent
            }
            self.collectionView.reloadData()
        }
    }
    
    private var canScrollToLast: Bool = true
    
    private func asyncScrollLastMessage(ani: Bool) {
        DispatchQueue.main.async {
            guard self.canScrollToLast else {
                return
            }
            let contentSize = self.collectionView.contentSize
            let contentInset = self.collectionView.contentInset
            let rect = CGRect(x: 0, y: contentSize.height - contentInset.bottom - 10, width: contentSize.width, height: 10)
            self.collectionView.scrollRectToVisible(rect, animated: ani)
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self || view == self.blurView {
            return nil
        }
        return view
    }
}

extension AUIAICallSubtitleListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listSubtitle.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallSubtitleCell
        cell.item = self.listSubtitle[indexPath.row]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.listSubtitle[indexPath.row]
        AUIAICallSubtitleCell.computeSize(item: item, maxWidth: self.collectionView.av_width)
        
        // 当前计算好所有的item高度是，进行异步滚动到底部（如果需要）
        if indexPath.row == self.listSubtitle.count - 1 {
            self.asyncScrollLastMessage(ani: true)
        }
        
        return item.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.perform(#selector(enableScrollToLast), with: nil, afterDelay: 3.0)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.canScrollToLast = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(enableScrollToLast), object: nil)
    }
    
    @objc func enableScrollToLast() {
        self.canScrollToLast = true
    }
}

@objcMembers open class AUIAICallSubtitleCellItem: NSObject {
    open var sentenceId: Int = 0
    open var subtitle: String = ""
    open var isAgent: Bool = false
    open var size: CGSize = CGSize.zero
}

@objcMembers open class AUIAICallSubtitleCell: UICollectionViewCell {

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(self.textLabel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel.frame = self.contentView.bounds.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = AVTheme.regularFont(16.0)
        return label
    }()
    
    
    open var item: AUIAICallSubtitleCellItem? = nil {
        didSet {
            if let item = self.item {
                self.textLabel.text = item.subtitle
            }
            else {
                self.textLabel.text = ""
            }
            if self.item?.isAgent == true {
                self.textLabel.textColor = AUIAICallBundle.color_text_tertiary
            }
            else {
                self.textLabel.textColor = AUIAICallBundle.color_text
            }
        }
    }
}


extension AUIAICallSubtitleCell {
    
    public static func computContentSize(attributeText: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        if attributeText.string.isEmpty {
            return CGSize(width: maxWidth, height: 24)
        }
        let maxSize = CGSize(width: maxWidth - 20 - 20, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let boundingBox = attributeText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let width = maxWidth
        let height = ceil(boundingBox.height)
        return CGSize(width: width, height: height)
    }
    
    // 计算item的占位大小
    public static func computeSize(item: AUIAICallSubtitleCellItem, maxWidth: CGFloat) {
        
        if item.size.equalTo(CGSize.zero) == false {
            return
        }
        
        let attr = NSAttributedString(string: item.subtitle, attributes: [.font: AVTheme.regularFont(16.0)])
        item.size = self.computContentSize(attributeText: attr, maxWidth: maxWidth)
    }
}
