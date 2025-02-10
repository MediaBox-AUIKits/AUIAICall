//
//  AUIAIChatRecordingAudioView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objc public enum AUIAIChatRecordingAudioViewState: Int32 {
    case Recording = 0
    case CancelRecord = 1
}

@objcMembers open class AUIAIChatRecordingAudioView: UIView {
    
    private var recordingDurationSec: Double = 0.0
    private var timer: Timer?
    
    public var onTimeOutBlock: (()-> Void)? = nil
    let maxTime = 3 * 60

    public var viewOnShow: Bool = false {
        didSet {
            if self.viewOnShow == false {
                self.timer?.invalidate()
                self.timer = nil
                self.roundedRectangleView.stopAnimate()
            }
        }
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        self.roundedRectangleView.stopAnimate()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.addSubview(self.bgView)
        self.addSubview(self.recordTipsLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.micStatusBgView)
        self.addSubview(self.micStatusView)
        self.addSubview(self.bottomView)
        self.addSubview(self.roundedRectangleView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.frame = CGRect(x: 0.0, y: 0.0, width: self.av_width, height: 144.0)
        
        let recordTipsLabelHeight = max(self.recordTipsLabel.av_height, 18.0)
        self.recordTipsLabel.frame = CGRect(x: 20.0, y: 20.0, width: self.av_width - 20.0 * 2, height: recordTipsLabelHeight)
        
        self.micStatusBgView.frame = CGRect(x: (self.av_width - 53.0) / 2, y: CGRectGetMaxY(self.bgView.frame) - 6.0 - 53.0, width: 53.0, height: 53.0)
        self.micStatusView.frame = CGRect(x: (self.av_width - 30.0) / 2, y: CGRectGetMinY(self.micStatusBgView.frame) + (self.micStatusBgView.av_height - 30.0) / 2, width: 30.0, height: 30.0)
        self.roundedRectangleView.frame = CGRect(x: CGRectGetMidX(self.micStatusView.frame) - CGRectGetWidth(self.roundedRectangleView.frame) / 2, y: CGRectGetMinY(self.micStatusView.frame) + 1.88, width: CGRectGetWidth(self.roundedRectangleView.frame), height: CGRectGetHeight(self.roundedRectangleView.frame))

        let timeLabelHeight = max(self.timeLabel.av_height, 18.0)
        self.timeLabel.frame = CGRect(x: 20.0, y: CGRectGetMinY(self.micStatusBgView.frame) - 5.0 - timeLabelHeight, width: self.av_width - 20.0 * 2, height: timeLabelHeight)
        
        let bottomViewHeight = UIView.av_safeBottom
        self.bottomView.frame = CGRect(x: 0, y: self.av_height - bottomViewHeight, width: self.av_width, height: bottomViewHeight)
    }
    
    open lazy var bgView: UIImageView = {
        let view = UIImageView()
        view.image = AUIAIChatBundle.getImage("bg_msg_voice_record")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var recordTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_weak
        label.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    open lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.mediumFont(14)
        label.textColor = AVTheme.text_strong
        label.text = "00:00"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    open lazy var micStatusView: UIImageView = {
        let view = UIImageView()
        view.image = AUIAIChatBundle.getImage("ic_speaking_mic")
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var micStatusBgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 53.0 / 2
        view.layer.masksToBounds = true
        view.alpha = 0.65
        view.backgroundColor = UIColor.av_color(withHexString: "#CBDDFF", alpha: 0.29)
        return view
    }()
    
    open lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.av_color(withHexString: "#0E0E10", alpha: 1.0)
        return view
    }()
    
    open lazy var roundedRectangleView: RoundedRectangleView = {
        let view = RoundedRectangleView(frame: CGRect(x: 0, y: 0, width: 9.37, height: 18.75))
        return view
    }()
    
    public var viewState: AUIAIChatRecordingAudioViewState = .Recording {
        didSet {
            switch self.viewState {
            case .Recording:
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
                self.recordTipsLabel.textColor = AVTheme.text_weak
                self.micStatusView.image = AUIAIChatBundle.getImage("ic_speaking_mic")
                self.timeLabel.textColor = AVTheme.text_strong
                self.roundedRectangleView.isHidden = false
                self.roundedRectangleView.startAnimate()
                break
            case .CancelRecord:
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to cancel")
                self.recordTipsLabel.textColor = UIColor.av_color(withHexString: "#F95353", alpha: 1.0)
                self.micStatusView.image = AUIAIChatBundle.getCommonImage("ic_mute_mic")
                self.timeLabel.textColor = UIColor.av_color(withHexString: "#F95353", alpha: 1.0)
                self.roundedRectangleView.stopAnimate()
                self.roundedRectangleView.isHidden = true
                break
            }
        }
    }
    
    public func updateRecordingTime (_ second: Int) {
        self.timer?.invalidate()
        self.timer = nil
        self.recordingDurationSec = Double(second)
        self.formatTimeLabel()
    }
    
    private func formatTimeLabel() {
        let minutes = Int(self.recordingDurationSec) / 60
        let remainingSeconds = Int(self.recordingDurationSec) % 60
        self.timeLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    public func startTiming() {
        self.recordingDurationSec = 0.0
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateRecordingDuration), userInfo: nil, repeats: true)
    }
    
    @objc private func updateRecordingDuration() {
        self.recordingDurationSec += 0.1
        self.formatTimeLabel()
        if self.recordingDurationSec >= Double(self.maxTime) {
            self.onTimeOutBlock?()
        }
    }
    
    @objcMembers open class RoundedRectangleView: UIView, CAAnimationDelegate {
        
        private var currentPath: UIBezierPath?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .clear
            self.currentPath = self.createRoundedRectPath(with: frame.size)
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            self.backgroundColor = .clear
            self.currentPath = self.createRoundedRectPath(with: frame.size)
        }
        
        open override func draw(_ rect: CGRect) {
            UIColor.av_color(withHexString: "#3295FB", alpha: 1.0).setFill()
            self.currentPath?.fill()
        }
        
        private func createRoundedRectPath(with size: CGSize) -> UIBezierPath {
            return UIBezierPath(roundedRect: CGRect(x: 0, y: self.av_height - size.height, width: size.width, height: size.height), cornerRadius: size.width / 2)
        }
        
        func startAnimate() {
            self.stopAnimate()
            let fromPath = self.createRoundedRectPath(with: CGSize(width: self.av_width, height: self.av_width))
            let toPath = self.createRoundedRectPath(with: CGSize(width: self.av_width, height: self.av_height))
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = fromPath.cgPath
            animation.toValue = toPath.cgPath
            animation.duration = 0.3
            animation.autoreverses = true
            animation.repeatCount = Float.infinity
            
            self.currentPath = toPath
            self.layer.mask?.removeFromSuperlayer()
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = toPath.cgPath
            self.layer.mask = shapeLayer
            shapeLayer.add(animation, forKey: "pathChangeAnimation")
        }
        
        func stopAnimate() {
            self.layer.mask?.removeFromSuperlayer()
        }
    }
}
