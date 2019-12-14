//
//  DDParamEscape.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/13.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

struct DDParamEscape {
    let param : [String: Any]
    
    init(_ param_ : [String: Any]) {
        self.param = param_
    }
    
    /// 把字典进行进行转义
    public func escape() -> String {
        var components: [(String, String)] = []
        
        for key in param.keys.sorted(by: <) {
            let value = param[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

// MARK: Encoding
extension DDParamEscape {
    
    fileprivate func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escaping(key), value.boolValue ? "1" : "0"))
            } else {
                components.append((escaping(key), escaping("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escaping(key), bool ? "1" : "0"))
        } else {
            components.append((escaping(key), escaping("\(value)")))
        }

        return components
    }
    
    
    /// 进行百分号转义
    /// - Parameter string: <#string description#>
    fileprivate func escaping(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        return escaped
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
