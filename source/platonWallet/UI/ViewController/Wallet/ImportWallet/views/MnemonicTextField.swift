//
//  MnemonicTextField.swift
//  platonWallet
//
//  Created by Ned on 6/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
class MnemonicTextField: UITextField {
    override func awakeFromNib() {
        self.custmoInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.custmoInit()
    }

    required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
        self.custmoInit()
    }

    func custmoInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(OnBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }

    @objc func OnBeginEditing(_ notification: Notification) {
        if let textField = notification.object as? UITextField, textField == self {
            self.backgroundColor = UIColor(rgb: 0xDDDFE6)
        }
    }

    @objc func OnDidEndEditing(_ notification: Notification) {
        if let textField = notification.object as? UITextField, textField == self {
            self.backgroundColor = UIColor(rgb: 0xF0F1F5)
        }
    }
}
