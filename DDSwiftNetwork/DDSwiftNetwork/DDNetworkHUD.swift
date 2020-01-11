//
//  DDNetworkHUD.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/16.
//  Copyright © 2019 刘恒. All rights reserved.
//
// tips:本着谁使用谁控制的原则，故没有全局的隐藏方法-MRC

import Foundation
import MBProgressHUD

public extension MBProgressHUD {
    func hideInMainThread(_ animated : Bool = true ) {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.hide(animated: animated)
        }
    }
}

/// HUD弹框
public enum DDShowHUD {
    case title(title: String)
    case success(title: String, duration: Int)
    case error(title: String, duration: Int)
    case warning(title: String, duration: Int)
    case progress(title: String)
    case determinate(title: String = "")
    
    /// 获取当前HUD的类型
    public var getShowHUDType : DDShowHUD {
        return self
    }
    
    @discardableResult
    public func show() -> MBProgressHUD {
        var vHud : MBProgressHUD
        switch self {
        case .title(let title):
            vHud = showTitleHUD(title: title)
        case .success(let title, let duration):
            vHud = showSuccessHUD(title: title, duration: duration)
        case .error(let title, let duration):
            vHud = showErrorHUD(title: title, duration: duration)
        case .warning(let title, let duration):
            vHud = showWarningHUD(title: title, duration: duration)
        case .progress(let title):
            vHud = showProgressHUD(title: title)
        case .determinate(let title):
            vHud = showDeterminateHUD(title: title)
        }
        return vHud
    }
}

extension DDShowHUD {
    fileprivate var currentView : UIView? {
        return getCurrentView()
    }
    
    fileprivate static var WarningImg : UIImage {
        return GetImageBundle.getImageBundle(imageName: "info")
    }
    
    fileprivate static var ErrorImg : UIImage {
        return GetImageBundle.getImageBundle(imageName: "error")
    }
    
    fileprivate static var SuccessImg : UIImage {
        return GetImageBundle.getImageBundle(imageName: "success")
    }
    
    fileprivate func showTitleHUD(title: String) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .text
        hud.detailsLabel.text = title
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 17)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.9)
        hud.contentColor = UIColor.white
        return hud
    }
    
    fileprivate func showSuccessHUD(title: String, duration: Int) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        hud.customView = UIImageView(image: DDShowHUD.SuccessImg)
        hud.isSquare = true
        hud.detailsLabel.text = title
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 17)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.9)
        hud.contentColor = UIColor.white
        hud.hide(animated: true, afterDelay: TimeInterval(duration))
        return hud
    }
    
    fileprivate func showErrorHUD(title: String, duration: Int) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        hud.customView = UIImageView(image: DDShowHUD.ErrorImg)
        hud.isSquare = true
        hud.label.text = title
        hud.label.font = UIFont.systemFont(ofSize: 17)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.9)
        hud.contentColor = UIColor.white
        hud.hide(animated: true, afterDelay: TimeInterval(duration))
        return hud
    }
    
    fileprivate func showWarningHUD(title: String, duration: Int) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        hud.customView = UIImageView(image: DDShowHUD.WarningImg)
        hud.isSquare = true
        hud.detailsLabel.text = title
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 17)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.9)
        hud.contentColor = UIColor.white
        hud.hide(animated: true, afterDelay: TimeInterval(duration))
        return hud
    }
    
    fileprivate func showProgressHUD(title: String) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.label.text = title
        hud.label.font = UIFont.systemFont(ofSize: 17)
        hud.label.textColor = UIColor.white
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.7)
        hud.contentColor = UIColor.white
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = UIColor.white
        return hud
    }
    
    fileprivate func showDeterminateHUD(title: String) -> MBProgressHUD {
        guard let windowView = currentView else {
            return MBProgressHUD()
        }
        let hud = MBProgressHUD.showAdded(to: windowView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .determinate
        hud.label.text = title
        hud.label.font = UIFont.systemFont(ofSize: 17)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.7)
        hud.contentColor = UIColor.white
        return hud
    }
}

fileprivate func getCurrentView() -> UIView? {
    var window : UIView?
    if #available(iOS 13.0, *) {
        for scene in UIApplication.shared.connectedScenes {
            if let scene = scene as? UIWindowScene{
                if scene.activationState == .foregroundActive{
                    window = scene.windows.first
                    break
                }else{
                    window = readCurrentController(scene.windows.first)?.view
                }
            }
        }
    }else{
        window = UIApplication.shared.keyWindow
    }
    return window
}

fileprivate func readCurrentController(_ window:UIWindow?) -> UIViewController? {
    var rootVc = window?.rootViewController
    if let rootVc_ = rootVc,
        rootVc_.isKind(of: UINavigationController.self) {
        rootVc = (rootVc_ as! UINavigationController).topViewController
    }
    while ((rootVc?.presentedViewController) != nil) {
        rootVc = rootVc?.presentedViewController
        if let rootVc_ = rootVc,
            rootVc_.isKind(of: UINavigationController.self) {
            rootVc = (rootVc_ as! UINavigationController).topViewController
        }
    }
    if let rootVc_ = rootVc,
        let rootVcNav_ = rootVc_.navigationController {
        while rootVc_.isBeingDismissed ||
            rootVcNav_.isBeingDismissed {
            rootVc = rootVc_.presentedViewController
        }
    }
    if let rootVc_ = rootVc,
        rootVc_.isKind(of: UITabBarController.self){
        rootVc = (rootVc_ as! UITabBarController).selectedViewController
    }
    if let rootVc_ = rootVc,
        rootVc_.isKind(of: UINavigationController.self) {
        rootVc = (rootVc_ as! UINavigationController).topViewController
    }
    return rootVc
}

fileprivate class GetImageBundle {
    static func getImageBundle(imageName:String) -> UIImage {
        let bundle = Bundle(path: Bundle.main.path(forResource: "DDNetworkHudImage", ofType: "bundle")!)
        let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) ?? UIImage()
        image.withRenderingMode(.alwaysTemplate)
        return image

    }
}
