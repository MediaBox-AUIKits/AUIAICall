//
//  AUIAICallSettingPanel.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

public typealias AUIAICallSettingSelectedBlock = (_ item: AUIAICallVoiceItem) -> Void
public typealias AUIAICallSettingInterruptBlock = (_ isOn: Bool) -> Void


@objcMembers open class AUIAICallSettingPanel: AVBaseCollectionControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleView.text = AUIAICallBundle.getString("Settings")
        
        self.contentView.addSubview(self.interruptSwitch)
        self.contentView.addSubview(self.descriptionView)

        self.interruptSwitch.frame = CGRect(x: 0, y: 5, width: self.contentView.av_width, height: 74)
        self.descriptionView.frame = CGRect(x: 0, y: self.interruptSwitch.av_bottom + 6, width: self.contentView.av_width, height: 50)

        self.collectionView.frame = CGRect(x: 0, y: self.descriptionView.av_bottom + 6, width: self.contentView.av_width, height: self.contentView.av_height - self.descriptionView.av_bottom)
        self.collectionView.register(AUIAICallSoundCell.self, forCellWithReuseIdentifier: "cell")
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func panelHeight() -> CGFloat {
        return 448
    }
        
    open lazy var interruptSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAICallBundle.getString("Interrupt AI Based on Sound and Environment")
        view.lineView.isHidden = true
        view.onSwitchValueChanged = { [weak self] bar in
            self?.interruptBlock?(bar.switchBtn.isOn)
        }
        return view
    }()
    
    open lazy var descriptionView: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAICallBundle.getString("New Voice Tone Will Take Effect in Next Response")
        view.switchBtn.isHidden = true
        view.lineView.isHidden = true
        return view
    }()
    
    
    open lazy var itemList: [AUIAICallVoiceItem] = {
        var list = [AUIAICallVoiceItem]()
        let item0 = AUIAICallVoiceItem()
        item0.voiceId = "zhixiaobai"
        item0.voiceName = AUIAICallBundle.getString("Zhi Xiaobai")
        item0.icon = "ic_sound_bai"
        list.append(item0)
        
        let item1 = AUIAICallVoiceItem()
        item1.voiceId = "zhixiaoxia"
        item1.voiceName = AUIAICallBundle.getString("Zhi Xiaoxia")
        item1.icon = "ic_sound_xia"
        list.append(item1)
        
        let item2 = AUIAICallVoiceItem()
        item2.voiceId = "abin"
        item2.voiceName = AUIAICallBundle.getString("Abin")
        item2.icon = "ic_sound_bin"
        list.append(item2)
        
        return list
    }()
    
    private var selectItem: AUIAICallVoiceItem? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    open var applyPlayBlock: AUIAICallSettingSelectedBlock? = nil
    open var interruptBlock: AUIAICallSettingInterruptBlock? = nil

    
    open func refreshUI(config: ARTCAICallConfig) {
        self.interruptSwitch.switchBtn.isOn = config.enableVoiceInterrupt
        self.selectItem = self.itemList.first { item in
            return item.voiceId == config.robotVoiceId
        }
    }
}

extension AUIAICallSettingPanel {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemList.count
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
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallSoundCell
        cell.item = self.itemList[indexPath.row]
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


@objcMembers open class AUIAICallVoiceItem: NSObject {
    open var voiceId: String = ""
    open var voiceName: String = ""
    open var icon: String = ""
}

@objcMembers open class AUIAICallSoundCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconView)
        self.addSubview(self.applyBtn)
        self.addSubview(self.appliedIcon)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconView.frame = CGRect(x: 20, y: (self.av_height - 32) / 2, width: 32, height: 32)
        
        self.applyBtn.sizeToFit()
        let width = self.applyBtn.av_width + 24
        self.applyBtn.frame = CGRect(x: self.av_width - width - 20, y: (self.av_height - 22) / 2, width: width, height: 22)
        self.appliedIcon.frame = self.applyBtn.frame
        
        self.titleLabel.frame = CGRect(x: self.iconView.av_right + 12, y: 0, width: self.applyBtn.av_left - self.iconView.av_right - 12 - 12, height: self.av_height)
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_strong
        return label
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = AVTheme.border_weak.cgColor
        return view
    }()
    
    
    open lazy var applyBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.layer.cornerRadius = 11
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setImage(nil, for: .normal)
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Use"), for: .normal)
        btn.isHidden = false
        return btn
    }()
    
    open lazy var appliedIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = AUIAICallBundle.getCommonImage("ic_sound_apply")
        view.isHidden = true
        return view
    }()
    
    open var item: AUIAICallVoiceItem? {
        didSet {
            self.titleLabel.text = self.item?.voiceName
            self.iconView.image = AUIAICallBundle.getImage(self.item?.icon)
        }
    }
    
    open var isApplied: Bool = false {
        didSet {
            self.applyBtn.isHidden = self.isApplied
            self.appliedIcon.isHidden = !self.isApplied
        }
    }
}
