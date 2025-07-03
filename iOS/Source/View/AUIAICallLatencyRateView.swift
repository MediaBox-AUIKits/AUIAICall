//
//  AUIAICallLatencyRateView.swift
//  AUIAICall
//
//  Created by wy on 2025/6/19.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallLatencyRateViewController: AVBaseCollectionViewController {
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    // 外部传入的延迟数据
    public var latencyData: [(id: Int32, latency: Int64)] = [] // 形如 ("Sentence ID", "12 ms")
    
    // MARK: - UI Components
    // 中间栏内容
    private lazy var middleSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(subtitleLabel)
        view.addSubview(subtitleTextView)
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = AUIAICallBundle.getString("Sentence Latency")
        label.textColor = AVTheme.text_medium
        label.font = AVTheme.mediumFont(14)
        return label
    }()
    
    private lazy var subtitleTextView: UITextView = {
        let textView = UITextView()
        textView.text = AUIAICallBundle.getString("The latency in an AI conversation turn, measured from the moment the user finishes their last word to when the AI agent begins its first response. Note: There is a statistical failure rate for conversation latency measurements. When unavoidable dirty data occurs, the system will automatically discard the conversation latency data.")
        textView.font = AVTheme.regularFont(14)
        textView.backgroundColor = .black
        textView.textColor = AVTheme.text_weak
        textView.isEditable = false // 禁止编辑
        textView.isSelectable = false // 禁止选择
        textView.isScrollEnabled = true // 开启滚动功能
        textView.showsVerticalScrollIndicator = true // 显示滚动条
        textView.alwaysBounceVertical = true
        textView.textContainerInset = .zero // 调整内边距
        return textView
    }()
    
    // 外部调用的方法，用于更新数据并刷新表格
    public func updateLatencyData(newData: [(id: Int32, latency: Int64)]) {
        latencyData = newData
        collectionView.reloadData() // 刷新表格
    }
    
    // MARK: - Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.titleView.text = AUIAICallBundle.getString("Latency Rate")
        self.hiddenMenuButton = true
        // 设置collectionView背景色
        self.collectionView.backgroundColor = AVTheme.bg_medium
        // 中间栏
        self.contentView.addSubview(middleSectionView)
        // 注册Cell
        self.collectionView.register(AUIAICallLatencyRateCell.self, forCellWithReuseIdentifier: AVCollectionViewCellIdentifier)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let padding: CGFloat = 16
        
        // 中间栏
        middleSectionView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: 120)
        subtitleLabel.frame = CGRect(x: padding, y: 0, width: middleSectionView.bounds.width - 2 * padding, height: 22)
        subtitleTextView.frame = CGRect(x: padding,
                                        y: subtitleLabel.frame.maxY + 8,
                                        width: middleSectionView.bounds.width - 2 * padding,
                                        height: max(0, middleSectionView.bounds.height - subtitleLabel.frame.height - 8))
        
        // 布局表格
        let collectionViewY = middleSectionView.frame.maxY
        collectionView.frame = CGRect(x: 0, y: collectionViewY, width: self.contentView.bounds.width, height: self.contentView.bounds.height - collectionViewY)
    }
}

// MARK: - TableView DataSource and Delegate

extension AUIAICallLatencyRateViewController {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return latencyData.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AVCollectionViewCellIdentifier, for: indexPath) as! AUIAICallLatencyRateCell
        let data = latencyData[indexPath.row]
        cell.configure(withID: data.id, latency: data.latency) // 配置单元格数据
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 50) // 每个单元格的大小
    }
}

// MARK: - 自定义 UICollectionViewCell

class AUIAICallLatencyRateCell: UICollectionViewCell {
    
    // 左上方显示 Sentence ID
    private lazy var idTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sentence ID"
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        return label
    }()

    // 左下方显示 ID
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        return label
    }()
    
    // 右侧显示延迟
    private lazy var latencyLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        label.textAlignment = .right
        return label
    }()
    
    // 分割线
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = AVTheme.text_strong
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(idTitleLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(latencyLabel)
        contentView.addSubview(separatorLine)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withID id: Int32, latency: Int64) {
        idLabel.text = "\(id)"
        latencyLabel.text = "\(latency) ms"
    }
    
    private func setupConstraints() {
        idTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        latencyLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            idTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idLabel.topAnchor.constraint(equalTo: idTitleLabel.bottomAnchor, constant: 4),
            idLabel.bottomAnchor.constraint(equalTo: separatorLine.topAnchor, constant: -8),
            
            latencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            latencyLabel.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor),
            
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5) // 高度固定为 0.5
        ])
    }
}
