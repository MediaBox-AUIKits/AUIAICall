//
//  AUIAICallSysAgentContentView.swift
//  ARTCAICallKit
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallSysAgentContentView: UIScrollView, UIScrollViewDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        var left: CGFloat = 0
        self.listView.forEach { view in
            view.av_left = left
            self.addSubview(view)
            left = view.av_right
        }
        
        self.contentSize = CGSize(width: left, height: self.av_height)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatImageView(bg: UIImage?, tag: Int) -> UIImageView {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.av_width, height: self.av_height))
        view.contentMode = .scaleAspectFit
        view.image = bg
        view.backgroundColor = UIColor.clear
        view.tag = tag
        return view
    }
    
    open lazy var outboundCallView: AUIAICallOutboundCallContentView = {
        let view = AUIAICallOutboundCallContentView(frame: CGRect(x: 0, y: 0, width: self.av_width, height: self.av_height))
        view.tag = OutboundCallTypeIndex
        return view
    }()
    
    open lazy var listView: [UIView] = {
        var list: [UIView] = [
            self.creatImageView(bg: AUIAIMainBundle.getCommonImage("bg_main_voice"), tag: VoiceAgentTypeIndex),
            self.creatImageView(bg: AUIAIMainBundle.getCommonImage("bg_main_avatar"), tag: AvatarAgentTypeIndex),
            self.creatImageView(bg: AUIAIMainBundle.getCommonImage("bg_main_vision"), tag: VisionAgentTypeIndex),
            self.creatImageView(bg: AUIAIMainBundle.getCommonImage("bg_main_chat"), tag: ChatAgentTypeIndex),
            self.creatImageView(bg: AUIAIMainBundle.getCommonImage("bg_main_video"), tag: VideoAgentTypeIndex),
        ]
        if AUIAICallAgentConfig.shared.enableOutboundCall {
            list.append(self.outboundCallView)
        }
        return list
    }()
    
    open var pageChanged: ((_ agentIndex: Int) -> Void)? = nil
    
    open func scrollToAgent(_ agentIndex: Int) {
        for i in 0..<self.listView.count {
            if self.listView[i].tag == agentIndex {
                let pageWidth = self.frame.size.width
                let targetOffset = CGPoint(x: pageWidth * CGFloat(i), y: 0)
                self.setContentOffset(targetOffset, animated: true)
                return
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        if currentPage < self.listView.count {
            self.pageChanged?(self.listView[currentPage].tag)
        }
    }
}
