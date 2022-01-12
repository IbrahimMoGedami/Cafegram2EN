//
//  UINavigationController+Ext.swift
//  Cafegram2EN
//
//  Created by Ibrahim Mo Gedami on 16/05/2020.
//  Copyright © 2020 Ibrahim Mo Gedami. All rights reserved
//

import UIKit

extension UINavigationController {
    
    // For Xcode 9 users, childForStatusBarStyle is equal to childViewControllerForStatusBarStyle
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

extension UIViewController {
    
    static let preventPageSheetPresentation: Void = {
        if #available(iOS 13, *) {
            _swizzling(forClass: UIViewController.self,
                       originalSelector: #selector(present(_: animated: completion:)),
                       swizzledSelector: #selector(_swizzledPresent(_: animated: completion:)))
        }
    }()
    
    @available(iOS 13.0, *)
    @objc private func _swizzledPresent(_ viewControllerToPresent: UIViewController,
                                        animated flag: Bool,
                                        completion: (() -> Void)? = nil) {
        if viewControllerToPresent.modalPresentationStyle == .pageSheet
            || viewControllerToPresent.modalPresentationStyle == .automatic {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        _swizzledPresent(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}


private func _swizzling(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
       let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
}
