//
//  QRCodeVIew.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class QRCodeView: UIView {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var saveImgAndShreadBtn: PButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        saveImgAndShreadBtn.style = .blue
    }
    
    func hidePublicKeyArea() {
    }
    
    
    

}
