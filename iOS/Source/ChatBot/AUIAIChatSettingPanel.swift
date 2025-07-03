//
//  AUIAIChatSettingPanel.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation

public typealias AUIAIChatSettingSelectedBlock = (_ item: AUIAICallVoiceItem) -> Void


@objcMembers open class AUIAIChatSettingPanel: AVBaseCollectionControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleView.text = AUIAIChatBundle.getString("Settings")
        
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.contentView.av_width, height: self.contentView.av_height)
        self.collectionView.register(AUIAICallVoiceCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.addSubview(self.collectionHeaderView)
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
        return 370
    }
    
    open lazy var collectionHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var voiceIdSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAIChatBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAIChatBundle.getString("New Voice Tone Will Take Effect in Next Play")
        view.switchBtn.isHidden = true
        view.lineView.isHidden = true
        return view
    }()
    
    private var voiceItemList: [AUIAICallVoiceItem] = []
    
    private lazy var defaultVoiceItem: AUIAICallVoiceItem = {
        let item = AUIAICallVoiceItem()
        item.voiceId = ""
        item.voiceName = AUIAIChatBundle.getString("Default")
        item.icon = "ic_sound_2"
        return item
    }()
    
    public func setup(voiceIdList: [String], selectItemId: String) {
        var selectItem: AUIAICallVoiceItem? = nil
        
        self.voiceItemList.removeAll()
        self.voiceItemList.append(self.defaultVoiceItem)
        for i in 0 ..< voiceIdList.count {
            let vid = voiceIdList[i]
            let item = AUIAICallVoiceItem()
            item.voiceId = vid
            item.voiceName = vid
            item.icon = "ic_sound_\(i % 3)"
            self.voiceItemList.append(item)
            
            if vid == selectItemId {
                selectItem = item
            }
        }
        self.selectItem = selectItem ?? self.defaultVoiceItem
        self.voiceIdSwitch.isHidden = self.voiceItemList.count == 0
    }
    
    private var selectItem: AUIAICallVoiceItem? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    open var applyPlayBlock: AUIAIChatSettingSelectedBlock? = nil
    
    private func updateLayout() {
        
        self.voiceIdSwitch.frame = CGRect(x: 0, y: 0, width: self.collectionView.av_width, height: 64)
        let top = self.voiceIdSwitch.isHidden ? 0 : self.voiceIdSwitch.av_bottom
        self.collectionHeaderView.frame = CGRect(x: 0, y: -top, width: self.collectionView.av_width, height: top)
        self.collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
    }
}

extension AUIAIChatSettingPanel {
    
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
