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
}

public enum BDCustomTarget: DDTargetType {
    
    /// The embedded `TargetType`.
    case target(BDTargetType)

    /// Initializes a `MultiTarget`.
    public init(_ target: BDTargetType) {
        self = BDCustomTarget.target(target)
    }

    /// The embedded target's base `URL`.
    public var path: String {
        return target.path
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        return URL(fileURLWithPath: "")
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
