//
//  MoyaProvider+Custom.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/9.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

extension MoyaProvider {
    
    /// Request-打印
    /// - Parameter target: <#target description#>
    public final class func DDEndpointMapping(target: Target) -> Endpoint {
        #if DEBUG
        var parm : String
        switch target.task {
        case .requestPlain:
            parm = target.path
        case .requestParameters(parameters: let dic, encoding: _):
            parm = dic.reduce("[", {"\($0)'\($1.key)'='\($1.value)', "}) + "]"
        case .requestCompositeData(bodyData: let data, urlParameters: let dic):
            parm = dic.reduce("[", {"\($0)'\($1.key)'='\($1.value)', "}) + "]" + "\nbody: \(String(data: data, encoding: .utf8) ?? "(invalid request)")"
        default:
            parm = "\(target.task)"
        }
        print("""
            Request
            Method: \(target.method)
            URL: \(target.baseURL)\(target.path)
            Parms: \(parm)
            """)
        #endif
        return MoyaProvider.defaultEndpointMapping(for: target)
    }
}
