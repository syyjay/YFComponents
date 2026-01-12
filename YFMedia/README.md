# YFMedia

轻量级媒体选择和处理库，基于 iOS 14+ 的 `PHPickerViewController`。

## 功能特性

- 📷 **图片选择** - 单选/多选，支持裁剪
- 📸 **拍照** - 前置/后置摄像头
- 🎬 **视频选择/录制** - 支持时长限制
- ✂️ **图片裁剪** - 自由/正方形/自定义比例
- 🗜 **图片压缩** - 质量/尺寸/大小压缩
- 👁 **图片预览** - 缩放、翻页、保存

## 安装

```ruby
pod 'YFMedia', :path => './Components/YFMedia'
```

> 需要 iOS 14.0+

---

## 快速开始

### 选择图片

```swift
import YFMedia

// 选择单张图片
YFMediaPicker.pickImage(from: self) { result in
    switch result {
    case .success(let image):
        imageView.image = image
    case .failure(let error):
        print(error)
    }
}

// 选择多张图片
YFMediaPicker.pickImages(from: self, maxCount: 9) { result in
    switch result {
    case .success(let images):
        // images: [UIImage]
    case .failure(let error):
        print(error)
    }
}
```

### 拍照

```swift
// 简单拍照
YFMediaPicker.takePhoto(from: self) { result in
    switch result {
    case .success(let image):
        imageView.image = image
    case .failure(let error):
        print(error)
    }
}
```

### 视频选择/录制

```swift
// 选择视频
YFMediaPicker.pickVideo(from: self, maxDuration: 60) { result in
    switch result {
    case .success(let video):
        print("时长: \(video.duration)秒")
        print("缩略图: \(video.thumbnail)")
        print("URL: \(video.videoURL)")
    case .failure(let error):
        print(error)
    }
}

// 录制视频
YFMediaPicker.recordVideo(from: self, maxDuration: 15) { result in
    // ...
}
```

---

## 链式配置

使用链式 API 进行高级配置：

```swift
YFMediaPicker.shared
    .reset()                    // 重置配置
    .source(.photoLibrary)      // 来源：相册 / .camera
    .mediaType(.image)          // 类型：.image / .video / .all
    .maxCount(9)                // 最多选择数量
    .allowsCrop(true)           // 允许裁剪
    .cropRatio(.square)         // 裁剪比例：.free / .square / .ratio(16/9)
    .compression(.medium)       // 压缩质量：.none / .low / .medium / .high
    .maxWidth(1080)             // 最大宽度
    .cameraDevice(.rear)        // 相机：.front / .rear
    .pickImages(from: self) { result in
        // ...
    }
```

---

## 图片裁剪

```swift
// 选择并裁剪（正方形）
YFMediaPicker.shared
    .source(.photoLibrary)
    .allowsCrop(true)
    .cropRatio(.square)
    .pickImages(from: self) { result in
        // 返回已裁剪的图片
    }

// 拍照并裁剪（16:9）
YFMediaPicker.shared
    .source(.camera)
    .allowsCrop(true)
    .cropRatio(.ratio(16/9))
    .pickImages(from: self) { result in
        // ...
    }
```

### 裁剪比例

| 值 | 说明 |
|---|---|
| `.free` | 自由裁剪（使用图片原始比例） |
| `.square` | 正方形 1:1 |
| `.ratio(CGFloat)` | 自定义比例（宽:高） |

---

## 图片压缩

### 使用选择器压缩

```swift
YFMediaPicker.shared
    .compression(.medium)       // 质量压缩
    .maxWidth(1080)             // 尺寸压缩
    .pickImages(from: self) { ... }
```

### 单独使用压缩工具

```swift
// 质量压缩
let compressed = YFImageCompressor.compress(image, quality: .medium)

// 压缩到指定大小
let compressed = YFImageCompressor.compress(image, maxSizeKB: 200)

// 按最大宽度压缩
let compressed = YFImageCompressor.compress(image, maxWidth: 1080)

// 获取图片大小
let size = YFImageCompressor.dataSize(of: image, quality: 0.8)
let sizeStr = YFImageCompressor.formatSize(size)  // "1.5 MB"
```

