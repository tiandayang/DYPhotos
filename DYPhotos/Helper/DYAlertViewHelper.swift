//
//  DYAlertViewHelper.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

typealias alertClickBlock = (_ index: Int) ->Void

class DYAlertViewHelper {

    /// 展示一个带有 标题 和 确定 按钮的alert
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showAlert(title: String, controller: UIViewController, complete: alertClickBlock?) {
        
        self.showAlert(title: title, confirmTitle: NSLocalizedString("确定", comment: ""), cancelTitle: nil, message: nil, controller: controller, complete: complete)
    }
    
    /// 展示一个显示 消息 和 确定 按钮的alert
    ///
    /// - Parameters:
    ///   - message: 消息内容
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showAlert(message: String, controller: UIViewController, complete: alertClickBlock?) {
        self.showAlert(title: nil, confirmTitle: NSLocalizedString("确定", comment: ""), cancelTitle: nil, message: message, controller: controller, complete: complete)
    }
    
    /// 展示一个显示 消息、标题 和 确定 按钮的alert
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showAlert(title: String?, message: String, controller: UIViewController, complete: alertClickBlock?) {
        self.showAlert(title: title, confirmTitle: NSLocalizedString("确定", comment: ""), cancelTitle: nil, message: message, controller: controller, complete: complete)
    }
    
    /// 展示一个显示 消息、标题 和 确定、取消 按钮的alert
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showAlertWithCancel(title: String?, message: String, controller: UIViewController, complete: alertClickBlock?) {
        self.showAlert(title: title, confirmTitle: NSLocalizedString("确定", comment: ""), cancelTitle: NSLocalizedString("取消", comment: ""), message: message, controller: controller, complete: complete)
    }
    
    /// 展示一个 自定义 按钮的alert
    ///
    /// - Parameters:
    ///   - title: title
    ///   - confirmTitle: 确定按钮名称
    ///   - cancelTitle: 取消按钮的名称
    ///   - message: 显示信息
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showAlert(title: String?, confirmTitle: String?, cancelTitle: String?, message: String?, controller: UIViewController, complete: alertClickBlock?) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if confirmTitle != nil  {
            let alertAction = UIAlertAction.init(title: confirmTitle, style: .default, handler: { (alertAction) in
                if complete != nil {
                    complete!(1)
                }
            })
            alertController.addAction(alertAction)
        }
        if cancelTitle != nil{
            let alertAction = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: { (alertAction) in
                if complete != nil {
                    complete!(0)
                }
            })
            alertController.addAction(alertAction)
        }
        controller.present(alertController, animated: true, completion: nil)
    }
    
}

class DYActionSheetHelper {
    /// 展示actionSheet
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - items: 按钮标题的集合
    ///   - controller: 当前VC
    ///   - complete: 点击回调
    public class func showActionSheet(title: String?, items: [String]?, cancelTitle: String, controller: UIViewController, complete: alertClickBlock?) {
        
        let actionSheetController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        if items != nil && items?.count != 0 {
            for itemTitle in items! {
                let action = UIAlertAction.init(title: itemTitle, style: .default, handler: { (action) in
                    if complete != nil {
                        complete!((items?.index(of: itemTitle))! + 1)
                    }
                })
                actionSheetController.addAction(action)
            }
        }
        let action = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: { (action) in
            if complete != nil {
                complete!(0)
            }
        })
        actionSheetController.addAction(action)
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
    
}
