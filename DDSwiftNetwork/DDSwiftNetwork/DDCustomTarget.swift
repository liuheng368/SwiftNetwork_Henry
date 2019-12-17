//
//  DDCustomTarget.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

/// DDTargetType转换为TargetTypeExtension协议
public enum DDCustomTarget: TargetTypeExtension {
    
    public init(_ target: DDTargetType) {
        self = DDCustomTarget.target(target)
    }
    
    case target(DDTargetType)

    public var target: DDTargetType {
        switch self {
        case .target(let target): return target
        }
    }

    /// The embedded target's base `URL`.
    public var path: String {
        return target.path
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        return target.baseURL
    }
    
    public var whiteList: [String] {
        return target.whiteList
    }
    
    public var timeOut: Int {
        return target.timeOut
    }
    
    public var HUDString : String {
        return target.HUDString
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
            do {
                return .requestParameters(parameters: try JSONEncoderForParam(encodable), encoding: URLEncoding.default)
            } catch {
                #if DEBUG
                print("\(error.localizedDescription)")
                #endif
                return .requestParameters(parameters: [:], encoding: URLEncoding.default)
            }
        case .postRequestParam(let bodyParameters, let urlParameters):
            return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: URLEncoding.httpBody, urlParameters: urlParameters)
        case .postRequestEncodable(let bodyParameters, let urlEncodable):
            do {
                return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: URLEncoding.httpBody, urlParameters: try JSONEncoderForParam(urlEncodable))
            } catch {
                #if DEBUG
                print("\(error.localizedDescription)")
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
        var strEncode = ""
        switch target.task {
        case .getRequestParam(parameters: let dic),
             .postRequestParam(bodyParameters: _, urlParameters: let dic),
             .downloadParameters(parameters: let dic, encoding: _, destination: _),
             .uploadCompositeMultipart(sd: _, urlParameters: let dic):
            strEncode = DDParamEscape(dic).escape()
        case .getRequestEncodable(let encodable),
             .postRequestEncodable(bodyParameters: _, urlEncodable: let encodable):
            do {
                strEncode = DDParamEscape(try JSONEncoderForParam(encodable)).escape()
            } catch {
                #if DEBUG
                print("\(error.localizedDescription)")
                #endif
            }
        }
        guard var header = target.headers else {
            return ["":""]
        }
        if target.bLmitate {
            header["Verification-Hash"] = "Alan.P"
        }else{
            header["Verification-Hash"] = "\(strEncode)Athens".MD5()
        }
        return header
    }

    /// The sampleData of the embedded target.
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}

fileprivate extension DDCustomTarget {
    /// 将Encodable转换为[String:Any]
    /// - Parameter urlEncodable: <#urlEncodable description#>
    func JSONEncoderForParam(_ urlEncodable: Encodable)throws -> [String:Any] {
        do {
            let encodable = AnyEncodable(urlEncodable)
            let data = try JSONEncoder().encode(encodable)
            let anyObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let _param = anyObj as? [String:Any]{
                return _param
            }else{
                throw DDNetworkError.encodeFormat
            }
        } catch {
            throw DDNetworkError.encoding(error: error)
        }
    }

    /// 将Encodable转为具体类型，否则无法用于解析
    struct AnyEncodable: Encodable {
        private let encodable: Encodable
        public init(_ encodable: Encodable) {
            self.encodable = encodable
        }
        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
    }
}
