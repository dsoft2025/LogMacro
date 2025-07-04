import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LogMacroMacros)
import LogMacroMacros

let testMacros: [String: Macro.Type] = [
    "log": LogMacro.self,
    "Logger": LoggingMacro.self,
    "mlog": MemberLogMacro.self,
]
#endif

final class LogMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(LogMacroMacros)
        assertMacroExpansion(
            #"""
            #log(a + b)
            """#,
            expandedSource: #"""
            {
                #if DEBUG
                if #available(iOS 14.0, macOS 11.0, *) {
                    os_log(.default, log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "Log"), "\(String(describing: a + b))")
                } else {
                    os_log("%{public}@", log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "Log"), "\(String(describing: a + b))")
                }
                #endif
            }()
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(LogMacroMacros)
        assertMacroExpansion(
            #"""
            #log("The value = \(result)")
            """#,
            expandedSource: #"""
            {
                #if DEBUG
                if #available(iOS 14.0, macOS 11.0, *) {
                    os_log(.default, log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "Log"), "\(String(describing: "The value = \(result)"))")
                } else {
                    os_log("%{public}@", log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "Log"), "\(String(describing: "The value = \(result)"))")
                }
                #endif
            }()
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroWithMember() throws {
        #if canImport(LogMacroMacros)
        assertMacroExpansion(
            #"""
            #mlog("x = \(self.x)")
            """#,
            expandedSource: #"""
            ({
                #if DEBUG
                if #available(iOS 14.0, macOS 11.0, *) {
                    logger.log(level: OSLogType.default, "\(String(describing: "x = \(self.x)"))")
                } else {
                    os_log("%{public}@", log: osLog, type: OSLogType.default, "\(String(describing: "x = \(self.x)"))")
                }
                #endif
                })()
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