### 压缩质量

| 值 | 压缩率 |
|---|---|
| `.none` | 1.0（不压缩） |
| `.low` | 0.3 |
| `.medium` | 0.5 |
| `.high` | 0.8 |
| `.custom(CGFloat)` | 自定义 0.0-1.0 |

---

## 图片预览

```swift
// 预览单张图片
YFImagePreview.show(image: image, from: self)

// 预览多张图片（可翻页）
YFImagePreview.show(images: images, initialIndex: 0, from: self)

// 允许保存到相册
YFImagePreview.show(image: image, from: self, allowSave: true)
```

预览功能：
- 双击缩放
- 捏合缩放
- 左右翻页
- 单击关闭
- 保存到相册

---

## 权限管理

```swift
// 检查相册权限
if YFMediaPermission.hasPhotoLibraryPermission {
    // 有权限
}

// 请求相册权限
YFMediaPermission.requestPhotoLibrary { status in
    switch status {
    case .authorized, .limited:
        // 可以访问
    case .denied, .restricted:
        // 无权限
    default:
        break
    }
}

// 检查相机权限
YFMediaPermission.requestCamera { granted in
    if granted {
        // 有权限
    } else {
        // 引导去设置
        YFMediaPermission.openSettings()
    }
}
```

---

## 错误处理

```swift
YFMediaPicker.pickImage(from: self) { result in
    switch result {
    case .success(let image):
        // 成功
    case .failure(let error):
        switch error {
        case .cancelled:
            // 用户取消
        case .noPermission(let type):
            // 无权限（相机/相册）
        case .cameraUnavailable:
            // 相机不可用
        case .loadFailed:
            // 加载失败
        case .cropFailed:
            // 裁剪失败
        default:
            print(error.localizedDescription)
        }
    }
}
```

---

## API 参考

### YFMediaPicker

| 方法 | 说明 |
|------|------|
| `pickImage(from:allowsCrop:completion:)` | 选择单张图片 |
| `pickImages(from:maxCount:completion:)` | 选择多张图片 |
| `takePhoto(from:allowsCrop:completion:)` | 拍照 |
| `pickVideo(from:maxDuration:completion:)` | 选择视频 |
| `recordVideo(from:maxDuration:completion:)` | 录制视频 |

### YFImageCompressor

| 方法 | 说明 |
|------|------|
| `compress(_:quality:)` | 按质量压缩 |
| `compress(_:maxSizeKB:)` | 压缩到指定大小 |
| `compress(_:maxWidth:)` | 按最大宽度压缩 |
| `dataSize(of:quality:)` | 获取图片数据大小 |
| `formatSize(_:)` | 格式化文件大小 |

### YFImagePreview

| 方法 | 说明 |
|------|------|
| `show(image:from:allowSave:)` | 预览单张图片 |
| `show(images:initialIndex:from:allowSave:)` | 预览多张图片 |

### YFMediaPermission

| 属性/方法 | 说明 |
|----------|------|
| `hasPhotoLibraryPermission` | 是否有相册权限 |
| `hasCameraPermission` | 是否有相机权限 |
| `isCameraAvailable` | 相机是否可用 |
| `requestPhotoLibrary(completion:)` | 请求相册权限 |
| `requestCamera(completion:)` | 请求相机权限 |
| `openSettings()` | 打开系统设置 |

---

## 注意事项

1. **Info.plist 配置**

需要在 `Info.plist` 中添加权限描述：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>

<key>NSCameraUsageDescription</key>
<string>需要使用相机拍照</string>

<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风录制视频</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>
```

2. **iOS 14+ Only**

本库基于 `PHPickerViewController`，仅支持 iOS 14.0 及以上版本。

3. **模拟器限制**

相机功能在模拟器上不可用，请使用真机测试。

---

## License

MIT License
