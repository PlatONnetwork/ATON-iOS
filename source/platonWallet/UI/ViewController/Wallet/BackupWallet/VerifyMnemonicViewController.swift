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

        self.layer.borderColor = UIColor(rgb: 0x316DEF).cgColor
        self.layer.borderWidth = 0.5
//        self.layer.cornerRadius = self.frame.size.height * 0.5

        label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(rgb: 0x316DEF)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
            maker.height.equalTo(34)
        }
    }

    func feedWord(_ word:String, isSelected:Bool = false, style: Style = .gray) {

        label.text = word

        switch style {
        case .white:

            label.textColor = UIColor(rgb: 0x316DEF)
            backgroundColor = .white
            self.layer.borderColor = UIColor(rgb: 0x316DEF).cgColor

        case .gray:

            backgroundColor = UIColor(rgb: 0xDCDFE8)
            label.textColor = UIColor(rgb: 0xB6BBD0)
            self.layer.borderColor = UIColor(rgb: 0xDCDFE8).cgColor

        }

    }

}

class VerifyMnemonicViewController: BaseViewController,MnemonicGridViewDelegate {

    var mnemonicGridView : MnemonicGridView? = UIView.viewFromXib(theClass: MnemonicGridView.self) as? MnemonicGridView

    @IBOutlet weak var mnemonicContainer: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!

    @IBOutlet weak var clearBtn: UIButton!

    var walletAddress : String?

    var words_order:[String]!

    var selectedWords : Dictionary<Int,String> = [:]

    //key: bottom disorder collectionCell index, value: grid UITextField index
    var words_disorder_selected_Map : Dictionary<String,String> = [:]

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
            } else {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rt_disableInteractivePop = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    func setupUI() {

        super.leftNavigationTitle = "verifyMnemonicVC_title"

        optionCollectionView.backgroundColor = view.backgroundColor
        optionCollectionView.collectionViewLayout = LeftAlignLayout(10.0)
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        optionCollectionView.register(OptionCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(OptionCollectionViewCell.self))
        self.checkSubmitButtonEnable()

        self.mnemonicContainer.addSubview(self.mnemonicGridView!)
        self.mnemonicGridView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.mnemonicContainer)
        })
        self.mnemonicGridView?.setDisableEditStyle()
        self.mnemonicGridView?.delegate = self
    }

    @IBAction func clear(_ sender: Any) {

        selectedWords.removeAll()
        words_disorder_selected_Map.removeAll()
        self.mnemonicGridView?.removeAllContent()
        optionCollectionView.reloadData()

    }

    @IBAction func submit(_ sender: Any) {

        let inputs = selectedWords.filter { (_,value) -> Bool in
            if value == ""{
                return false
            }
            return true
        }

        if words_order.count != inputs.count {
            return
        }

        if wordsOrderIsCorrect() {
            showDisclaimerAlert()
            guard self.walletAddress != nil, let wallet = WalletService.sharedInstance.getWalletByAddress(address: self.walletAddress!) else {
                return
            }
//            WalletService.sharedInstance.afterBackupMnemonic(wallet: wallet)
            NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: nil)
        } else {
            showErrorAlert()
        }
    }

    private func checkSubmitButtonEnable() {
        let inputs = selectedWords.filter { (_,value) -> Bool in
            if value == ""{
                return false
            }
            return true
        }
        if inputs.count < 12 {
            submitButton.style = .disable
        } else {
            submitButton.style = .blue
        }
    }

    private func wordsOrderIsCorrect() -> Bool {

        let inputs = selectedWords.filter { (_,value) -> Bool in
            if value == ""{
                return false
            }
            return true
        }

        if words_order.count != inputs.count {
            return false
        }

        let inputWords = self.mnemonicGridView?.getMnemonic().split(separator: " ").map({String($0)})

        var isCorrect = true
        for i in 0..<words_order.count {
            if words_order[i] != inputWords![i] {
                isCorrect = false
            }
        }
        return isCorrect

    }

    private func showErrorAlert() {

        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.AlertWithRedTitle(title: "alert_backupFailed_title", message: "alert_backupFailed_msg")
        alertVC.confirmButton.localizedNormalTitle = "alert_backupFailed_confirmBtn_title"
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    private func showDisclaimerAlert() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.AlertWithRedTitle(title: "alert_disclaimer_title", message: "alert_disclaimer_msg")
        alertVC.confirmButton.localizedNormalTitle = "alert_disclaimer_confirmBtn_title"
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            self.afterBackupRouter()
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    func showQuitBackupAlert() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.ChoiceView(message: "backup_quit_tip")
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            self.gotoMain()
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    // MARK: - User Action

    override func onCustomBack() {
        self.showQuitBackupAlert()
    }

    func gotoMain() {
        self.afterBackupRouter()
    }

}

extension VerifyMnemonicViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    ///UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words_disorder.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: NSStringFromClass(OptionCollectionViewCell.self), for: indexPath) as! OptionCollectionViewCell

        let gridViewIndex = words_disorder_selected_Map[String(indexPath.item)]
        var style = OptionCollectionViewCell.Style.white
        if gridViewIndex != nil && (gridViewIndex?.length)! > 0 {
            style = OptionCollectionViewCell.Style.gray
        }
        cell.feedWord(words_disorder[indexPath.item], style: style)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var targetString = ""
        targetString = words_disorder[indexPath.row]

        let wordWidth = (targetString as NSString).boundingRect(with: CGSize(width: 300, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil).width

        return CGSize(width: wordWidth + 20 , height: 34)
    }

    ///UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! OptionCollectionViewCell
        if words_disorder_selected_Map[String(indexPath.row)]?.length ?? 0 > 0 {
            //Invert Selection
            let gridIndexS = words_disorder_selected_Map[String(indexPath.row)]
            guard gridIndexS != nil,let gridindex = Int(gridIndexS!) else {
                return
                }
            selectedWords[gridindex] = ""
            self.mnemonicGridView?.setTextAtIndex(index: gridindex, text: "")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                //delay wait for text setted (self.mnemonicGridView?.setTextAtIndex(index: gridindex, text: ""))
                self.words_disorder_selected_Map[String(indexPath.row)] = ""
                self.optionCollectionView.reloadData()
                self.checkSubmitButtonEnable()
                print("selectedWords:\(self.selectedWords)")
            }

            return
        }

        let gridViewIndex = (self.mnemonicGridView?.getFirstEmptyFieldIndex())!
        words_disorder_selected_Map[String(indexPath.row)] = String(gridViewIndex)
        selectedWords[gridViewIndex] = cell.label.text!
        cell.feedWord(cell.label.text!, isSelected: false, style: .gray)

        self.mnemonicGridView?.setTextAtIndex(index:gridViewIndex, text: cell.label.text!)
        optionCollectionView.reloadData()
        checkSubmitButtonEnable()
        self.checkSubmitButtonEnable()
        print("gridViewIndex:\(gridViewIndex),selectedWords:\(selectedWords)")
    }

    // MARK: MnemonicGridViewDelegate

    func onTextFieldSelected(index: Int,word: String) {
        selectedWords[index] = ""
        for (k,v) in words_disorder_selected_Map {
            if v == String(index) {
                words_disorder_selected_Map[k] = ""
                break
            }
        }

        self.mnemonicGridView?.setTextAtIndex(index: index, text: "")
        optionCollectionView.reloadData()
    }

}
