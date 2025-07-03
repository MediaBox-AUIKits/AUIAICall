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
        
        self.titleView.text = AUIAICallBundle.getString("Settings")
        
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.contentView.av_width, height: self.contentView.av_height)
        self.collectionView.register(AUIAICallVoiceCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.addSubview(self.collectionHeaderView)
        self.collectionHeaderView.addSubview(self.normalModeBtn)
        self.collectionHeaderView.addSubview(self.pptModeBtn)
        // 添加延迟率按钮
        self.collectionHeaderView.addSubview(self.latencyRateView)
        self.collectionHeaderView.addSubview(self.interruptSwitch)
        self.collectionHeaderView.addSubview(self.voiceprintSettingView)
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
        return 448
    }
    
    private var voiceItemList: [AUIAICallVoiceItem] = []

    public var voiceIdList: [String] = [] {
        didSet {
            self.voiceItemList.removeAll()
            for i in 0 ..< self.voiceIdList.count {
                let vid = self.voiceIdList[i]
                let item = AUIAICallVoiceItem()
                item.voiceId = vid
                item.voiceName = vid
                item.icon = "ic_sound_\(i % 3)"
                self.voiceItemList.append(item)
            }
            self.voiceIdSwitch.isHidden = self.voiceItemList.count == 0
        }
    }
    
    
    public var enableVoiceprintSwitch: Bool = true {
        didSet {
            self.voiceprintSettingView.isHidden = !self.enableVoiceprintSwitch
        }
    }
    
    public var isVoiceprintRegisted: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open lazy var collectionHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var normalModeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Natural Conversation Mode"), for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.border_ultraweak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .selected)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_normal"), for: .normal)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_select"), for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 8
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
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.border_ultraweak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .selected)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_normal"), for: .normal)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_select"), for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 8
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            self?.onPushToTalkSwitchChanged(ptt: true)
            self?.pushToTalkBlock?(true)
        }
        return btn
    }()
    
    // 延时率
    open lazy var latencyRateView: UIView = {
        let latencyRateView = UIView()
        latencyRateView.addSubview(latencyRateTitleLabel)
        latencyRateView.addSubview(latencyRateButton)
        return latencyRateView
    }()
    
    open lazy var latencyRateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = AUIAICallBundle.getString("Latency Rate")
        label.textColor = AVTheme.text_strong
        label.font = AVTheme.regularFont(14)
        return label
    }()
    
    open lazy var latencyRateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(AUIAICallBundle.getString("Click To View >"), for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.semanticContentAttribute = .forceLeftToRight
        btn.addTarget(self, action: #selector(handleLatencyRate), for: .touchUpInside)
        return btn
    }()
    
    // 延时率按钮点击事件
    @objc private func handleLatencyRate() {
        self.onLatencyRateViewTapped?()
    }

        
    open lazy var interruptSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAICallBundle.getString("Interrupt Agent Based on Sound and Environment")
        view.lineView.isHidden = true
        view.onSwitchValueChanged = { [weak self] bar in
            self?.interruptBlock?(bar.switchBtn.isOn)
        }
        return view
    }()
    
    
    open lazy var voiceprintSettingView: AUIAICallVoiceprintSettingView = {
        let view = AUIAICallVoiceprintSettingView()
        view.voiceprintSwitch.onSwitchValueChanged = { [weak self] bar in
            self?.voiceprintBlock?(bar.switchBtn.isOn)
        }
        view.removeBtn.clickBlock = { [weak self] btn in
            if let self = self {
                self.clearVoiceprintBlock?(self)
            }
        }
        return view
    }()
    
    open lazy var voiceIdSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAICallBundle.getString("New Voice Tone Will Take Effect in Next Response")
        view.switchBtn.isHidden = true
        view.lineView.isHidden = true
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
    open var voiceprintBlock: AUIAICallSettingEnableBlock? = nil
    open var clearVoiceprintBlock: AUIAICallSettingDefaultBlock? = nil
    
    // 延迟率按钮点击闭包
    open var onLatencyRateViewTapped: (() -> Void)?
    // 控制是否显示延迟率按钮
    open func hiddenLatencyView(_ isHidden: Bool) {
        self.latencyRateView.isHidden = isHidden
        self.updateLayout()
    }

    open var config: AUIAICallConfig? = nil {
        didSet {
            self.refreshUI()
        }
    }

    private func refreshUI() {
        self.onPushToTalkSwitchChanged(ptt: self.config?.agentConfig.enablePushToTalk == true)

        self.interruptSwitch.switchBtn.isOn = self.config?.agentConfig.interruptConfig.enableVoiceInterrupt ?? true
        self.voiceprintSettingView.voiceprintSwitch.switchBtn.isOn = self.config?.agentConfig.voiceprintConfig.useVoiceprint ?? true
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
        
        let w = (self.collectionView.av_width - 20 - 20 - 16) / 2.0
        self.normalModeBtn.frame = CGRect(x: 20, y: top, width: w, height: 52)
        self.pptModeBtn.frame = CGRect(x: self.normalModeBtn.av_right + 16, y: top, width: w, height: 52)
        top = self.pptModeBtn.av_bottom + 16
        
        self.latencyRateView.frame =  CGRect(x: 20, y: top, width: self.collectionView.av_width, height: 74)
        top = self.latencyRateView.isHidden ? top : self.latencyRateView.av_bottom
        self.latencyRateTitleLabel.frame = CGRect(x: 0, y: 0, width: self.latencyRateView.av_width/2, height: 74)
        self.latencyRateButton.frame = CGRect(x: self.latencyRateView.av_width/2, y: 0, width: self.latencyRateView.av_width/2, height: 74)
        
        self.interruptSwitch.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: 74)
        top = self.interruptSwitch.isHidden ? top : self.interruptSwitch.av_bottom
        
        let vp = 74.0 + (self.isVoiceprintRegisted ? 48.0 : 0.0)
        self.voiceprintSettingView.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: vp)
        top = self.voiceprintSettingView.isHidden ? top : self.voiceprintSettingView.av_bottom + 6
        
        self.voiceIdSwitch.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: 50)
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
        return CGSize(width: self.contentView.av_width, height: 48)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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


