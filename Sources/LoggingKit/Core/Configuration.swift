//
//  Configuration.swift
//  logging-kit
//
//  Created by tutuzhou on 2025/9/24.
//

import Foundation
import Logging

public struct Configuration: Sendable {
    /// 日志保存目录
    public let directoryURL: URL
    
    /// 单个文件最大大小 (字节)
    public let maxFileSize: Int
    
    /// 最大文件数量
    public let maxFiles: Int
    
    /// 文件命名格式
    public let filenameFormat: String
    
    /// 时区，秒数偏移
    public var timeZone: TimeZone?
    
    /// 全局默认日志级别
    public let logLevel: Logger.Level
    
    /// 异步写入队列（使用全局队列避免捕获self）
    public let queue: DispatchQueue
    
    public init(
        directoryURL: URL = Self.defaultLogDirectory(),
        maxFileSize: Int = 1 * 1024 * 1024,
        maxFiles: Int = 5,
        filenameFormat: String = "yyyy-MM-dd-HH-mm-ss",
        timeZone: TimeZone? = TimeZone(secondsFromGMT: 8 * 3600),
        logLevel: Logger.Level = .info,
        queue: DispatchQueue = DispatchQueue(label: "com.loggingkit.file", qos: .utility)
    ) {
        self.directoryURL = directoryURL
        self.maxFileSize = maxFileSize
        self.maxFiles = maxFiles
        self.filenameFormat = filenameFormat
        self.timeZone = timeZone
        self.logLevel = logLevel
        self.queue = queue
    }
    
    /// 获取默认日志目录
    public static func defaultLogDirectory() -> URL {
        let logsPath = (NSHomeDirectory() as NSString).appendingPathComponent("Logs")
        return URL(filePath: logsPath)
    }
}
