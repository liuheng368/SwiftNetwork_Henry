//
//  bdSupTArget.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya


public protocol BDTargetType {

    /// 请求路径
    var path: String { get }

    /// 请求体
    var task: DDTask { get }
    
    /// 请求弹框文案
    var HUDString : String { get }
}

extension BDTargetType {
    var HUDString: String {
        return "sdsd"
    }
}

public enum BDCustomTarget: DDTargetType {
    public init(_ target: BDTargetType) {
        self = BDCustomTarget.target(target)
    }
    
    public var whiteList: [String] {
        return []
    }
    
    public var timeOut: Int {
        return 30
    }
    
    /// The embedded `TargetType`.
    case target(BDTargetType)

    /// Initializes a `MultiTarget`.
    

    /// The embedded target's base `URL`.
    public var path: String {
        return target.path
    }
    
    public var HUDString: String {
        return target.HUDString
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        return URL(fileURLWithPath: "https://www.douban.com")
    }

    /// The `Task` of the embedded target.
    public var task: DDTask {
        return .getRequestParam(parameters: [:])
    }

    /// The headers of the embedded target.
    public var headers: [String: String]? {
        return [:]
    }

    /// The embedded `TargetType`.
    public var target: BDTargetType {
        switch self {
        case .target(let target): return target
        }
    }
    
    public var bLmitate: Bool {
        return false
    }
}
