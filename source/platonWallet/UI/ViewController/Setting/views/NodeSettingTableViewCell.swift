//
//  NodeSettingTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

protocol NodeSettingTableViewCellDelegate: AnyObject {
    func deleteNode(_ cell:NodeSettingTableViewCell)
    func editNode(_ cell:NodeSettingTableViewCell)
}

class NodeSettingTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nodeTF: UITextField!
    
    @IBOutlet weak var selectionImgV: UIImageView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var hideDeleteBtnConstraint: NSLayoutConstraint!
    
    weak var delegate: NodeSettingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(node: String, isSelected: Bool, isEdit: Bool, desc: String = "") {
        
        nodeTF.text = desc.length > 0 ? node + "  (\(Localized(desc)))" : node
        nodeTF.delegate = self
        nodeTF.isEnabled = isEdit
        selectionImgV.isHidden = !isSelected
        deleteBtn.isHidden = !isEdit
        
        UIView.animate(withDuration: 0.25) { 
            self.hideDeleteBtnConstraint.priority = isEdit ? .defaultLow : .defaultHigh
            self.layoutIfNeeded()
        }

    }
    
    @IBAction func deleteNode(_ sender: Any) {
        delegate?.deleteNode(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { 
            self.delegate?.editNode(self)
        }
        return true
    }
    
}
