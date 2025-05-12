//
//  AUIAIChatMarkdownView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/03/12.
//

import UIKit
import AUIFoundation
import SDWebImage


@objcMembers open class AUIAIChatImageViewer: AVBaseViewController {

    public init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.hiddenMenuButton = true
        
        self.scrollView = UIScrollView(frame: self.contentView.bounds)
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.contentView.addSubview(self.scrollView)

        self.imageView = UIImageView(image: self.image)
        self.imageView.contentMode = .scaleAspectFit
        self.scrollView.addSubview(self.imageView)
        
        self.updateImageViewZoomScale()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    let image: UIImage!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    // 调整图片的初始缩放比例
    private func updateImageViewZoomScale() {
        guard let image = self.imageView.image else { return }

        let scrollViewSize = self.scrollView.bounds.size
        let imageSize = image.size

        let imageAspectRatio = imageSize.width / imageSize.height
        let scrollViewAspectRatio = scrollViewSize.width / scrollViewSize.height

        let scale: CGFloat
        if imageAspectRatio > scrollViewAspectRatio {
            // 图片宽度大于 UIScrollView 宽度
            scale = scrollViewSize.width / imageSize.width
        } else {
            // 图片高度大于 UIScrollView 高度
            scale = scrollViewSize.height / imageSize.height
        }

        self.scrollView.minimumZoomScale = scale
        self.scrollView.maximumZoomScale = scale + 3
        self.scrollView.zoomScale = scale

        self.centerImageView()
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            // 放大到最大缩放比例的一半
            self.scrollView.setZoomScale((self.scrollView.maximumZoomScale - self.scrollView.minimumZoomScale) / 2.0 + self.scrollView.minimumZoomScale, animated: true)
        } else {
            // 缩小到最小缩放比例
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
}

extension AUIAIChatImageViewer: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImageView()
    }

    private func centerImageView() {
        let boundsSize = self.scrollView.bounds.size
        var frameToCenter = self.imageView.frame

        // 水平居中
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        // 垂直居中
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        self.imageView.frame = frameToCenter
    }
}
