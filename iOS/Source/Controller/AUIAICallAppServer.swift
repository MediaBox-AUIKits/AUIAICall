//
//  AUIAICallAppServer.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

public let AICallServerDomain = "你的AppServer线上域名"
public let AICallServerDomainPre = "你的AppServer预发域名"

@objcMembers public class AUIAICallAppServer: NSObject {

    public init(serverDomain: String = AUIAICallAppServer.serverDomain) {
        self.serverDomain = serverDomain
    }
    
    public private(set) var serverDomain = AICallServerDomain
    public func request(path: String, body: [AnyHashable: Any]?, completed: @escaping (_ response: URLResponse?, _ data: [AnyHashable: Any]?, _ error: Error?) -> Void) -> Void {
        
        if !AUIAICallAppServer.serverAuthValid() {
            completed(nil, nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
            return
        }
        
        let urlString = "\(self.serverDomain)\(path)"
        let url = URL(string: urlString)
        guard let url = url else {
            completed(nil, nil, NSError(domain: "auicall", code: -1, userInfo: [NSLocalizedDescriptionKey: "path error"]))
            return
        }
        
        debugPrint("AUIAICallAppServer url: \(url)")
        debugPrint("AUIAICallAppServer body: \(body?.aicall_jsonString ?? "nil")")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let clientTime = "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
        debugPrint(clientTime)
        urlRequest.setValue(clientTime, forHTTPHeaderField: "ct")
        if let serverAuth = AUIAICallAppServer.serverAuth {
            urlRequest.setValue(serverAuth, forHTTPHeaderField: "Authorization")
            debugPrint("AUIAICallAppServer serverAuth: \(serverAuth)")
        }
        urlRequest.httpMethod = "POST"
        if let body = body {
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            guard let bodyData = bodyData else {
                completed(nil, nil, NSError(domain: "auicall", code: -1, userInfo: [NSLocalizedDescriptionKey: "body error"]))
                return
            }
            urlRequest.httpBody = bodyData
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession.init(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, rsp, error in
            DispatchQueue.main.async {
                if error != nil {
                    completed(rsp, nil, error)
                    return
                }
                
                if let httpRsp = rsp as? HTTPURLResponse {
                    if httpRsp.statusCode != 200 {
                        completed(rsp, nil, NSError(domain: "auiaicall", code: httpRsp.statusCode, userInfo: [NSLocalizedDescriptionKey: "network error"]))
                        return
                    }
                }
                
                if let data = data {
                    debugPrint("AUIAICallAppServer rsp: \(String(data: data, encoding: .utf8) ?? "")")
                    let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let dict = obj as? [AnyHashable : Any]
                    let code = dict?["code"] as? Int
                    if code == 200 {
                        completed(rsp, dict, nil)
                    }
                    else {
                        completed(rsp, nil, NSError(domain: "auiaicall", code: code ?? -1, userInfo: [NSLocalizedDescriptionKey: (dict?["code"] as? String) ?? "network error"]))
                    }
                    return
                }
                
                
                
                completed(rsp, nil, NSError(domain: "auiaicall", code: -1, userInfo: [NSLocalizedDescriptionKey: "network error"]))
            }
        }
        task.resume()
    }
}

extension AUIAICallAppServer {
    
    public static var serverDomain = AICallServerDomain
    public static var disableServerAuth: Bool = true
    public static var serverAuth: String? = ""
    public static func serverAuthValid() -> Bool {
        return self.disableServerAuth || (self.serverAuth != nil && !(self.serverAuth!.isEmpty))
    }
}
