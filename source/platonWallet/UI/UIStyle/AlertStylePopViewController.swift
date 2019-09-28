//
//  PAlertViewController.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

extension UIViewController {
    static func initFromNib() -> Self {
        func instanceFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: self), bundle: nil)
        }
        return instanceFromNib()
    }
}

//reutrn value: whether we dismiss this alert view or not
typealias ButtonActionBlock = (_ text: String?,_ userInfo: AnyObject? ) -> (Bool)


enum PAlertStyle{
    case passwordInput(walletName: String?)
    case AlertWithRedTitle(title: String?,message: String?) //no cancle button
    case AlertWithText(attributedStrings: [NSAttributedString]?)
    case ChoiceView(message: String?) //no cancle button
    case commonInput(title: String?,placeHoder: String?,preInputText: String?)
    case commonInputWithItemDes(itemDes: String?,itemContent: String?,inputDes: String?,placeHoder: String?,preInputText: String?)
}

class AlertStylePopViewController: UIViewController,UITextFieldDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // force load view form xib
        view.backgroundColor = .clear
        //self.contentCenterYConstraint.constant = -1030
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var confirmBlock : ButtonActionBlock?
    var cancelBlock : ButtonActionBlock?
    
    var dismissCompletion : (() -> ())?
    
    var keyboardHeight: CGFloat = 0
    var keyboardShown: Bool = false
    
    var enablePassowrdCommonCheck = true
    
    var enableWalletNameInputCheck = true
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var whiteContentView: UIView!
    

    @IBOutlet weak var textFieldInputContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldContainer: UIView!
    
    @IBOutlet weak var messageLabelHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabelBottomConstraint: NSLayoutConstraint!
    
    //textFieldInputContainer - begin
    //@IBOutlet weak var item1Des: UILabel!
    
    //@IBOutlet weak var item1Content: UILabel!
    
    @IBOutlet weak var textInputDes: UILabel!
    
    @IBOutlet weak var textFieldInput: PTextFieldWithPadding!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBOutlet weak var singleTextFieldConstraint: NSLayoutConstraint!
    
    //textFieldInputContainer - end
    
    @IBOutlet weak var confirmButton: PButton!
    
    @IBOutlet weak var confirmButtonBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBOutlet weak var contentCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    
    @IBOutlet weak var touchTodisappear: UIView!
    
    var style : PAlertStyle?{
        didSet{
            self.styleInitilize()
        }
    }
    
    func styleInitilize(){

        self.titleLabel.localizedText  = ""
        self.textFieldInput.delegate = self
        self.textFieldInput.autocorrectionType = .no
        self.textFieldInput.tintColor = UIColor(rgb: 0x0077FF)
        self.errorLabel.text = ""
        
        switch style {
        case .passwordInput(let walletName)?:
            //self.item1Content.text = walletName
            self.textInputDes.text = walletName
            self.configPasswordInputStyle()
        case .AlertWithRedTitle(let title, let message)?:
            self.titleLabel.localizedText = title
            self.messageLabel.localizedText = message
            self.configAlertWithRedTitle()
        case .ChoiceView(let message)?:
            self.titleLabel.text = ""
            self.messageLabel.localizedText = message
            self.configChoiceView()
        case .commonInput(let title, let placeHoder,let preInputText)?:
            self.titleLabel.localizedText = title
            self.textFieldInput.LocalizePlaceholder = placeHoder
            if preInputText != nil && (preInputText?.length)! > 0{
                self.textFieldInput.text = preInputText
            }
            self.configcommonInput()
        case .commonInputWithItemDes(let itemDes,let itemContent,let inputDes,let placeHoder,let preInputText)?:
            //self.item1Des.text = itemDes
            //self.item1Content.text = itemContent
            self.textInputDes.text = inputDes
            self.configCommonInputWithMessage()
        case .AlertWithText(let attributedStrings)?:
            self.titleLabel.localizedAttributedTexts = attributedStrings!
            self.configAlertWithText()
        default:
            do{}
        }
    }
    
    //MAKR: - Style Configuration
    
    func configPasswordInputStyle(){
        self.imageIcon.image = UIImage(named: "alertPwdImage")
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.cancelButton.localizedNormalTitle = "alert_cancelBtn_title"
        //self.item1Des.localizedText = "alert_walletnamecolon"
        self.textFieldInput.LocalizePlaceholder = "alert_input_psw_title_placeholder"
        //self.textInputDes.localizedText = "alert_pwdcolon"
        self.titleLabel.localizedText = "alert_input_psw_title"
        self.hideMessageLabel()
        self.errorLabel.isHidden = true
        self.textFieldInput.tipsLabel = self.errorLabel
        self.textFieldInput.isSecureTextEntry = true
        self.textFieldInput.becomeFirstResponder()
        if enablePassowrdCommonCheck{ 
            self.textFieldInput.bottomSeplineStyleChangeWithErrorTip = false
            self.confirmButton.style = .disable
            self.textFieldInput.checkInput(mode: CheckMode.textChange, check: {[weak self] (input) -> (Bool, String) in 
                let ret = CommonService.isValidWalletPassword(input)
                if ret.0{
                    self?.confirmButton.style = .blue
                }else{
                    self?.confirmButton.style = .disable
                }
                //away set as Editting
                self?.textFieldInput.setBottomLineStyle(style: .Editing)
                return (ret.0,"")
                //return (ret.0,ret.1 ?? "")
            }) { textField in
                
            }
        }
        
    }
    
    func configAlertWithText() {
        self.titleLabel.numberOfLines = 0
        self.imageIcon.image = UIImage(named: "3.icon-doubt")
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.hideCancelButton()
        self.hideInputArea()
        self.hideMessageLabel()
        self.hideConfirmButton()
    }
    
    func configAlertWithRedTitle(){
        self.titleLabel.textColor = UIColor(rgb: 0xF5302C)
        self.imageIcon.image = UIImage(named: "alertTipImage")
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.hideCancelButton()
        self.hideInputArea()
    }
    
    func configChoiceView(){
        self.imageIcon.image = UIImage(named: "alertTipImage")
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.confirmButton.localizedNormalTitle = "alert_quit_backup_yes"
        self.cancelButton.localizedNormalTitle = "alert_quit_backup_no"
        self.hideInputArea()
    }
    
    func configcommonInput(){
        self.imageIcon.image = UIImage(named: "alertEditImage")
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.cancelButton.localizedNormalTitle = "alert_cancelBtn_title"
        self.singleTextFieldStyle()
        self.errorLabel.text = ""
        self.textFieldInput.tipsLabel = self.errorLabel
        self.hideMessageLabel()
        self.textFieldInput.becomeFirstResponder()
        
        if enableWalletNameInputCheck{ 
            self.textFieldInput.bottomSeplineStyleChangeWithErrorTip = false
            self.confirmButton.style = .disable
            self.textFieldInput.checkInput(mode: CheckMode.textChange, check: {[weak self] (input) -> (Bool, String) in
                let ret = CommonService.isValidWalletName(input)
                if ret.0{
                    self?.confirmButton.style = .blue
                }else{
                    self?.confirmButton.style = .disable
                }
                //away set as Editting
                self?.textFieldInput.setBottomLineStyle(style: .Editing)
                return (ret.0,ret.1 ?? "")
            }) { textField in
                
            } 
        }
        
    } 
    
    func configCommonInputWithMessage(){
        self.imageIcon.image = UIImage(named: "alertEditImage")
        self.hideMessageLabel()
        self.hideTitleAndMessageLabel()
        self.confirmButton.localizedNormalTitle = "alert_confirmBtn_title"
        self.cancelButton.localizedNormalTitle = "alert_cancelBtn_title"
        self.textFieldInput.tipsLabel = self.errorLabel
        self.textFieldInput.becomeFirstResponder()
        
        if enableWalletNameInputCheck{ 
            self.textFieldInput.bottomSeplineStyleChangeWithErrorTip = false
            self.confirmButton.style = .disable
            self.textFieldInput.checkInput(mode: CheckMode.textChange, check: {[weak self] (input) -> (Bool, String) in
                let ret = CommonService.isValidWalletName(input)
                if ret.0{
                    self?.confirmButton.style = .blue
                }else{
                    self?.confirmButton.style = .disable
                }
                //away set as Editting
                self?.textFieldInput.setBottomLineStyle(style: .Editing)
                return (ret.0,ret.1 ?? "")
            }) { textField in
                
            }
        }
    }
    
    func hideMessageLabel(){
        self.messageLabel.isHidden = true
        self.messageLabelHideConstraint.priority = UILayoutPriority(rawValue: 999)
        self.messageLabelHideConstraint.constant = 24
    }
    
    func hideTitleAndMessageLabel(){
        self.messageLabel.isHidden = true
        self.titleLabel.isHidden = true
        self.titleLabel.text = ""
        self.messageLabelHideConstraint.priority = UILayoutPriority(rawValue: 999)
        self.messageLabelHideConstraint.constant = 0
    }
    
    func hideCancelButton(){
        self.confirmButtonBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        self.cancelButton.isHidden = true
    }
    
    func hideConfirmButton() {
        self.messageLabelBottomConstraint.priority = UILayoutPriority(rawValue: 1000)
        self.confirmButton.isHidden = true
    }
    
    func hideInputArea(){
        self.textFieldInputContainerHeight.constant = 0
        self.textFieldInputContainerHeight.priority = UILayoutPriority(rawValue: 999)
        self.textFieldContainer.isHidden = true
    }
    
    func singleTextFieldStyle(){
        self.singleTextFieldConstraint.priority = UILayoutPriority(rawValue: 999)
        self.singleTextFieldConstraint.constant = 0
        //self.item1Des.isHidden = true
        //self.item1Content.isHidden = true
        self.textInputDes.isHidden = true
        self.textFieldInputContainerHeight.constant = 50
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
        if self.whiteContentView.frame.origin.y != 0{
            var origin = self.whiteContentView.frame.origin
            let size = self.whiteContentView.frame.size
            origin.y = kUIScreenHeight
            self.whiteContentView.frame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        }
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        view.isOpaque = false
        view.backgroundColor = .clear
        modalPresentationCapturesStatusBarAppearance = true
        
    
        confirmButton.style = .blue
        self.whiteContentView.layer.cornerRadius = 6
        self.whiteContentView.layer.masksToBounds = true
        
        self.contentCenterYConstraint.constant = kUIScreenHeight
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.touchTodisappear.addGestureRecognizer(tap)
        
        addObservers()
    }

    
    // MARK: - ButtonAction
    
    @IBAction func onCancel(_ sender: Any) {
        self.textFieldInput.resignFirstResponder()
        guard self.cancelBlock != nil else{
            return
        }
        if self.cancelBlock!(self.textFieldInput.text,nil){
            self.dismissWithCompletion()
        }
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        guard self.confirmBlock != nil else{
            return
        }
        if self.confirmBlock!(self.textFieldInput.text,nil){
            self.dismissWithCompletion()
        }
    }
    
    func onAction(confirm:ButtonActionBlock?, cancel:ButtonActionBlock?) {
        self.confirmBlock = confirm
        self.cancelBlock = cancel
    }
    
    @objc func onTap(){
        self.dismissWithCompletion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //(UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = UIColor.clear
    }
    
    //MARK: - public 
    
    func showInViewController(viewController: UIViewController, _ animated : Bool = false, _      completion: (() -> Void)? = nil){
        //prevent mutiply show
        
        //(UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = UIColor.clear
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewController.present(self, animated: animated, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.contentCenterYConstraint.constant = -30
                UIView.animate(withDuration: 0.35,
                               delay: 0,
                               usingSpringWithDamping: CGFloat(0.75),
                               initialSpringVelocity: CGFloat(3.0),
                               options: UIView.AnimationOptions.allowUserInteraction,
                               animations: {
                                self.view.layoutIfNeeded()
                },completion: nil)
            })
            
        }
    }
    
    func dismissWithCompletion(){
        //prevent mutiply show
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: false, completion: nil)
            guard self.dismissCompletion != nil else {
                return 
            }
            self.dismissCompletion!()
