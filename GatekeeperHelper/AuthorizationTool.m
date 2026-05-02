//  AuthorizationTool.m

#import "AuthorizationTool.h"

@implementation AuthorizationTool

+ (BOOL)runCommand:(NSString *)command error:(NSString * _Nullable * _Nullable)errorOut {
    // 将命令放到 /bin/bash -lc "..."，并处理引号转义，确保 PATH 与登录 Shell 一致
    NSString *escaped = [command stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *bash = [NSString stringWithFormat:@"/bin/bash -lc \\\"%@\\\"", escaped];

    NSString *scriptSource = [NSString stringWithFormat:
                              @"do shell script \"%@\" with administrator privileges",
                              bash];

    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptSource];
    NSDictionary *errInfo = nil;
    NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&errInfo];

    if (!result) {
        if (errorOut) {
            // AppleScript 常见错误码：
            // -128 用户取消； 1.. 任意非零为命令本身非 0 退出码
            NSString *msg = errInfo[NSLocalizedDescriptionKey];
            if (!msg) msg = errInfo[@"NSAppleScriptErrorMessage"];
            if (!msg) msg = [NSString stringWithFormat:@"执行失败（错误码：%@）",
                             errInfo[@"NSAppleScriptErrorNumber"] ?: @(-1)];
            *errorOut = msg;
        }
        return NO;
    }

    // 走到这里说明命令实际以 0 退出（成功）
    return YES;
}

@end
