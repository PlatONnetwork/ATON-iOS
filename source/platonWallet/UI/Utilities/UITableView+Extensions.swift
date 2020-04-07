//
//  UITableView+Extensions.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

extension UITableViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}