//        }
    }
    
    func showInputErrorTip(string: String?){
        DispatchQueue.main.async {
            self.textFieldInput.showErrorTip(locolizedError: string ?? "")
        }
    }
}




/// This extension is designed to handle dialog positioning
/// if a keyboard is displayed while the popup is on top
internal extension AlertStylePopViewController {
    
    func centerPopup(){

        let p2 = self.whiteContentView.convert(self.whiteContentView.bounds, to: self.view)
        let m = kUIScreenHeight - p2.maxY
        let whiteContentBottomToKeyboardView = (m - keyboardHeight)// - 30
        self.contentCenterYConstraint.constant = whiteContentBottomToKeyboardView - 5
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.75),
                       initialSpringVelocity: CGFloat(3.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        self.view.layoutIfNeeded()
        },completion: nil)
        
    }
    // MARK: - Keyboard & orientation observers
    
    /*! Add obserservers for UIKeyboard notifications */
    func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    /*! Remove observers */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }
    
    // MARK: - Actions
    
    /*!
     Keyboard will show notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        keyboardShown = true
        centerPopup()
    }
    
    /*!
     Keyboard will hide notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard isTopAndVisible else { return }
        keyboardShown = false
//        centerPopup()
    }
    
    /*!
     Keyboard will change frame notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardRect = (notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        keyboardHeight = keyboardRect.cgRectValue.height
    }
    

}

//MARK: - UITextFieldDelegate

extension AlertStylePopViewController{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
