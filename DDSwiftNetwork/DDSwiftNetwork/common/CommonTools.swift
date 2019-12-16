//
//  CommonTools.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya
import CommonCrypto

/// 白名单中是否包含该targetType
/// - Parameter target: <#target description#>
func isWhiteList(_ target:TargetType) -> Bool {
    guard let _ = target.whiteList.firstIndex(of: target.path) else {
        return false
    }
    return true
}


extension String {
    
    /// 将字符串进行MD5加密
    public func MD5() -> String {
        if let str = self.cString(using: .utf8){
            let strLength = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
            let digestLen = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
            CC_MD5(str, strLength, result)
            let hash = NSMutableString()
            for i in 0 ..< digestLen {
                hash.appendFormat("%02x", result[i])
            }
            result.deinitialize(count: digestLen)
            return String(hash)
        }
        return ""
    }
}
