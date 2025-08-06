//
//  AUIAICallVoiceprintViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2025/07/04.
//

import UIKit
import AUIFoundation
import AVFoundation

@objcMembers open class AUIAICallVoiceprintViewController: AVBaseCollectionViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = AVTheme.bg_medium
        self.titleView.text = AUIAICallBundle.getString("Voiceprint Feature Information")
        self.hiddenMenuButton = true
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.envTipsLabel)
        self.contentView.addSubview(self.recordTipsLabel)
        self.contentView.addSubview(self.readLabel)
        self.contentView.addSubview(self.speakBtn)

        self.imageView.center = CGPoint(x: self.contentView.av_width / 2.0, y: 36 + self.imageView.av_height / 2.0)
        self.envTipsLabel.frame = CGRect(x: 0, y: self.imageView.av_bottom + 60, width: self.contentView.av_width, height: 22)
        self.recordTipsLabel.frame = CGRect(x: 0, y: self.envTipsLabel.av_bottom + 20, width: self.contentView.av_width, height: 22)

        self.readLabel.frame = CGRect(x: 44, y: self.recordTipsLabel.av_bottom + 60, width: self.contentView.av_width - 44 - 44, height: 0)
        self.readLabel.sizeToFit()
        
        self.speakBtn.iconMargin = 12
        self.speakBtn.av_size = CGSize(width: 116, height: 78)
        self.speakBtn.av_centerX = self.contentView.av_width / 2.0
        self.speakBtn.av_bottom = self.contentView.av_height - UIView.av_safeBottom - 46
        
        self.updateRecordTipsLabel(time: 0)
    }
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
        view.image = AUIAICallBundle.getImage("ic_voiceprint_info")
        return view
    }()
    
    open lazy var envTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = AUIAICallBundle.getString("Please read the following sentence in a quiet environment.")
        return label
    }()
    
    open lazy var recordTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_medium
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open lazy var readLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        label.numberOfLines = 0
        label.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.lineHeightMultiple = 1.2;
        label.attributedText = NSMutableAttributedString(string: AUIAICallBundle.getString("'Woah, I think the dress you're wearing today is especially vibrant and elegant. It really complements your style – it's absolutely beautiful! Could you tell me where you bought such a lovely dress? I'd love to find one too.'"), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.kern: 0.56]);
        return label
    }()
        
    open lazy var speakBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Press to start recording, release to stop."),
                                         iconBgColor: AVTheme.fill_infrared,
                                         normalIcon: AUIAICallBundle.getCommonImage("ic_ptt_press"),
                                         selectedBgColor: AVTheme.colourful_fill_strong,
                                         selectedTitle:AUIAICallBundle.getString("Press to start recording, release to stop."),
                                         selectedIcon:AUIAICallBundle.getCommonImage("ic_ptt_release"))
        btn.longPressAction = { [weak self] btn, state, elapsed in
            guard let self = self else { return }
            if state == 1 {
                btn.isSelected = false
                // finish
                if let voiceRecorder = self.voiceRecorder{
                    if let audioFileUrl = voiceRecorder.stopRecording() {
                        self.onRecordCompleted(audioFileUrl)
                    }
                }
                self.updateRecordTipsLabel(time: 0)
            }
            else if state == 2 {
                btn.isSelected = false
                // cancel
                if let voiceRecorder = self.voiceRecorder{
                    _ = voiceRecorder.stopRecording()
                    AVToastView.show(AUIAICallBundle.getString("Recording cancelled."), view: self.contentView, position: .mid)
                }
                self.updateRecordTipsLabel(time: 0)
            }
            else {
                if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                    // start
                    if self.voiceRecorder == nil {
                        self.voiceRecorder = AUIAICallVoiceprintRecorder()
                    }
                    if let error = self.voiceRecorder?.startRecording() {
                        AVToastView.show(AUIAICallBundle.getString("Recording failed") + ": \(error.localizedDescription)", view: self.contentView, position: .mid)
                        self.voiceRecorder = nil
                    }
                    else {
                        btn.isSelected = true
                    }
                }
                else {
                    AVDeviceAuth.checkMicAuth { _ in }
                }
            }
        }
        btn.pressTimeUpdate = { [weak self] t in
            self?.updateRecordTipsLabel(time: t)
        }
        btn.maxPressTime = 60.0
        return btn
    }()
    
    private var voiceRecorder: AUIAICallVoiceprintRecorder? = nil
    
    open func onRecordCompleted(_ audioFileUrl: URL) {
        let hud = AVProgressHUD.showAdded(to: self.view, animated: true)
        hud.iconType = .loading
        hud.labelText = AUIAICallBundle.getString("Voiceprint information is uploading. Please wait...")
        AUIAICallVoiceprintManager.shared.start(audioFileUrl: audioFileUrl) { [weak self] error in
            guard let self = self else { return }
            hud.hide(animated: true)
            if let error = error {
                AVAlertController.show(AUIAICallBundle.getString("Voiceprint enrollment failed. Please re-record.") + "：(\(error.aicall_desc))", vc: self)
            }
            else {
                AVAlertController.aicall_show(message: AUIAICallBundle.getString("Voiceprint enrollment successful."), on: self) { [weak self] in
                    self?.goBack()
                }
            }
        }
    }
    
    private var recordTime: TimeInterval = 0
    private var recordTimer: Timer? = nil
    
    private func updateRecordTipsLabel(time: TimeInterval) {
        if time <= 0 {
            self.recordTipsLabel.text = AUIAICallBundle.getString("Recording Duration: Minimum 12s, Maximum 60s")
        }
        else {
            self.recordTipsLabel.text = String(format: AUIAICallBundle.getString("Recording: %ds"), Int(time))
        }
    }
}


