//
//  ViewController.swift
//  DDSwiftNetwork
//
//  Created by 刘恒 on 2019/12/9.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import Moya

func createTarget(_ t : BDTargetType) -> DDCustomTarget {
    return DDCustomTarget(BDCustomTarget(t))
}

class ViewController: UIViewController {

    let p = MoyaProvider<DDCustomTarget>(plugins: [DDNetworkLoggerPlugin(),
                                                   DDNetworkActivityPlugin(),
                                                   DDNetWorkTimeOutPlugin()])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func JSONEncoderForParam()throws -> [String:Any] {
            throw DDNetworkError.encodeFormatFailed
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
        
        p.request(createTarget(dd.ffff("sd")), completion: { result in
            switch result {
            case let .success(response):break
            case let .failure(error):break
            }
        })
    }
    


    enum dd:BDTargetType {
        case ffff(_ ff:String)
        
        var path: String {
            return ""
        }
        
        var task: DDTask {
            return .getRequestParam(parameters: [:])
        }
        
    }
    
}


struct ddsd : Codable {
    var s:String = "sd"
    var b:Int = 232
    var c:Bool = false
}

