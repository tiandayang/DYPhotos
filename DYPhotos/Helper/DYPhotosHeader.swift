//
//  DYPhotosHeader.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

enum DYPhotoMediaType: Int {
    case image
    case video
    case both 
}

typealias dySelectImagesComplete = ((_ selectArray: Array<DYPhotoModel>)->()) //选择所有完成的回调

typealias dyRequestImageComplete = ((_ image: UIImage?)->()) // 获取图片的回调

typealias dyBoolComplete = ((_ success: Bool)->()) //带有bool 回调值的block

//屏幕宽高
public let WINDOW_WIDTH = UIScreen.main.bounds.size.width
public let WINDOW_HEIGHT = UIScreen.main.bounds.size.height

//屏幕宽高比
public let WINDOW_WIDTH_SCALE = UIScreen.main.bounds.size.width / 375
public let WINDOW_HEIGHT_SCALE = UIScreen.main.bounds.size.height / 667

//按当前屏幕宽高比适配后的宽度和高度
public func SCALE_WIDTH(width:CGFloat) -> CGFloat {
    return UIScreen.main.bounds.size.width / 375 * width
}
public func SCALE_HEIGHT(height:CGFloat) -> CGFloat {
    return UIScreen.main.bounds.size.height / 667 * height
}

public func dy_safeAsync(_ block: @escaping ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}

public func dy_Print<T>(_ item: T,
                        file: String = #file,
                        method: String = #function,
                        line: Int = #line){
    #if DEBUG
    print("\((file as NSString).lastPathComponent).line:[\(line)],method:\(method):\(item)")
    #endif
}

public func HexColor(hexValue: UInt) -> UIColor {
    return UIColor(red: ((CGFloat)(((hexValue) & 0xFF0000) >> 16))/255.0, green: ((CGFloat)(((hexValue) & 0xFF00) >> 8))/255.0, blue: ((CGFloat)((hexValue) & 0xFF))/255.0, alpha: 1.0)
}
