//
//  UINavigationController+Extensions.swift
//  platonWallet
//
//  Created by Admin on 24/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

extension UINavigationController {
    func viewController(_ index: Int) -> UIViewController? {
        guard index < viewControllers.count && index > 0 else {
            return nil
        }
        return viewControllers[index]
    }
}
