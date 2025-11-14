//
//  AUIAICallVoiceprintViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2025/07/04.
//

import UIKit
import AUIFoundation
import AVFoundation

@objcMembers open class AUIAICallVoiceprintViewController: UIViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = AUIAICallBundle.color_bg
        self.view.addSubview(self.bgLineView)
        self.backBtn.sizeToFit()
        self.backBtn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: self.backBtn.av_width + 12, height: 48)
        self.view.addSubview(self.backBtn)
        
        self.view.addSubview(self.contentView)
        
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
        
        self.speakBtn.av_size = CGSize(width: self.contentView.av_width, height: 100)
        self.speakBtn.av_centerX = self.contentView.av_width / 2.0
        self.speakBtn.av_bottom = self.contentView.av_height - UIView.av_safeBottom - 46
        
        self.updateRecordTipsLabel(time: 0)
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
        let view = AUIAICallBgLineView(frame: self.view.bounds, gradient: true)
        return view
    }()
    
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAICallBundle.getTemplateImage("ic_back"), for: .normal)
        btn.tintColor = AUIAICallBundle.color_icon
        btn.setTitle(AUIAICallBundle.getString("Voiceprint Feature Information"), for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(16)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        btn.clickBlock = { [weak self] sender in
            self?.goBack()
        }
        return btn
    }()
    
    open lazy var contentView: UIView = {
        let top = UIView.av_safeTop + 48
        let height = self.view.av_height - top
        let view = UIView(frame: CGRect(x: 0, y: top, width: self.view.av_width, height:height))
        return view
    }()
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 190, height: 190))
        view.image = AUIAICallBundle.getImage("ic_voiceprint_info")
        return view
    }()
    
    open lazy var envTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAICallBundle.color_text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = AUIAICallBundle.getString("Please read the following sentence in a quiet environment.")
        return label
    }()
    
    open lazy var recordTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AUIAICallBundle.color_text
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open lazy var readLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAICallBundle.color_text
        label.numberOfLines = 0
        label.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.lineHeightMultiple = 1.2;
        label.attributedText = NSMutableAttributedString(string: AUIAICallBundle.getString("'Woah, I think the dress you're wearing today is especially vibrant and elegant. It really complements your style – it's absolutely beautiful! Could you tell me where you bought such a lovely dress? I'd love to find one too.'"), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.kern: 0.56]);
        return label
    }()
        
    open lazy var speakBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_fill_secondary
        btn.selectedBgColor = AUIAICallBundle.color_fill_selection
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_ptt_press")
        btn.selectedImage = AUIAICallBundle.getTemplateImage("ic_ptt_release")
        btn.normalTintColor = AUIAICallBundle.color_icon
        btn.selectedTintColor = AUIAICallBundle.color_icon_Inverse
        btn.normalTitle = AUIAICallBundle.getString("Press to start recording, release to stop.")
        btn.selectedTitle = AUIAICallBundle.getString("Press to start recording, release to stop.")
        btn.iconLength = 70
        btn.iconMargin = 21
        btn.isSelected = false
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
                    self.contentView.aicall_showToast(AUIAICallBundle.getString("Recording cancelled."))
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
                        self.contentView.aicall_showToast(AUIAICallBundle.getString("Recording failed") + ": \(error.localizedDescription)")
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
        if self.recordTime < 12.0 {
            AVAlertController.show(AUIAICallBundle.getString("Voiceprint enrollment failed. Duration is less than 12 seconds."), vc: self)
            return
        }
        let hud = self.view.aicall_showProgressHud(AUIAICallBundle.getString("Voiceprint information is uploading. Please wait..."))
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
        self.recordTime = time
        if time <= 0 {
            self.recordTipsLabel.text = AUIAICallBundle.getString("Recording Duration: Minimum 12s, Maximum 60s")
        }
        else {
            self.recordTipsLabel.text = String(format: AUIAICallBundle.getString("Recording: %ds"), Int(time))
        }
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
