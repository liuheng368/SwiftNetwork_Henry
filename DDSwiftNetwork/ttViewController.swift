//
//  ttViewController.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/16.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import MBProgressHUD

class ttViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var window : UIWindow?
        if #available(iOS 13.0, *) {
            for window_ in UIApplication.shared.windows {
                    if window_.windowLevel == .normal{
                        window = window_
                        break
                    }
                }
        }else{
                window = UIApplication.shared.keyWindow
            }
        let hud = MBProgressHUD.showAdded(to: window!, animated: true)
        hud.mode = .text
        hud.label.text = "sasdsdadd"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
