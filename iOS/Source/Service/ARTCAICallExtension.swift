//
//  ARTCAICallExtension.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

extension Dictionary {
    
    public var aicall_jsonString: String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as NSDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let string = String(data: stringData, encoding: String.Encoding.utf8){
                return string
            }
        } catch _ {
            
        }
        return "{}"
    }
}

extension NSError {
    public static func aicall_create(code: Int, message: String?) -> NSError {
        let error = NSError(domain: "aui.aicall", code: code, userInfo: [NSLocalizedDescriptionKey:message ?? "unknown"])
        return error
    }
}
