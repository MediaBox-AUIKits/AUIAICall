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

    public private(set) var viewOnShow: Bool = false
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        self.animator.stop()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.layer.addSublayer(self.gradientlayer)
        self.addSubview(self.sendingBar)
        self.addSubview(self.recordTipsLabel)
        self.sendingBar.addSubview(self.timeLabel)
        self.sendingBar.addSubview(self.animator)
        self.isUserInteractionEnabled = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let y = self.getRecordTipsHeight() + 8.0
        self.gradientlayer.frame = CGRect(x: 0, y: 0, width: self.av_width, height: y)
        self.recordTipsLabel.frame = CGRect(x: 0, y: self.getRecordTipsHeight() - 18 - 16, width: self.av_width, height: 18)
        self.sendingBar.frame = CGRect(x: 24, y: y, width: self.av_width - 48, height: 50)
        self.animator.center = CGPoint(x: self.sendingBar.bounds.midX, y: self.sendingBar.bounds.midY)
        self.timeLabel.frame = CGRect(x: 12, y: 0, width: 100, height: 50)
        
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.gradientlayer.colors = [AUIAIChatBundle.color_bg_elevated.withAlphaComponent(0.0).cgColor, AUIAIChatBundle.color_bg_elevated.cgColor]
    }
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 32.0/108.0)
        layer.colors = [AUIAIChatBundle.color_bg_elevated.withAlphaComponent(0.0).cgColor, AUIAIChatBundle.color_bg_elevated.cgColor]
        return layer
    }()

    
    open lazy var sendingBar: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAIChatBundle.color_primary
        view.layer.cornerRadius = 4
        return view
    }()
    
    open lazy var recordTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAIChatBundle.color_text_tertiary
        label.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
        label.textAlignment = .center
        return label
    }()
    
    open lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.mediumFont(14)
        label.textColor = AUIAIChatBundle.color_text_identical
        label.text = "0''"
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    open lazy var animator: AUIAICallVolumeBarAnimator = {
        let animator = AUIAICallVolumeBarAnimator(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        return animator
    }()
    
    public var viewState: AUIAIChatRecordingAudioViewState = .Recording {
        didSet {
            switch self.viewState {
            case .Recording:
                self.sendingBar.backgroundColor = AUIAIChatBundle.color_primary
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
                self.recordTipsLabel.textColor = AUIAIChatBundle.color_text_tertiary
                
                self.animator.start()
                break
            case .CancelRecord:
                self.sendingBar.backgroundColor = AUIAIChatBundle.color_error
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to cancel")
                self.recordTipsLabel.textColor = AUIAIChatBundle.color_error
                
                self.animator.stop()
                break
            }
        }
    }
    
    private func formatTimeLabel() {
        let minutes = Int(self.recordingDurationSec) / 60
        let remainingSeconds = Int(self.recordingDurationSec) % 60
        if minutes > 0 {
            self.timeLabel.text = String(format: "%d'%d''", minutes, remainingSeconds)
        }
        else {
            self.timeLabel.text = String(format: "%d''", remainingSeconds)
        }
    }
    
    public func resetTiming() {
        self.timer?.invalidate()
        self.timer = nil
        self.recordingDurationSec = Double(0)
        self.formatTimeLabel()
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
}

extension AUIAIChatRecordingAudioView {
    
    open func getSendingBarHeight() -> CGFloat {
        return 66.0
    }
    
    open func getRecordTipsHeight() -> CGFloat {
        return 108.0
    }
    
    open func presentOnView(parent: UIView, bottom: CGFloat) {
        let height = self.getSendingBarHeight() + self.getRecordTipsHeight()
        self.frame = CGRectMake(0, bottom - height, parent.av_width, height)
        parent.addSubview(self)
        
        self.resetTiming()
        self.viewState = .Recording
        self.startTiming()
        self.viewOnShow = true
    }
    
    open func dismiss() {
        self.removeFromSuperview()
        
        self.resetTiming()
        self.viewOnShow = false
        
        self.animator.stop()
    }
}


