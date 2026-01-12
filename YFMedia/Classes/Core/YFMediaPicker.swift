//
//  YFMediaPicker.swift
//  YFMedia
//
//  统一媒体选择入口
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import YFUIKit
import YFLogger

public final class YFMediaPicker: NSObject {
    
    // MARK: - 单例
    
    public static let shared = YFMediaPicker()
    
    // MARK: - 属性
    
    private var config = YFMediaConfig()
    private var imageCompletion: ((Result<[UIImage], YFMediaError>) -> Void)?
    private var videoCompletion: ((Result<YFVideoResult, YFMediaError>) -> Void)?
    private weak var presentingController: UIViewController?
    
    private override init() {
        super.init()
    }
    
    // MARK: - 链式配置
    
    /// 重置配置
    @discardableResult
    public func reset() -> Self {
        config = YFMediaConfig()
        return self
    }
    
    /// 设置来源
    @discardableResult
    public func source(_ source: YFMediaSource) -> Self {
        config.source = source
        return self
    }
    
    /// 设置媒体类型
    @discardableResult
    public func mediaType(_ type: YFMediaType) -> Self {
        config.mediaType = type
        return self
    }
    
    /// 设置最大选择数量
    @discardableResult
    public func maxCount(_ count: Int) -> Self {
        config.maxCount = max(1, count)
        return self
    }
    
    /// 设置是否裁剪
    @discardableResult
    public func allowsCrop(_ allows: Bool) -> Self {
        config.allowsCrop = allows
        return self
    }
    
    /// 设置裁剪比例
    @discardableResult
    public func cropRatio(_ ratio: YFCropRatio) -> Self {
        config.cropRatio = ratio
        return self
    }
    
    /// 设置压缩质量
    @discardableResult
    public func compression(_ quality: YFCompressionQuality) -> Self {
        config.compression = quality
        return self
    }
    
    /// 设置最大宽度
    @discardableResult
    public func maxWidth(_ width: CGFloat) -> Self {
        config.maxWidth = width
        return self
    }
    
    /// 设置相机设备
    @discardableResult
    public func cameraDevice(_ device: YFCameraDevice) -> Self {
        config.cameraDevice = device
        return self
    }
    
    /// 设置视频最大时长
    @discardableResult
    public func maxVideoDuration(_ duration: TimeInterval) -> Self {
        config.maxVideoDuration = duration
        return self
    }
    
    // MARK: - 选择图片
    
    /// 选择图片（链式调用）
    public func pickImages(from vc: UIViewController, completion: @escaping (Result<[UIImage], YFMediaError>) -> Void) {
        self.imageCompletion = completion
        self.presentingController = vc
        
        switch config.source {
        case .photoLibrary:
            pickFromPhotoLibrary(vc: vc)
        case .camera:
            takePhotoFromCamera(vc: vc)
        }
    }
    
    /// 选择视频（链式调用）
    public func pickVideo(from vc: UIViewController, completion: @escaping (Result<YFVideoResult, YFMediaError>) -> Void) {
        self.videoCompletion = completion
        self.presentingController = vc
        config.mediaType = .video
        
        switch config.source {
        case .photoLibrary:
            pickVideoFromLibrary(vc: vc)
        case .camera:
            recordVideoFromCamera(vc: vc)
        }
    }
    
    // MARK: - 便捷静态方法
    
