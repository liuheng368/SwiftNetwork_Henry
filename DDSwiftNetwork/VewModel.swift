//
//  VewModel.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/20.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit

enum ListRequest : BDTargetType {
    case listDic
    case listEncodable
    
    var path: String{
        return "/j/app/radio/channels"
    }
    
    var task: DDTask {
        switch self {
        case .listDic:
            return .getRequestParam(parameters: [:])
        case .listEncodable:
            return .getRequestEncodable(nil)
        }
    }
    
    var HUDString: String {
        return "列表加载中"
    }
}

struct ListResponse : Decodable {
    var channels:[channelModel] = []
    
    struct channelModel : Codable {
        var abbr_en : String = ""
        var channel_id : Int = 0
        var name : String = ""
        var name_en : String = ""
        var seq_id : Int = 0
    }
}
