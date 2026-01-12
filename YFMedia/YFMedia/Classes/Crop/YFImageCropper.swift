//
//  YFImageCropper.swift
//  YFMedia
//
//  图片裁剪控制器
//

import UIKit
import YFUIKit
import YFLogger

public class YFImageCropper: UIViewController {
    
    // MARK: - 属性
    
    private let originalImage: UIImage
    private let cropRatio: YFCropRatio
    private let completion: (Result<UIImage, YFMediaError>) -> Void
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bouncesZoom = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 5.0
        sv.backgroundColor = .black
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var cropOverlay: YFCropOverlayView = {
        let view = YFCropOverlayView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("完成", for: .normal)
        btn.setTitleColor(.systemYellow, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var toolbar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
    
    // MARK: - 初始化
    
    public init(
        image: UIImage,
        ratio: YFCropRatio = .free,
        completion: @escaping (Result<UIImage, YFMediaError>) -> Void
    ) {
        self.originalImage = image
        self.cropRatio = ratio
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCropFrame()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(cropOverlay)
        view.addSubview(toolbar)
        toolbar.addSubview(cancelButton)
        toolbar.addSubview(confirmButton)
        
        imageView.image = originalImage
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        cropOverlay.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            cropOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            cropOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cropOverlay.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 80 + view.safeAreaInsets.bottom),
            
            cancelButton.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 20),
            
            confirmButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -20),
            confirmButton.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 20)
        ])
    }
    
    private func setupCropFrame() {
        let cropFrame = calculateCropFrame()
        cropOverlay.cropRect = cropFrame
        
        // 设置图片视图大小
        let imageSize = originalImage.size
        let scrollViewSize = scrollView.bounds.size
        
        // 计算适合的缩放比例
        let widthRatio = scrollViewSize.width / imageSize.width
        let heightRatio = scrollViewSize.height / imageSize.height
        let ratio = max(widthRatio, heightRatio)
        
        let scaledSize = CGSize(
            width: imageSize.width * ratio,
            height: imageSize.height * ratio
        )
        
        imageView.frame = CGRect(origin: .zero, size: scaledSize)
        scrollView.contentSize = scaledSize
        
        // 居中
        let offsetX = max(0, (scaledSize.width - scrollViewSize.width) / 2)
        let offsetY = max(0, (scaledSize.height - scrollViewSize.height) / 2)
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
        
        // 设置最小缩放
        let cropSize = cropFrame.size
        let minScale = max(cropSize.width / scaledSize.width, cropSize.height / scaledSize.height)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    private func calculateCropFrame() -> CGRect {
        let scrollViewSize = scrollView.bounds.size
        let padding: CGFloat = 20
        let maxWidth = scrollViewSize.width - padding * 2
        let maxHeight = scrollViewSize.height - padding * 2
        
        var cropSize: CGSize
        
        if let ratio = cropRatio.value {
            // 固定比例
            if maxWidth / ratio <= maxHeight {
                cropSize = CGSize(width: maxWidth, height: maxWidth / ratio)
            } else {
                cropSize = CGSize(width: maxHeight * ratio, height: maxHeight)
            }
        } else {
            // 自由裁剪（使用图片比例）
            let imageRatio = originalImage.size.width / originalImage.size.height
            if maxWidth / imageRatio <= maxHeight {
                cropSize = CGSize(width: maxWidth, height: maxWidth / imageRatio)
            } else {
                cropSize = CGSize(width: maxHeight * imageRatio, height: maxHeight)
            }
        }
        
        let x = (scrollViewSize.width - cropSize.width) / 2
        let y = (scrollViewSize.height - cropSize.height) / 2
        
        return CGRect(x: x, y: y, width: cropSize.width, height: cropSize.height)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true) {
            self.completion(.failure(.cancelled))
        }
    }
    
    @objc private func confirmTapped() {
        guard let croppedImage = cropImage() else {
            completion(.failure(.cropFailed))
            dismiss(animated: true)
            return
        }
        
        dismiss(animated: true) {
            logD("裁剪完成: \(croppedImage.size)")
            self.completion(.success(croppedImage))
        }
    }
    
    private func cropImage() -> UIImage? {
        let cropFrame = cropOverlay.cropRect
        let zoomScale = scrollView.zoomScale
        let contentOffset = scrollView.contentOffset
        
        // 计算在原图上的裁剪区域
        let imageViewSize = imageView.frame.size
        let imageSize = originalImage.size
        
        let scaleX = imageSize.width / imageViewSize.width
        let scaleY = imageSize.height / imageViewSize.height
        
        let cropRect = CGRect(
            x: (cropFrame.origin.x + contentOffset.x) * scaleX / zoomScale,
            y: (cropFrame.origin.y + contentOffset.y) * scaleY / zoomScale,
            width: cropFrame.width * scaleX / zoomScale,
            height: cropFrame.height * scaleY / zoomScale
        )
        
        guard let cgImage = originalImage.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
}

// MARK: - UIScrollViewDelegate

extension YFImageCropper: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    private func centerImageView() {
        let cropFrame = cropOverlay.cropRect
        let contentSize = scrollView.contentSize
        
        var inset = UIEdgeInsets.zero
        
        if contentSize.width < cropFrame.width {
            inset.left = (cropFrame.width - contentSize.width) / 2
            inset.right = inset.left
        } else {
            inset.left = cropFrame.origin.x
            inset.right = scrollView.bounds.width - cropFrame.maxX
        }
        
        if contentSize.height < cropFrame.height {
            inset.top = (cropFrame.height - contentSize.height) / 2
            inset.bottom = inset.top
        } else {
            inset.top = cropFrame.origin.y
            inset.bottom = scrollView.bounds.height - cropFrame.maxY
        }
        
        scrollView.contentInset = inset
    }
}

// MARK: - 裁剪遮罩层

private class YFCropOverlayView: UIView {
    
    var cropRect: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 半透明遮罩
        context.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
        context.fill(rect)
        
        // 清除裁剪区域
        context.clear(cropRect)
        
        // 绘制边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(cropRect)
        
        // 绘制网格线
        let thirdWidth = cropRect.width / 3
        let thirdHeight = cropRect.height / 3
        
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(0.5)
        
        // 垂直线
        for i in 1...2 {
            let x = cropRect.origin.x + thirdWidth * CGFloat(i)
            context.move(to: CGPoint(x: x, y: cropRect.origin.y))
            context.addLine(to: CGPoint(x: x, y: cropRect.maxY))
        }
        
        // 水平线
        for i in 1...2 {
            let y = cropRect.origin.y + thirdHeight * CGFloat(i)
            context.move(to: CGPoint(x: cropRect.origin.x, y: y))
            context.addLine(to: CGPoint(x: cropRect.maxX, y: y))
        }
        
        context.strokePath()
        
        // 绘制四角
        let cornerLength: CGFloat = 20
        let cornerWidth: CGFloat = 3
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(cornerWidth)
        
        let corners = [
            (cropRect.origin, CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)),
            (CGPoint(x: cropRect.maxX, y: cropRect.origin.y), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 1)),
            (CGPoint(x: cropRect.origin.x, y: cropRect.maxY), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: -1)),
            (CGPoint(x: cropRect.maxX, y: cropRect.maxY), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: -1))
        ]
        
        for (point, dir1, dir2) in corners {
            context.move(to: CGPoint(x: point.x + dir1.x * cornerLength, y: point.y + dir1.y * cornerLength))
            context.addLine(to: point)
            context.addLine(to: CGPoint(x: point.x + dir2.x * cornerLength, y: point.y + dir2.y * cornerLength))
        }
        
        context.strokePath()
    }
}
