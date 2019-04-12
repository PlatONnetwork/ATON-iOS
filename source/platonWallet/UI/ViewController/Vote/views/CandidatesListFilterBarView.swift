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

enum SearchStyle {
    case normal, searching, searchTextFieldHide
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

class CandidatesListFilterBarView: UIView {
    
    @IBOutlet var filterButtons: [SpringButton]!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var searchTF: UITextFieldWithSearch!
    
    @IBOutlet weak var filterContainerLeading: NSLayoutConstraint!
    
    @IBOutlet weak var filterContainerTrailingToSuper: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextFieldLeading: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextFieldTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var searchBtnTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var myvoteBtn: UIButton!
    
    var bottomSelectIndicator : UIView = UIView(frame: .zero)
    
    @IBOutlet weak var filterButtonContainer: UIView!
    
    @IBOutlet weak var expandNavView: UIView!
    
    weak var delegate: HeaderViewProtocol?
    
    var barHeaderExpand : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //initSubViews()
    }
    
    
    private func initSubViews() {
        
        let view = Bundle.main.loadNibNamed("CandidatesListFilterBarView", owner: self, options: nil)?.first as! UIView
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        let leftView = UIImageView(image: UIImage(named: "vote_search_icon_s"), highlightedImage: nil)
        leftView.frame = CGRect(x: 5, y: 5, width: 12, height: 12)
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
        searchTF.layer.cornerRadius = 15
        searchTF.layer.masksToBounds = true
        searchTF.layer.borderColor = UIColor.init(rgb: 0xD5D8DF).cgColor
        searchTF.layer.borderWidth = 1
        searchTF.tintColor = UIColor(rgb: 0x0077FF) 
        searchTF.backgroundColor = .white
        searchTF.text = ""
        
        self.filterButtonContainer.addSubview(bottomSelectIndicator)
        bottomSelectIndicator.backgroundColor = UIColor(rgb: 0x105CFE)
        self.updateFilterIndicator(index: 0)
        
        self.bottomSelectIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextBeginEnding(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)

    }
    
    @objc func onTextBeginEnding(_ notification: Notification){
        guard let textField = notification.object as? UITextField, textField == self.searchTF else {
            return
        }
        self.searchStyle = .searching
    }
    
    var searchStyle : SearchStyle? = .normal{
        didSet{
            if searchStyle == .normal{
                self.searchBtn.isHidden = false
                self.searchTF.isHidden = true
                
                //button container
                self.filterContainerLeading.constant = 0
                self.filterContainerTrailingToSuper.constant = 100
                //search textfield
                self.searchTextFieldLeading.constant = kUIScreenWidth
                self.searchTextFieldTrailing.constant = 0
                //search button
                self.searchBtnTrailing.constant = 16
                
            }else if searchStyle == .searching{
                
                self.searchBtn.isHidden = true
                self.searchTF.isHidden = false
                
                //button container
                self.filterContainerLeading.constant = -kUIScreenWidth
                self.filterContainerTrailingToSuper.constant = kUIScreenWidth
                //search textfield
                self.searchTextFieldLeading.constant = 16
                self.searchTextFieldTrailing.constant = 16
                //search button
                self.searchBtnTrailing.constant = -50
                
            }else if searchStyle == .searchTextFieldHide{
                
                self.searchBtn.isHidden = true
                self.searchTF.isHidden = true
                
                //button container
                self.filterContainerLeading.constant = 0
                self.filterContainerTrailingToSuper.constant = 0
                //search textfield
                self.searchTextFieldLeading.constant = kUIScreenWidth
                self.searchTextFieldTrailing.constant = 0
                //search button
                self.searchBtnTrailing.constant = -50
                
            }
            
            UIView.animate(withDuration: 0.35, animations: {
                self.layoutIfNeeded()
            })
            
        }
    } 
    
    func updateFilterButtonStyle(){
        
        var selectedButton : SpringButton?
        for btn in filterButtons {
            if btn.isSelected{
                selectedButton = btn
            }
            if self.barHeaderExpand{
                btn.contentHorizontalAlignment = .center
            }else{
                btn.contentHorizontalAlignment = .left
            }
        }
        guard selectedButton != nil else{
            return
        }
        self.updateSelectedBtn(selectedButton!)
    }
    
    func updateSelectedBtn(_ selectedBtn: UIButton) {
        
        var scaleFactor : CGFloat = 1.0
        var xoffset : CGFloat = 0
        if self.barHeaderExpand{
            scaleFactor = 1.0
            xoffset = 0.0
        }else{
            scaleFactor = 1.15
            xoffset = 5
        }
        
        for btn in filterButtons {
            
            if btn != selectedBtn {
                btn.isSelected = false
                btn.scaleX = 1.0
                btn.scaleY = 1.0
                btn.x = 0
            }else {
                btn.isSelected = true
                btn.scaleX = scaleFactor
                btn.scaleY = scaleFactor
                btn.x = xoffset
            }
            
            btn.curve = "spring"
            btn.duration = 1.0
            btn.damping = 1.0
            btn.velocity = 6.0
            btn.animateTo()
        }
    }
    
    func setlayoutStyle(expand: Bool){
        self.barHeaderExpand = expand
        if expand{
            self.bottomSelectIndicator.isHidden = false
            self.snp.updateConstraints { (make) in
                make.height.equalTo(filterBarExpandHeight)
            }
            self.searchStyle = SearchStyle.searchTextFieldHide
            self.myvoteBtn.isHidden = false

        }else{
            
            self.bottomSelectIndicator.isHidden = true
            self.snp.updateConstraints { (make) in
                make.height.equalTo(filterBarShrinkHeight)
            }
            self.searchStyle = SearchStyle.normal
            self.myvoteBtn.isHidden = true
        }
        self.updateFilterButtonStyle()
    }
    
    func changeLayoutWhileScrolling(offset: CGFloat){
          
    }
    
    @IBAction func showSearchTF(_ sender: Any) {
        searchBtn.isHidden = true
        searchTF.isHidden = false
        if !self.barHeaderExpand{
            searchTF.becomeFirstResponder()
        }
        
    }

    @objc func hideSearchTF() {
        delegate?.hideSearchTextField(searchTF)
        searchTF.text = ""
        searchBtn.isHidden = false
        searchTF.isHidden = true
        searchTF.resignFirstResponder()
        
        self.searchStyle = .normal
    }
     
    //MARK: - Indicator
    func updateFilterIndicator(index: Int){
        self.bottomSelectIndicator.snp.removeConstraints()
        UIView.animate(withDuration: 0.2) { 
            self.bottomSelectIndicator.snp.makeConstraints { (make) in
                let alignView : UIView = self.filterButtons[index]
                let width = kUIScreenWidth * 0.3333
                make.centerX.equalTo(alignView)
                make.width.equalTo(width)
                make.bottom.equalToSuperview()
                make.height.equalTo(2)
            }   
            self.layoutIfNeeded()
        }
    }
    
    

}
