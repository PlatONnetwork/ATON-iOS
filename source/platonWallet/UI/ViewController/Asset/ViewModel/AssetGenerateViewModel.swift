//
//  AssetGenerateViewModel.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetGenerateViewModel: RowViewModel, ViewModelPressible {
    let title: String
    var icon: UIImage?
    var cellPressed: (() -> Void)?

    init(title: String, icon: UIImage?) {
        self.title = title
        self.icon = icon
    }
}
