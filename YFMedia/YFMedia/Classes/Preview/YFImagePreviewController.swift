//
//  YFImagePreviewController.swift
//  YFMedia
//
//  图片预览控制器
//

import UIKit
import YFUIKit
import YFLogger

public class YFImagePreview {
    
    /// 预览单张图片
    public static func show(
        image: UIImage,
        from vc: UIViewController,
        allowSave: Bool = false
    ) {
        show(images: [image], initialIndex: 0, from: vc, allowSave: allowSave)
    }
    
    /// 预览多张图片
    public static func show(
        images: [UIImage],
        initialIndex: Int = 0,
        from vc: UIViewController,
        allowSave: Bool = false
    ) {
        let preview = YFImagePreviewController(
            images: images,
            initialIndex: initialIndex,
            allowSave: allowSave
        )
        preview.modalPresentationStyle = .fullScreen
        preview.modalTransitionStyle = .crossDissolve
        vc.present(preview, animated: true)
    }
}

public class YFImagePreviewController: UIViewController {
    
    // MARK: - 属性
    
    private let images: [UIImage]
    private let allowSave: Bool
    private var currentIndex: Int
    
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .black
        cv.delegate = self
        cv.dataSource = self
        cv.register(YFImagePreviewCell.self, forCellWithReuseIdentifier: "ImageCell")
        return cv
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var toolbar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    // MARK: - 初始化
    
    public init(images: [UIImage], initialIndex: Int = 0, allowSave: Bool = false) {
        self.images = images
        self.currentIndex = min(max(0, initialIndex), images.count - 1)
        self.allowSave = allowSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePageLabel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
        
        // 滚动到初始位置
        if currentIndex > 0 {
            collectionView.scrollToItem(
                at: IndexPath(item: currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        toolbar.addSubview(closeButton)
        toolbar.addSubview(pageLabel)
        
        if allowSave {
            toolbar.addSubview(saveButton)
        }
        
        setupConstraints()
        
        // 单击关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            pageLabel.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor),
            pageLabel.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor)
        ])
        
        if allowSave {
            NSLayoutConstraint.activate([
                saveButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16),
                saveButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
                saveButton.widthAnchor.constraint(equalToConstant: 44),
                saveButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    private func updatePageLabel() {
        if images.count > 1 {
            pageLabel.text = "\(currentIndex + 1) / \(images.count)"
        } else {
            pageLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        let image = images[currentIndex]
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            logE("保存图片失败: \(error)")
            YFToast.error("保存失败")
        } else {
            logD("保存图片成功")
            YFToast.success("已保存到相册")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension YFImagePreviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! YFImagePreviewCell
        cell.configure(with: images[indexPath.item])
        return cell
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentIndex = page
        updatePageLabel()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension YFImagePreviewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 避免与 Cell 内部的手势冲突
        return touch.view == view || touch.view == collectionView
    }
}

// MARK: - 预览 Cell

private class YFImagePreviewCell: UICollectionViewCell {
    
    private var currentImage: UIImage?
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 5.0
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bouncesZoom = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .black
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        // 双击缩放
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func configure(with image: UIImage) {
        currentImage = image
        imageView.image = image
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = contentView.bounds
        
        guard let image = currentImage else { return }
        
        scrollView.zoomScale = 1.0
        
        let containerSize = scrollView.bounds.size
        guard containerSize.width > 0 && containerSize.height > 0 else { return }
        
        let imageSize = image.size
        
        // 计算适合容器的尺寸
        let widthRatio = containerSize.width / imageSize.width
        let heightRatio = containerSize.height / imageSize.height
        let ratio = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(
            width: imageSize.width * ratio,
            height: imageSize.height * ratio
        )
        
        // 设置 imageView 的大小和位置
        imageView.frame = CGRect(
            x: (containerSize.width - scaledSize.width) / 2,
            y: (containerSize.height - scaledSize.height) / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )
        
        scrollView.contentSize = scaledSize
    }
    
    @objc private func doubleTapped(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let zoomScale: CGFloat = 2.5
            let width = scrollView.bounds.width / zoomScale
            let height = scrollView.bounds.height / zoomScale
            let rect = CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.zoomScale = 1.0
        imageView.image = nil
        currentImage = nil
    }
}

extension YFImagePreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 缩放后居中显示
        let containerSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let offsetX = max((containerSize.width - contentSize.width) / 2, 0)
        let offsetY = max((containerSize.height - contentSize.height) / 2, 0)
        
        imageView.center = CGPoint(
            x: contentSize.width / 2 + offsetX,
            y: contentSize.height / 2 + offsetY
        )
    }
}
