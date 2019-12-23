//
//  DDNetworkActivityPlugin.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya
import Result
import MBProgressHUD

final class DDNetworkActivityPlugin: PluginType {
    
    fileprivate var hud : MBProgressHUD?
    lazy var activialCount = 0
    
    func willSend(_ request: RequestType, target: TargetType) {
        if isWhiteList(target) {return}
        if let target = target.typeExtension{
            if target.HUDString.count <= 0 {return}
            if let hud = hud {
                hud.label.text = target.HUDString
            }else{
                hud = DDShowHUD.progress(title: target.HUDString).show()
            }
            objc_sync_enter(self)
            activialCount += 1
            objc_sync_exit(self)
        }
    }

    /// Called by the provider as soon as a response arrives, even if the request is canceled.
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if isWhiteList(target) {return}
        
        if activialCount > 1 {
            objc_sync_enter(self)
            activialCount -= 1
            objc_sync_exit(self)
        }else{
            hud?.hideInMainThread()
            activialCount = 0
        }
        
        if case .success(let response) = result {
            do {
                _ = try response.filterSuccessfulStatusCodes()
            } catch {
                do {
                    if let dic = try response.mapJSON() as? [String:Any],
                        let strError = dic["errorMsg"] as? String {
                        DDShowHUD.error(title: strError, duration: 2).show()
                    }else{DDShowHUD.error(title: "请求错误", duration: 2).show()}
                } catch {
                    DDShowHUD.error(title: "请求错误", duration: 2).show()
                }
            }
        }else if case .failure(let error) = result{
            if let strError = cuteMessageWithErrorCode(error.errorCode) {
                DDShowHUD.error(title: strError, duration: 2).show()
            }
        }
    }
    
    /// 将错误码转为 #萌萌哒#版本
    /// debug下展示错误真实描述
    /// 未知情况不弹框提示
    /// - Parameter errCode: <#errCode description#>
    private func cuteMessageWithErrorCode(_ errCode:Int) -> String? {
        var errorMessage : String?
#if DEBUG
        switch (errCode) {
        case 300:
            errorMessage = "针对请求，服务器可执行多种操作。 服务器可根据请求者 (user agent) 选择一项操作，或提供操作列表供请求者选择"
        case 301:
            errorMessage = "请求的网页已永久移动到新位置。 服务器返回此响应（对 GET 或 HEAD 请求的响应）时，会自动将请求者转到新位置"
        case 302:
            errorMessage = "服务器目前从不同位置的网页响应请求，但请求者应继续使用原有位置来进行以后的请求"
        case 303:
            errorMessage = "请求者应当对不同的位置使用单独的 GET 请求来检索响应时，服务器返回此代码"
        case 304:
            errorMessage = "自从上次请求后，请求的网页未修改过。 服务器返回此响应时，不会返回网页内容"
        case 305:
            errorMessage = "请求者只能使用代理访问请求的网页。 如果服务器返回此响应，还表示请求者应使用代理"
        case 307:
            errorMessage = "服务器目前从不同位置的网页响应请求，但请求者应继续使用原有位置来进行以后的请求"
        case 400:
            errorMessage = "服务器不理解请求的语法"
        case 401:
            errorMessage = "请求要求身份验证。 对于需要登录的网页，服务器可能返回此响应"
        case 403:
            errorMessage = "服务器拒绝请求"
        case 404:
            errorMessage = "服务器找不到请求的网页"
        case 405:
            errorMessage = "禁用请求中指定的方法"
        case 406:
            errorMessage = "无法使用请求的内容特性响应请求的网页"
        case 407:
            errorMessage = "此状态代码与 401（未授权）类似，但指定请求者应当授权使用代理"
        case 408:
            errorMessage = "服务器等候请求时发生超时"
        case 409:
            errorMessage = "服务器在完成请求时发生冲突。 服务器必须在响应中包含有关冲突的信息"
        case 410:
            errorMessage = "如果请求的资源已永久删除，服务器就会返回此响应"
        case 411:
            errorMessage = "服务器不接受不含有效内容长度标头字段的请求"
        case 412:
            errorMessage = "服务器未满足请求者在请求中设置的其中一个前提条件"
        case 413:
            errorMessage = "服务器无法处理请求，因为请求实体过大，超出服务器的处理能力"
        case 414:
            errorMessage = "请求的 URI（通常为网址）过长，服务器无法处理"
        case 415:
            errorMessage = "请求的格式不受请求页面的支持"
        case 416:
            errorMessage = "如果页面无法提供请求的范围，则服务器会返回此状态代码"
        case 417:
            errorMessage = "服务器未满足期望请求标头字段的要求"
        case 500:
            errorMessage = "服务器遇到错误，无法完成请求"
        case 501:
            errorMessage = "服务器不具备完成请求的功能。 例如，服务器无法识别请求方法时可能会返回此代码"
        case 502:
            errorMessage = "服务器作为网关或代理，从上游服务器收到无效响应"
        case 503:
            errorMessage = "服务器目前无法使用（由于超载或停机维护）。 通常，这只是暂时状态"
        case 504:
            errorMessage = "服务器作为网关或代理，但是没有及时从上游服务器收到请求"
        case 505:
            errorMessage = "服务器不支持请求中所用的 HTTP 协议版本"
        default:break
        }
        if let errorMessage = errorMessage{
            return "\(errorMessage) : \(errCode)"
        }
#else
        switch (errCode) {
        case 500:
            return "服务器吃坏了, 正在医治中"
        case 502:
            return "服务器吃撑了, 不要再喂了"
        case 403:
            return "服务器不高兴, 不给看指定内容"
        case 404:
            return "服务器没头脑, 找不到指定内容"
        case 500..<600:
            return "服务器饿晕了, 工程师正在解救\(errCode)"
        case 400..<500:
            return "打开服务器的方式不对\(errCode),调整一下？"
        default:
            return "未知问题"
        }
#endif
        return nil
    }
}
