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
