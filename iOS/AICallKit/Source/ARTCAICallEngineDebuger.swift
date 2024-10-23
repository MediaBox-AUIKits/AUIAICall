//
//  ARTCAICallEngineDebuger.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit


// 开发者相关
@objcMembers open class ARTCAICallEngineDebuger: NSObject {
    
    /**
     * 是否开启Dump音频数据
     */
    public static var Debug_IsEnableDumpData: Bool = false
    
    /**
     * 是否开启运行数据实时输出
     */
    public static var Debug_IsEnableTipsData: Bool = false
    
    /**
     * 是否开启运行数据实时输出
     */
    public static var Debug_IsEnablePreRelease: Bool = false
    
    
    /**
     * 设置实时数据输出视图
     */
    public static var Debug_TipsView: UITextView? = nil

    /**
     * 是否开启扩展数据，开启的话，可以通过NotificationCenter添加“DebugExtentInfoUpdate”的监听
     */
    public static var Debug_IsEnableExtendData: Bool = false {
        didSet {
            if self.Debug_IsEnableExtendData == false {
                self.Debug_ExtendInfo.removeAll()
                NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
            }
        }
    }
    
    /**
     * 本地记录的扩展数据
     */
    public static var Debug_ExtendInfo: [String: String] = [:]
    
    /**
     * 更新扩展数据
     */
    public static func Debug_UpdateExtendInfo(key: String, value: Any) {
        if Debug_IsEnableExtendData == false {
            self.Debug_ExtendInfo.removeAll()
            return
        }
        
        var post = false
        if let value = value as? String {
            self.Debug_ExtendInfo.updateValue(value, forKey: key)
            post = true
        }
        else if let value = value as? [String: String] {
            self.Debug_ExtendInfo.merge(value)  { (_, new) in new }
            post = true
        }
        
        if post == true {
//            debugPrint("Debug Extent Info:\(self.Debug_ExtendInfo)")
            NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
        }
    }
    
    internal static func Debug_ClearTipsData() {
        self.Debug_TipsView?.text = nil
        self.Debug_ExtendInfo.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
    }
}
