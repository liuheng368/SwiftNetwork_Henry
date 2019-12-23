//
//  MoyaProviderType+Rx.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/16.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import CleanJSON

/// 请求发起者
public class DDMoyaProvider: MoyaProvider<DDCustomTarget> {
    
    init() {
        super.init(plugins: [DDNetworkLoggerPlugin(),
                             DDNetworkActivityPlugin(),
                             DDNetWorkTimeOutPlugin()])
    }
}

extension DDMoyaProvider: ReactiveCompatible {}

public extension Reactive where Base: MoyaProviderType {
    
    /// 请求方法，返回值为 T : Decodable，推荐使用
    /// - Parameter token: <#token description#>
    func requestDecodable<T:Decodable>(_ target: Base.Target) -> Single<T> {
        return Single<T>.create { [weak base] single in
            let cancellableToken = base?.request(target, callbackQueue: nil, progress: nil) { result in
                switch result {
                case .success(let response):
                    do {
                        let successRes = try response.filterSuccessfulStatusCodes()
                        if let strJson = try? successRes.mapJSON(),
                            let successDic = strJson as? [String:Any],
                            let data = try? JSONSerialization.data(withJSONObject: successDic["content"] as Any, options: .fragmentsAllowed),
                            let decodable = try? CleanJSONDecoder().decode(T.self, from: data) {
                            single(.success(decodable))
                        }else{
                            single(.error(DDNetworkError
                                .responseEncoding(data: response.data)))
                        }
                    } catch {
                        if let DDTarget = target as? DDTargetType,
                            response.statusCode == 1006 {
                            DDTarget.loginOutTime()
                            DDShowHUD.error(title: "登录过期，请重新登录", duration: 2).show()
                        }else{
                            single(.error(DDNetworkError
                                .networkState(errorResponse: response)))
                        }
                    }
                case .failure(let error):
                    single(.error(DDNetworkError
                        .network(errorCode: error.errorCode, error: error)))
                }
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
    /// 请求方法，返回值为response中content的值
    /// - Parameter token: <#token description#>
    func requestContent(_ target: Base.Target) -> Single<Any> {
        return Single<Any>.create { [weak base] single in
            let cancellableToken = base?.request(target, callbackQueue: nil, progress: nil) { result in
                switch result {
                case .success(let response):
                    do {
                        let successRes = try response.filterSuccessfulStatusCodes()
                        if let strJson = try? successRes.mapJSON(),
                            let successDic = strJson as? [String:Any],
                            let content = successDic["content"]{
                            single(.success(content))
                        }else{
                            single(.error(DDNetworkError
                                .responseJson(data: response.data)))
                        }
                    } catch {
                        if let DDTarget = target as? DDTargetType,
                            response.statusCode == 1006 {
                            DDTarget.loginOutTime()
                            DDShowHUD.error(title: "登录过期，请重新登录", duration: 2).show()
                        }else{
                            single(.error(DDNetworkError
                                .networkState(errorResponse: response)))
                        }
                    }
                case .failure(let error):
                    single(.error(DDNetworkError
                        .network(errorCode: error.errorCode, error: error)))
                }
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
    /// 带进度的请求方法
    /// - Parameter token: <#token description#>
    /// - Parameter callbackQueue: <#callbackQueue description#>
    func requestWithProgress(_ token: Base.Target) -> Observable<ProgressResponse> {
        let progressBlock: (AnyObserver) -> (ProgressResponse) -> Void = { observer in
            return { progress in
                observer.onNext(progress)
            }
        }

        let response: Observable<ProgressResponse> = Observable.create { [weak base] observer in
            let cancellableToken = base?.request(token, callbackQueue: nil, progress: progressBlock(observer)) { result in
                switch result {
                case .success:
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(DDNetworkError
                        .network(errorCode: error.errorCode, error: error))
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }

        // Accumulate all progress and combine them when the result comes
        return response.scan(ProgressResponse()) { last, progress in
            let progressObject = progress.progressObject ?? last.progressObject
            let response = progress.response ?? last.response
            return ProgressResponse(progress: progressObject, response: response)
        }
    }
}
