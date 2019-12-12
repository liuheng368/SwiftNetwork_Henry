//
//  DDCustomTarget.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

public enum DDCustomTarget: TargetType {
    case target(DDTargetType)

    public var target: DDTargetType {
        switch self {
        case .target(let target): return target
        }
    }
    
    public init(_ target: DDTargetType) {
        self = DDCustomTarget.target(target)
    }

    /// The embedded target's base `URL`.
    public var path: String {
        return target.path
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        return target.baseURL
    }

    /// The HTTP method of the embedded target.
    public var method: Moya.Method {
        switch target.task {
        case .getRequestEncodable(_),
             .getRequestParam(parameters: _),
             .downloadParameters(parameters: _, encoding: _, destination: _):
            return .get
        case .postRequestParam(bodyParameters: _, urlParameters: _),
             .postRequestEncodable(bodyParameters: _, urlEncodable: _),
             .uploadCompositeMultipart(_, urlParameters: _):
            return .post
        }
    }

    /// The `Task` of the embedded target.
    public var task: Task {
        switch target.task {
        case .getRequestParam(parameters: let urlParameters):
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
        case .getRequestEncodable(let encodable):
            if let dic = JSONEncoderForParam(encodable){
                return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            }else{
                #if DEBUG
                print("[NetworkLogger:getRequestEncodable failed encoder]")
                #endif
                return .requestParameters(parameters: [:], encoding: URLEncoding.default)
            }
        case .postRequestParam(let bodyParameters, let urlParameters):
            return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: URLEncoding.httpBody, urlParameters: urlParameters)
        case .postRequestEncodable(let bodyParameters, let urlEncodable):
            if let dic = JSONEncoderForParam(urlEncodable){
                return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: URLEncoding.httpBody, urlParameters: dic)
            }else{
                #if DEBUG
                print("[NetworkLogger:postRequestEncodable failed encoder]")
                #endif
                return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: URLEncoding.httpBody, urlParameters: [:])
            }
        case .downloadParameters(let parameters, let encoding, let destination):
            return .downloadParameters(parameters: parameters, encoding: encoding, destination: destination)
        case .uploadCompositeMultipart(let sd, let urlParameters):
            return .uploadCompositeMultipart(sd, urlParameters: urlParameters)
        }
    }

    /// The headers of the embedded target.
    public var headers: [String: String]? {
        target.task
        return target.headers
    }

    /// The sampleData of the embedded target.
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    /// 将Encodable转换为[String:Any]
    /// - Parameter urlEncodable: <#urlEncodable description#>
    private func JSONEncoderForParam(_ urlEncodable: Encodable) -> [String:Any]? {
        let encodable = AnyEncodable(urlEncodable)
        if let data = try? JSONEncoder().encode(encodable),
            let anyObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            return anyObj as? [String:Any]
        }else{
            return nil
        }
    }

    /// 将Encodable转为具体类型，否则无法用于解析
    private struct AnyEncodable: Encodable {
        private let encodable: Encodable
        public init(_ encodable: Encodable) {
            self.encodable = encodable
        }
        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
    }
}

