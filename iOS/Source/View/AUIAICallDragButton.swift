//
//  AUIAICallDragButton.swift
//  AUIAICall
//
//  Created by Bingo on 2025/03/20.
//

import UIKit
import AUIFoundation


open class AUIAICallDragButton: UIButton {

    public let boundsExtension: CGFloat = 0.0
    open var touchDownBlock: ((AUIAICallDragButton) -> Void)? = nil
    open var touchUpBlock: ((AUIAICallDragButton, Bool) -> Void)? = nil
    open var touchDragBlock: ((AUIAICallDragButton, Bool) -> Void)? = nil

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        let outerBounds = self.bounds.insetBy(dx: -1 * self.boundsExtension, dy: -1 * self.boundsExtension)
        let currentLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)

        let touchOutside = !outerBounds.contains(currentLocation)
        if touchOutside {
            let previousTouchInside = outerBounds.contains(previousLocation)
            if previousTouchInside {
                self.touchDragBlock?(self, false)
                self.sendActions(for: .touchDragExit)
            }
            else {
                self.sendActions(for: .touchDragOutside)
            }
        }
        else {
            let previousTouchOutside = !outerBounds.contains(previousLocation)
            if previousTouchOutside {
                self.touchDragBlock?(self, true)
                self.sendActions(for: .touchDragEnter)
            }
            else {
                self.sendActions(for: .touchDragInside)
            }
        }

        return true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touchDownBlock?(self)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHighlighted = false
        let touch = touches.first!
        let outerBounds = self.bounds.insetBy(dx:-1 * self.boundsExtension, dy: -1 * self.boundsExtension)
        let currentLocation = touch.location(in: self)
        let touchInside: Bool = outerBounds.contains(currentLocation)
        if touchInside {
            self.touchUpBlock?(self, true)
            self.sendActions(for: .touchUpInside)
            return
        }
        self.touchUpBlock?(self, false)
        self.sendActions(for: .touchUpOutside)
    }
}