@objcMembers public class AUIAICallVoiceprintRecorder: NSObject {

    private var audioRecorder: AVAudioRecorder? = nil

    private var audioFileUrl: URL? = nil

    // 开始录音
    public func startRecording() -> NSError? {
        let ts = Int(Date().timeIntervalSince1970)
        self.audioFileUrl = AUIAICallVoiceprintManager.shared.getDirectory().appendingPathComponent("\(ts)_recording.wav")

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16, // 16-bit PCM
                AVLinearPCMIsBigEndianKey: false, // 小端格式
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            self.audioRecorder = try AVAudioRecorder(url: self.audioFileUrl!, settings: settings)
            self.audioRecorder?.record()
            debugPrint("录音开始")
            return nil
        } catch {
            debugPrint("录音失败: \(error.localizedDescription)")
            return error as NSError
        }
    }

    // 停止录音
    public func stopRecording() -> URL? {
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        debugPrint("录音结束")
        return self.audioFileUrl
    }

}


open class AUIAICallVoiceprintBubbleView: UILabel {

    // 气泡样式配置
    let cornerRadius: CGFloat = 4
    let triangleHeight: CGFloat = 5
    let triangleWidth: CGFloat = 12
    
    let trianglePosRight: CGFloat = 16
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setNeedsDisplay()
    }

    
    open override func draw(_ rect: CGRect) {
        // 1. 创建气泡主体路径
        let bubblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: self.triangleHeight, width: self.bounds.width, height: self.bounds.height - self.triangleHeight - self.triangleHeight), cornerRadius: self.cornerRadius)

        // 2. 创建底部三角形路径
        let trianglePath = self.createTrianglePath()

        // 3. 合并路径
        bubblePath.append(trianglePath)
        bubblePath.usesEvenOddFillRule = true
        
        // 4. 填充
        AVTheme.bg_weak.setFill()
        bubblePath.fill()
        
        // 5.绘制边框
        AVTheme.border_weak.setStroke()
        bubblePath.lineWidth = 1
        bubblePath.stroke()
        
        // 6. 去掉小三角的上面那一横（覆盖法）
        let centerX = self.bounds.width - self.trianglePosRight
        let bottomY = self.bounds.height
        let point1 = CGPoint(x: centerX - self.triangleWidth / 2, y: bottomY - self.triangleHeight) // 左顶点
        let point2 = CGPoint(x: centerX + self.triangleWidth / 2, y: bottomY - self.triangleHeight) // 右顶点
        let linePath = UIBezierPath()
        linePath.move(to: point1)
        linePath.addLine(to: point2)
        linePath.close()
        AVTheme.bg_weak.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
        
        super.draw(rect)

    }

    private func createTrianglePath() -> UIBezierPath {
        let trianglePath = UIBezierPath()

        let centerX = self.bounds.width - self.trianglePosRight
        let bottomY = self.bounds.height

        // 向下的三角形（尖端朝下）
        let point1 = CGPoint(x: centerX, y: bottomY) // 底部中心
        let point2 = CGPoint(x: centerX - self.triangleWidth / 2, y: bottomY - self.triangleHeight) // 左顶点
        let point3 = CGPoint(x: centerX + self.triangleWidth / 2, y: bottomY - self.triangleHeight) // 右顶点

        trianglePath.move(to: point1)
        trianglePath.addLine(to: point2)
        trianglePath.addLine(to: point3)
        trianglePath.close()

        return trianglePath
    }
}
