//
//  PAlertController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/26.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift


typealias InputCheck = (_ input: String) -> Bool

open class PAlertController: UIViewController, UITextFieldDelegate{
    
    private(set) var textField: UITextField?
    
    private(set) var confirmButton: PopupDialogButton?
    
    var inputVerify : InputCheck?
    
    lazy private(set) var imageView: UIImageView? = {
        
        guard image != nil else {
            return nil
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy private(set) var titleLabel: UILabel? = {
        
        guard alertTitle != nil && !alertTitle!.isEmpty else {
            return nil
        }
        
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = alertTitle!
        label.textColor = isWarnning ? UIColor(rgb: 0xFF3030) : UIColor(rgb: 0x24272B)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return label
        
    }()
    
    lazy private(set) var messageLabel: UILabel? = {
        
        guard message != nil && !message!.isEmpty else {
            return nil
        }
        
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message!
        label.textColor = UIColor(rgb: 0x24272B)
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        return label
        
    }()
    
    open var alertTitle: String? 
    
    open var message: String?
    
    open var image: UIImage?
    
    open var isWarnning: Bool = false
    
    var actions:[(title: String, handler: ()->Void)] = []
    
    var markedActions:[String] = []
    
    public convenience init(title: String?, message: String?, image: UIImage? = nil, warnning: Bool = false) {
        
        self.init()
        
        alertTitle = title
        self.message = message
        self.image = image
        isWarnning = warnning
        
        if imageView != nil {
            addImageView(imageView!)
        }
        
        if titleLabel != nil {
            addTitleLabel(titleLabel!)
        }
        
        if messageLabel != nil {
            addMessageLabel(messageLabel!)
        }

    }
    
    open func addTextField(text: String? = nil, placeholder: String? = nil, isSecureTextEntry: Bool = false) {
        
        let tf = UITextField(frame: .zero)
        tf.borderStyle = .roundedRect
        tf.textColor = UIColor(rgb: 0x24272B)
        tf.isSecureTextEntry = isSecureTextEntry
        tf.text = text
        tf.placeholder = placeholder
        tf.layer.borderColor = UIColor(rgb: 0xF2F3F7).cgColor
        textField = tf
        textField?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        view.addSubview(tf)
        
        tf.snp.makeConstraints { (maker) in
            if messageLabel != nil {
                maker.top.equalTo(messageLabel!.snp.bottom).offset(15)
            }else if titleLabel != nil {
                maker.top.equalTo(titleLabel!.snp.bottom).offset(15)
            }else {
                maker.top.equalToSuperview().offset(15)
            }
            maker.height.equalTo(40)
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.bottom.equalToSuperview().offset(-16).priority(UILayoutPriority.defaultHigh)
        }
    }
    
    open func addAction(title: String, handler:@escaping ()->Void) {
        actions.append((title, handler))
    }
    
    open func addActionEnableStyle(title: String){
        markedActions.append(title)
    }
    
    open func show(inViewController vc: UIViewController, animated: Bool = false) {
        
        let dialog = PopupDialog(viewController: self, buttonAlignment: .horizontal)
        for action in actions {
            let button = DefaultButton(title: action.title, height: 38, action: action.handler)
            
            if markedActions.contains(action.title){
                button.titleColor = UIColor(rgb: 0xd0e6ff)
                self.confirmButton = button
                self.confirmButton?.dismissOnTap = false
            }
            
            dialog.addButton(button)
        }
        
        self.checkInputTextView()
        vc.present(dialog, animated: animated, completion: nil)

    }
    
    
    
    
    
    
    private func addImageView(_ imgV: UIImageView) {
        
        view.addSubview(imgV)
        imageView!.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(80)
            maker.top.equalToSuperview().offset(10)
            maker.centerX.equalToSuperview()
        }
    }
    
    private func addTitleLabel(_ titleL: UILabel) {
        view.addSubview(titleL)
        titleLabel!.snp.makeConstraints { (maker) in
            if imageView != nil {
                maker.top.equalTo(imageView!.snp.bottom).offset(3)
            }else {
                maker.top.equalToSuperview().offset(16)
            }
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.bottom.equalToSuperview().offset(-16).priority(UILayoutPriority.defaultLow)
        }
    }
    
    private func addMessageLabel(_ msgL: UILabel) {
        view.addSubview(msgL)
        messageLabel!.snp.makeConstraints { (maker) in
            
            if titleLabel != nil {
                maker.top.equalTo(titleLabel!.snp.bottom).offset(10)
            }else if imageView != nil {
                maker.top.equalTo(imageView!.snp.bottom).offset(3)
            }else {
                maker.top.equalToSuperview().offset(16)
            }
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.bottom.equalToSuperview().offset(-16).priority(500)
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    @objc func onTextDidChange(_ notification: Notification){
        
        guard self.confirmButton != nil else {
            return
        }
        self.checkInputTextView()
    }
    
    func checkInputTextView(){
        guard self.confirmButton != nil else {
            return
        }
        if let inputV = self.inputVerify{
            if self.textField!.text != nil && inputV(self.textField!.text!){
                self.confirmButton!.titleColor = UIColor(red: 0, green: 119.0/255.0, blue: 1, alpha: 1)
            }else{
                self.confirmButton!.titleColor = UIColor(rgb: 0xd0e6ff)
            }
        }
    }
    
    
    
}
