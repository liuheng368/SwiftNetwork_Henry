//
//  DDNetworkError.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/14.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

public enum DDNetworkError : Error {
    //request
    case encoding(error: Error)
    case encodeFormat
    //network
    case network(errorCode:Int,error: Error)
    case networkState(errorResponse:Response)
    //response
    case responseJson(data:Data)
    case responseEncoding(data:Data)
}

extension DDNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .encoding:
            return "[DDNetworkError:请求参数无法通过Encodable解析]"
        case .encodeFormat:
            return "[DDNetworkError:请求参数无法格式化]"
        case .network(let errorCode, let error):
            return "[DDNetworkError:请求失败错误码:\(errorCode)\n\(error)]"
        case .networkState(let errorResponse):
            return "[DDNetworkError:请求State失败:错误码\(errorResponse.statusCode)\n错误内容\(errorResponse))]"
        case .responseJson(_):
            return "[DDNetworkError:响应Data无法解析为Json]"
        case .responseEncoding(data: _):
            return "[DDNetworkError:响应Data无法通过Encoding解析]"
        }
    }
    
    /// Depending on error type, returns an underlying `Error`.
    public var underlyingError: Swift.Error? {
        switch self {
        case .encoding(let error): return error
        case .network(_, let error): return error
        default: return nil
        }
    }
}

extension DDNetworkError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
