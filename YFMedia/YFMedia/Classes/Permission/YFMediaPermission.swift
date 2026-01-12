//
//  YFMediaPermission.swift
//  YFMedia
//
//  媒体权限管理
//

import UIKit
import Photos
import AVFoundation
import YFLogger

public final class YFMediaPermission {
    
    // MARK: - 相册权限
    
    /// 检查相册权限状态
    public static var photoLibraryStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /// 是否有相册权限
    public static var hasPhotoLibraryPermission: Bool {
        let status = photoLibraryStatus
        return status == .authorized || status == .limited
    }
    
    /// 请求相册权限
    /// - Parameter completion: 回调（主线程）
    public static func requestPhotoLibrary(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let status = photoLibraryStatus
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    logD("相册权限请求结果: \(newStatus.rawValue)")
                    completion(newStatus)
                }
            }
        default:
            completion(status)
        }
    }
    
    // MARK: - 相机权限
    
    /// 检查相机权限状态
    public static var cameraStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// 是否有相机权限
    public static var hasCameraPermission: Bool {
        return cameraStatus == .authorized
    }
    
    /// 相机是否可用
    public static var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// 请求相机权限
    /// - Parameter completion: 回调（主线程）
    public static func requestCamera(completion: @escaping (Bool) -> Void) {
        let status = cameraStatus
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    logD("相机权限请求结果: \(granted)")
                    completion(granted)
                }
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    // MARK: - 麦克风权限
    
    /// 检查麦克风权限状态
    public static var microphoneStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    /// 是否有麦克风权限
    public static var hasMicrophonePermission: Bool {
        return microphoneStatus == .authorized
    }
    
    /// 请求麦克风权限
    /// - Parameter completion: 回调（主线程）
    public static func requestMicrophone(completion: @escaping (Bool) -> Void) {
        let status = microphoneStatus
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    logD("麦克风权限请求结果: \(granted)")
                    completion(granted)
                }
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    // MARK: - 打开设置
    
    /// 打开系统设置
    public static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - 权限描述
    
    /// 获取权限状态描述
    public static func photoLibraryStatusDescription(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "未请求"
        case .restricted: return "受限"
        case .denied: return "已拒绝"
        case .authorized: return "已授权"
        case .limited: return "有限访问"
        @unknown default: return "未知"
        }
    }
}
