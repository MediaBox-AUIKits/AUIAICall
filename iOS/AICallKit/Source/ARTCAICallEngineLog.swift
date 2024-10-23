//
//  ARTCAICallEngineLog.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit

@objcMembers open class ARTCAICallEngineLog: NSObject {
    
#if DEBUG
    public static var shared: ARTCAICallEngineLog? = ARTCAICallEngineLog()
#else
    public static var shared: ARTCAICallEngineLog? = nil
#endif
    
    public static func WriteLog(_ items: Any...) {
        self.shared?.writeLog(items)
    }
    
    private override init() {
        super.init()
    }
        
    public func writeLog(_ items: Any...) {
        let timestamp = self.getCurrentTimeString()
        let itemsWithTimestamp = ["[\(timestamp)]"] + items.map { "\($0)" }
        let message = itemsWithTimestamp.joined(separator: " ")
        debugPrint(message)
        
        self.logQueue.async {
            if let logFileHandle = self.logFileHandle {
                logFileHandle.seekToEndOfFile() // 移动到文件末尾
                if let data = message.appending("\n").data(using: .utf8) {
                    logFileHandle.write(data) // 写入数据
                }
            }
        }
    }
    
    public func startLog(fileName: String) {
        self.stopLog()
        self.logQueue.async {
            let fileManager = FileManager.default
            let fileDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("aicall_log")
            if !fileManager.fileExists(atPath: fileDir.path) {
                do {
                    try fileManager.createDirectory(at: fileDir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return
                }
            }
            let fileURL = fileDir.appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: fileURL.path) {
                let text = "log start\n"
                try? text.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            // 以追加模式打开文件
            self.logFileHandle = try? FileHandle(forUpdating: fileURL)
        }
    }
    
    public func stopLog() {
        self.logQueue.async {
            if let logFileHandle = self.logFileHandle {
                let text = "log end\n"
                logFileHandle.seekToEndOfFile() // 移动到文件末尾
                if let data = text.data(using: .utf8) {
                    logFileHandle.write(data) // 写入数据
                }
                logFileHandle.closeFile()
                self.logFileHandle = nil
            }
        }
    }
    
    // 创建一个串行队列
    private let logQueue = DispatchQueue(label: "com.artcaicallengine.logqueue")
    
    private var logFileHandle: FileHandle? = nil
    
    // 获取当前时间并格式化为字符串
    private func getCurrentTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
}
