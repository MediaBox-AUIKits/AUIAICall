//
//  AUIAICallVolumeBarAnimator.swift
//  AUIAICall
//
//  Created by Bingo on 2025/03/20.
//

import UIKit
import AUIFoundation


@objcMembers open class AUIAICallVolumeBarAnimator: UIView {
    
    public struct Params {
        var count: Int = 10
        var width: CGFloat = 4
        var margin: CGFloat = 6
        var minHeight: CGFloat = 6
        var maxHeight: CGFloat = 12
        var barColor: UIColor = .white
        var duration: CGFloat = 0.4
    }
    
    public init(frame: CGRect, params: Params) {
        self.param = params
        super.init(frame: frame)
        
        self.barViews.forEach { view in
            self.addSubview(view)
        }
        self.updateLayout()
    }
    
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, params: Params())
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let param: Params!
    
    private lazy var barViews: [UIView] = {
        var list = [UIView]()
        let count = self.param.count
        for i in 0..<count {
            let view = UIView()
            view.backgroundColor = self.param.barColor
            view.layer.cornerRadius = self.param.width / 2.0
            view.layer.masksToBounds = true
            list.append(view)
        }
        return list
    }()
    
    private func updateLayout() {
        
        let bar = Double(self.barViews.count)
        let bar_height = self.param.minHeight
        let bar_margin = self.param.margin
        let bar_midY = self.av_height / 2.0
        let bar_startX = (self.av_width - bar_height * bar - bar_margin * (bar - 1.0)) / 2.0
        
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            view.layer.cornerRadius = bar_height / 2.0
            view.frame = CGRect(x: bar_startX + Double(i) * (bar_height + bar_margin), y: bar_midY - bar_height / 2.0, width: bar_height, height: bar_height)
        }
    }
    
    private var isAni: Bool = false
    
    private func growAni(view: UIView) {
        let bar_height = self.param.minHeight
        let max_height = self.param.maxHeight
        let bar_bottom = self.av_height / 2.0 + bar_height / 2.0
        let growH = Double(arc4random() % UInt32(max_height - bar_height))
        let time = (Double(arc4random() % 100) / 1000.0 + self.param.duration) / 2.0
        UIView.animate(withDuration: time, delay: 0.0, options: [.curveEaseOut], animations: {
            // 改变高度的动画
            view.av_height = growH + bar_height
            view.av_bottom = bar_bottom
        }) { finished in
            UIView.animate(withDuration: time, delay: 0.0, options: [.curveEaseOut]) {
                view.av_height = bar_height
                view.av_bottom = bar_bottom
            } completion: { finished in
                if self.isAni {
                    self.growAni(view: view)
                }
            }
        }
    }
    
    func start() {
        self.isAni = true
        self.barViews.forEach { view in
            self.growAni(view: view)
        }
        return
    }
    
    func stop() {
        self.isAni = false
        self.barViews.forEach { view in
            view.layer.removeAllAnimations()
        }
    }
    
}
