//
//  AUIAICallTheme.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallTheme: NSObject {
    
    public init(_ bundleName: String, _ colorBundleName: String = "AUIAICall") {
        self.bundleName = bundleName
        self.colorBundleName = colorBundleName
    }
    
    public let bundleName: String
    public let colorBundleName: String
    
    open func getColor(_ key: String) -> UIColor {
        return AVTheme.color(withNamed: key, withModule: self.colorBundleName)
    }
    
    open func getImage(_ key: String?) -> UIImage? {
        guard let key = key else { return nil }
        return AVTheme.image(withNamed: key, withModule: self.bundleName)
    }
    
    open func getTemplateImage(_ imageKey: String) -> UIImage? {
        guard let originalImage = self.getCommonImage(imageKey) else {
            return nil
        }
        let templateImage = originalImage.withRenderingMode(.alwaysTemplate)
        return templateImage
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

// AI实时互动Primary色表
extension AUIAICallTheme {
    
    open var color_primary_bg: UIColor {
        return self.getColor("color_primary_bg")
    }
    
    open var color_primary_bg_hover: UIColor {
        return self.getColor("color_primary_bg_hover")
    }
    
    open var color_primary_border: UIColor {
        return self.getColor("color_primary_border")
    }
    
    open var color_primary_border_hover: UIColor {
        return self.getColor("color_primary_border_hover")
    }
    
    open var color_primary_hover: UIColor {
        return self.getColor("color_primary_hover")
    }
    
    open var color_primary: UIColor {
        return self.getColor("color_primary")
    }
    
    open var color_primary_active: UIColor {
        return self.getColor("color_primary_active")
    }
    
    open var color_primary_text_hover: UIColor {
        return self.getColor("color_primary_text_hover")
    }
    
    open var color_primary_text: UIColor {
        return self.getColor("color_primary_text")
    }
    
    open var color_primary_text_active: UIColor {
        return self.getColor("color_primary_text_active")
    }
}



// AI实时互动Text色表
extension AUIAICallTheme {
    
    open var color_text: UIColor {
        return self.getColor("color_text")
    }
    
    open var color_text_secondary: UIColor {
        return self.getColor("color_text_secondary")
    }
    
    open var color_text_tertiary: UIColor {
        return self.getColor("color_text_tertiary")
    }
    
    open var color_text_disabled: UIColor {
        return self.getColor("color_text_disabled")
    }
    
    open var color_text_Inverse: UIColor {
        return self.getColor("color_text_Inverse")
    }
    
    open var color_text_identical: UIColor {
        return self.getColor("color_text_identical")
    }
    
    open var color_text_selection: UIColor {
        return self.getColor("color_text_selection")
    }
}


// AI实时互动Link色表
extension AUIAICallTheme {
    
    open var color_link: UIColor {
        return self.getColor("color_link")
    }
    
    open var color_link_hover: UIColor {
        return self.getColor("color_link_hover")
    }
    
    open var color_link_selection: UIColor {
        return self.getColor("color_link_selection")
    }
    
    open var color_link_active: UIColor {
        return self.getColor("color_link_active")
    }
}


// AI实时互动Icon色表
extension AUIAICallTheme {
    
    open var color_icon: UIColor {
        return self.getColor("color_icon")
    }
    
    open var color_icon_secondary: UIColor {
        return self.getColor("color_icon_secondary")
    }
    
    open var color_icon_tertiary: UIColor {
        return self.getColor("color_icon_tertiary")
    }
    
    open var color_icon_disabled: UIColor {
        return self.getColor("color_icon_disabled")
    }
    
    open var color_icon_Inverse: UIColor {
        return self.getColor("color_icon_Inverse")
    }
    
    open var color_icon_identical: UIColor {
        return self.getColor("color_icon_identical")
    }
    
    open var color_icon_hover: UIColor {
        return self.getColor("color_icon_hover")
    }
    
    open var color_icon_selection: UIColor {
        return self.getColor("color_icon_selection")
    }
}



// AI实时互动Border色表
extension AUIAICallTheme {
    
    open var color_border: UIColor {
        return self.getColor("color_border")
    }
    
    open var color_border_secondary: UIColor {
        return self.getColor("color_border_secondary")
    }
    
    open var color_border_tertiary: UIColor {
        return self.getColor("color_border_tertiary")
    }
    
    open var color_border_identical: UIColor {
        return self.getColor("color_border_identical")
    }
    
    open var color_border_selection: UIColor {
        return self.getColor("color_border_selection")
    }
}


// AI实时互动Background&Foreground色表
extension AUIAICallTheme {
    
    open var color_bg: UIColor {
        return self.getColor("color_bg")
    }
    
    open var color_bg_elevated: UIColor {
        return self.getColor("color_bg_elevated")
    }
    
    open var color_bg_mask: UIColor {
        return self.getColor("color_bg_mask")
    }
    
    open var color_fill: UIColor {
        return self.getColor("color_fill")
    }
    
    open var color_fill_secondary: UIColor {
        return self.getColor("color_fill_secondary")
    }
    
    open var color_fill_tertiary: UIColor {
        return self.getColor("color_fill_tertiary")
    }
    
    open var color_fill_quaternary: UIColor {
        return self.getColor("color_fill_quaternary")
    }
    
    open var color_fill_disabled: UIColor {
        return self.getColor("color_fill_disabled")
    }
    
    open var color_fill_primary: UIColor {
        return self.getColor("color_fill_primary")
    }
    
    open var color_fill_toast_identical: UIColor {
        return self.getColor("color_fill_toast_identical")
    }
    
    open var color_fill_switch_identical: UIColor {
        return self.getColor("color_fill_switch_identical")
    }
    
    open var color_fill_selection: UIColor {
        return self.getColor("color_fill_selection")
    }
}


// AI实时互动Success色表
extension AUIAICallTheme {
    
    open var color_success: UIColor {
        return self.getColor("color_success")
    }
    
    open var color_success_bg: UIColor {
        return self.getColor("color_success_bg")
    }
    
    open var color_success_bg_hover: UIColor {
        return self.getColor("color_success_bg_hover")
    }
    
    open var color_success_border: UIColor {
        return self.getColor("color_success_border")
    }
    
    open var color_success_border_hover: UIColor {
        return self.getColor("color_success_border_hover")
    }
    
    open var color_success_base: UIColor {
        return self.getColor("color_success_base")
    }
    
    open var color_success_active: UIColor {
        return self.getColor("color_success_active")
    }
    
    open var color_success_text_hover: UIColor {
        return self.getColor("color_success_text_hover")
    }
    
    open var color_success_text: UIColor {
        return self.getColor("color_success_text")
    }
    
    open var color_success_text_active: UIColor {
        return self.getColor("color_success_text_active")
    }
}


// AI实时互动Warning色表
extension AUIAICallTheme {
    
    open var color_warning: UIColor {
        return self.getColor("color_warning")
    }
    
    open var color_warning_bg: UIColor {
        return self.getColor("color_warning_bg")
    }
    
    open var color_warning_bg_hover: UIColor {
        return self.getColor("color_warning_bg_hover")
    }
    
    open var color_warning_border: UIColor {
        return self.getColor("color_warning_border")
    }
    
    open var color_warning_border_hover: UIColor {
        return self.getColor("color_warning_border_hover")
    }
    
    open var color_warning_hover: UIColor {
        return self.getColor("color_warning_hover")
    }
    
    open var color_warning_base: UIColor {
        return self.getColor("color_warning_base")
    }
    
    open var color_warning_active: UIColor {
        return self.getColor("color_warning_active")
    }
    
    open var color_warning_text_hover: UIColor {
        return self.getColor("color_warning_text_hover")
    }
    
    open var color_warning_text: UIColor {
        return self.getColor("color_warning_text")
    }
    
    open var color_warning_text_active: UIColor {
        return self.getColor("color_warning_text_active")
    }
}


// AI实时互动Info色表
extension AUIAICallTheme {
    
    open var color_info_bg: UIColor {
        return self.getColor("color_info_bg")
    }
    
    open var color_info_bg_hover: UIColor {
        return self.getColor("color_info_bg_hover")
    }
    
    open var color_info_border: UIColor {
        return self.getColor("color_info_border")
    }
    
    open var color_info_border_hover: UIColor {
        return self.getColor("color_info_border_hover")
    }
    
    open var color_info_hover: UIColor {
        return self.getColor("color_info_hover")
    }
    
    open var color_info_base: UIColor {
        return self.getColor("color_info_base")
    }
    
    open var color_info_active: UIColor {
        return self.getColor("color_info_active")
    }
    
    open var color_info_text_hover: UIColor {
        return self.getColor("color_info_text_hover")
    }
    
    open var color_info_text: UIColor {
        return self.getColor("color_info_text")
    }
    
    open var color_info_text_active: UIColor {
        return self.getColor("color_info_text_active")
    }
}



// AI实时互动Error色表
extension AUIAICallTheme {
    
    open var color_error: UIColor {
        return self.getColor("color_error")
    }
    
    open var color_error_bg: UIColor {
        return self.getColor("color_error_bg")
    }
    
    open var color_error_bg_hover: UIColor {
        return self.getColor("color_error_bg_hover")
    }
    
    open var color_error_border: UIColor {
        return self.getColor("color_error_border")
    }
    
    open var color_error_border_hover: UIColor {
        return self.getColor("color_error_border_hover")
    }
    
    open var color_error_hover: UIColor {
        return self.getColor("color_error_hover")
    }
    
    open var color_error_base: UIColor {
        return self.getColor("color_error_base")
    }
    
    open var color_error_active: UIColor {
        return self.getColor("color_error_active")
    }
    
    open var color_error_text_hover: UIColor {
        return self.getColor("color_error_text_hover")
    }
    
    open var color_error_text: UIColor {
        return self.getColor("color_error_text")
    }
    
    open var color_error_text_active: UIColor {
        return self.getColor("color_error_text_active")
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

extension UIView {
    
    @discardableResult
    public func aicall_showToast(_ text: String) -> AVToastView {
        let toastView = AVToastView()
        toastView.backgroundColor = AUIAICallBundle.color_fill_toast_identical
        toastView.layer.cornerRadius = 4
        toastView.layer.borderWidth = 1
        toastView.layer.borderColor = AUIAICallBundle.color_border_identical.cgColor
        toastView.toastLabel.font = AVTheme.regularFont(12)
        toastView.toastLabel.textColor = AUIAICallBundle.color_text_identical
        toastView.show(text, view: self, position: .mid)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            toastView.removeFromSuperview()
        }
        return toastView
    }
    
    public func aicall_showProgressHud(_ text: String) -> AVProgressHUD {
        let hud = AVProgressHUD.showAdded(to: self, animated: true)
        hud.layer.cornerRadius = 4
        hud.layer.borderWidth = 1
        hud.layer.borderColor = AUIAICallBundle.color_border_identical.cgColor
        hud.label.font = AVTheme.regularFont(12)
        hud.label.textColor = AUIAICallBundle.color_text_identical
        
        hud.iconType = .loading
        hud.labelText = text
        return hud
    }
}
