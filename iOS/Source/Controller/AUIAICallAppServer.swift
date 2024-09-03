//
//  AUIAICallAppServer.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

public let AICallServerDomain = "你的AppServer域名"
//public let AICallServerDomain = "你的AppServer域名"

@objcMembers public class AUIAICallAppServer: NSObject {

    public init(serverDomain: String = AICallServerDomain, serverAuth: String? = nil) {
        self.serverDomain = serverDomain
        self.serverAuth = serverAuth
    }
    
    public private(set) var serverDomain = AICallServerDomain
    public private(set) var serverAuth: String? = ""
    public func request(path: String, body: [AnyHashable: Any]?, completed: @escaping (_ response: URLResponse?, _ data: [AnyHashable: Any]?, _ error: Error?) -> Void) -> Void {
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
        if self.serverAuth != nil {
            urlRequest.setValue("Bearer \(self.serverAuth!)", forHTTPHeaderField: "Authorization")
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
    
    public func serverAuthValid() -> Bool {
        return self.serverAuth != nil && !(self.serverAuth!.isEmpty)
    }
}
