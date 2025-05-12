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
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        let isAppActive = UIApplication.shared.applicationState == .active
        let isLoading = newState == .Connecting || newState == .None
        let isError = newState == .Error
        self.loadingAniView.isHidden = !isLoading
        self.errorView.isHidden = !isError
        
        if isLoading {
            if isAppActive && self.isStartAni == false {
                self.isStartAni = true
                self.loadingAniView.start()
            }
        }
        else {
            self.loadingAniView.stop()
            self.isStartAni = false
        }
    }
    
    @objc private func applicationWillResignActive() {
        self.loadingAniView.stop()
    }
    
    @objc private func applicationDidBecomeActive() {
        if self.isStartAni {
            self.loadingAniView.start()
        }
    }
    
    private var isStartAni: Bool = false
    
}
