//
//  QRCodeVIew.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class QRCodeView: UIView {

    @IBOutlet weak var walletLabelBGView: UIView!
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var pubkeyCopyBtn: CopyButton!
    @IBOutlet weak var addrCopyBtn: CopyButton!
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var publicKeyAreaView: UIView!
    
    @IBOutlet weak var saveImgAndShreadBtn: UIButton!
    @IBOutlet weak var topContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pkLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pkAreaHeight: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        
        pubkeyCopyBtn.hitTestEdgeInsets = UIEdgeInsets(top: -30, left: -30, bottom: -30, right: -30)
        addrCopyBtn.hitTestEdgeInsets = UIEdgeInsets(top: -30, left: -30, bottom: -30, right: -30)
        pubkeyCopyBtn.attachTextView = publicKeyLabel
        addrCopyBtn.attachTextView = addressLabel
        
    }
    
    func hidePublicKeyArea() {
        self.publicKeyAreaView.isHidden = true
        self.publicKeyLabel.isHidden = true
        self.topContainerHeight.constant = 130
        self.pkAreaHeight.constant = 0
        self.pkLabelHeight.constant = 0
    }
    
    
    

}
