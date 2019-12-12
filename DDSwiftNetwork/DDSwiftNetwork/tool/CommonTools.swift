//
//  CommonTools.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

/// 白名单中是否包含该targetType
/// - Parameter target: <#target description#>
func isWhiteList(_ target:TargetType) -> Bool {
    guard let _ = target.whiteList.firstIndex(of: target.path) else {
        return false
    }
    return true
}