    /// 选择单张图片
    public static func pickImage(
        from vc: UIViewController,
        allowsCrop: Bool = false,
        completion: @escaping (Result<UIImage, YFMediaError>) -> Void
    ) {
        shared.reset()
            .source(.photoLibrary)
            .maxCount(1)
            .allowsCrop(allowsCrop)
            .pickImages(from: vc) { result in
                switch result {
                case .success(let images):
                    if let image = images.first {
                        completion(.success(image))
                    } else {
                        completion(.failure(.loadFailed))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /// 选择多张图片
    public static func pickImages(
        from vc: UIViewController,
        maxCount: Int = 9,
        completion: @escaping (Result<[UIImage], YFMediaError>) -> Void
    ) {
        shared.reset()
            .source(.photoLibrary)
            .maxCount(maxCount)
            .pickImages(from: vc, completion: completion)
    }
    
    /// 拍照
    public static func takePhoto(
        from vc: UIViewController,
        allowsCrop: Bool = false,
        completion: @escaping (Result<UIImage, YFMediaError>) -> Void
    ) {
        shared.reset()
            .source(.camera)
            .allowsCrop(allowsCrop)
            .pickImages(from: vc) { result in
                switch result {
                case .success(let images):
                    if let image = images.first {
                        completion(.success(image))
                    } else {
                        completion(.failure(.loadFailed))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /// 选择视频
    public static func pickVideo(
        from vc: UIViewController,
        maxDuration: TimeInterval = 60,
        completion: @escaping (Result<YFVideoResult, YFMediaError>) -> Void
    ) {
        shared.reset()
            .source(.photoLibrary)
            .maxVideoDuration(maxDuration)
            .pickVideo(from: vc, completion: completion)
    }
    
    /// 录制视频
    public static func recordVideo(
        from vc: UIViewController,
        maxDuration: TimeInterval = 60,
        completion: @escaping (Result<YFVideoResult, YFMediaError>) -> Void
    ) {
        shared.reset()
            .source(.camera)
            .maxVideoDuration(maxDuration)
            .pickVideo(from: vc, completion: completion)
    }
}

// MARK: - PHPicker (iOS 14+)

extension YFMediaPicker: PHPickerViewControllerDelegate {
    
    private func pickFromPhotoLibrary(vc: UIViewController) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = config.maxCount
        
        switch config.mediaType {
        case .image:
            configuration.filter = .images
        case .video:
            configuration.filter = .videos
        case .all:
            configuration.filter = .any(of: [.images, .videos])
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        vc.present(picker, animated: true)
        
        logD("打开相册选择器: maxCount=\(config.maxCount), type=\(config.mediaType)")
    }
    
    private func pickVideoFromLibrary(vc: UIViewController) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .videos
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        vc.present(picker, animated: true)
        
        logD("打开视频选择器")
    }
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            imageCompletion?(.failure(.cancelled))
            videoCompletion?(.failure(.cancelled))
            return
        }
        
        if config.mediaType == .video {
            handleVideoResult(results.first)
        } else {
            handleImageResults(results)
        }
    }
    
    private func handleImageResults(_ results: [PHPickerResult]) {
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    defer { group.leave() }
                    
                    guard let self = self, let image = object as? UIImage else {
                        logE("图片加载失败: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    // 压缩处理
                    let compressed = YFImageCompressor.compress(image, config: self.config)
                    images.append(compressed)
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if images.isEmpty {
                self.imageCompletion?(.failure(.loadFailed))
            } else if self.config.allowsCrop && images.count == 1, let image = images.first {
                // 单张图片裁剪
                self.showCropper(for: image)
            } else {
                logD("选择了 \(images.count) 张图片")
                self.imageCompletion?(.success(images))
            }
        }
    }
    
    private func handleVideoResult(_ result: PHPickerResult?) {
        guard let result = result else {
            videoCompletion?(.failure(.loadFailed))
            return
        }
        
        let provider = result.itemProvider
        
        if provider.hasItemConformingToTypeIdentifier("public.movie") {
            provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url, error in
                guard let self = self else { return }
                
                guard let sourceURL = url else {
                    DispatchQueue.main.async {
                        self.videoCompletion?(.failure(.loadFailed))
                    }
                    return
                }
                
                // 复制到临时目录
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                
                do {
                    try FileManager.default.copyItem(at: sourceURL, to: tempURL)
                    
                    let asset = AVAsset(url: tempURL)
                    let duration = CMTimeGetSeconds(asset.duration)
                    let thumbnail = self.generateThumbnail(from: tempURL)
                    
                    let videoResult = YFVideoResult(
                        videoURL: tempURL,
                        duration: duration,
                        thumbnail: thumbnail
                    )
                    
                    DispatchQueue.main.async {
                        logD("选择视频: \(duration)秒")
                        self.videoCompletion?(.success(videoResult))
                    }
                } catch {
                    DispatchQueue.main.async {
                        logE("视频复制失败: \(error)")
                        self.videoCompletion?(.failure(.loadFailed))
                    }
                }
            }
        } else {
            videoCompletion?(.failure(.loadFailed))
        }
    }
    
    private func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            logE("生成缩略图失败: \(error)")
            return nil
        }
    }
}

// MARK: - UIImagePickerController (相机)

extension YFMediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func takePhotoFromCamera(vc: UIViewController) {
        guard YFMediaPermission.isCameraAvailable else {
            imageCompletion?(.failure(.cameraUnavailable))
            return
        }
        
        YFMediaPermission.requestCamera { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.showCamera(vc: vc, mediaType: .image)
            } else {
                self.imageCompletion?(.failure(.noPermission("相机")))
                self.showPermissionAlert(for: "相机", on: vc)
            }
        }
    }
    
    private func recordVideoFromCamera(vc: UIViewController) {
        guard YFMediaPermission.isCameraAvailable else {
            videoCompletion?(.failure(.cameraUnavailable))
            return
        }
        
        YFMediaPermission.requestCamera { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                YFMediaPermission.requestMicrophone { micGranted in
                    if micGranted {
                        self.showCamera(vc: vc, mediaType: .video)
                    } else {
                        self.videoCompletion?(.failure(.noPermission("麦克风")))
                        self.showPermissionAlert(for: "麦克风", on: vc)
                    }
                }
            } else {
                self.videoCompletion?(.failure(.noPermission("相机")))
                self.showPermissionAlert(for: "相机", on: vc)
            }
        }
    }
    
