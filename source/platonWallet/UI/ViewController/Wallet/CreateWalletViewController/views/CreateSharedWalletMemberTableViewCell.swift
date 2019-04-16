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
    
    //@IBOutlet weak var addressBookIcon: UIImageView!
    
    @IBOutlet weak var walletAvatar: UIImageView!
    
    @IBOutlet weak var myClassicWalletName: UILabel!
    
    @IBOutlet weak var myClassicWalletAddress: UILabel!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var myWaleltInfoContainer: UIView!
    
    @IBOutlet weak var nameContainer: UIView!
    
    @IBOutlet weak var addressContainer: UIView!
    
    @IBOutlet weak var quickSaveAddressBtn: QuickSaveAddressButton!
    
    weak var delegate: CreateSharedWalletMemberDelegate?
    
    
    //@IBOutlet weak var addressbookBtn: NSLayoutConstraint!
    
    
//    var checkInput: ((_ remark:String, _ address:String, _ isEndEditFromAddress: Bool) -> Void)?
    
    lazy var scanBtn : UIButton = {
        
        let btn = UIButton(frame: CGRect(x: 0, y: 5, width: 30, height: 30))
        btn.setImage(UIImage(named: "textField_icon_scan"), for: .normal)
        btn.addTarget(self, action: #selector(scan(_ :)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rightView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        
        let scan = UIButton(frame: CGRect(x: 15, y: 5, width: 30, height: 30))
        scan.setImage(UIImage(named: "textField_icon_scan"), for: .normal)
        scan.addTarget(self, action: #selector(scan(_ :)), for: .touchUpInside)
        view.addSubview(scan)
        
        let addressbook = UIButton(frame: CGRect(x: 50, y: 5, width: 30, height: 30))
        addressbook.setImage(UIImage(named: "textField_icon_addressBook"), for: .normal)
        addressbook.addTarget(self, action: #selector(addressBook(_ :)), for: .touchUpInside)
        
        view.addSubview(addressbook)
        
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addressTF.rightView = rightView
        addressTF.rightViewMode = .always
        //addressBookIcon.isUserInteractionEnabled = true
        //let tapGes = UITapGestureRecognizer(target: self, action: #selector(gotoAddressBook))
        //addressBookIcon.addGestureRecognizer(tapGes)
        
        addressTF.delegate = self
        remarkTF.delegate = self
        self.quickSaveAddressBtn.status = .QuickSaveDisable
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange(_:)), name: UITextField.textDidChangeNotification, object: nil)

    }
    
    @objc private func scan(_ sender: UIButton) {
        delegate?.tableViewCellDidClickScan(self)
    }
    
    @objc private func addressBook(_ sender: UIButton){
        delegate?.tableViewCellDidClickAddressBook(self)
    }
    
    @objc private func gotoAddressBook() {
        delegate?.tableViewCellDidClickAddressBook(self)
    }
    
    func updateMyWallet(wallet: Wallet?){
        guard wallet != nil else {
            return
        }
        self.walletAvatar.image = wallet?.image()
        self.myClassicWalletName.text = wallet?.name
        self.myClassicWalletAddress.text = wallet?.key?.address
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
            addressTF.rightView = rightView
            //addressBookIcon.isHidden = false
            addressTF.isUserInteractionEnabled = true
            remarkTF.isUserInteractionEnabled = true
            //addressbookBtn.constant = 40
            
            self.nameContainer.isHidden = false
            self.addressContainer.isHidden = false
            self.myWaleltInfoContainer.isHidden = true
            self.quickSaveAddressBtn.isHidden = false
            
        }else{
            addressTF.rightView = nil
            //addressBookIcon.isHidden = true
            addressTF.isUserInteractionEnabled = false
            remarkTF.isUserInteractionEnabled = false
            //addressbookBtn.constant = 0
            
            self.nameContainer.isHidden = true
            self.addressContainer.isHidden = true
            self.myWaleltInfoContainer.isHidden = false
            self.quickSaveAddressBtn.isHidden = true
        }
    }

    @IBAction func onQuickSave(_ sender: Any) {
        quickSaveAddressBtn.quickSave(address: addressTF.text, name: remarkTF.text)
        quickSaveAddressBtn.checkAndUpdateStatus(address: addressTF.text,name: remarkTF.text)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}

extension CreateSharedWalletMemberTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.tableViewCell(self, didEndEditTextField: (remarkTF.text!, addressTF.text!, textField == addressTF))
        
    }
    
    @objc func onTextChange(_ notification: Notification){
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == addressTF || textField == remarkTF{
            quickSaveAddressBtn.checkAndUpdateStatus(address: addressTF.text,name: remarkTF.text)
        }
    }
}
