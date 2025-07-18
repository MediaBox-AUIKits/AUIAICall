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

@objcMembers open class AUIAICallOutboundCallViewController: AVBaseViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.start()
#endif
    }
    
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        
#if AICALL_ENABLE_FEEDBACK
        AUIAICallReport.shared.finish()
#endif
        
        ARTCAICallEngineDebuger.Debug_ClearTipsData()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AVTheme.bg_medium
        self.hiddenMenuButton = true
        self.titleView.text = AUIAIMainBundle.getString("AI Call Out")
        
#if AICALL_ENABLE_FEEDBACK
        self.reportBtn = self.setupReportBtn()
#endif
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.stateLabel)
        
        self.contentView.addSubview(self.infoLabel)
        self.contentView.addSubview(self.copyBtn)
        
        self.infoLabel.isHidden = true
        self.copyBtn.isHidden = true
        
        self.startAIAgentOutboundCall()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = self.stateLabel.sizeThatFits(CGSize(width: self.contentView.av_width, height: 0))
        self.stateLabel.frame = CGRect(x: 0, y: self.iconView.av_bottom + 26, width: self.contentView.av_width, height: size.height)

        self.infoLabel.sizeToFit()
        self.copyBtn.sizeToFit()
        let width = self.infoLabel.av_width + self.copyBtn.av_width + 8
        self.infoLabel.frame = CGRect(x: (self.contentView.av_width - width) / 2, y: self.stateLabel.av_bottom + 18, width: self.infoLabel.av_width, height: 18)
        self.copyBtn.frame = CGRect(x: self.infoLabel.av_right + 8, y: self.infoLabel.av_top, width: self.copyBtn.av_width, height: 18)
    }
    
    open var reportBtn: UIButton? = nil
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        view.image = AUIAIMainBundle.getImage("ic_call_out_succ")
        view.center = CGPoint(x: self.contentView.av_width / 2, y: self.contentView.av_height / 5 * 1)
        return view
    }()
    
    open lazy var stateLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = AUIAIMainBundle.getString("The call is being placed, please be ready to answer")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(16)
        title.numberOfLines = 0
        title.textAlignment = .center
        return title
    }()
    
    open lazy var infoLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = "ID: xxxxx"
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(14)
        title.textAlignment = .center
        return title
    }()
    
    open lazy var copyBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setTitle("Copy", for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        btn.layer.cornerRadius = 9
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.clickBlock = { [weak self] btn in
            guard let self = self, let instanceId = self.rspModel?.instanceId else { return }
            UIPasteboard.general.string = instanceId
            AVToastView.show(AUIAIMainBundle.getString("InstanceId copied"), view: self.view, position: .mid)
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
        self.iconView.image = AUIAIMainBundle.getImage("ic_call_out_failed")
        self.stateLabel.text = "\(AUIAIMainBundle.getString("Call failed")): \(self.rspModel?.errorCode ?? "unknown")"
        self.infoLabel.text = "ID: \(self.rspModel?.instanceId ?? "")"
        self.infoLabel.isHidden = !(self.rspModel?.instanceId.isEmpty == false)
        self.copyBtn.isHidden = self.infoLabel.isHidden
        self.viewDidLayoutSubviews()
    }
}

#if AICALL_ENABLE_FEEDBACK
extension AUIAICallOutboundCallViewController {
    
    func setupReportBtn() -> UIButton {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitle(AUIAIMainBundle.getString("Report Issues"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            if let rspModel = self.rspModel {
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.reqModel.agentId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: self.reqModel.userId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: rspModel.instanceId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: rspModel.requestId)
            }
            
            self.av_presentFullScreenViewController(AUIAICallReportViewController(), animated: true)
        }
        self.headerView.addSubview(btn)
        btn.sizeToFit()
        btn.frame = CGRect(x: self.headerView.av_width - 24 - btn.av_width, y: self.headerView.av_height - 44, width: btn.av_width, height: 44)
        return btn
    }
}
#endif
