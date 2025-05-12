//
//  AUIAICallLoadingAnimator.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallAgentAnimator: UIView {
    
    
    open func updateState(newState: AUIAICallState) {
    }
    
    open func updateAgentAnimator(state: ARTCAICallAgentState) {
        
    }
    
    open func onAgentInterrupted() {
        
    }
    
    open func updateAgentAnimator(emotion: String) {
        
    }
}


@objcMembers open class AUIAICallAgentSimpleAnimator: AUIAICallAgentAnimator {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.callStateAni)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.callStateAni.frame = self.bounds
    }
    
    open override func updateState(newState: AUIAICallState) {
        self.callStateAni.updateState(newState: newState)
    }
    
    open lazy var callStateAni: AUIAICallStateAnimation = {
        let view = AUIAICallStateAnimation()
        return view
    }()
}
