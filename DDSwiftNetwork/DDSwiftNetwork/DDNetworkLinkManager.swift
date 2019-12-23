//
//  DDNetworkLinkManager.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/14.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

extension DDNetworkLinkManager {
    public static let shared = DDNetworkLinkManager()
    public typealias NetState = NetworkReachabilityManager.NetworkReachabilityStatus
    
    /// 网络链接状态
    /// 主线程监听
    public func state() -> Driver<(NetState,Bool)> {
        return Observable<(NetState,Bool)>.create {[unowned self] (observer) in
            self.reachManager?.listener = { status in
                switch status {
                    case .unknown:
                        self.netState = NetState.unknown
                        observer.onNext((NetState.unknown,self.firstLink))
                    case .notReachable:
                        self.netState = NetState.notReachable
                        observer.onNext((NetState.notReachable,self.firstLink))
                    case .reachable(let status_):
                        self.netState = NetState.reachable(status_)
                        observer.onNext((NetState.reachable(status_),self.firstLink))
                    }
                self.firstLink = false
            }
            return Disposables.create {[unowned self] in
                self.reachManager?.stopListening()
            }
        }.asDriver(onErrorJustReturn: (NetState.unknown,self.firstLink))
    }
}

public class DDNetworkLinkManager {
    public var netState : NetState?
    
    private var reachManager = NetworkReachabilityManager()
    private var firstLink : Bool = true
    private init() {
        self.reachManager?.startListening()
    }
}
