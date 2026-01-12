//
//  YFLogFileWriter.swift
//  YFLogger
//
//  日志文件写入器
//

import Foundation

/// 日志文件写入器
public class YFLogFileWriter {
    
    private let config: YFLogConfig
    private var fileHandle: FileHandle?
    private var currentFileURL: URL?
    private let queue = DispatchQueue(label: "com.yf.logger.file")
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public init(config: YFLogConfig) {
        self.config = config
        setupDirectory()
    }
    
    deinit {
        closeFile()
    }
    
    // MARK: - Public
    
    /// 写入日志
    public func write(_ message: String) {
        queue.async { [weak self] in
            self?.writeToFile(message)
        }
    }
    
    /// 获取所有日志文件
    public func getLogFiles() -> [URL] {
        guard let directory = config.logDirectory else { return [] }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            return files
                .filter { $0.pathExtension == "log" }
                .sorted { $0.lastPathComponent > $1.lastPathComponent }
        } catch {
            return []
        }
    }
    
    /// 清理日志文件
    public func clearLogs() {
        queue.async { [weak self] in
            self?.closeFile()
            guard let directory = self?.config.logDirectory else { return }
            
            do {
                let files = try FileManager.default.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                )
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            } catch {
                print("[YFLogger] 清理日志失败: \(error)")
            }
        }
    }
    
    // MARK: - Private
    
    private func setupDirectory() {
        guard let directory = config.logDirectory else { return }
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("[YFLogger] 创建日志目录失败: \(error)")
            }
        }
    }
    
    private func writeToFile(_ message: String) {
        // 检查是否需要切换文件
        checkAndRotateFile()
        
        // 确保文件已打开
        if fileHandle == nil {
            openFile()
        }
        
        // 写入
        guard let data = (message + "\n").data(using: .utf8) else { return }
        fileHandle?.write(data)
    }
    
    private func openFile() {
        guard let directory = config.logDirectory else { return }
        
        let dateString = dateFormatter.string(from: Date())
        let fileName = "\(config.filePrefix)_\(dateString).log"
        let fileURL = directory.appendingPathComponent(fileName)
        
        // 如果文件不存在，创建它
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        
        do {
            fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle?.seekToEndOfFile()
            currentFileURL = fileURL
        } catch {
            print("[YFLogger] 打开日志文件失败: \(error)")
        }
    }
    
    private func closeFile() {
        try? fileHandle?.close()
        fileHandle = nil
        currentFileURL = nil
    }
    
    private func checkAndRotateFile() {
        guard let fileURL = currentFileURL else { return }
        
        // 检查日期是否变化
        let currentDate = dateFormatter.string(from: Date())
        let fileDate = extractDate(from: fileURL.lastPathComponent)
        
        if currentDate != fileDate {
            closeFile()
            cleanOldFiles()
            return
        }
        
        // 检查文件大小
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = attributes[.size] as? UInt64 ?? 0
            
            if fileSize >= config.maxFileSize {
                closeFile()
                // 重命名当前文件，添加序号
                rotateCurrentFile(fileURL)
            }
        } catch {
            // 忽略错误
        }
    }
    
    private func rotateCurrentFile(_ fileURL: URL) {
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let directory = fileURL.deletingLastPathComponent()
        
        // 查找下一个可用序号
        var index = 1
        var newURL: URL
        repeat {
            newURL = directory.appendingPathComponent("\(baseName)_\(index).log")
            index += 1
        } while FileManager.default.fileExists(atPath: newURL.path)
        
        do {
            try FileManager.default.moveItem(at: fileURL, to: newURL)
        } catch {
            print("[YFLogger] 轮转日志文件失败: \(error)")
        }
    }
    
    private func cleanOldFiles() {
        guard let directory = config.logDirectory else { return }
        
        do {
            var files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            // 按创建时间排序（最新的在前）
            files.sort { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
            
            // 删除超出数量限制的文件
            if files.count > config.maxFileCount {
                for file in files.dropFirst(config.maxFileCount) {
                    try FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("[YFLogger] 清理旧日志文件失败: \(error)")
        }
    }
    
    private func extractDate(from fileName: String) -> String? {
        // 从 "log_2024-01-15.log" 提取 "2024-01-15"
        let pattern = "\\d{4}-\\d{2}-\\d{2}"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: fileName, range: NSRange(fileName.startIndex..., in: fileName)),
              let range = Range(match.range, in: fileName) else {
            return nil
        }
        return String(fileName[range])
    }
}
