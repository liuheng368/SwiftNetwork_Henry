//
//  DDNetworkLoggerPlugin.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/11.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya
import Result

public final class DDNetworkLoggerPlugin: PluginType {
    
    /// Request-打印
    /// - Parameter target: <#target description#>
    public func willSend(_ request: RequestType, target: TargetType) {
        var header : String = "[:]"
        if let headers = target.headers {
            header = headers.reduce("[", {"\($0)'\($1.key)'='\($1.value)', "}) + "]"
        }
        
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
        
        let strResult =
        """
        [NetworkLogger:Request
        Method: \(target.method)
        URL: \(target.baseURL)\(target.path)
        Header: \(header)
        Parms: \(parm)]
        """
        
        #if DEBUG
        print(strResult)
        #endif
        
        NotificationCenter.default.post(name: DDSWIFTNETWORK_REQUEST_LOGGER_KEY, object: strResult)
    }
    
    
    /// Response打印
    /// - Parameter result: <#result description#>
    /// - Parameter target: <#target description#>
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        var responseResult : Any
        if case .success(let responses) = result,
            let str = try? JSONSerialization.jsonObject(with: responses.data, options: .mutableContainers){
            responseResult = str
        }else{
            responseResult = "Received empty network response for \(target.baseURL)\(target.path)"
        }
        let strResult =
        """
        [NetworkLogger:Response
        reslut:\(responseResult)]
        """
        
        #if DEBUG
        print(strResult)
        #endif
        
        NotificationCenter.default.post(name: DDSWIFTNETWORK_RESPONSE_LOGGER_KEY, object: strResult)
    }
}
