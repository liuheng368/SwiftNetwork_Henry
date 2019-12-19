//
//  DDMoyaProviderImgUpdaload+Rx.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/17.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import UIKit
import Moya
import RxSwift
import RxCocoa
import MBProgressHUD
import Qiniu
import UpYunSDK

let kUserDefaultLastQiNiuFail = "kUserDefaultLastQiNiuFail"
public extension Reactive where Base: MoyaProviderType {
    
    /// 上传图片，优先使用:七牛云,降级方案:有拍云
    /// - Parameter token: <#token description#>
    /// - Parameter callbackQueue: <#callbackQueue description#>
    func uploadImages(_ target: Base.Target, images:[UIImage]) -> Observable<[String]> {
        let hud = DDShowHUD.determinate(title: "已传0张/共\(images.count)张").show()
        hud.progress = 0

        var arrImgUrl : [String] = []
        let disposeBag = DisposeBag()
        return Observable.create { (observe) -> Disposable in
            var bError = false
            
            func upload() {
                DDMoyaProvider<BDCustomTarget>().rx
                .requestContent(target as! DDCustomTarget)
                    .subscribe(onSuccess: { (<#Any#>) in
                        <#code#>
                    }, onError: { (<#Error#>) in
                        <#code#>
                    })
                    
                    
                .asDriver { (error) in
                    DDShowHUD.error(title: "上传图片出错,请重试", duration: 2).show()
                    return Driver.empty()
                    }.drive(onNext: <#T##((Any) -> Void)?##((Any) -> Void)?##(Any) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
                    
                .map({ (obj) -> String in
                    if let dic = obj as? [String:Any] {
                        let currentStr = self.uploadQiniu(dic, images[arrObserv.count], images.count, arrObserv.count, hud: hud)
                        arrImgUrl.append(currentStr)
                        return currentStr
                    }else{
                        hud.hideInMainThread()
                        bError = true
                        observe.onError(DDNetworkError.imageUpload)
                    }
                }))
            }
            while arrObserv.count >= images.count && !bError {
                
            }
            
            Observable.combineLatest(arrObserv).subscribe(onNext: { (strImgUrl) in
                observe.onNext(strImgUrl)
                observe.onCompleted()
                }).disposed(by: disposeBag)
            return Disposables.create()
        }
        
    }

    private func uploadQiniu(_ token:[String:Any] ,_ image:UIImage,_ total:Int,_ doneImg:Int,hud:MBProgressHUD) -> String {
        if let dic = token["qiniu"] as? [String:String],
            let key = dic["key"],
            let token = dic["token"],
            let url = dic["url"]{
            func upload() {
        
                hud.label.text = "已传\(alreadyImg.count)张/共\(images.count)张"
                let option = QNUploadOption(progressHandler: { (key_, percent) in
                    if key == key_ {
                        let f = 1 / Float(images.count)
                        hud.progress = f * Float(alreadyImg.count) + f * percent
                    }
                })
                let upManager = QNUploadManager()
                let imgData = images[alreadyImg.count].jpegData(compressionQuality: 0.8)
                upManager?.put(imgData, key: key, token: token, complete: { (_, key_, _) in
                    alreadyImg.append(url)
                }, option: option)
            }
        }
    }
    
    
    
    private func uploadUpYun(_ token:[String:Any] ,images:[UIImage]) -> Observable<String> {
        
    }
}

