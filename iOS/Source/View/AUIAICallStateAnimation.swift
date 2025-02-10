//
//  AUIAICallStateAnimation.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallStateAnimation: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.loadingAniView)
        self.addSubview(self.errorView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.loadingAniView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
        self.errorView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
    }
    
    open lazy var loadingAniView: AUIAICallLoadingAnimator = {
        let view = AUIAICallLoadingAnimator(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.isHidden = true
        return view
    }()
    
    open lazy var errorView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.image = AUIAICallBundle.getCommonImage("ic_error")
        view.contentMode = .center
        view.isHidden = true
        return view
    }()
    
    
    open func updateState(newState: AUIAICallState) {
        if self.state == newState {
            return
        }
        
        debugPrint("AUIAICallStateAnimation: updateState:\(newState)")
        self.state = newState
        self.loadingAniView.isHidden = !(self.state == .Connecting || self.state == .None)
        self.errorView.isHidden = self.state != .Error

        if self.isAni {
            self.start()
        }
    }
    
    open private(set) var state: AUIAICallState = .None
    
    open private(set) var isAni: Bool = false
    
    open func start() {
        self.stop()
        
        debugPrint("AUIAICallStateAnimation: start ani")
        self.isAni = true
        if self.loadingAniView.isHidden == false {
            self.loadingAniView.start()
        }
    }
    
    open func stop() {
        debugPrint("AUIAICallStateAnimation: stop ani")
        self.isAni = false
        
        self.loadingAniView.stop()
    }
    
}
