//
//  BaseImportWalletViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/9.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class BaseImportWalletViewController: BaseViewController {

    var defaultText: String = ""

    convenience init(text: String = "") {
        self.init()
        defaultText = text
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
