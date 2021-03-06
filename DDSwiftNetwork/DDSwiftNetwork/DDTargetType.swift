//
//  DDTask.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya


/// Request参数体
public protocol DDTargetType {

    /// 根路径
    var baseURL: URL { get }

    /// 请求路径
    var path: String { get }

    /// 请求体
    var task: DDTask { get }

    /// 请求头
    var headers: [String: String]? { get }

    /// 是否是伪登录
    var bLmitate : Bool { get }
    
    /// 请求弹框文案
    var HUDString : String { get }
    
    /// 白名单
    var whiteList : [String] { get }
    
    /// 请求超时定义
    var timeOut : Int { get }
    
    /// 登录过期的操作
    var loginOutTime : ()->Void { get }
}

public enum DDTask {
//Default
    case `default`
    
//GET
    case getRequestParam(parameters: [String: Any])
    //default OutputFormat:prettyPrinted
    case getRequestEncodable(Encodable?)
    
//POST
    //请求时会将body转为Data
    case postRequestParam(bodyParameters: Any?,
        urlParameters: [String: Any])
    case postRequestEncodable(bodyParameters: Any?,
        urlEncodable: Encodable?)
//Download
    case downloadParameters(parameters: [String: Any],
        encoding: URLEncoding,
        destination: DownloadDestination)
    
//Upload
    case uploadCompositeMultipart(sd:[MultipartFormData],
        urlParameters: [String: Any])
}
