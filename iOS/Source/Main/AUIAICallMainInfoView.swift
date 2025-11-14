//
//  AUIAICallMainInfoView.swift
//  ARTCAICallKit
//
//  Created by Bingo on 2025/9/10.
//

import UIKit
import AUIFoundation



@objcMembers open class AUIAICallMainInfoView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.currTabItem = AUIAICallMianTabItem.tabInfoList.first!

        self.addSubview(self.titleImageView)
        
        self.addSubview(self.tabTitleView)
        self.addSubview(self.tabPositionView)
        self.addSubview(self.tabInfoView)
        
        self.addSubview(self.contentShowView)
        self.updateTabLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var titleImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: self.av_width - 313 + 20, y: 16, width: 313, height: 30))
        view.image = AUIAIMainBundle.getTemplateImage("img_agent")
        view.tintColor = AUIAIMainBundle.color_icon
        view.contentMode = .topLeft
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }()
    
    open lazy var contentShowView: AUIAICallMainShowView = {
        let view = AUIAICallMainShowView(frame: CGRect(x: 0, y: self.titleImageView.av_bottom, width: self.av_width, height: self.tabTitleView.av_top - self.titleImageView.av_bottom))
        return view
    }()
    
    open lazy var tabTitleView: UILabel = {
        let view = UILabel(frame: CGRect(x: 25, y: self.av_height - 98 - 16, width: self.av_width - 50, height: 16))
        view.textColor = AUIAIMainBundle.color_text
        view.font = AVTheme.regularFont(16)
        return view
    }()
    
    open lazy var tabPositionView: UILabel = {
        let view = UILabel(frame: CGRect(x: self.av_width - 25 - 120, y: self.tabTitleView.av_centerY - 8, width: 120, height: 16))
        view.textAlignment = .right
        view.textColor = AUIAIMainBundle.color_text
        view.font = AVTheme.regularFont(14)
        return view
    }()
    
    open lazy var tabInfoView: UILabel = {
        let view = UILabel(frame: CGRect(x: 25, y: self.tabTitleView.av_bottom + 19, width: self.av_width - 50, height: 54))
        view.textColor = AUIAIMainBundle.color_text
        view.font = AVTheme.regularFont(14)
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    open var currTabItem: AUIAICallMianTabItem = AUIAICallMianTabItem() {
        didSet {
            self.updateTabLayout()
        }
    }
    
    func updateTabLayout() {
        
        self.tabTitleView.text = self.currTabItem.title
        let array = AUIAICallMianTabItem.tabInfoList
        let index = array.firstIndex(of: self.currTabItem) ?? 0
        self.tabPositionView.text = String.init(format: "[. %d_%d]", index + 1, array.count)
        
        self.tabInfoView.text = self.currTabItem.info
        let size = self.tabInfoView.sizeThatFits(CGSize(width: self.av_width - 160, height: 54.0))
        self.tabInfoView.av_size = CGSize(width: size.width, height: min(54.0, size.height))
        self.tabInfoView.av_right = self.av_width - 25
    }
}

@objcMembers open class AUIAICallMainShowView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageListView.forEach { view in
            self.addSubview(view)
            self.updateProgress(tag: view.tag, progress: 2.0)
            return
        }

        self.addSubview(self.scrollView)
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentSize.width / 2.0 - self.scrollView.av_width, y: 0.0)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var imageListView: [UIView] = {
        var list: [UIView] = []
        let tabInfoList = AUIAICallMianTabItem.tabInfoList
        for i in 0..<tabInfoList.count {
            let tabInfo = tabInfoList[tabInfoList.count - 1 - i]
            let view = self.creatImageView(index: i)
            view.image = AUIAIMainBundle.getCommonImage("ic_show_\(tabInfo.index.rawValue)")
            view.tag = Int(tabInfo.index.rawValue)
            list.append(view)
        }
        return list
    }()
    
    
    func creatImageView(index: Int) -> UIImageView {
        let view = UIImageView(frame: self.getImageViewFrame)
        view.contentMode = .scaleAspectFill
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .bottomLeft],
                                cornerRadii: CGSize(width: 8, height: 8))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
        return view
    }
    
    var getImageViewFrame: CGRect {
        get {
            let scale = 300.0 / 390.0
            let width = self.av_width * scale
            let size = CGSize(width: width, height: width / 302.0 * 339.0)
            let y = (self.av_height - size.height) / 2.0
            let x = self.av_width - width
            return CGRect(x: x, y: y, width: size.width, height: size.height)
        }
    }
    
    open lazy var scrollView: AUIAICallMainScrollView = {
        let view = AUIAICallMainScrollView(frame: self.bounds)
        view.tabViewDidScroll = { [weak self] view, zIndex in
            guard let self = self else {
                return
            }
            let cp = view.frame.origin
            let tp = self.scrollView.convert(view.frame.origin, to: self)
            let showWidth = self.av_width
            //debugPrint("【\(view.tag)】scrollViewDidScroll: \(cp) to \(tp) for showWidth: \(showWidth)")
            var progress = 1.0
            if tp.x <= -showWidth * 2 {
                progress = 0.0
            }
            else if tp.x < 0 {
                progress = 1.0 + tp.x / (showWidth * 2.0)
            }
            else if tp.x >= showWidth {
                progress = 2.0
            }
            else if tp.x > 0 {
                progress = 1.0 + tp.x / (showWidth * 1.0)
            }
            else {
                progress = 1.0
            }
            //debugPrint("【\(view.tag)】ShowViewScrollProgress: \(progress)")
            self.updateProgress(tag: view.tag, progress: progress)
        }
        return view
    }()
    
    
    // pogress=[0,2]  1表示当前展示，2表示右边划走隐藏， 0表示左边缩小展示
    open func updateProgress(tag: Int, progress: CGFloat) {
        guard let first = self.imageListView.first (where: { view in
            return view.tag == tag
        }) else {
            return
        }
        let normalFrame = self.getImageViewFrame
        let pageWidth = self.bounds.width
        let width = normalFrame.width
        let centerX = normalFrame.midX
        let midWidth = 200.0 / 390.0 * pageWidth
        let minScale = midWidth / width
        let minTranslate = 24 + midWidth / 2.0 - centerX
        let maxScale = 1.0
        let maxTranslate = width
        
        var curScale = 1.0
        var curTrans = 0.0
        if progress <= 0 {
            // (-∞, 0]
            curScale = minScale
            curTrans = minTranslate
            
        }
        else if progress < 1.0 {
            // (0, 1)
            let factor = progress
            curScale = minScale + (maxScale - minScale) * factor
            curTrans = minTranslate * (1.0 - factor)
        }
        else if progress >= 2.0 {
            // [2, +∞]
            curScale = maxScale
            curTrans = maxTranslate
        }
        else if progress > 1.0 {
            // (1, 2)
            let factor = progress - 1.0
            curScale = maxScale
            curTrans = maxTranslate * factor
        }
        else {
            // [1, 1]
            curScale = 1.0
            curTrans = 0.0
        }
        var transform = CGAffineTransform.identity
        transform = CGAffineTransform(translationX: curTrans, y: 0)
        transform = transform.scaledBy(x: curScale, y: curScale)
        first.transform = transform
        self.bringSubviewToFront(first)
    }
}

