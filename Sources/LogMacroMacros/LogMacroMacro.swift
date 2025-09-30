import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoggingMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let allowTypes: [SyntaxKind] = [
          .classDecl,
          .structDecl,
          .actorDecl,
        ]

        guard allowTypes.contains(declaration.kind) else {
          let msg = "@Logger는 Class, Struct, Actor에만 사용 가능합니다."
          throw MacroExpansionErrorMessage(msg)
        }

        return [
          DeclSyntax(
            #"""
            private lazy var osLog: OSLog = {
                OSLog(subsystem: LoggingMacroHelper.subsystem(#fileID), category: String(describing: Self.self)) 
            }()
            private lazy var logger: Logger = {
                LoggingMacroHelper.generateLogger(category: String(describing: Self.self))
            }()
            """#),
        ]
    }
}

public struct LogMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard (node.arguments.first?.expression) != nil else {
            fatalError("The macro requires a value")
        }

        var category = "Log"
        let extractedExpr: Slice<LabeledExprListSyntax>
        if node.arguments.last?.label?.text == "category" {
            category = (node.arguments.last?.expression.trimmedDescription)!.replacingOccurrences(of: "\"", with: "")
            extractedExpr = node.arguments.dropLast(1)
        } else {
            extractedExpr = node.arguments.dropLast(0)
        }
        let message = "\(extractedExpr.map({ String(describing: "\\(String(describing: \($0.expression)))") }).joined(separator: " "))"
        
        return """
            {
                #if DEBUG
                if #available(iOS 14.0, macOS 11.0, *) {
                    os_log(.default, log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: \(literal: category.description)), "\(raw: message)")
                } else {
                    os_log("%{public}@", log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: \(literal: category.description)), "\(raw: message)")
                }
                #endif
            }() 
            """
    }
}


public struct MemberLogMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard (node.arguments.first?.expression) != nil else {
            fatalError("The macro requires a value")
        }
        
        var level: String = ".default"
        let list: Slice<LabeledExprListSyntax>
        if node.arguments.first?.label?.text == "level" {
            level = node.arguments.first?.expression.trimmedDescription.replacingOccurrences(of: "\"", with: "") ?? ".default"
            list = node.arguments.dropFirst()
        } else {
            list = node.arguments.dropFirst(0)
        }

        let extractedExpr: Slice<LabeledExprListSyntax> = list.dropLast(0)
        let message = "\(extractedExpr.map({ String(describing: "\\(String(describing: \($0.expression)))") }).joined(separator: " "))"
        
        return """
            ({
                #if DEBUG
                if #available(iOS 14.0, macOS 11.0, *) {
                    self.logger.log(level: OSLogType\(raw: level), "\(raw: message)")
                } else {
                    os_log("%{public}@", log: self.osLog, type: OSLogType\(raw: level), "\(raw: message)")
                }
                #endif
            })()
            """
    }
}

@main
struct LogMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoggingMacro.self,
        LogMacro.self,
        MemberLogMacro.self
    ]
}
