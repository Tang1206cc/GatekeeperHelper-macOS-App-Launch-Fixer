//  AuthorizationTool.h

#import <Foundation/Foundation.h>

@interface AuthorizationTool : NSObject

/// 以管理员权限执行命令。
/// @param command 要执行的 shell 命令（可包含空格与引号，我们会处理转义）
/// @param errorOut 若失败，返回可读的错误信息（可为空）
/// @return YES 表示命令执行成功（exit code == 0）；NO 表示用户取消、认证失败或命令出错。
+ (BOOL)runCommand:(NSString *)command error:(NSString * _Nullable * _Nullable)errorOut;

@end
