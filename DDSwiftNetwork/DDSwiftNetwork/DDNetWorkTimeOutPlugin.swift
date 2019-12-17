//
//  DDNetWorkTimeOutPlugin.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya
import Result

public final class DDNetWorkTimeOutPlugin: PluginType {
    
    /// 请求超时设置
    /// - Parameter request: <#request description#>
    /// - Parameter target: <#target description#>
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var timeOutRequest = request
        if let target = target.typeExtension,
            target.timeOut > 0 {
            timeOutRequest.timeoutInterval = TimeInterval(target.timeOut)
        }
        return timeOutRequest
    }
}
