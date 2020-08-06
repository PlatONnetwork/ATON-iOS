//
//  WalletManagerTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

class WalletManagerTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!

    @IBOutlet weak var walletIcon: UIImageView!

    @IBOutlet weak var walletName: UILabel!

    @IBOutlet weak var address: UILabel!

    @IBOutlet weak var backupContainer: UIView!

    @IBOutlet weak var backupButton: UIButton!

    @IBOutlet weak var jointIcon: UIImageView!

    @IBOutlet weak var WalletTypeTag: PaddingLabel!
    
    var backupButtonClickCallback:((_ sender: UIButton) -> Void)?

    @IBOutlet weak var walletNameCenterVerticalCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
        walletName.font = .systemFont(ofSize: 14.0, weight: .medium)
        walletName.numberOfLines = 0
    }

    func feedData(_ wallet:AnyObject) {

        self.WalletTypeTag.layer.borderColor = UIColor.init(rgb: 0x4A90E2).cgColor
        self.WalletTypeTag.layer.cornerRadius = 3
        self.WalletTypeTag.layer.borderWidth = 1

        self.backupContainer.isHidden = true
        self.backupButton.isEnabled = false
        self.backupButton.addTarget(self, action: #selector(backupButtonClick(sender:)), for: .touchUpInside)

        if let aptWallet = wallet as? Wallet {
            walletName.text = aptWallet.name
            if aptWallet.isHD == true && aptWallet.depth == 0 {
                address.isHidden = true
                walletNameCenterVerticalCons.priority = UILayoutPriority(rawValue: 1000)
            } else {
                address.isHidden = false
                walletNameCenterVerticalCons.priority = UILayoutPriority(rawValue: 250)
            }
            address.text = aptWallet.address
            walletIcon.image = UIImage(named: aptWallet.avatar)?.circleImage()

            backupContainer.isHidden = !aptWallet.canBackupMnemonic
            backupButton.isEnabled = aptWallet.canBackupMnemonic

//            if (aptWallet.keystoreMnemonic.count > 0) {
//                self.backupContainer.isHidden = false
//                self.backupButton.isEnabled = true
//            }

            jointIcon.isHidden = true
        }

//        if "Offline_Walle_Tag" = "Cold";
//        "Observed_Wallet_Tag" = "Observed";
        if let aptWallet = wallet as? Wallet {
            if aptWallet.type == .classic {
                self.WalletTypeTag.isHidden = true
                self.WalletTypeTag.text = ""
            } else if aptWallet.type == .cold {
                self.WalletTypeTag.isHidden = false
                self.WalletTypeTag.localizedText = "Offline_Walle_Tag"
            } else if aptWallet.type == .observed {
                self.WalletTypeTag.isHidden = false
                self.WalletTypeTag.localizedText = "Observed_Wallet_Tag"
            }
        }
    }

    @objc func backupButtonClick(sender: UIButton) {
        guard let callback = backupButtonClickCallback else {
            return
        }
        callback(sender)
    }
}