@objcMembers open class AUIAICallMainScrollView: UIScrollView, UIScrollViewDelegate {
    
    
    public override init(frame: CGRect) {
        
        var list = [AUIAICallMianTabItem]()
        let tabInfoList = AUIAICallMianTabItem.tabInfoList
        for i in 0..<tabInfoList.count {
            list.insert(tabInfoList[i], at: 0)
        }
        self.curTabInfoList = list
        
        super.init(frame: frame)
        
        self.tabViewList.forEach { view in
            self.addSubview(view)
        }
        
        self.contentSize = CGSize(width: CGFloat(self.allCount) * self.av_width, height: self.av_height)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
//        self.contentOffset = CGPoint(x: self.contentSize.width / 2.0, y: 0.0)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatView(index: Int) -> UIImageView {
        let view = UIImageView(frame: self.bounds)
        //let colors: [UIColor] = [.red, .green, .yellow, .blue, .purple, .orange, .brown, .cyan]
        //view.backgroundColor = colors[index % colors.count].withAlphaComponent(0.2)
        return view
    }
    
    let curTabInfoList: [AUIAICallMianTabItem]
    
    var countForOneCircle: Int {
        return self.curTabInfoList.count
    }
    
    var circles: Int {
        return 10
    }
    
    var allCount: Int {
        return self.countForOneCircle * self.circles
    }
    
    func getTag(col: Int) -> Int {
        let tabInfoList = self.curTabInfoList
        let index = col % self.countForOneCircle
        return Int(tabInfoList[index].index.rawValue)
    }
    
    open lazy var tabViewList: [UIView] = {
        var list: [UIView] = []
        let tabInfoList = self.curTabInfoList
        for i in 0..<tabInfoList.count {
            let view = self.creatView(index: i)
            view.tag = Int(tabInfoList[i].index.rawValue)
            list.append(view)
        }
        return list
    }()
    
    open var tabWillChanged: ((_ item: AUIAICallMianTabItem, _ posIndex: Int) -> Void)? = nil
    
    open func scroll(_ item: AUIAICallMianTabItem) {
        if let toIndex = self.curTabInfoList.firstIndex(of: item) {
            let pageWidth = self.frame.size.width
            let currentPage = Int(self.contentOffset.x / pageWidth)
            let currentIndex = currentPage % self.countForOneCircle
            var toPage = currentPage + toIndex - currentIndex
            if toPage < 0 || toPage > self.allCount {
                // 找中间附近的page
                toPage = self.circles / 2 + toIndex
            }
            let targetOffset = CGPoint(x: pageWidth * CGFloat(toPage), y: 0)
            self.setContentOffset(targetOffset, animated: true)
        }
    }
    
    open var tabViewDidScroll: ((_ view: UIView, _ zIndex: Int) -> Void)? = nil
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = self.frame.size.width
        let currentPage = Int(self.contentOffset.x / pageWidth)
        var startPage = currentPage - (self.countForOneCircle + 1) / 2
        if startPage < 0 {
            startPage = 0
        }
        
        var left = CGFloat(startPage) * pageWidth
        let startIndex = startPage % self.countForOneCircle
        //debugPrint("scrollViewDidScroll: \(startIndex)")
        for i in startIndex..<(startIndex + self.countForOneCircle) {
            var view: UIView!
            if i >= self.countForOneCircle {
                view = self.tabViewList[i - self.countForOneCircle]
            }
            else {
                view = self.tabViewList[i]
            }
            view.av_left = left
            left = view.av_right
            self.tabViewDidScroll?(view, i)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = self.frame.size.width
        let currentPage = Int(self.contentOffset.x / pageWidth)
        let currentIndex = currentPage % self.countForOneCircle
        self.tabWillChanged?(self.curTabInfoList[currentIndex], currentIndex)
    }
    
}

