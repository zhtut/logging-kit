// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Logging

public enum LoggingKit {
    
    public static func fileHandler(config: Configuration = .init()) -> LogHandler {
        var handlers: [LogHandler] = []
        
        // 文件输出
        let fileHandler = FileDestination(config: config)
        handlers.append(fileHandler)
        
        // 设置日志系统
        let letHandlers = handlers
        if handlers.count == 1 {
            return handlers[0]
        } else {
           return MultiplexLogHandler(letHandlers)
        }
    }
    
    /// 快速设置日志系统
    public static func bootstrap(config: Configuration = .init()) {
        LoggingSystem.bootstrap { _ in Self.fileHandler(config: config) }
    }
}

