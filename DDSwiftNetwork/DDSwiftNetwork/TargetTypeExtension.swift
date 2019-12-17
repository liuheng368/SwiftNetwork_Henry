//
//  TargetTypeExtension.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

internal extension TargetType {
    
    /// 协议类型转换，使用前需解包
    var typeExtension : TargetTypeExtension? {
        return self as? TargetTypeExtension
    }
}

internal protocol TargetTypeExtension : TargetType {
    
    /// 白名单
    /// 不会触发弹框、错误提示
    var whiteList : [String] {
        get
    }
    
    /// 请求超时定义
    var timeOut : Int {
        get
    }
    
    /// 请求弹框文案展示
    /// tips:图片上传不在此控制
    /// tips:不设置该字段则不会展示HUD
    var HUDString : String {
        get
    }
}

