//
//  ARTCAICallEngineLog.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit

@objcMembers open class ARTCAICallEngineLog: NSObject {
    
    
    public enum LogType: Int32 {
        case Debug = 0
        case Info
        case Error
        case None
    }
    
    
    public static func WriteLog(_ items: Any...) {
        self.shared.writeLog(logType: .Info, items: items)
    }
    
    public static func WriteLog(_ logType: LogType, _ items: Any...) {
        self.shared.writeLog(logType: logType, items: items)
    }
    
    public static func StartLog(fileName: String) {
        self.shared.startLog(fileName: fileName)
    }
    
    public static func StopLog() {
        self.shared.stopLog()
    }
    
    public static var EnableLogType: LogType = .None
    
    public static var PrintLogBlock: ((_ logType: LogType, _ logString: String) -> Void)? = nil
    
    private static let shared: ARTCAICallEngineLog = ARTCAICallEngineLog()

    private override init() {
        super.init()
    }

    private func writeLog(logType: LogType, items: Any...) {
        let timestamp = self.getCurrentTimeString()
        let itemsWithTimestamp = ["[\(timestamp)]\(self.getLogTypeString(logType: logType))"] + items.map { "\($0)" }
        let message = itemsWithTimestamp.joined(separator: " ")
        ARTCAICallEngineLog.PrintLogBlock?(logType, message)
        
        if logType.rawValue < ARTCAICallEngineLog.EnableLogType.rawValue {
            return
        }
        self.logQueue?.async {
            if let logFileHandle = self.logFileHandle {
                logFileHandle.seekToEndOfFile() // 移动到文件末尾
                if let data = message.appending("\n").data(using: .utf8) {
                    logFileHandle.write(data) // 写入数据
                }
            }
        }
    }
    
    private func startLog(fileName: String) {
        if ARTCAICallEngineLog.EnableLogType == .None {
            return
        }
        self.stopLog()
        if self.logQueue == nil {
            self.logQueue = DispatchQueue(label: "com.artcaicallengine.logqueue")
        }
        self.logQueue?.async {
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
    
    private func stopLog() {
        self.logQueue?.async {
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
        self.logQueue = nil
    }
    
    // 串行队列
    private var logQueue: DispatchQueue? = nil
    private var logFileHandle: FileHandle? = nil
    
    // 获取当前时间并格式化为字符串
    private func getCurrentTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
    
    private func getLogTypeString(logType: LogType) -> String {
        if logType == .Debug {
            return "[DEBUG]"
        }
        if logType == .Info {
            return "[INFO]"
        }
        if logType == .Error {
            return "[ERROR]"
        }
        return ""
    }
}
