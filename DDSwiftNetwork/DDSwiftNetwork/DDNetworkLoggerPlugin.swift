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
        if isWhiteList(target) {return}
        
        var header : String = "[:]"
        if let headers = target.headers {
            header = headers.reduce("[", {"\($0)'\($1.key)'='\($1.value)', "}) + "]"
        }
        
        let strResult =
        """
        [NetworkLogger:Request
        Method: \(target.method)
        URL: \(target.baseURL)\(target.path)
        Header: \(header)
        Parms: \(requestParm(target))]
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
        if isWhiteList(target) {return}
        
        var responseResult : Any = ""
        if case .success(let responses) = result {
            if let str = try? JSONSerialization.jsonObject(with: responses.data, options: .mutableContainers){
                responseResult = str
            }else{
                responseResult = "Received error/empty response data for\n \(target.baseURL)\(target.path)"
            }
        }else if case .failure(let error) = result{
            responseResult = "Received error network response for\n \(target.baseURL)\(target.path)\nErrorCode:\(error.errorCode)\nRequest:\(requestParm(target))"
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
    
    /// 请求参数格式化
    /// - Parameter target: <#target description#>
    private func requestParm(_ target:TargetType) -> String {
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
        return parm
    }
    
    
}
