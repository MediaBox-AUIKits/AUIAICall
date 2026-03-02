//
//  AUIAICallSceneViewController.swift
//  Pods
//
//  Created by Bingo on 2026/1/16.
//

import UIKit
import AUIFoundation
import ARTCAICallKit


@objcMembers open class AUIAICallSceneViewController: UIViewController {
    
    public init(tabIndex: AUIAICallMainTabIndex) {
        super.init(nibName: nil, bundle: nil)
        
        if (tabIndex == AUIAICallMainTabIndex.VoiceAgent) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("VoiceAgent")
        }
        else if (tabIndex == AUIAICallMainTabIndex.AvatarAgent) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("AvatarAgent")
        }
        else if (tabIndex == AUIAICallMainTabIndex.VisionAgent) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("VisionAgent")
        }
        else if (tabIndex == AUIAICallMainTabIndex.VideoAgent) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("VideoAgent")
        }
        else if (tabIndex == AUIAICallMainTabIndex.ChatAgent) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("ChatAgent")
        }
        else if (tabIndex == AUIAICallMainTabIndex.OutboundCall) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("OutboundCall")
        }
        else if (tabIndex == AUIAICallMainTabIndex.InboundCall) {
            self.agentSceneList = AUIAICallAgentManager.shared.getScenes("InboundCall")
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        
        self.view.addSubview(self.bgLineView)
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.enterBtn)
        
        self.view.addSubview(self.collectionView)
        
        if self.agentSceneList.count > 0 {
            self.selectIndex = 0
            self.collectionView.selectItem(at: IndexPath(row: self.selectIndex, section: 0), animated: false, scrollPosition: .top)
        }
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
    
    open lazy var bgLineView: AUIAICallBgLineView = {
        let view = AUIAICallBgLineView(frame: self.view.bounds, gradient: false)
        return view
    }()
        
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_exit"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon
        btn.frame = CGRect(x: self.view.av_width - 12 - 48, y: UIView.av_safeTop, width: 48, height: 48)
        btn.clickBlock = { [weak self] sender in
            if self?.navigationController != nil {
                self?.navigationController?.popViewController(animated: true)
            }
            else {
                self?.dismiss(animated: true)
            }
        }
        return btn
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = AUIAIMainBundle.getString("Select Scenario")
        label.textColor = AUIAIMainBundle.color_text
        label.font = AVTheme.regularFont(28)
        label.sizeToFit()
        label.av_left = 24
        label.av_top = UIView.av_safeTop + 122 - label.av_height
        return label
    }()
    
    open lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: CGRect(x: 0, y: self.titleLabel.av_bottom + 32, width: self.view.av_width, height: self.enterBtn.av_top - self.titleLabel.av_bottom - 32 - 32), collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.register(AUIAICallSceneCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    
    open lazy var enterBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 25.0, y: self.view.av_height - UIView.av_safeBottom - 26.0 - 44.0, width: self.view.av_width - 25.0 - 25.0, height: 44.0))
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAIMainBundle.getString("Enter"), for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_Inverse, for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill_disabled, for: .disabled)
        btn.setTitleColor(AUIAIMainBundle.color_text_disabled, for: .disabled)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.isEnabled = self.agentSceneList.count > 0
        btn.clickBlock = { [weak self] sender in
            guard let self = self else { return }
            if self.navigationController != nil {
                self.onEnterBtnClicked?(self.agentSceneList[self.selectIndex])
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.navigationController?.popViewController(animated: false)
                    let vcs = self.navigationController?.viewControllers
                    if let index = vcs?.firstIndex(of: self) {
                        self.navigationController?.viewControllers.remove(at: index)
                    }
                }
            }
            else {
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.onEnterBtnClicked?(self.agentSceneList[self.selectIndex])
                }
            }
        }
        return btn
    }()
    
    private var agentSceneList: [AUIAICallAgentScene] = []
    private var selectIndex: Int = 0
    
    open var onEnterBtnClicked: ((_ scene: AUIAICallAgentScene)->Void)? = nil
    
}


// MARK: - TableView DataSource and Delegate

extension AUIAICallSceneViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.agentSceneList.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallSceneCell
        cell.updateScene(scene: self.agentSceneList[indexPath.row])
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 72) // 每个单元格的大小
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
    }
}


// MARK: - 自定义 UICollectionViewCell

class AUIAICallSceneCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAIMainBundle.color_bg_elevated
        self.av_setLayerBorderColor(AUIAIMainBundle.color_border_secondary)
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.asrLabel)
        self.contentView.addSubview(self.ttsLabel)
        self.contentView.addSubview(self.voiceIdLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.sizeToFit()
        self.titleLabel.av_top = 16
        self.titleLabel.av_left = 16
        
        let margin = 8.0
        let width = (self.av_width - 16 - margin * 2) / 3.0
        self.asrLabel.frame = CGRect(x: 16, y: 46, width: width, height: 12)
        self.ttsLabel.frame = CGRect(x: self.asrLabel.av_right + margin, y: 46, width: width, height: 12)
        self.voiceIdLabel.frame = CGRect(x: self.ttsLabel.av_right + margin, y: 46, width: width, height: 12)

        let top = self.titleLabel.av_centerY - 9
        var x = self.titleLabel.av_right + 10
        self.tabLabels.forEach { tb in
            tb.av_left = x
            tb.av_top = top
            x = tb.av_right + 4
        }
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = self.isSelected
            self.av_setLayerBorderColor(self.isSelected ? AUIAIMainBundle.color_border_selection : AUIAIMainBundle.color_border_secondary)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAIMainBundle.color_text
        return label
    }()

    private lazy var asrLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.text = ""
        label.textColor = AUIAIMainBundle.color_text_tertiary
        return label
    }()
    
    private lazy var ttsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.text = ""
        label.textColor = AUIAIMainBundle.color_text_tertiary
        return label
    }()
    
    private lazy var voiceIdLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.text = ""
        label.textColor = AUIAIMainBundle.color_text_tertiary
        return label
    }()
    
    
    private lazy var tabLabels: Array<UILabel> = {
        let ret = Array<UILabel>()
        return ret
    }()
    
    open func updateScene(scene: AUIAICallAgentScene) {
        self.titleLabel.text = scene.title
        self.asrLabel.text = "·ASR \(scene.asrModelId)"
        self.ttsLabel.text = "·TTS \(scene.ttsModelId)"
        if scene.voiceStyles.isEmpty == false {
            self.voiceIdLabel.text = "·\(AUIAIMainBundle.getString("VoiceID")) \(scene.voiceStyles.first!.name)"
        }
        else {
            self.voiceIdLabel.text = ""
        }
        
        self.updateTabs(tabs: scene.tags)
    }
    
    private func updateTabs(tabs: [AUIAICallAgentSceneTag]) {
        self.tabLabels.forEach { la in
            la.removeFromSuperview()
        }
        self.tabLabels.removeAll()
        
        tabs.forEach { tag in
            let label = UILabel()
            label.text = tag.name
            label.font = AVTheme.regularFont(12)
            label.textAlignment = .center
            label.textColor = UIColor.av_color(withHexString: tag.fg ?? "#C62F0E")
            label.backgroundColor = UIColor.av_color(withHexString: tag.bg ?? "#FFEDEA")
            label.sizeToFit()
            label.av_width = label.av_width + 12
            label.av_height = 18
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            
            self.addSubview(label);
            self.tabLabels.append(label)
        }
        
        self.setNeedsLayout()
    }
}
