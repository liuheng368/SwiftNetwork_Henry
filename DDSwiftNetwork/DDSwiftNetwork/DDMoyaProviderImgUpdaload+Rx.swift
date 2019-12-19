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

public extension Reactive where Base: MoyaProviderType {
    
    
    /// 上传图片，优先使用:七牛云,降级方案:有拍云
    /// - Parameter token: <#token description#>
    /// - Parameter callbackQueue: <#callbackQueue description#>
    func uploadImages(_ target: Base.Target, images:[UIImage]) -> Observable<[String]> {
        let hud = DDShowHUD.determinate(title: "已传0张/共\(images.count)张").show()
        hud.progress = 0
        var arrImgUrl : [String] = []
        
        return Observable.create {(observe) -> Disposable in
            var disposeBag = DisposeBag()
            func upload() {
                if arrImgUrl.count >= images.count {
                    observe.onNext(arrImgUrl)
                    observe.onCompleted()
                    return
                }
                DDMoyaProvider<BDCustomTarget>().rx
                    .requestContent(target as! DDCustomTarget)
                    .subscribe(onSuccess: { (obj) in
                        if let dic = obj as? [String:Any] {
                            self.uploadQiniu(dic, images[arrImgUrl.count], images.count, arrImgUrl.count, hud) { (str) in
                                guard str.count > 0 else{
                                    hud.hideInMainThread()
                                    DDShowHUD.error(title: "上传图片出错,请重试", duration: 2).show()
                                    observe.onError(DDNetworkError.imageUpload)
                                    return
                                }
                                arrImgUrl.append(str)
                                upload()
                            }
                        }else{
                            hud.hideInMainThread()
                            DDShowHUD.error(title: "上传图片出错,请重试", duration: 2).show()
                            observe.onError(DDNetworkError.imageUpload)
                        }
                    }, onError: { (error) in
                        hud.hideInMainThread()
                        DDShowHUD.error(title: "上传图片出错,请重试", duration: 2).show()
                        observe.onError(DDNetworkError.imageUpload)
                    }).disposed(by: disposeBag)
            }
            
            upload()
            return Disposables.create {
                hud.hideInMainThread()
            }
        }
        
    }

    private func uploadQiniu(_ tokenDic:[String:Any] ,_ image:UIImage,_ total:Int,_ doneImg:Int,_ hud:MBProgressHUD,_ successBlock:@escaping (String)->Void) {
        if let dic = tokenDic["qiniu"] as? [String:String],
            let key = dic["key"],
            let token = dic["token"],
            let url = dic["url"]{
            hud.label.text = "已传\(doneImg)张/共\(total)张"
            let option = QNUploadOption(progressHandler: { (key_, percent) in
                if key == key_ {
                    let f = 1 / Float(total)
                    hud.progress = f * Float(doneImg) + f * percent
                }
            })
            let upManager = QNUploadManager()
            let imgData = image.jpegData(compressionQuality: 0.8)
            upManager?.put(imgData, key: key, token: token, complete: { (_, _, resp) in
                if let _ = resp {
                    successBlock(url)
                }else{
                    self.uploadUpYun(tokenDic, image, total, doneImg, hud, successBlock)
                }
            }, option: option)
        }else{
            self.uploadUpYun(tokenDic, image, total, doneImg, hud, successBlock)
        }
    }
    
    
    
    private func uploadUpYun(_ tokenDic:[String:Any] ,_ image:UIImage,_ total:Int,_ doneImg:Int,_ hud:MBProgressHUD,_ successBlock:@escaping (String)->Void) {
        if let dic = tokenDic["upyun"] as? [String:Any],
            let bucket = dic["bucket"] as? String,
            let policy = dic["policy"] as? String,
            let signature = dic["signature"] as? Int,
            let url = dic["url"] as? String{
            hud.label.text = "已传\(doneImg)张/共\(total)张"
            let upYun = DDUpYun(bucket: bucket, andPolicy: policy, andSignature: "\(signature)")
            upYun?.expiresIn = 10 * 100060
            if let keyString = url.components(separatedBy: "/").last,
                let index = url.range(of: keyString){
                let imageBaseURL = url[..<index.lowerBound]
                let imgData = image.jpegData(compressionQuality: 0.8)
                upYun?.uploadFile(with: imgData, useSaveKey: keyString, progress: { (percent) in
                    let f = 1 / Float(total)
                    hud.progress = f * Float(doneImg) + f * Float(percent)
                }, completion: { (success, result, error) in
                    if success {
                        if let result = result,
                            let url = result["url"] as? String {
                            successBlock("\(imageBaseURL)\(url)")
                        }else{successBlock("")}
                    }else{successBlock("")}
                })
            }
        }else{successBlock("")}
    }
}

