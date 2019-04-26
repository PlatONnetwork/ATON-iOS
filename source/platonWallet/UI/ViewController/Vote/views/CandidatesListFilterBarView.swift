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
import Localize_Swift

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
    
    var filterButtons: [SpringButton] = []
    
    @IBOutlet weak var searchBtn: UIButton!
    
//    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var searchTF: UITextFieldWithSearch!
    
    @IBOutlet weak var searchTextFieldLeading: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextFieldTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var filterContainerLeading: NSLayoutConstraint!
    
    @IBOutlet weak var filterContainerTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var searchBtnTrailing: NSLayoutConstraint!
    
//    @IBOutlet weak var myvoteBtn: UIButton!
    
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
    
    private func factorySpringButton(title titleString: String) -> SpringButton {
        let springButton = SpringButton(type: UIButton.ButtonType.custom)
        springButton.setTitle(titleString, for: .normal)
        springButton.setTitleColor(.black, for: .normal)
        springButton.setTitleColor(UIColor(hex: "105cfe"), for: .selected)
        springButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        springButton.translatesAutoresizingMaskIntoConstraints = false
        return springButton
    }
    
    private func initFilterContainerSubViews() {
        let defaultButton = factorySpringButton(title: Localized("CandidateListVC_defaultBtn_title"))
        let rewardButton = factorySpringButton(title: Localized("CandidateListVC_bonusBtn_title"))
        let locationButton = factorySpringButton(title: Localized("CandidateListVC_areaBtn_title"))
        let spaceOneView = UIView()
        let spaceTwoView = UIView()
        
        filterButtons.append(defaultButton)
        filterButtons.append(rewardButton)
        filterButtons.append(locationButton)
        
        filterButtonContainer.addSubview(defaultButton)
        filterButtonContainer.addSubview(rewardButton)
        filterButtonContainer.addSubview(locationButton)
        filterButtonContainer.addSubview(spaceOneView)
        filterButtonContainer.addSubview(spaceTwoView)
        
        defaultButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(spaceOneView.snp.leading)
        }
        
        spaceOneView.snp.makeConstraints { make in
            make.width.equalTo(spaceTwoView.snp.width)
            make.centerY.equalToSuperview()
        }
        
        rewardButton.snp.makeConstraints { make in
            make.leading.equalTo(spaceOneView.snp.trailing)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(spaceTwoView.snp.leading)
        }
        
        spaceTwoView.snp.makeConstraints { make in
            make.width.equalTo(spaceOneView.snp.width)
            make.centerY.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints { make in
            make.leading.equalTo(spaceTwoView.snp.trailing)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(0)
        }
    }
    
    
    private func initSubViews() {
        
        let view = Bundle.main.loadNibNamed("CandidatesListFilterBarView", owner: self, options: nil)?.first as! UIView
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        initFilterContainerSubViews()
        
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
        
        self.addSubview(bottomSelectIndicator)
        bottomSelectIndicator.backgroundColor = UIColor(rgb: 0x105CFE)
        bottomSelectIndicator.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.bottom.equalToSuperview()
            make.width.equalTo(0)
            make.leading.equalToSuperview().offset(-38)
        }
        
//        self.bottomSelectIndicator.isHidden = true
        
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
                self.filterButtonContainer.alpha = 1.0
                //search textfield
                self.searchTextFieldLeading.constant = kUIScreenWidth
                self.searchTextFieldTrailing.constant = 0
                //search button
                self.searchBtnTrailing.constant = 16
                
            }else if searchStyle == .searching{
                self.searchBtn.isHidden = true
                self.searchTF.isHidden = false
                
                //button container
                self.filterButtonContainer.alpha = 0.0
                //search textfield
                self.searchTextFieldLeading.constant = 16
                self.searchTextFieldTrailing.constant = 16
                //search button
                self.searchBtnTrailing.constant = -50
                
            }else if searchStyle == .searchTextFieldHide{
                
                self.searchBtn.isHidden = true
                self.searchTF.isHidden = true
                
                //button container
                self.filterButtonContainer.alpha = 1.0
                
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
    
    
    
    func updateLayoutstyle(_ offset: CGFloat) {
        self.searchBtn.alpha = offset
        
        // 计算出左右边距距离，为中间间距的1/2
        let itemWidth = kUIScreenWidth/3.0
        let buttonTitleLabelWidth = self.filterButtons.first?.titleLabel?.frame.width
        let spaceWidth = (itemWidth - buttonTitleLabelWidth!)/2.0
        
        let constant = 40 + (offset * ((kUIScreenWidth/2.0) - spaceWidth - 40))
        
        filterButtonContainer.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(16 + (1-offset) * (spaceWidth-16))
            make.trailing.equalToSuperview().offset(-constant)
        }
        
        self.searchStyle = offset == 0.0 ? .searchTextFieldHide : .normal
        
        for (index, btn) in self.filterButtons.enumerated() {
            if btn.isSelected{
                self.updateFilterIndicator(index: index, animated: true)
                break
            }
        }
    }
    
    func setlayoutStyle(expand: Bool){
        self.barHeaderExpand = expand
        if expand{
            self.bottomSelectIndicator.isHidden = false
//            self.snp.updateConstraints { (make) in
//                make.height.equalTo(filterBarExpandHeight)
//            }
            self.searchStyle = SearchStyle.searchTextFieldHide
//            self.myvoteBtn.isHidden = false
//            self.leftTitle.isHidden = false
        }else{
            
            self.bottomSelectIndicator.isHidden = true
//            self.snp.updateConstraints { (make) in
//                make.height.equalTo(filterBarShrinkHeight)
//            }
            self.searchStyle = SearchStyle.normal
//            self.myvoteBtn.isHidden = true
//            self.leftTitle.isHidden = true
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
    
    func updateFilterIndicator(index: Int, animated: Bool = true){
        bottomSelectIndicator.snp.updateConstraints { make in
            make.width.equalTo(searchStyle == .searchTextFieldHide ? self.frame.width/3.0 : 0.0)
            make.leading.equalToSuperview().offset(searchStyle == .searchTextFieldHide ? (self.frame.width*CGFloat(index))/3.0 : 0)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomSelectIndicator.alpha = 1.0
                self.layoutIfNeeded()
            }) { (finished) in
                
            }
        }
    }

}
