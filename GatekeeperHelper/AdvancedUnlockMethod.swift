//
//  AdvancedUnlockMethod.swift
//  GatekeeperHelper
//
//  专用于“xxx意外退出”问题的签名方式选择
//

import Foundation

enum AdvancedUnlockMethod: CaseIterable {
    case appBundle // 应用程序签名
    case executable // Unix 可执行文件签名

    var description: String {
        switch self {
        case .appBundle:
            return "应用程序签名（首选）"
        case .executable:
            return "Unix 可执行文件签名（若不成功再选）"
        }
    }
}
