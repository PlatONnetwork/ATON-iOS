//
//  RowViewModel.swift
//  platonWallet
//
//  Created by Admin on 24/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

protocol RowViewModel {}

protocol ViewModelPressible {
    var cellPressed: (() -> Void)? { get set}
}
