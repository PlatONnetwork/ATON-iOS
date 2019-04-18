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
    
    override func awakeFromNib() {
        saveImgAndShreadBtn.style = .blue
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPress.minimumPressDuration = 1
        qrCodeImageView.isUserInteractionEnabled = true
        qrCodeImageView.addGestureRecognizer(longPress)
    }
    
    @objc func onLongPress(){
        if (addressLabel.text?.length)! > 0 {
            let pasteboard = UIPasteboard.general
            pasteboard.string = addressLabel.text
            UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("ExportVC_copy_success"))
        }
    }
    
    
    

}
