//
//  QRCodeVIew.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class QRCodeView: UIView {

    @IBOutlet weak var qrCodeImageView: UIImageView!

    @IBOutlet weak var saveImgAndShreadBtn: PButton!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var tipsLabel: UILabel!

    override func awakeFromNib() {
        saveImgAndShreadBtn.style = .blue
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.numberOfTapsRequired = 1
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(tap)
    }

    @objc func onTap() {
        if (addressLabel.text?.length)! > 0 {
            let pasteboard = UIPasteboard.general
            pasteboard.string = addressLabel.text
            UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("ExportVC_copy_success"))
        }
    }

}
