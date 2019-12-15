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
}

public enum DDTask {
    
//GET
    case getRequestParam(parameters: [String: Any])
    //default OutputFormat:prettyPrinted
    case getRequestEncodable(Encodable)
    
//POST
    case postRequestParam(bodyParameters: [String: Any]=[:],
        urlParameters: [String: Any])
    //default OutputFormat:prettyPrinted
    case postRequestEncodable(bodyParameters: [String: Any]=[:],
        urlEncodable: Encodable)
    
//Download
    case downloadParameters(parameters: [String: Any],
        encoding: URLEncoding,
        destination: DownloadDestination)
    
//Upload
    case uploadCompositeMultipart(sd:[MultipartFormData],
        urlParameters: [String: Any])
}
