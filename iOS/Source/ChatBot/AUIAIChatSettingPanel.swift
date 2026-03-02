//
//  AUIAIChatSettingPanel.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation

public typealias AUIAIChatSettingSelectedBlock = (_ item: AUIAICallAgentVoiceStyle) -> Void


@objcMembers open class AUIAIChatSettingPanel: AVBaseCollectionControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAIChatBundle.color_bg_elevated
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.headerView.isHidden = true
        self.titleView.text = AUIAIChatBundle.getString("Settings")
        self.titleView.textAlignment = .left
        self.titleView.font = AVTheme.mediumFont(16)
        self.titleView.frame = CGRect(x: 24, y: 20, width: self.av_width - 54, height: 24)
        self.titleView.removeFromSuperview()
        self.addSubview(self.titleView)
        
        let exitBtn = AVBlockButton(frame: CGRect(x: self.av_width - 44 - 10, y: 10, width: 44, height: 44))
        exitBtn.setImage(AUIAIChatBundle.getTemplateImage("ic_exit"), for: .normal)
        exitBtn.tintColor = AUIAIChatBundle.color_icon
        exitBtn.clickBlock = {[weak self] sender in
            self?.hide()
        }
        self.addSubview(exitBtn)
        
        self.collectionView.frame = CGRect(x: 0, y: 20, width: self.contentView.av_width, height: self.contentView.av_height - 20)
        self.collectionView.register(AUIAICallVoiceCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.addSubview(self.collectionHeaderView)
        self.collectionHeaderView.addSubview(self.issueReportView)
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
    
    open override class func present(_ cp: AVBaseControllPanel, on onView: UIView, backgroundType bgType: AVControllPanelBackgroundType) {
        super.present(cp, on: onView, backgroundType: bgType)
        cp.bgViewOnShowing?.backgroundColor = AUIAIChatBundle.color_bg_mask
    }
    
    open lazy var collectionHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open var clickIssueReportBlock: ((_ sender: AUIAIChatSettingPanel) -> Void)? = nil

    // 问题反馈
    open lazy var issueReportView: AUIAICallRightClickBar = {
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAIChatBundle.getString("Report Issues")
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            self.clickIssueReportBlock?(self)
        }
        return view
    }()
    
    open lazy var voiceIdSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIChatBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAIChatBundle.getString("New Voice Tone Will Take Effect in Next Play")
        view.switchBtn.isHidden = true
        return view
    }()
    
    private var voiceStyles: [AUIAICallAgentVoiceStyle] = []
    
    private var selectedVoiceStyle: AUIAICallAgentVoiceStyle? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    public func setup(voiceStyles: [AUIAICallAgentVoiceStyle], selectedId: String) {
        var selectItem: AUIAICallAgentVoiceStyle? = nil
        
        self.voiceStyles.removeAll()
        self.voiceStyles.append(contentsOf: voiceStyles)
        
        for i in 0 ..< self.voiceStyles.count {
            let item = self.voiceStyles[i]
            if item.icon?.isEmpty != false {
                item.icon = "file://ic_sound_\(i % 2)"  // 使用本地默认图片
            }
            
            if item.voiceId == selectedId {
                selectItem = item
            }
        }
        self.selectedVoiceStyle = selectItem
        self.voiceIdSwitch.isHidden = self.voiceStyles.count == 0
    }
    
    open var onVoiceStyleSelectedBlock: AUIAIChatSettingSelectedBlock? = nil
    
    private func updateLayout() {
        
        var top: CGFloat = 0
        self.issueReportView.frame =  CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 48)
        top = self.issueReportView.isHidden ? top : self.issueReportView.av_bottom
        
        self.voiceIdSwitch.frame = CGRect(x: 24, y: top, width: self.collectionView.av_width - 48, height: 76)
        top = self.voiceIdSwitch.isHidden ? 0 : self.voiceIdSwitch.av_bottom
        
        self.collectionHeaderView.frame = CGRect(x: 0, y: -top, width: self.collectionView.av_width, height: top)
        self.collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
    }
}

extension AUIAIChatSettingPanel {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.voiceStyles.count
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
        cell.item = self.voiceStyles[indexPath.row]
        cell.isApplied = cell.item == self.selectedVoiceStyle
        cell.applyBtn.clickBlock = {[weak self, weak cell] sender in
            if let item = cell?.item {
                self?.onVoiceStyleSelectedBlock?(item)
                self?.selectedVoiceStyle = item
            }
        }
        return cell
    }
}
