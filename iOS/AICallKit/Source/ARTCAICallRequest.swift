//
//  AUIAICallAppServer.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit


@objcMembers open class ARTCAICallRequest: NSObject {

    public init(serverDomain: String) {
        self.serverDomain = serverDomain
    }
    
    open private(set) var serverDomain = ""
    
    open func willRequest(urlRequest: inout URLRequest) {
    }
    
    open func request(path: String, body: [AnyHashable: Any]?, completed: @escaping (_ response: URLResponse?, _ data: [AnyHashable: Any]?, _ error: NSError?) -> Void) -> Void {
        
        let urlString = "\(self.serverDomain)\(path)"
        let url = URL(string: urlString)
        guard let url = url else {
            completed(nil, nil, NSError.aicall_create(code: .InvalidParames, message: "path error"))
            return
        }
        
        debugPrint("ARTCAICallRequest url: \(url)")
        debugPrint("ARTCAICallRequest body: \(body?.aicall_jsonString ?? "nil")")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let clientTime = "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
        debugPrint(clientTime)
        urlRequest.setValue(clientTime, forHTTPHeaderField: "ct")
        urlRequest.httpMethod = "POST"
        self.willRequest(urlRequest: &urlRequest)
        if let body = body {
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            guard let bodyData = bodyData else {
                completed(nil, nil, NSError.aicall_create(code: .InvalidParames, message: "body error"))
                return
            }
            urlRequest.httpBody = bodyData
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession.init(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, rsp, error in
            DispatchQueue.main.async {
                if error != nil {
                    debugPrint("ARTCAICallRequest rsp failed: \(error!))")
                    completed(rsp, nil, error as? NSError)
                    return
                }
                
                if let httpRsp = rsp as? HTTPURLResponse {
                    debugPrint("ARTCAICallRequest rsp code: \(httpRsp.statusCode))")
                    var dict: [AnyHashable : Any]? = nil
                    if httpRsp.statusCode != 200 {
                        if let data = data {
                            debugPrint("ARTCAICallRequest rsp: \(String(data: data, encoding: .utf8) ?? "")")
                            let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            dict = obj as? [AnyHashable : Any]
                        }
                        completed(rsp, dict, NSError.aicall_create(code: httpRsp.statusCode, message: "network error"))
                        return
                    }
                }
                
                if let data = data {
                    debugPrint("ARTCAICallRequest rsp: \(String(data: data, encoding: .utf8) ?? "")")
                    let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let dict = obj as? [AnyHashable : Any]
                    let code = dict?["code"] as? Int
                    if code == 200 {
                        completed(rsp, dict, nil)
                    }
                    else {
                        completed(rsp, dict, NSError.aicall_create(code: code ?? Int(ARTCAICallErrorCode.UnknowError.rawValue), message: "unknown error"))
                    }
                    return
                }
                
                completed(rsp, nil, NSError.aicall_create(code: .UnknowError, message: "unknown error"))
            }
        }
        task.resume()
    }
}

let ARTCAICallShareServerDomain = "ShareServer域名"
extension ARTCAICallRequest {
    static let defaultRequest = ARTCAICallRequest(serverDomain: ARTCAICallShareServerDomain)
}
