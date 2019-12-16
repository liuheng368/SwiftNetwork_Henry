//
//  DDNetworkResponse.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/16.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya



class DDMoyaProvider<Target: DDTargetType>: MoyaProvider<DDCustomTarget> {
    /// 请求发起者初始化
    init() {
        
        super.init(plugins: [DDNetworkLoggerPlugin(),
                             DDNetworkActivityPlugin(),
                             DDNetWorkTimeOutPlugin()])
    }
}
