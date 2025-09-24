//
//  LogEntry.swift
//  logging-kit
//
//  Created by tutuzhou on 2025/9/24.
//

import Foundation
import Logging

public struct LogEntry: Sendable {
    public let timestamp: Date
    public let level: Logger.Level
    public let message: Logger.Message
    public let metadata: Logger.Metadata
    public let source: String
    public let file: String
    public let function: String
    public let line: UInt
    
    public init(
        timestamp: Date,
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
    }
}

//// 扩展 Logger.Metadata 使其符合 Sendable
//extension Logger.Metadata: @unchecked Sendable {
//    // Logger.Metadata 本身是值类型，但包含的 Value 可能不是
//    // 使用 @unchecked Sendable 因为我们知道实际使用中是安全的
//}
//
//extension Logger.MetadataValue: @unchecked Sendable {
//    // 同样标记为 @unchecked Sendable
//}
