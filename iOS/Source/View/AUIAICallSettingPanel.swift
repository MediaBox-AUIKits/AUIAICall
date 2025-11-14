//
//  AUIAICallSettingPanel.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

public typealias AUIAICallSettingSelectedBlock = (_ item: AUIAICallVoiceItem) -> Void
public typealias AUIAICallSettingEnableBlock = (_ isOn: Bool) -> Void
public typealias AUIAICallSettingDefaultBlock = (_ sender: AUIAICallSettingPanel) -> Void


@objcMembers open class AUIAICallSettingPanel: AVBaseCollectionControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAICallBundle.color_bg_elevated
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.headerView.isHidden = true
        self.titleView.text = AUIAICallBundle.getString("Settings")
        self.titleView.textAlignment = .left
        self.titleView.font = AVTheme.mediumFont(16)
        self.titleView.frame = CGRect(x: 24, y: 20, width: self.av_width - 54, height: 24)
        self.titleView.removeFromSuperview()
        self.addSubview(self.titleView)
        
        let exitBtn = AVBlockButton(frame: CGRect(x: self.av_width - 44 - 10, y: 10, width: 44, height: 44))
        exitBtn.setImage(AUIAICallBundle.getTemplateImage("ic_exit"), for: .normal)
        exitBtn.tintColor = AUIAICallBundle.color_icon
        exitBtn.clickBlock = {[weak self] sender in
            self?.hide()
        }
        self.addSubview(exitBtn)
        
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.contentView.av_width, height: self.contentView.av_height)
        self.collectionView.register(AUIAICallVoiceCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.addSubview(self.collectionHeaderView)
        self.collectionHeaderView.addSubview(self.normalModeBtn)
        self.collectionHeaderView.addSubview(self.pptModeBtn)
        self.collectionHeaderView.addSubview(self.issueReportView)
        self.collectionHeaderView.addSubview(self.latencyRateView)
        self.collectionHeaderView.addSubview(self.interruptSwitch)
        self.collectionHeaderView.addSubview(self.lineView)
        self.collectionHeaderView.addSubview(self.voiceIdSwitch)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func panelHeight() -> CGFloat {
        return UIScreen.main.bounds.height - 200
    }
    
    open override class func present(_ cp: AVBaseControllPanel, on onView: UIView, backgroundType bgType: AVControllPanelBackgroundType) {
        super.present(cp, on: onView, backgroundType: bgType)
        cp.bgViewOnShowing?.backgroundColor = AUIAICallBundle.color_bg_mask
    }
    
    private var voiceItemList: [AUIAICallVoiceItem] = []

    public var voiceIdList: [String] = [] {
        didSet {
            self.voiceItemList.removeAll()
            for i in 0 ..< self.voiceIdList.count {
                let vid = self.voiceIdList[i]
                let item = AUIAICallVoiceItem()
                let ret = vid.components(separatedBy: ":")
                if ret.count == 2 {
                    item.voiceId = ret[0]
                    item.voiceName = ret[1]
                }
                else {
                    item.voiceId = vid
                    item.voiceName = vid
                }
                
                item.icon = "ic_sound_\(i % 2)"
                self.voiceItemList.append(item)
            }
            self.voiceIdSwitch.isHidden = self.voiceItemList.count == 0
            self.lineView.isHidden = self.voiceIdSwitch.isHidden
        }
    }
    
    open lazy var collectionHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var normalModeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Natural Conversation Mode"), for: .normal)
        btn.backgroundColor = AUIAICallBundle.color_fill_tertiary
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAICallBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAICallBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAICallBundle.color_border_selection, for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 2
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            self?.onPushToTalkSwitchChanged(ptt: false)
            self?.pushToTalkBlock?(false)
        }
        return btn
    }()
    
    open lazy var pptModeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Push to Talk Mode"), for: .normal)
        btn.backgroundColor = AUIAICallBundle.color_fill_tertiary
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAICallBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAICallBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAICallBundle.color_border_selection, for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 2
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            self?.onPushToTalkSwitchChanged(ptt: true)
            self?.pushToTalkBlock?(true)
        }
        return btn
    }()
    
    // 问题反馈
    open lazy var issueReportView: AUIAICallRightClickBar = {
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAICallBundle.getString("Report Issues")
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            self.clickIssueReportBlock?(self)
        }
        return view
    }()
    
    // 延时率
    open lazy var latencyRateView: AUIAICallRightClickBar = {
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAICallBundle.getString("Latency Rate")
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            self.clickLatencyRateBlock?(self)
        }
        return view
    }()
    
    open lazy var interruptSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAICallBundle.getString("Interrupt Agent Based on Sound and Environment")
        view.onSwitchValueChangedBlock = { [weak self] bar in
            self?.interruptBlock?(bar.switchBtn.isOn)
        }
        return view
    }()
    
    open lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAICallBundle.color_border_secondary
        return view
    }()
    
    open lazy var voiceIdSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAICallBundle.getString("New Voice Tone Will Take Effect in Next Response")
        view.switchBtn.isHidden = true
        return view
    }()
    
    
    private var selectItem: AUIAICallVoiceItem? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    open var pushToTalkBlock: AUIAICallSettingEnableBlock? = nil
    open var applyPlayBlock: AUIAICallSettingSelectedBlock? = nil
    open var interruptBlock: AUIAICallSettingEnableBlock? = nil
    open var clickIssueReportBlock: AUIAICallSettingDefaultBlock? = nil
    open var clickLatencyRateBlock: AUIAICallSettingDefaultBlock? = nil

    // 控制是否显示延迟率按钮
    open func hiddenLatencyView(_ isHidden: Bool) {
        self.latencyRateView.isHidden = isHidden
        self.setNeedsLayout()
    }

    open var config: AUIAICallConfig? = nil {
        didSet {
            self.refreshUI()
        }
    }

    private func refreshUI() {
        self.onPushToTalkSwitchChanged(ptt: self.config?.agentConfig.enablePushToTalk == true)

        self.interruptSwitch.switchBtn.isOn = self.config?.agentConfig.interruptConfig.enableVoiceInterrupt ?? true
        self.selectItem = self.voiceItemList.first { item in
            return item.voiceId == self.config?.agentConfig.ttsConfig.agentVoiceId
        }
        
        self.setNeedsLayout()
    }
    
    private func onPushToTalkSwitchChanged(ptt: Bool) {
        self.normalModeBtn.isSelected = !ptt
        self.pptModeBtn.isSelected = ptt
        self.interruptSwitch.isHidden = ptt
        
        self.setNeedsLayout()
    }
    
    private func updateLayout() {
        
        var top: CGFloat = 16
        
        let w = (self.collectionView.av_width - 24 - 24 - 12) / 2.0
        self.normalModeBtn.frame = CGRect(x: 24, y: top, width: w, height: 48)
        self.pptModeBtn.frame = CGRect(x: self.normalModeBtn.av_right + 12, y: top, width: w, height: 48)
        top = self.pptModeBtn.av_bottom + 16
        
        self.issueReportView.frame =  CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 48)
        top = self.issueReportView.av_bottom
        
        self.latencyRateView.frame =  CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 48)
        top = self.latencyRateView.isHidden ? top : self.latencyRateView.av_bottom
        
        self.interruptSwitch.frame = CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 76)
        top = self.interruptSwitch.isHidden ? top : self.interruptSwitch.av_bottom
        
        self.lineView.frame = CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 1)
        top = self.lineView.isHidden ? top : self.lineView.av_bottom
        
        self.voiceIdSwitch.frame = CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 76)
        top = self.voiceIdSwitch.isHidden ? top : self.voiceIdSwitch.av_bottom
        
        self.collectionHeaderView.frame = CGRect(x: 0, y: -top, width: self.collectionView.av_width, height: top)
        self.collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
    }
}

extension AUIAICallSettingPanel {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.voiceItemList.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.av_width - 24 - 24, height: 52)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: UIView.av_safeBottom, right: 0)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallVoiceCell
        cell.item = self.voiceItemList[indexPath.row]
        cell.isApplied = cell.item == self.selectItem
        cell.applyBtn.clickBlock = {[weak self, weak cell] sender in
            if let item = cell?.item {
                self?.applyPlayBlock?(item)
                self?.selectItem = item
            }
        }
        return cell
    }
}
