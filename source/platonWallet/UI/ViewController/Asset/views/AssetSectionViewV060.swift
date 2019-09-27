//
//  AssetSectionViewV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

let sectionHeight : CGFloat = 52.0
let maskHeight : CGFloat = 36.0



class AssetSectionViewV060: UIView {
    
    var restrictedIconTapHandler: (() -> Void)?
    
    var walelt: AnyObject?

    @IBOutlet weak var walletAvatar: UIButton!
    
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var lockedBalanceLabel: UILabel!
    
    @IBOutlet weak var forgroundView: UIView!
    
    @IBOutlet weak var transactionLabel: UILabel!
    
    @IBOutlet weak var txIcon: UIImageView!
    
    @IBOutlet weak var sendIcon: UIImageView!
    
    @IBOutlet weak var receiveIcon: UIImageView!
    
    
    @IBOutlet weak var sendLabel: UILabel!
    
    @IBOutlet weak var recvLabel: UILabel!
    
    @IBOutlet weak var backUpbtn: UIButton!
    
    @IBOutlet weak var bottomSepline: UIView!
    
    @IBOutlet weak var backupContainer: UIView!
    
    
    var bottomSelectIndicator : UIView = UIView(frame: .zero)
    
    var maskOffset : CGFloat = 0
    
    var selectedIndex = 0
    
    var tmpBlock : Bool = false
    
    var isDraging : Bool = false
    
    var onSelectItem : ((_ index: Int) -> Void)?
    
    var onWalletAvatarTapAction: (() -> Void)?
    
    var onLockedBalanceTapAction: (() -> Void)?
    
    @IBOutlet weak var grayoutBackground: UIView!
    
