//
//  VerifyMnemonicViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/25.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class OptionCollectionViewCell: UICollectionViewCell {
    
    enum Style {
        case white,gray
    }
    
    var label: UILabel!
    
    var style: Style = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    private func initUI() {
//        backgroundColor = UIColor(rgb: 0x465170)
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 13)
//        label.textColor = UIColor.white
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
            maker.height.equalTo(24)
        }
    }
    
    func feedWord(_ word:String, isSelected:Bool = false, style: Style = .gray) {
        
        label.text = word
        switch style {
        case .white:
            
            backgroundColor = UIColor(rgb: 0xE3E6EC)
            label.textColor = UIColor(rgb: 0x24272B)
            
        case .gray: 
            
            if isSelected {
                backgroundColor = UIColor(rgb: 0x313950)
                label.textColor = UIColor(rgb: 0x7A8092)
            }else {
                backgroundColor = UIColor(rgb: 0x465170)
                label.textColor = UIColor.white
            }

        }
        
        
    }
    
}

class VerifyMnemonicViewController: BaseViewController {

    @IBOutlet weak var inputCollectionView: UICollectionView!
    
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    @IBOutlet weak var clearBtn: PButton!
    
    var words_order:[String]!
    
    var selectedWords = [String]()
    
    @IBOutlet weak var submitButton: PButton!
    
    lazy var words_disorder:[String] = {
        
        guard words_order != nil else {
            return []
        }
        
        var words = words_order
        words!.sort(by: { (s1, s2) -> Bool in
            return s1 > s2
        })
        
        words!.sort(by: { (s1:String, s2) -> Bool in
            let seed = arc4random_uniform(2)
            if seed == 1 {
                return s1.compare(s2, options:.backwards) == .orderedAscending
            }else {
                return s2.compare(s1, options:.backwards) == .orderedAscending
            }
        })
        
        return words!
        
    }()
    
    lazy var shadowLayer: CALayer  = {
        let shadowL = CALayer()
        shadowL.backgroundColor = view.backgroundColor?.cgColor
        shadowL.shadowColor = UIColor(rgb: 0x020527, alpha: 0.2).cgColor
        shadowL.shadowOffset = CGSize(width: 0, height: 2)
        shadowL.shadowOpacity = 0.2
        shadowL.shadowRadius = 3
        return shadowL
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addShadow()
    }

    
    func setupUI() {
        
        navigationItem.localizedText = "verifyMnemonicVC_title"
        clearBtn.style = .gray
        
        inputCollectionView.layer.cornerRadius = 4.0
        inputCollectionView.backgroundColor = UIColor(rgb: 0x1F2841)
        inputCollectionView.collectionViewLayout = LeftAlignLayout(10.0, sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        inputCollectionView.delegate = self
        inputCollectionView.dataSource = self
        inputCollectionView.register(OptionCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(OptionCollectionViewCell.self))
        
        optionCollectionView.backgroundColor = view.backgroundColor
        optionCollectionView.collectionViewLayout = LeftAlignLayout(10.0)
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        optionCollectionView.register(OptionCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(OptionCollectionViewCell.self))
        self.checkSubmitButtonEnable()
    }
    
    func addShadow() {
        
        if view.layer.sublayers == nil || !view.layer.sublayers!.contains(shadowLayer) {
            view.layer.insertSublayer(shadowLayer, below: inputCollectionView.layer)
        }
        shadowLayer.frame = inputCollectionView.frame
    }

    @IBAction func clear(_ sender: Any) {
        
        selectedWords.removeAll()
        inputCollectionView.reloadData()
        optionCollectionView.reloadData()
        
    }
    
    @IBAction func submit(_ sender: Any) {
        
        if words_order.count != selectedWords.count {
            return
        }
        
        if wordsOrderIsCorrect() {
            showDisclaimerAlert()
        }else {
            showErrorAlert()
        }
    }
    
    private func checkSubmitButtonEnable(){
        if words_order.count != selectedWords.count || selectedWords.count == 0 {
            submitButton.style = .disable
        }else{
            submitButton.style = .common
        }
    }
    
    
    private func wordsOrderIsCorrect() ->Bool {
        
        if words_order.count != selectedWords.count {
            return false 
        }
        var isCorrect = true
        for i in 0..<words_order.count {
            if words_order[i] != selectedWords[i] {
                isCorrect = false
            }
        }
        return isCorrect
        
    }
    
    private func showErrorAlert() {
        
        let alertC = PAlertController(title: Localized("alert_backupFailed_title"), message: Localized("alert_backupFailed_msg"))
        alertC.addAction(title: Localized("alert_backupFailed_confirmBtn_title")) { 
            
        }
        alertC.show(inViewController: self)
        
    }
    
    private func showDisclaimerAlert() {
        
        let alertC = PAlertController(title: Localized("alert_disclaimer_title"), message: Localized("alert_disclaimer_msg"))
        alertC.addAction(title: Localized("alert_disclaimer_confirmBtn_title")) {
            (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
            
        }
        alertC.show(inViewController: self)
        
    }
    
    override func back() {
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
    }
    
}


extension VerifyMnemonicViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    ///UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == inputCollectionView ? selectedWords.count : words_disorder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: NSStringFromClass(OptionCollectionViewCell.self), for: indexPath) as! OptionCollectionViewCell
        if collectionView == optionCollectionView {
            cell.feedWord(words_disorder[indexPath.item], isSelected: selectedWords.contains(words_disorder[indexPath.item]))
        }else {
            cell.feedWord(selectedWords[indexPath.item], style: .white)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var targetString = ""
        if collectionView == inputCollectionView {
            targetString = selectedWords[indexPath.row]
        }else {
            targetString = words_disorder[indexPath.row]
        }
        
        let wordWidth = (targetString as NSString).boundingRect(with: CGSize(width: 300, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13)], context: nil).width
        
        return CGSize(width: wordWidth + 16 , height: 24)
    }
    
    ///UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == optionCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! OptionCollectionViewCell
            
            if selectedWords.contains(cell.label.text!) {
                return
            }
            
            selectedWords.append(cell.label.text!)
            let targetIndexPath = IndexPath(item: selectedWords.count - 1, section: 0)
            inputCollectionView.insertItems(at: [IndexPath(item: selectedWords.count - 1, section: 0)])
            inputCollectionView.scrollToItem(at: targetIndexPath, at: .bottom, animated: true)
        }else {
            selectedWords.remove(at: indexPath.row)
            inputCollectionView.deleteItems(at: [indexPath])
        }
        optionCollectionView.reloadData()
        checkSubmitButtonEnable()
    }
    
}
