//
//  DDNetworkError.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/14.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation

public enum DDNetworkError : Error {
    
    case encodingFailed(error: Error)
    case encodeFormatFailed
}

extension DDNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "[DDNetworkError:请求参数无法通过Encodable解析]"
        case .encodeFormatFailed:
            return "[DDNetworkError:请求参数无法格式化]"
        }
        
        
    }
    
    /// Depending on error type, returns an underlying `Error`.
    public var underlyingError: Swift.Error? {
        switch self {
        case .encodingFailed(let error): return error
        case .encodeFormatFailed: return nil
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
