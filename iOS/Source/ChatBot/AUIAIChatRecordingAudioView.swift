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
        
        self.recordTipsLabel.frame = CGRect(x: 0, y: 0, width: self.av_width, height: self.getRecordTipsHeight())
        self.sendingBar.frame = CGRect(x: 20, y: self.recordTipsLabel.av_bottom + 2.0 + 14, width: self.av_width - 40, height: 40)
        self.animator.center = CGPoint(x: self.sendingBar.bounds.midX, y: self.sendingBar.bounds.midY)
        self.timeLabel.frame = CGRect(x: 12, y: 0, width: 100, height: 40)
        
    }
    
    open lazy var sendingBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.av_color(withHexString: "#3295FB", alpha: 1.0)
        view.layer.cornerRadius = 20
        return view
    }()
    
    open lazy var recordTipsLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        label.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
        label.textAlignment = .center
        return label
    }()
    
    open lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.mediumFont(14)
        label.textColor = AVTheme.text_strong
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
                self.sendingBar.backgroundColor = UIColor.av_color(withHexString: "#3295FB", alpha: 1.0)
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to send, swipe up to cancel")
                self.recordTipsLabel.textColor = AVTheme.text_strong
                
                self.animator.start()
                break
            case .CancelRecord:
                self.sendingBar.backgroundColor = UIColor.av_color(withHexString: "#F95353", alpha: 1.0)
                self.recordTipsLabel.text = AUIAIChatBundle.getString("Release to cancel")
                self.recordTipsLabel.textColor = UIColor.av_color(withHexString: "#F95353", alpha: 1.0)
                
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
        return 68.0
    }
    
    open func getRecordTipsHeight() -> CGFloat {
        return 20.0
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


