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

    @IBOutlet weak var sublabel: UILabel!

    @IBOutlet weak var selectionImgV: UIImageView!

    @IBOutlet weak var deleteBtn: UIButton!

    @IBOutlet weak var hideDeleteBtnConstraint: NSLayoutConstraint!

    @IBOutlet weak var textFieldWidth: NSLayoutConstraint!

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

        //nodeTF.text = desc.length > 0 ? node + "  (\(Localized(desc)))" : node
        nodeTF.text = node

        nodeTF.delegate = self
        nodeTF.isEnabled = isEdit
        selectionImgV.isHidden = !isSelected
        deleteBtn.isHidden = !isEdit

        if isEdit {
            textFieldWidth.constant = kUIScreenWidth - 16 - 16 - 42
            sublabel.attributedText = nil
            sublabel.text = ""
            nodeTF.text = node
        } else {
            textFieldWidth.constant = 0
            let desloc = Localized(desc)
            let text = desc.length > 0 ? node + "\(desloc)" : node
            let desrange = NSRange(location: 0, length: node.length)
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: desrange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: desrange)
            if desloc.length > 0 {
                let desrange = NSRange(location: node.length, length: desloc.length)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(rgb: 0x898C9E), range: desrange)
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: desrange)
            }
            sublabel.attributedText = attributedString
            if isEdit {
                contentView.backgroundColor = UIColor(rgb: 0xffffff)
            } else {
                contentView.backgroundColor = UIColor(rgb: 0xffffff)
            }
        }

        UIView.animate(withDuration: 0.25) {

            if isEdit {
                self.hideDeleteBtnConstraint.priority = UILayoutPriority(999)
                self.hideDeleteBtnConstraint.constant = 16 + 42
            } else {
                self.hideDeleteBtnConstraint.priority = UILayoutPriority(999)
                self.hideDeleteBtnConstraint.constant = 16
            }
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
