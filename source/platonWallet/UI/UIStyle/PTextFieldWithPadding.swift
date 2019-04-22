//
//  PTextFieldWithPadding.swift
//  platonWallet
//
//  Created by matrixelement on 16/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

let bottomLineNormalColor = UIColor(rgb: 0xD5D8DF)
let bottomLineEditingColor = UIColor(rgb: 0x0077FF)
let bottomLineErrorColor = UIColor(rgb: 0xF5302C)

enum TextFiledStyle {
    case Editing
    case Normal
    case Error
}

enum TextFieldBottomLineStyle {
    case Normal,Editing,Error
}

class PTextFieldWithPadding: UITextField {
    
    private var mode: CheckMode = .endEdit
    
    private var check:((String)->(correct:Bool, errMsg:String))?
    
    private var heightChange:((PTextFieldWithPadding)->Void)?
    
    var bottomSeplineStyleChangeWithErrorTip : Bool = true
    
    
    @IBInspectable public var bottomInset: CGFloat {
        get { return inputAreaPadding.bottom }
        set { inputAreaPadding.bottom = newValue }
    }
    @IBInspectable public var leftInset: CGFloat {
        get { return inputAreaPadding.left }
        set { inputAreaPadding.left = newValue }
    }
    @IBInspectable public var rightInset: CGFloat {
        get { return inputAreaPadding.right }
        set { inputAreaPadding.right = newValue }
    }
    @IBInspectable public var topInset: CGFloat {
        get { return inputAreaPadding.top }
        set { inputAreaPadding.top = newValue }
    }
    
    public var inputAreaPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)  
    
    var tipsLabel : UILabel?
    
    private var _placeholder : String?
    
    var bottomSeplineView : UIView?
    
    override func awakeFromNib() {
        restyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        restyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        restyle()
    }
    
    override var placeholder: String?{
        get{
            return self._placeholder
        }
        set{
            self._placeholder = newValue
            if _placeholder != nil {
                self.attributedPlaceholder = NSAttributedString(string: _placeholder!,
                                                                attributes: [NSAttributedString.Key.foregroundColor: transfer_placeholder_color])
            }
        }
    }
    
    func restyle() {
        backgroundColor = UIColor.white
        textColor = UIColor.black
        tintColor = textColor
        
        self.bottomSeplineView = UIView(frame: .zero)
        self.addSubview(bottomSeplineView!)
        bottomSeplineView?.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(inputAreaPadding.left)
            make.trailing.equalTo(self).offset(-inputAreaPadding.right)
            make.bottom.equalTo(self).offset(0)
            make.height.equalTo(1)
        }
        bottomSeplineView?.backgroundColor = UIColor(rgb: 0xD5D8DF)
        self.tipsLabel?.text = ""
        self.tipsLabel?.localizedText = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        

    }
  
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if let rigth = rightView {
            
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rigth.frame.width))
        }
        return bounds.inset(by: inputAreaPadding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inputAreaPadding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let rigth = rightView {
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rigth.frame.width))
        }
        return bounds.inset(by: inputAreaPadding)
    }
    
    //MARK: - InputChecking
    
    func showErrorTip(_ show: Bool = true,locolizedError: String){
        guard let label = self.tipsLabel else{
            return
        }
        if show{
            label.localizedText = locolizedError
            label.isHidden = false
        }else{
            label.localizedText = ""
            label.isHidden = true
        }

    }
    
    func checkInput(mode:CheckMode, check:@escaping ((String)->(Bool,String)), heightChange:@escaping ((PTextFieldWithPadding)->Void)) {
        self.mode = mode
        self.check = check
        self.heightChange = heightChange
        
    }
    
    private func startCheck(text: String) {
        guard check != nil else {
            return
        }
        let res = self.check!(self.text ?? "")
        if res.correct {
            if bottomSeplineStyleChangeWithErrorTip{
                bottomSeplineView!.backgroundColor = bottomLineEditingColor
            }
            
            if let label = self.tipsLabel{
                label.localizedText = ""
                label.text = ""
                label.isHidden = false
            }
            heightChange?(self)
        }else{
            if bottomSeplineStyleChangeWithErrorTip{
                bottomSeplineView!.backgroundColor = bottomLineErrorColor
            }
            if let label = self.tipsLabel{
                label.localizedText = res.errMsg
                label.isHidden = false
            }
            heightChange?(self)
        }

    }
    
    //MARK: - Notification

    @objc func OnBeginEditing(_ notification: Notification){
            if let textField = notification.object as? UITextField, textField == self{
                bottomSeplineView?.backgroundColor = bottomLineEditingColor
            }
    }
    
    @objc func OnDidEndEditing(_ notification: Notification){
        if let textField = notification.object as? UITextField, textField == self{
            //bottomSeplineView?.backgroundColor = bottomLineNormalColor
            if mode == .endEdit {
                startCheck(text: textField.text ?? "")
            }
        }
    }
    
    @objc func OnDidChange(_ notification: Notification){
        if let textField = notification.object as? UITextField, textField == self{
            if mode == .textChange {
                startCheck(text: textField.text ?? "")
            }
            
        }
    }
    
    func setBottomLineStyle(style: TextFieldBottomLineStyle) {
        switch style {
        case .Normal:
            self.bottomSeplineView?.backgroundColor = bottomLineNormalColor
        case .Editing:
            self.bottomSeplineView?.backgroundColor = bottomLineEditingColor
        case .Error:
            self.bottomSeplineView?.backgroundColor = bottomLineErrorColor
        }
    }
    


}
