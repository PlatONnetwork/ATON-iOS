//
//  CandidatesListSectionHeaderView.swift
//  platonWallet
//
//  Created by juzix on 2018/12/26.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Spring

protocol HeaderViewProtocol: AnyObject {
    func hideSearchTextField(_ textField: UITextField);
}

class CandidatesListSectionHeaderView: UIView {
    
    @IBOutlet var btns: [SpringButton]!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var searchTF: UITextField!
    
    weak var delegate: HeaderViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    
    private func initSubViews() {
        let view = Bundle.main.loadNibNamed("CandidatesListSectionHeaderView", owner: self, options: nil)?.first as! UIView
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        let leftView = UIImageView(image: UIImage(named: "vote_search_icon_s"), highlightedImage: nil)
        leftView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        leftView.contentMode = .center
        searchTF.leftView = leftView
        searchTF.leftViewMode = .always
        
        let rightView = UIImageView(image: UIImage(named: "vote_clear_icon"), highlightedImage: nil)
        rightView.contentMode = .center
        rightView.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
        searchTF.rightView = rightView
        searchTF.rightViewMode = .always
        searchTF.rightView!.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSearchTF))
        searchTF.rightView?.addGestureRecognizer(tap)
        
        searchTF.setValue(UIColor(rgb: 0x7A8092), forKeyPath: "_placeholderLabel.textColor")
        searchTF.layer.cornerRadius = 1.0

    }
    
    func updateSelectedBtn(_ selectedBtn: UIButton) {
        
        for btn in btns {
            
            if btn != selectedBtn {
                btn.isSelected = false
                btn.scaleX = 1.0
                btn.scaleY = 1.0
            }else {
                btn.isSelected = true
                btn.scaleX = 1.33
                btn.scaleY = 1.33
            }

            btn.curve = "spring"
            btn.duration = 1.0
            btn.damping = 1.0
            btn.velocity = 6.0
            btn.animateTo()
        }
        
    }
    
    @IBAction func showSearchTF(_ sender: Any) {
        searchBtn.isHidden = true
        searchTF.isHidden = false
        searchTF.becomeFirstResponder()
    }

    @objc func hideSearchTF() {
        delegate?.hideSearchTextField(searchTF)
        searchTF.text = ""
        searchBtn.isHidden = false
        searchTF.isHidden = true
        searchTF.resignFirstResponder()
        
    }

}
