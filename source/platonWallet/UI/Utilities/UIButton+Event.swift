//
//  UIButton+Event.swift
//  platonWallet
//
//  Created by Admin on 16/10/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    /// 对外交换方法的方法 AppDelegate Launch中使用
    public static func methodExchange() {
        DispatchQueue.once(token: "UIButton") {
            let originalSelector = Selector.sysFunc
            let swizzledSelector = Selector.myFunc
            changeMethod(originalSelector, swizzledSelector, self)
        }
    }


    /// Runtime方法交换
    ///
    /// - Parameters:
    ///   - original: 原方法
    ///   - swizzled: 交换方法
    ///   - object: 对象
    private static func changeMethod(_ original: Selector, _ swizzled: Selector, _ object: AnyClass) -> () {

        guard let originalMethod = class_getInstanceMethod(object, original),
            let swizzledMethod = class_getInstanceMethod(object, swizzled) else {
                return
        }

        let didAddMethod = class_addMethod(object, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(object, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }


    /// 结构体静态key
    private struct UIButtonKey {
        static var isEventUnavailableKey = "isEventUnavailableKey"
        static var eventIntervalKey = "eventIntervalKey"
    }

    /// 触发事件的间隔
    var eventInterval: TimeInterval {
        get {
            return (objc_getAssociatedObject(self, &UIButtonKey.eventIntervalKey) as? TimeInterval) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &UIButtonKey.eventIntervalKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 是否可以触发事件
    fileprivate var isEventUnavailable: Bool {
        get {
            return (objc_getAssociatedObject(self, &UIButtonKey.isEventUnavailableKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIButtonKey.isEventUnavailableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 手写的set方法
    ///
    /// - Parameter isEventUnavailable: 事件是否可用
    @objc private func setIsEventUnavailable(_ isEventUnavailable: Bool) {
        self.isEventUnavailable = isEventUnavailable
    }

    /// mySendAction
    @objc fileprivate func mySendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        print("交换了按钮事件的方法")

        if isEventUnavailable == false {
            isEventUnavailable = true
            mySendAction(action, to: target, for: event)
            perform(#selector(setIsEventUnavailable(_: )), with: false, afterDelay: eventInterval)
        }
    }
}

fileprivate extension Selector {
    static let sysFunc = #selector(UIButton.sendAction(_:to:for:))
    static let myFunc = #selector(UIButton.mySendAction(_:to:for:))
}

extension DispatchQueue {
    private static var onceTracker = [String]()

    open class func once(token: String, block:() -> ()) {
        //注意defer作用域，调用顺序——即一个作用域结束，该作用域中的defer语句自下而上调用。
        objc_sync_enter(self)
        defer {
            print("线程锁退出")
            objc_sync_exit(self)
        }

        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
        defer {
            print("block执行完毕")
        }
    }
}
