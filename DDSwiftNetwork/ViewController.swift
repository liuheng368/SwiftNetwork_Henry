//
//  ViewController.swift
//  DDSwiftNetwork
//
//  Created by 刘恒 on 2019/12/9.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import MBProgressHUD


extension ViewController {
    func networkStatus() {
        DDNetworkLinkManager.shared.state()
            .drive(onNext: { (status,firstLink) in
                print(status,firstLink)
            }).disposed(by: disposeBag)
    }
}


class ViewController: UIViewController {

    let network = DDMoyaProvider()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DDShowHUD.error(title: "sdfdsfsdfsdfffsdfdf,dfsdf", duration: 100).show()
        network.rx.requestForContent(CreateTarget(ListRequest.listDic)).subscribe(onSuccess: { (any) in
            print(any)
        }) { (e) in
            print(e)
        }.disposed(by: disposeBag)
//
//        network.rx.requestDecodable(CreateTarget(ListRequest.listEncodable), ListResponse.self).subscribe(onSuccess: { (model) in
//            print(model)
//        }) { (error) in
//            print(error)
//        }.disposed(by: disposeBag)
    }
}









extension ViewController {
    func test() {
                
        networkStatus()
        self.view.backgroundColor = UIColor.systemRed

//        DDShowHUD.error(title: "sdakdjalkdjlkajdklasjdklajdlkajdlkajdlk", duration: 1000).show()
        
        func JSONEncoderForParam()throws -> [String:Any] {
            throw DDNetworkError.encodeFormat
        }
        do {
            try JSONEncoderForParam()
        } catch {
            print(error.localizedDescription)
        }
        
//                let obj = ddsd()
//                let encoder = JSONEncoder()
//                let data = try? encoder.encode(obj)
//                let a = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//                if let dic = a as? [String:Any]{
//                    print(dic)
//                }


        
//        aad.request(createTarget(dd.ffff("sd")), completion: { result in
//            switch result {
//            case let .success(response):break
//            case let .failure(error):break
//            }
//        })
    }
}