    private func showCamera(vc: UIViewController, mediaType: YFMediaType) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        
        switch mediaType {
        case .image:
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = config.allowsCrop
        case .video:
            picker.mediaTypes = ["public.movie"]
            picker.videoMaximumDuration = config.maxVideoDuration
            picker.videoQuality = .typeHigh
        case .all:
            picker.mediaTypes = ["public.image", "public.movie"]
        }
        
        switch config.cameraDevice {
        case .front:
            picker.cameraDevice = .front
        case .rear:
            picker.cameraDevice = .rear
        }
        
        vc.present(picker, animated: true)
        logD("打开相机: type=\(mediaType)")
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // 处理图片
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            let compressed = YFImageCompressor.compress(image, config: config)
            
            if config.allowsCrop && !picker.allowsEditing {
                showCropper(for: compressed)
            } else {
                logD("拍照完成")
                imageCompletion?(.success([compressed]))
            }
            return
        }
        
        // 处理视频
        if let videoURL = info[.mediaURL] as? URL {
            let asset = AVAsset(url: videoURL)
            let duration = CMTimeGetSeconds(asset.duration)
            let thumbnail = generateThumbnail(from: videoURL)
            
            let result = YFVideoResult(
                videoURL: videoURL,
                duration: duration,
                thumbnail: thumbnail
            )
            
            logD("录制视频: \(duration)秒")
            videoCompletion?(.success(result))
            return
        }
        
        imageCompletion?(.failure(.loadFailed))
        videoCompletion?(.failure(.loadFailed))
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        imageCompletion?(.failure(.cancelled))
        videoCompletion?(.failure(.cancelled))
    }
    
    private func showPermissionAlert(for type: String, on vc: UIViewController) {
        let alert = UIAlertController(
            title: "无法访问\(type)",
            message: "请在设置中允许访问\(type)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            YFMediaPermission.openSettings()
        })
        vc.present(alert, animated: true)
    }
}

// MARK: - 裁剪

extension YFMediaPicker {
    
    private func showCropper(for image: UIImage) {
        guard let vc = presentingController else {
            imageCompletion?(.success([image]))
            return
        }
        
        let cropper = YFImageCropper(image: image, ratio: config.cropRatio) { [weak self] result in
            switch result {
            case .success(let croppedImage):
                let compressed = YFImageCompressor.compress(croppedImage, config: self?.config ?? YFMediaConfig())
                self?.imageCompletion?(.success([compressed]))
            case .failure(let error):
                self?.imageCompletion?(.failure(error))
            }
        }
        
        vc.present(cropper, animated: true)
    }
}
