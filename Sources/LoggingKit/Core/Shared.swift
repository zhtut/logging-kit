//
//  Shared.swift
//  logging-kit
//
//  Created by tutuzhou on 2025/9/24.
//
import Foundation
import Logging

public extension Logger {
    
    init(config: Configuration) {
        self = Logger(label: "file") { _ in
            return LoggingKit.fileHandler(config: config)
        }
    }
    
    static let shared = Self(config: .shared)
}

@inlinable
public func logTrace(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .trace,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logDebug(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .debug,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logInfo(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .info,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logNotice(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .notice,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logWarning(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .warning,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logError(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .error,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}

@inlinable
public func logCritical(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    source: @autoclosure () -> String? = nil,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    Logger.shared.log(
        level: .critical,
        message(),
        metadata: metadata(),
        source: source(),
        file: file,
        function: function,
        line: line
    )
}