@objcMembers open class AUIAICallVoiceprintSettingView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.addSubview(voiceprintSwitch)
        self.addSubview(self.stateView)
        self.stateView.addSubview(self.titleLabel)
        self.stateView.addSubview(self.removeBtn)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.voiceprintSwitch.frame = CGRect(x: 0, y: 0, width: self.av_width, height: 74)
        self.stateView.frame = CGRect(x: 20, y: self.voiceprintSwitch.av_bottom, width: self.av_width - 20 - 20, height: 48)
        self.titleLabel.sizeToFit()
        self.titleLabel.center = CGPoint(x: self.titleLabel.av_width / 2.0 + 16, y: self.stateView.av_height / 2.0)
        
        self.removeBtn.sizeToFit()
        let width = self.removeBtn.av_width + 24
        self.removeBtn.frame = CGRect(x: self.stateView.av_width - width - 16, y: (self.stateView.av_height - 22) / 2, width: width, height: 22)
    }
    
    open var voiceprintIsApply: Bool = false {
        didSet {
            self.stateView.isHidden = !self.voiceprintIsApply
        }
    }
    
    open lazy var voiceprintSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Voiceprint(Invitation for Testing)")
        view.infoLabel.text = AUIAICallBundle.getString("The AI only uses your voice as input.")
        view.lineView.isHidden = true
        return view
    }()
    
    open lazy var stateView: UIView = {
        let view = UIView()
        view.backgroundColor = AVTheme.fill_weak
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_weak
        label.text = AUIAICallBundle.getString("Detected speaking")
        return label
    }()
    
    open lazy var removeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.layer.cornerRadius = 11
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setImage(nil, for: .normal)
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Remove Voiceprint"), for: .normal)
        btn.isHidden = false
        return btn
    }()
}
