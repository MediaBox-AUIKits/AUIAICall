//
//  AUIAICallLatencyRateView.swift
//  AUIAICall
//
//  Created by wy on 2025/6/19.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallLatencyRateViewController: UIViewController {
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    // 外部传入的延迟数据
    public var latencyData: [(id: Int32, latency: Int64)] = [] // 形如 ("Sentence ID", "12 ms")
    
    // MARK: - UI Components
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAICallBundle.getTemplateImage("ic_back"), for: .normal)
        btn.tintColor = AUIAICallBundle.color_icon
        btn.setTitle(AUIAICallBundle.getString("Latency Rate"), for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(16)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        btn.clickBlock = { [weak self] sender in
            self?.goBack()
        }
        return btn
    }()
    
    open lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.register(AUIAICallSubtitleCell.self, forCellWithReuseIdentifier: "cell")
        view.showsHorizontalScrollIndicator = false
        view.register(AUIAICallLatencyRateCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = AUIAICallBundle.getString("Sentence Latency")
        label.textColor = AUIAICallBundle.color_text
        label.font = AVTheme.regularFont(16)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = AUIAICallBundle.getString("The latency in an AI conversation turn, measured from the moment the user finishes their last word to when the AI agent begins its first response. Note: There is a statistical failure rate for conversation latency measurements. When unavoidable dirty data occurs, the system will automatically discard the conversation latency data.")
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAICallBundle.color_text_tertiary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAICallBundle.color_border
        return view
    }()
    
    // 外部调用的方法，用于更新数据并刷新表格
    public func updateLatencyData(newData: [(id: Int32, latency: Int64)]) {
        self.latencyData = newData
        self.collectionView.reloadData() // 刷新表格
    }
    
    // MARK: - Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAICallBundle.color_bg
        self.backBtn.sizeToFit()
        self.backBtn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: self.backBtn.av_width + 12, height: 48)
        self.view.addSubview(self.backBtn)
            
        self.subtitleLabel.frame = CGRect(x: 24, y: self.backBtn.av_bottom + 38, width: self.view.av_width - 48, height: 24)
        self.view.addSubview(self.subtitleLabel)

        let size = self.detailLabel.sizeThatFits(CGSize(width: self.subtitleLabel.av_width, height: CGFloat.greatestFiniteMagnitude))
        self.detailLabel.frame = CGRect(x: 24, y: self.subtitleLabel.av_bottom + 8, width: size.width, height: size.height)
        self.view.addSubview(self.detailLabel)
        
        self.separatorLine.frame = CGRect(x: 24, y: self.detailLabel.av_bottom + 12.0, width: self.view.av_width - 48, height: 1)
        self.view.addSubview(self.separatorLine)

        let y = self.separatorLine.av_bottom
        self.collectionView.frame = CGRect(x: 0, y: y, width: self.view.av_width, height: self.view.av_height - y)
        self.view.addSubview(self.collectionView)
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
    
    func goBack() {
        if let nv = self.navigationController {
            nv.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - TableView DataSource and Delegate

extension AUIAICallLatencyRateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return latencyData.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24, bottom: UIView.av_safeBottom, right: 24)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallLatencyRateCell
        let data = latencyData[indexPath.row]
        cell.configure(withID: data.id, latency: data.latency) // 配置单元格数据
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 84) // 每个单元格的大小
    }
}

// MARK: - 自定义 UICollectionViewCell

class AUIAICallLatencyRateCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.idTitleLabel)
        self.contentView.addSubview(self.idLabel)
        self.contentView.addSubview(self.latencyLabel)
        self.contentView.addSubview(self.separatorLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.idTitleLabel.sizeToFit()
        self.idTitleLabel.av_top = 14
        
        self.idLabel.sizeToFit()
        self.idLabel.av_top = 46
        
        self.latencyLabel.frame = CGRect(x: self.idLabel.av_right, y: self.idLabel.av_top, width: self.contentView.av_width - self.idLabel.av_right, height: self.idLabel.av_height)
        
        self.separatorLine.frame = CGRect(x: 0, y: self.av_height - 1, width: self.av_width, height: 1)
    }
    
    // 左上方显示 Sentence ID
    private lazy var idTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sentence ID"
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAICallBundle.color_text
        return label
    }()

    // 左下方显示 ID
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAICallBundle.color_text_tertiary
        return label
    }()
    
    // 右侧显示延迟
    private lazy var latencyLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAICallBundle.color_text_secondary
        label.textAlignment = .right
        return label
    }()
    
    // 分割线
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAICallBundle.color_border
        return view
    }()

    
    func configure(withID id: Int32, latency: Int64) {
        self.idLabel.text = "\(id)"
        self.latencyLabel.text = "\(latency) ms"
    }
    
}
