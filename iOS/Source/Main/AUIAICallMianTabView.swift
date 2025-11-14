//
//  AUIAICallMianTabView.swift
//  ARTCAICallKit
//
//  Created by Bingo on 2025/9/10.
//

import UIKit
import AUIFoundation

public enum AUIAICallMainTabIndex: Int32 {
    case VoiceAgent = 0
    case AvatarAgent = 1
    case VisionAgent = 2
    case VideoAgent = 3
    case ChatAgent = 100
    case OutboundCall = 101
    case InboundCall = 102
    case CustomAgent = 103
}

@objcMembers open class AUIAICallMianTabItem: NSObject {
    
    init(_ index: AUIAICallMainTabIndex = .VoiceAgent, _ title: String = "", _ info: String = "") {
        self.index = index
        self.title = title
        self.info = info
    }
    
    open var index: AUIAICallMainTabIndex = .VoiceAgent
    open var title: String = ""
    open var info: String = ""
    
    public static var tabInfoList: [AUIAICallMianTabItem] = {
        var list = [AUIAICallMianTabItem]()
        list.append(AUIAICallMianTabItem(.VoiceAgent, AUIAIMainBundle.getString("Voice Call"), AUIAIMainBundle.getString("AI_Voice_Call_Detail")))
        list.append(AUIAICallMianTabItem(.AvatarAgent, AUIAIMainBundle.getString("Avatar Call"), AUIAIMainBundle.getString("AI_Avatar_Call_Detail")))
        list.append(AUIAICallMianTabItem(.VisionAgent, AUIAIMainBundle.getString("Vision Call"), AUIAIMainBundle.getString("AI_Vision_Call_Detail")))
        list.append(AUIAICallMianTabItem(.VideoAgent, AUIAIMainBundle.getString("Video Call"), AUIAIMainBundle.getString("AI_Video_Call_Detail")))
        list.append(AUIAICallMianTabItem(.ChatAgent, AUIAIMainBundle.getString("Chat"), AUIAIMainBundle.getString("AI_Chat_Detail")))
        if AUIAICallAgentConfig.shared.enableOutboundCall {
            list.append(AUIAICallMianTabItem(.OutboundCall, AUIAIMainBundle.getString("Call Out"), AUIAIMainBundle.getString("AI_Call_Out_Detail")))
        }
        if AUIAICallAgentConfig.shared.enableInboundCall {
            list.append(AUIAICallMianTabItem(.InboundCall, AUIAIMainBundle.getString("Call In"), AUIAIMainBundle.getString("AI_Call_In_Detail")))
        }
        list.append(AUIAICallMianTabItem(.CustomAgent, AUIAIMainBundle.getString("Custom Agent"), AUIAIMainBundle.getString("Custom_Agent_Detail")))
        return list
    }()
}

// TODO: remove
let VoiceAgentTypeIndex: Int = 0
let AvatarAgentTypeIndex: Int = 1
let VisionAgentTypeIndex: Int = 2
let VideoAgentTypeIndex: Int = 3
let ChatAgentTypeIndex: Int = 100
let OutboundCallTypeIndex: Int = 101
let InboundCallTypeIndex: Int = 102

@objcMembers open class AUIAICallMianTabView: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.currTabItem = AUIAICallMianTabItem.tabInfoList.first!
        var start = 24.0
        AUIAICallMianTabItem.tabInfoList.forEach { info in
            let btn = self.createTabBtn(info: info)
            btn.av_left = start
            self.addSubview(btn)
            self.tabBtnList.append(btn)
            start = btn.av_right + 24.0
        }
        start += 24.0

        self.addSubview(self.lineView)
        self.contentSize = CGSize(width: start, height: self.av_height)
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.updateTabLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tabBtnList: [AVBlockButton] = []
    
    open lazy var lineView: UIView = {
        let view = UIView(frame: CGRect(x: 24.0, y: self.av_height - 2, width: 30, height: 2))
        view.backgroundColor = AUIAIMainBundle.color_text
        return view
    }()
    
    open var tabWillChanged: ((_ item: AUIAICallMianTabItem, _ posIndex: Int) -> Void)? = nil
    
    open var currTabItem: AUIAICallMianTabItem = AUIAICallMianTabItem() {
        didSet {
            self.updateTabLayout()
        }
    }
    
    func createTabBtn(info: AUIAICallMianTabItem) -> AVBlockButton {
        let btn = AVBlockButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        btn.setTitle(info.title, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.tag = Int(info.index.rawValue)
        btn.sizeToFit()
        btn.av_size = CGSize(width: btn.av_width + 4, height: 40)
        btn.clickBlock = { [weak self] sender in
            guard let self = self else { return }
            let tabIndex = AUIAICallMainTabIndex(rawValue: Int32(sender.tag))!
            if let posIndex = AUIAICallMianTabItem.tabInfoList.firstIndex(where: { info in
                return info.index == tabIndex
            }) {
                self.currTabItem = AUIAICallMianTabItem.tabInfoList[posIndex]
                self.tabWillChanged?(self.currTabItem, posIndex)
            }
            
        }
        return btn
    }
    
    func updateTabLayout() {
        for btn in self.tabBtnList {
            if btn.tag == Int(self.currTabItem.index.rawValue) {
                UIView.animate(withDuration: 0.3) {
                    self.lineView.av_centerX = btn.av_centerX
                }
                let frame = btn.frame.insetBy(dx: -24, dy: 0)
                self.scrollRectToVisible(frame, animated: true)
                break
            }
        }
        for btn in self.tabBtnList {
            if btn.tag == Int(self.currTabItem.index.rawValue) {
                btn.titleLabel?.font = AVTheme.mediumFont(14)
            }
            else {
                btn.titleLabel?.font = AVTheme.regularFont(14)
            }
        }
    }
    
}
