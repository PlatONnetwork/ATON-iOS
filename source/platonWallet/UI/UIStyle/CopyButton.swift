//
//  CopyButton.swift
//  platonWallet
//
//  Created by matrixelement on 30/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CopyButton: UIButton {

    var attachTextView: UIView?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        self.addTarget(self, action: #selector(onCopy), for: .touchUpInside)
    }

    @objc func onCopy() {
        if let label = attachTextView as? UILabel {
            if (label.text?.length)! > 0 {
                let pasteboard = UIPasteboard.general
                pasteboard.string = label.text
                UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("ExportVC_copy_success"))
            }
        }
    }

}
