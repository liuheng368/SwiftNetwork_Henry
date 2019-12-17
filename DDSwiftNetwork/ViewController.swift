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
import MBProgressHUD

func createTarget(_ t : BDTargetType) -> DDCustomTarget {
    return DDCustomTarget(BDCustomTarget(t))
}

extension ViewController {
    func networkStatus() {
        DDNetworkLinkManager.shared.state()
            .drive(onNext: { (status,firstLink) in
                print(status,firstLink)
            }).disposed(by: disposeBag)
    }
}


class ViewController: UIViewController {

    let aad = DDMoyaProvider<BDCustomTarget>()
    let disposeBag = DisposeBag()
    
    
    
    @objc func asd() {
        print("ghjkl")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        btn.setTitle("sdsd", for: .normal)
        btn.backgroundColor = UIColor.black
        btn.addTarget(self, action: #selector(asd), for: .allEvents)
        self.view.addSubview(btn)
        
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
        
        let obj = ddsd()
        let encoder = JSONEncoder()
        let data = try? encoder.encode(obj)
        let a = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        if let dic = a as? [String:Any]{
            print(dic)
        }
        
        aad.request(createTarget(dd.ffff("sd")), completion: { result in
            switch result {
            case let .success(response):break
            case let .failure(error):break
            }
        })
    }
    


    enum dd:BDTargetType {
        
        case ffff(_ ff:String)
        
        var path: String {
            return "/j/app/radio/channels"
        }
        
        var task: DDTask {
            return .getRequestParam(parameters: [:])
        }
        
//        var HUDString: String {
//            return "5678uhbnmkjhgfr4"
//        }
    }
    
}


struct ddsd : Codable {
    var s:String = "sd"
    var b:Int = 232
    var c:Bool = false
}
