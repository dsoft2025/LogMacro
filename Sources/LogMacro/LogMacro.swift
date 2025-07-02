// The Swift Programming Language
// https://docs.swift.org/swift-book

@freestanding(expression)
public macro log(_ items: Any..., category: String = "Log") = #externalMacro(module: "LogMacroMacros", type: "LogMacro")

@attached(member, names: named(logger))
@available(iOS 14.0, macOS 11.0, *)
public macro Logging() = #externalMacro(module: "LogMacroMacros", type: "LoggingMacro")

@freestanding(expression)
public macro mlog(level: OSLogType = .default, _ items: Any..., category: String = "Log") = #externalMacro(module: "LogMacroMacros", type: "MemberLogMacro")

import Foundation
@_exported import OSLog

// MARK: - Helper

public enum LoggingMacroHelper {
    @available(iOS 14.0, macOS 11.0, *)
    public static func generateLogger(_ fileID: String = #fileID, category: String) -> Logger {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let subsystem = fileID.components(separatedBy: "/").first.map { "\(bundleId) \($0)" }
        return subsystem.map { Logger(subsystem: $0, category: category) }
            ?? Logger()
    }
    
    public static func subsystem(_ fileID: String = #fileID) -> String {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let subsystem = fileID.components(separatedBy: "/").first.map { "\(bundleId) \($0)" }
        return subsystem ?? ""
    }
}
