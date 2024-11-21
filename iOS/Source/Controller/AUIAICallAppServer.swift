//
//  AUIAICallAppServer.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit

public let AICallServerDomain = "你的AppServer线上域名"
public let AICallServerDomainPre = "你的AppServer预发域名"

@objcMembers public class AUIAICallAppServer: ARTCAICallRequest {

    public override init(serverDomain: String = AUIAICallAppServer.serverDomain) {
        super.init(serverDomain: serverDomain)
    }
    
    public override func willRequest(urlRequest: inout URLRequest) {
        super.willRequest(urlRequest: &urlRequest)
        if let serverAuth = AUIAICallAppServer.serverAuth {
            urlRequest.setValue(serverAuth, forHTTPHeaderField: "Authorization")
            debugPrint("AUIAICallAppServer serverAuth: \(serverAuth)")
        }
    }
    
    public override func request(path: String, body: [AnyHashable: Any]?, completed: @escaping (_ response: URLResponse?, _ data: [AnyHashable: Any]?, _ error: NSError?) -> Void) -> Void {
        
        if !AUIAICallAppServer.serverAuthValid() {
            completed(nil, nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
            return
        }
        
        super.request(path: path, body: body, completed: completed)
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
