//
//  CreateSharedWalletMemberTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/14.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

protocol CreateSharedWalletMemberDelegate: AnyObject {
    
    func tableViewCellDidClickScan(_ cell: UITableViewCell)
    func tableViewCellDidClickAddressBook(_ cell: UITableViewCell)
    func tableViewCell(_ cell: UITableViewCell, didEndEditTextField content:(remark: String, address: String, isEditAddress: Bool))
}

class CreateSharedWalletMemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var remarkTF: PTextFieldWithPadding!
    
    @IBOutlet weak var addressTF: PTextFieldWithPadding!
    
    @IBOutlet weak var addressBookIcon: UIImageView!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    weak var delegate: CreateSharedWalletMemberDelegate?
    
    
    @IBOutlet weak var addressbookBtn: NSLayoutConstraint!
    
    
//    var checkInput: ((_ remark:String, _ address:String, _ isEndEditFromAddress: Bool) -> Void)?
    
    lazy var scanBtn : UIButton = {
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.setImage(UIImage(named: "icon_scan_white"), for: .normal)
        btn.addTarget(self, action: #selector(scan(_ :)), for: .touchUpInside)
        return btn
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addressTF.rightView = scanBtn
        addressTF.rightViewMode = .always
        addressBookIcon.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(gotoAddressBook))
        addressBookIcon.addGestureRecognizer(tapGes)
        
        addressTF.delegate = self
        remarkTF.delegate = self
    }
    
    @objc private func scan(_ sender: UIButton) {
        delegate?.tableViewCellDidClickScan(self)
    }
    
    @objc private func gotoAddressBook() {
        delegate?.tableViewCellDidClickAddressBook(self)
    }
    
    func setup(title: String, address: String, remark: String, tips: String? ,index: Int) {
        
        self.title.text = title
        addressTF.text = address
        remarkTF.text = remark
        
        if tips != nil && tips!.length > 0 {
            tipsLabel.isHidden = false 
            tipsLabel.text = tips
        }else {
            tipsLabel.isHidden = true 
        }
    }
    
    func setEnableMode(enable: Bool){
        if enable{
            addressTF.rightView = scanBtn
            addressBookIcon.isHidden = false
            addressTF.isUserInteractionEnabled = true
            remarkTF.isUserInteractionEnabled = true
            addressbookBtn.constant = 40
        }else{
            addressTF.rightView = nil
            addressBookIcon.isHidden = true
            addressTF.isUserInteractionEnabled = false
            remarkTF.isUserInteractionEnabled = false
            addressbookBtn.constant = 0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}

extension CreateSharedWalletMemberTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
//        checkInput?(remarkTF.text!, addressTF.text!, textField == addressTF)
        
        delegate?.tableViewCell(self, didEndEditTextField: (remarkTF.text!, addressTF.text!, textField == addressTF))
    }
    
}
