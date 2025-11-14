//
//  AUIAICallOutboundCallViewController.swift
//  Pods
//
//  Created by Bingo on 2025/6/19.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallOutboundCallReqModel: NSObject {
    open var userId: String = ""
    open var agentId: String = ""
    open var region: String = ""
    open var phoneNumber: String = ""
    open var config: ARTCAICallAgentConfig? = nil
    open var userData: [String: Any]? = nil
    open var sessionId: String? = nil
}

@objcMembers open class AUIAICallOutboundCallRspModel: NSObject {
    
    open var requestId: String = ""
    open var instanceId: String = ""
    open var errorCode: String = ""
    open var errorMsg: String = ""
}

@objcMembers open class AUIAICallOutboundCallViewController: UIViewController {
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        self.view.addSubview(self.backBtn)
                
        self.view.addSubview(self.iconView)
        self.view.addSubview(self.stateLabel)
        
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.copyBtn)
        
        self.infoLabel.isHidden = true
        self.copyBtn.isHidden = true
        
        self.startAIAgentOutboundCall()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.iconView.center = CGPoint(x: self.view.av_width / 2, y: self.view.av_height / 5 * 2)

        let size = self.stateLabel.sizeThatFits(CGSize(width: self.view.av_width, height: 0))
        self.stateLabel.frame = CGRect(x: 0, y: self.iconView.av_bottom + 24, width: self.view.av_width, height: size.height)

        self.infoLabel.sizeToFit()
        self.copyBtn.sizeToFit()
        let width = self.infoLabel.av_width + self.copyBtn.av_width + 8
        self.infoLabel.frame = CGRect(x: (self.view.av_width - width) / 2, y: self.stateLabel.av_bottom + 8, width: self.infoLabel.av_width, height: 24)
        self.copyBtn.frame = CGRect(x: self.infoLabel.av_right + 8, y: self.infoLabel.av_top, width: self.copyBtn.av_width, height: 24)
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_back"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon
        btn.setTitle(AUIAIMainBundle.getString("AI Call Out"), for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(16)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        btn.sizeToFit()
        btn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: btn.av_width + 12, height: 48)
        btn.clickBlock = { [weak self] sender in
            self?.navigationController?.popViewController(animated: true)
        }
        return btn
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        view.contentMode = .center
        view.backgroundColor = AUIAIMainBundle.color_fill_secondary
        view.layer.cornerRadius = 45
        view.layer.masksToBounds = true
        view.tintColor = AUIAIMainBundle.color_icon
        view.image = AUIAIMainBundle.getTemplateImage("ic_call_out_succ")
        return view
    }()
    
    open lazy var stateLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = AUIAIMainBundle.getString("The call is being placed, please be ready to answer")
        title.textColor = AUIAIMainBundle.color_text
        title.font = AVTheme.regularFont(16)
        title.numberOfLines = 0
        title.textAlignment = .center
        return title
    }()
    
    open lazy var infoLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = "ID: xxxxx"
        title.textColor = AUIAIMainBundle.color_text
        title.font = AVTheme.regularFont(16)
        title.textAlignment = .center
        return title
    }()
    
    open lazy var copyBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setTitle("Copy", for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_link, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        btn.clickBlock = { [weak self] btn in
            guard let self = self, let instanceId = self.rspModel?.instanceId else { return }
            UIPasteboard.general.string = instanceId
            self.view.aicall_showToast(AUIAIMainBundle.getString("InstanceId copied"))
        }
        return btn
    }()
    
    open var reqModel: AUIAICallOutboundCallReqModel = AUIAICallOutboundCallReqModel()
    open var rspModel: AUIAICallOutboundCallRspModel? = nil
    internal var appserver: AUIAICallAppServer = {
        let appserver = AUIAICallAppServer()
        return appserver
    }()

    open func startAIAgentOutboundCall() {
        var body: [String : Any] = [
            "ai_agent_id": self.reqModel.agentId,
            "region": self.reqModel.region,
            "called_number": self.reqModel.phoneNumber,
            "user_id": self.reqModel.userId,
        ]
        if let config = self.reqModel.config {
            body.updateValue(config.toData().aicall_jsonString, forKey: "config")
        }
        if let userData = self.reqModel.userData {
            body.updateValue(userData.aicall_jsonString, forKey: "user_data")
        }
        if let sessionId = self.reqModel.sessionId {
            body.updateValue(sessionId, forKey: "session_id")
        }

        self.appserver.request(path: "/api/v2/aiagent/startAIAgentOutboundCall", body: body) {[weak self] response, data, error in
            let rspModel = AUIAICallOutboundCallRspModel()
            rspModel.requestId = (data?["request_id"] as? String) ?? ""
            var succeed = false
            if error == nil {
                debugPrint("startAIAgentOutboundCall response: success")
                if let instance_id = data?["instance_id"] as? String {
                    rspModel.instanceId = instance_id
                    succeed = true
                }
                else if let error_code = data?["error_code"] as? String {
                    rspModel.errorCode = error_code
                    rspModel.errorMsg = data?["message"] as? String ?? ""
                }
            }
            else {
                debugPrint("startAIAgentInstance response: failed, error:\(error!)")
                rspModel.errorCode = "\(error!.code)"
            }
            self?.rspModel = rspModel
            if succeed {
                self?.refreshUIWithSucceed()
            }
            else {
                self?.refreshUIWithFailed()
            }
        }
    }
    
    open func refreshUIWithSucceed() {
        self.infoLabel.text = "ID: \(self.rspModel?.instanceId ?? "")"
        self.infoLabel.isHidden = !(self.rspModel?.instanceId.isEmpty == false)
        self.copyBtn.isHidden = self.infoLabel.isHidden
        self.viewDidLayoutSubviews()
    }
    
    open func refreshUIWithFailed() {
        self.iconView.image = AUIAIMainBundle.getTemplateImage("ic_call_out_failed")
        self.stateLabel.text = "\(AUIAIMainBundle.getString("Call failed")): \(self.rspModel?.errorCode ?? "unknown")"
        self.infoLabel.text = "ID: \(self.rspModel?.instanceId ?? "")"
        self.infoLabel.isHidden = !(self.rspModel?.instanceId.isEmpty == false)
        self.copyBtn.isHidden = self.infoLabel.isHidden
        self.viewDidLayoutSubviews()
    }
}
