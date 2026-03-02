//
//  AUIAICallListPicker.swift
//  AUIAICall
//
//  Created by Bingo on 2026/1/21.
//

import UIKit
import AUIFoundation


@objcMembers open class AUIAICallListPicker: AVBaseControllPanel {

    public init(width: CGFloat, title: String, list: [String], selected: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        
        self.backgroundColor = AUIAICallBundle.color_bg_elevated
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.headerView.isHidden = true
        self.titleView.text = title
        self.titleView.textAlignment = .left
        self.titleView.font = AVTheme.mediumFont(16)
        self.titleView.frame = CGRect(x: 24, y: 20, width: self.av_width - 54, height: 24)
        self.titleView.removeFromSuperview()
        self.addSubview(self.titleView)
        
        let exitBtn = AVBlockButton(frame: CGRect(x: self.av_width - 44 - 10, y: 10, width: 44, height: 44))
        exitBtn.setImage(AUIAICallBundle.getTemplateImage("ic_exit"), for: .normal)
        exitBtn.tintColor = AUIAICallBundle.color_icon
        exitBtn.clickBlock = {[weak self] sender in
            self?.hide()
        }
        self.addSubview(exitBtn)
        
        self.pickerListText = list
        var top = 60.0
        self.pickerListText.forEach { text in
            let c = self.createPickerView(text: text)
            c.container.av_top = top
            self.addSubview(c.container)
            self.pickerListView.append(c)
            top = c.container.av_bottom
        }
        if selected < self.pickerListText.count && selected >= 0 {
            self.pickerListView[selected].right.isHidden = false
            self.selected = selected
        }
        
        top = top + UIView.av_safeBottom + 12
        self.av_height = top
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func present(_ cp: AVBaseControllPanel, on onView: UIView, backgroundType bgType: AVControllPanelBackgroundType) {
        super.present(cp, on: onView, backgroundType: bgType)
        cp.bgViewOnShowing?.backgroundColor = AUIAICallBundle.color_bg_mask
    }
    
    private var pickerListText: [String] = []
    private var pickerListView: [(container: UIView, right: UIImageView)] = []
    private var selected: Int = 0
    
    private func createPickerView(text: String) -> (container: UIView, right: UIImageView) {
        let view = UIView(frame: CGRect(x: 24, y: 0, width: self.av_width - 48, height: 50))
        let label = UILabel(frame: view.bounds)
        label.font = AVTheme.regularFont(16.0)
        label.textColor = AUIAICallBundle.color_text
        label.text = text
        view.addSubview(label)
        
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        image.image = AUIAICallBundle.getTemplateImage("ic_picker")
        image.tintColor = AUIAICallBundle.color_icon
        image.av_right = view.av_width
        image.av_centerY = view.av_height / 2.0
        image.isHidden = true
        view.addSubview(image)
        
        let line = UIView(frame: CGRect(x: 0, y: view.av_height - 1, width: view.av_width, height: 1))
        line.backgroundColor = AUIAICallBundle.color_border_secondary
        view.addSubview(line)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPickerViewClicked(recognizer:))))

        return (view, image)
    }
    
    @objc open func onPickerViewClicked(recognizer: UIGestureRecognizer) {
        
        let clickView = recognizer.view
        if let index = self.pickerListView.firstIndex(where: { (container: UIView, right: UIImageView) in
            return container == clickView
        }) {
            self.pickerListView[self.selected].right.isHidden = true
            self.pickerListView[index].right.isHidden = false
            self.selected = index
            self.onPickerSelected?(index, self.pickerListText[index])
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.hide()
            }
        }
        
    }
    
    open var onPickerSelected: ((_ index: Int, _ text: String) -> Void)? = nil

}

