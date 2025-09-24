//
//  FileDestination.swift
//  logging-kit
//
//  Created by tutuzhou on 2025/9/24.
//

import Foundation
import Logging

/// 文件日志目的地 - 使用 Actor 确保线程安全
public final actor FileDestination: LogHandler {
    private let config: Configuration
    private var currentFileHandle: FileHandle?
    private var currentFileSize: Int = 0
    private var currentFilename: String = ""
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        if let timeZone = config.timeZone {
            dateFormatter.timeZone = timeZone
        }
        return dateFormatter
    }()
    
    // LogHandler 协议要求
    public nonisolated(unsafe) var logLevel: Logger.Level
    public nonisolated(unsafe) var metadata: Logger.Metadata = [:]
    
    public nonisolated subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public init(config: Configuration = .init()) {
        self.config = config
        self.logLevel = config.logLevel
        
        Task {
            await setupLogDirectory()
            await rotateLogFileIfNeeded()
        }
    }
    
    deinit {
        // 在 actor 隔离上下文中安全关闭文件
        nonisolatedCloseCurrentFile()
    }
    
    private nonisolated func nonisolatedCloseCurrentFile() {
        Task {
            await closeCurrentFile()
        }
    }
    
    private func closeCurrentFile() {
        currentFileHandle?.closeFile()
        currentFileHandle = nil
    }
}

extension FileDestination {
    /// 设置 metadata 值（actor 隔离）
    private func setMetadataValue(_ value: Logger.Metadata.Value?, forKey key: String) {
        if let value = value {
            metadata[key] = value
        } else {
            metadata.removeValue(forKey: key)
        }
    }
    
    /// LogHandler 协议的主要方法
    nonisolated public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        // 快速检查日志级别（非隔离访问）
        guard level >= logLevel else { return }
        
        // 创建日志条目（在调用线程上）
        let logEntry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            metadata: metadata ?? [:],
            source: source,
            file: file,
            function: function,
            line: line
        )
        
        // 异步发送到 actor 进行处理
        Task { [weak self] in
            await self?.processLogEntry(logEntry)
        }
    }
    
    /// Actor 隔离的处理方法
    private func processLogEntry(_ entry: LogEntry) async {
        // 这里可以添加条件过滤逻辑
        if shouldWriteEntryToFile(entry) {
            await writeLogEntry(entry)
        }
    }
    
    /// 检查是否应该写入文件（支持条件过滤）
    private func shouldWriteEntryToFile(_ entry: LogEntry) -> Bool {
        // 默认全部写入，可以通过 metadata 控制
        if let writeToFile = entry.metadata["writeToFile"] {
            switch writeToFile {
            case .string(let value):
                return value.lowercased() == "true"
            case .stringConvertible(let value):
                return String(describing: value).lowercased() == "true"
            default:
                break
            }
        }
        return true
    }
}

extension FileDestination {
    /// 设置日志目录（actor 隔离）
    private func setupLogDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: config.directoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            print("创建日志目录失败: \(error)")
        }
    }
    
    /// 生成基于时间的文件名
    private func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = config.filenameFormat
        formatter.timeZone = config.timeZone ?? TimeZone.current
        let timestamp = formatter.string(from: Date())
        return "log-\(timestamp).log"
    }
    
    /// 轮转日志文件（actor 隔离）
    private func rotateLogFileIfNeeded() {
        closeCurrentFile()
        
        // 生成新文件名
        currentFilename = generateFilename()
        let fileURL = currentLogFileURL()
        
        // 创建新文件
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        
        do {
            currentFileHandle = try FileHandle(forWritingTo: fileURL)
            currentFileSize = 0
            
            // 写入文件头
            let dateString = dateFormatter.string(from: Date())
            let header = "=== LoggingKit Start: \(dateString) ===\n"
            if let data = header.data(using: .utf8) {
                try writeData(data)
            }
            
        } catch {
            print("创建日志文件失败: \(error)")
        }
        
        // 清理旧文件
        cleanupOldFiles()
    }
    
    /// 获取当前日志文件路径
    private func currentLogFileURL() -> URL {
        return config.directoryURL.appendingPathComponent(currentFilename)
    }
    
    /// 异步写入数据
    private func writeData(_ data: Data) throws {
        try currentFileHandle?.write(contentsOf: data)
        currentFileHandle?.synchronizeFile()
        currentFileSize += data.count
    }
    
    /// 写入日志条目
    private func writeLogEntry(_ entry: LogEntry) async {
        let logString = formatLogEntry(entry) + "\n"
        
        guard let data = logString.data(using: .utf8) else { return }
        
        // 检查文件大小，需要时轮转
        if currentFileSize + data.count > config.maxFileSize {
            rotateLogFileIfNeeded()
        }
        
        // 写入文件
        do {
            try writeData(data)
        } catch {
            print("写入日志失败: \(error)")
        }
    }
    
    /// 格式化日志条目
    private func formatLogEntry(_ entry: LogEntry) -> String {
        let timestamp = entry.timestamp
        let dateString = dateFormatter.string(from: timestamp)
        return "\(dateString) [\(entry.level)] \(entry.message) \(formatMetadata(entry.metadata))"
    }
    
    /// 格式化 metadata
    private func formatMetadata(_ metadata: Logger.Metadata) -> String {
        guard !metadata.isEmpty else { return "" }
        return metadata.map { "\($0)=\($1)" }.joined(separator: " ")
    }
    
    /// 清理旧文件
    private func cleanupOldFiles() {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: config.directoryURL,
                includingPropertiesForKeys: [.creationDateKey]
            )
            
            let logFiles = files.filter { $0.lastPathComponent.hasPrefix("log-") }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2
                }
            
            // 删除超过数量的文件
            if logFiles.count > config.maxFiles {
                for file in logFiles.dropFirst(config.maxFiles) {
                    try FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("清理旧文件失败: \(error)")
        }
    }
}
