import Foundation

@objc class AuthorizationTool: NSObject {
    @objc static func runCommand(_ command: String, error errorOut: UnsafeMutablePointer<NSString?>?) -> Bool {
        // 构造完整 AppleScript 命令
        let fullCommand = "do shell script \"\(command.replacingOccurrences(of: "\"", with: "\\\""))\" with administrator privileges"

        var error: NSDictionary?
        if let script = NSAppleScript(source: fullCommand) {
            let result = script.executeAndReturnError(&error)
            if error == nil {
                return true
            } else {
                if let errorMessage = error?[NSAppleScript.errorBriefMessage] as? NSString {
                    errorOut?.pointee = errorMessage
                } else {
                    errorOut?.pointee = "未知错误"
                }
                return false
            }
        } else {
            errorOut?.pointee = "无法创建 AppleScript 实例"
            return false
        }
    }
}
