//
//  AUIAICallTheme.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallTheme: NSObject {
    
    public init(_ bundleName: String) {
        self.bundleName = bundleName
    }
    
    public let bundleName: String
    
    open func getImage(_ key: String?) -> UIImage? {
        guard let key = key else { return nil }
        return AVTheme.image(withNamed: key, withModule: self.bundleName)
    }
    
    open func getCommonImage(_ key: String?) -> UIImage? {
        guard let key = key else { return nil }
        return AVTheme.image(withCommonNamed: key, withModule: self.bundleName)
    }
    
    open func getString(_ key: String) -> String {
        return AVLocalization.string(withKey: key, withModule: self.bundleName)
    }
    
    open func getResourceFullPath(_ path: String) -> String {
        let final = Bundle.main.resourcePath
        if let final = final {
            return final + "/" + self.bundleName + ".bundle/" + path
        }
        return path
    }
    
    open var danger_strong: UIColor {
        return UIColor.av_color(withHexString: "F53F3FFF")
    }
    
    open var success_ultrastrong: UIColor {
        return UIColor.av_color(withHexString: "3BB346FF")
    }
    
    open var chat_bg: UIColor {
        return UIColor.av_color(withHexString: "3295FBFF")
    }
}

public let AUIAICallBundle = AUIAICallTheme("AUIAICall")
public let AUIAIChatBundle = AUIAICallTheme("AUIAIChat")


extension AVAlertController {
    /// Creates and returns a configured alert controller with an "OK" button and a completion handler.
    ///
    /// - Parameters:
    ///   - message: The message to display in the alert.
    ///   - viewController: The view controller that will present the alert.
    ///   - completion: A closure that is called when the "OK" button is tapped.
    ///
    /// - Returns: A configured `UIAlertController` instance.
    public static func aicall_show(message: String, on viewController: UIViewController, completion: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        AVTheme.updateRootViewControllerInterfaceStyle(alertController)

        let okAction = UIAlertAction(
            title: AVLocalization.string(withKey: "OK", withModule: "AUIFoundation"),
            style: .default
        ) { _ in
            completion()
        }
        
        alertController.addAction(okAction)

        // Present the alert controller
        viewController.present(alertController, animated: true, completion: nil)
    }
}
