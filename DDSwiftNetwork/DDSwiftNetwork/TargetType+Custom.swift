//
//  TargetType+Custom.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
    
    /// 白名单
    /// 不会触发弹框、错误提示
    var whiteList : [String] {
        return []
    }
    
    /// 请求超时定义
    var timeOut : Int {
        return 60
    }
    
    /// 请求弹框文案展示
    /// tips:图片上传不在此控制
    /// tips:不设置该字段则不会展示HUD
    var HUDString : String {
        return ""
    }
    
    /// 是否是伪登录
    var bLmitate : Bool {
        return false
    }
}