    var maskLayer : CALayer{
        let w = bounds.width * 0.3
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: w, height: maskHeight)
        maskLayer.frame = .zero
        maskLayer.backgroundColor = UIColor.red.cgColor
        maskLayer.cornerRadius = maskHeight * 0.5
        return maskLayer
    }
    
    override func awakeFromNib() {
        //self.forgroundOffset.constant = -sectionHeight
        //self.forgroundView.layer.mask = maskLayer
        
        updateWaleltInfo() 
        AssetVCSharedData.sharedData.registerHandler(object: self) {[weak self] in
            self?.updateWaleltInfo()
        }
        
        self.grayoutBackground.addSubview(bottomSelectIndicator)
        bottomSelectIndicator.backgroundColor = UIColor(rgb: 0x105CFE)
        self.updateBottonIndicator(index: 0)
        
        walletAvatar.addTarget(self, action: #selector(walletAvatarTapAction), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
        
        lockedBalanceLabel.adjustsFontSizeToFitWidth = true
        lockedBalanceLabel.isUserInteractionEnabled = true
        lockedBalanceLabel.textColor = common_lightLightGray_color
        lockedBalanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
        
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.textColor = .black
    }
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        restrictedIconTapHandler?()
    }
    
    
    func newMaskLayer() -> CALayer{
        let w = bounds.width * 0.3
        let maskLayer = CALayer()
        
        maskLayer.frame = CGRect(x: 45, y: 0, width: w, height: bounds.height)
        maskLayer.backgroundColor = UIColor.red.cgColor
        maskLayer.cornerRadius = 52.0 * 0.5
        return maskLayer
    }
    
    @objc private func walletAvatarTapAction() {
        onWalletAvatarTapAction?()
    }
    
    private func updateBottonIndicator(index: Int){
        self.bottomSelectIndicator.snp.removeConstraints()
        UIView.animate(withDuration: 0.2) { 
            self.bottomSelectIndicator.snp.makeConstraints { (make) in
                var alignView : UIView?
                if index == 0{
                    alignView = self.transactionLabel
                }else if index == 1{
                    alignView = self.sendLabel
                }else if index == 2{
                    alignView = self.recvLabel
                } 
                let (_,width) = self.bottomIndicatorXPositionWithIndex(index: index)
                make.centerX.equalTo(alignView!).offset(-10)
                make.width.equalTo(width)
                make.bottom.equalToSuperview()
                make.height.equalTo(3)
            }   
            self.layoutIfNeeded()
        }
        
        let secColor = #colorLiteral(red: 0.06274509804, green: 0.3607843137, blue: 0.9960784314, alpha: 1)
        if index == 0{
            self.txIcon.image = UIImage(named: "txSegmentBlue")
            self.sendIcon.image = UIImage(named: "sendSegmentBlack")
            self.receiveIcon.image = UIImage(named: "recvSegmentBlack")
            
            self.transactionLabel.textColor = secColor
            self.sendLabel.textColor = .black
            self.recvLabel.textColor = .black
            
        }else if index == 1{
            self.txIcon.image = UIImage(named: "txSegmentBlack")
            self.sendIcon.image = UIImage(named: "sendSegmentBlue")
            self.receiveIcon.image = UIImage(named: "recvSegmentBlack")
            
            self.transactionLabel.textColor = .black
            self.sendLabel.textColor = secColor
            self.recvLabel.textColor = .black
        }else if index == 2{
            self.txIcon.image = UIImage(named: "txSegmentBlack")
            self.sendIcon.image = UIImage(named: "sendSegmentBlack")
            self.receiveIcon.image = UIImage(named: "recvSegmentBlue")
            
            self.transactionLabel.textColor = .black
            self.sendLabel.textColor = .black
            self.recvLabel.textColor = secColor
        }
        
        
    }
    
    private func bottomIndicatorXPositionWithIndex(index: Int) -> (CGFloat,CGFloat){
        var label : UILabel?
        if index == 0{
            label = transactionLabel
        }else if index == 1{
            label = sendLabel
        }else if index == 2{
            label = recvLabel
        } 
        let wordWidth = label?.text!.boundingRect(with: CGSize(width: 300, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil).width
        let finnalWidth = CGFloat(wordWidth ?? 0.0) + 30
        let itemCenter = kUIScreenWidth * 0.333 * CGFloat(index) + 0.5 * (kUIScreenWidth * 0.333)
        let x = itemCenter - finnalWidth * 0.5 + 5 + maskOffset
        let frame = CGRect(x: x, y: (sectionHeight - maskHeight) * 0.5, width: finnalWidth, height: maskHeight)
        
        return (frame.origin.x + frame.size.width * 0.5,finnalWidth)
    }
    
    func maskPositionWithIndex(index: Int) -> CGRect{
        
//        return .zero
        
        var label : UILabel?
        if index == 0{
            label = transactionLabel
        }else if index == 1{
            label = sendLabel
        }else if index == 2{
            label = recvLabel
        } 
        let wordWidth = label?.text!.boundingRect(with: CGSize(width: 300, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil).width
        let finnalWidth = CGFloat(wordWidth ?? 0.0) + 50.0
        let itemCenter = kUIScreenWidth * 0.333 * CGFloat(index) + 0.5 * (kUIScreenWidth * 0.333)
        let x = itemCenter - finnalWidth * 0.5 + 5 + maskOffset
        let frame = CGRect(x: x, y: (sectionHeight - maskHeight) * 0.5, width: finnalWidth, height: maskHeight)
        
        return frame
    }
    
  
    //MAKR: - User Interaction
       
    @IBAction func onTab(_ sender: Any) {
        if let button = sender as? UIButton{
            self.setSectionSelectedIndex(index: button.tag)
        }
    }
    
    func setSectionSelectedIndex(index: Int){
        selectedIndex = index
        updateBottonIndicator(index: index)
        self.layoutIfNeeded()
        self.setNeedsLayout()
        if onSelectItem != nil{
            onSelectItem!(selectedIndex)
        }
    }
    
    func updateWaleltInfo(){ 
        guard AssetVCSharedData.sharedData.selectedWallet != nil else {
            self.walletName.text = "--"
            self.balanceLabel.text = "--"
            self.walletAvatar.setImage(UIImage(), for: .normal)
            self.backupContainer.isHidden = true
            return
        }
        self.walelt = AssetVCSharedData.sharedData.selectedWallet
        if let cwallet = self.walelt as? Wallet{
            self.walletName.text = cwallet.name
            self.lockedBalanceLabel.attributedText = cwallet.lockedBalanceAttrForDisplayAsset()
            
            self.balanceLabel.text = cwallet.balanceDescription()
            self.walletAvatar.setImage(cwallet.image(), for: .normal)
            self.backupContainer.isHidden = !cwallet.canBackupMnemonic
        }
    }
    
    func changingOffset(offset: CGFloat, currentIndex:Int, draging: Bool = false) {
        print("page scrolling:\(offset) index:\(currentIndex) draging:\(draging)")
        self.isDraging = draging
        if (offset < 0 && currentIndex == 0) || ( offset > 0 && currentIndex == 2){
            maskOffset = 0
            return
        }
        if !draging{
            maskOffset = 0
            return
        }
        if tmpBlock{
            maskOffset = 0
            return
        }
        let rectfrom = self.maskPositionWithIndex(index: currentIndex)
        let rectto = self.maskPositionWithIndex(index: currentIndex + 1)
        
        maskOffset = offset*(rectto.origin.x - rectfrom.origin.x)/self.frame.size.width
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    func didFinishAnimating(index: Int){
        maskOffset = 0
        selectedIndex = index
        tmpBlock = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.tmpBlock = false
        }
        self.updateBottonIndicator(index: selectedIndex)
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    // MARK: - Notification
    
    @objc func didUpdateAllAsset(){
        self.updateWaleltInfo()
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
