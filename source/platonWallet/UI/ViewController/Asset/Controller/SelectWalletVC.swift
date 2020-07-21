//
//  SelectWalletVC.swift
//  platonWallet
//
//  Created by juzix on 2020/7/20.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SelectWalletVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum EnterMode {
        /// 从切换钱包处进入
        case fromChangeWallet
        /// 从委托代理进入
        case fromDelegation
    }

    let contentView = UIView()
    let selectWalletTitleLabel = UILabel()
    var selectedCateIndex: Int = 0 {
        didSet {
            reloadCatesInfo()
        }
    }
    /// 进入页面时的钱包地址
    fileprivate var walletAddress: String? {
        didSet {
            tableView.reloadData()
        }
    }
    fileprivate var enterMode: EnterMode?

    var cateButtons: [SelectWalletTypeButton]!
    let searchBar = SelectWalletSearchBar()
    let cateTitles = [Localized("WalletTypeTag_all"), Localized("WalletTypeTag_HD"), Localized("WalletTypeTag_normal")]
    let searchButton = UIButton(type: .custom)

    var isSearchBarHidden: Bool = true
    // 该页面tableView的数据源
    var sectionInfos: [SelectWalletDisplaySectionInfo] = [] {
        didSet {
            
        }
    }
    /// 搜索关键字
    var searchingKeyword: String = ""
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    // 选中的indexPath
    var selectedIndexPath: IndexPath?
    /// 选中了新的钱包回调
    var chooseWalletCallback: ((_ walletAddress: String) -> Void)?

    convenience init(walletAddress: String, enterMode: SelectWalletVC.EnterMode) {
        self.init()
        self.walletAddress = walletAddress
        self.enterMode = enterMode
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        configData()
        configContent()
        if let indexPath = getInitialSectedIndex() {
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    func configData() {
        sectionInfos = generatePageDataSource(cate: .all)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showContent()
    }

    func show(from viewController: UIViewController) {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        viewController.navigationController?.present(self, animated: true, completion: nil)
    }

    func configContent() {
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor(hex: "F9FBFF")
        contentView.frame = CGRect(x: self.view.bounds.width, y: 0, width: 290, height: self.view.bounds.height)
        contentView.cropView(corners: [.topLeft, .bottomLeft], cornerRadiiV: 35)

        contentView.addSubview(selectWalletTitleLabel)
        selectWalletTitleLabel.text = Localized("Wallet_selectingTitle")
        selectWalletTitleLabel.font = UIFont.systemFont(ofSize: 18)
        selectWalletTitleLabel.frame = CGRect(x: 16, y: 38, width: 112, height: 25)

        cateButtons = []
        for i in 0..<cateTitles.count {
            let btn = SelectWalletTypeButton(type: .custom)
            btn.setTitle(cateTitles[i], for: .normal)
            cateButtons.append(btn)
            contentView.addSubview(btn)
            let itemW: CGFloat = 68
            let itemH: CGFloat = 28
            let itemSpacing: CGFloat = 14
            btn.frame = CGRect(x: 16 + CGFloat(i) * (itemW + itemSpacing), y: 81, width: itemW, height: itemH)
            btn.isSelected = selectedCateIndex == i
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(cateButtonClick(sender:)), for: .touchUpInside)
        }

        contentView.addSubview(searchButton)
        searchButton.frame = CGRect(x: 290 - 10 - 20, y: 85, width: 20, height: 20)
        searchButton.setImage(UIImage(named: "wallet_icon_Search"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonClick(sender:)), for: .touchUpInside)

        contentView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(searchButton.snp.bottom).offset(18)
            make.height.equalTo(35)
        }
        searchBar.hideButtonClickCallback = {[weak self] (sender) in
            guard let self = self else { return }
            self.changeHiddenStatus()
        }
        searchBar.textFieldMainValueEditingCallback = {[weak self] (text) in
            guard let self = self else { return }
            self.searchingKeyword = text
            self.reloadCatesInfo()
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(-UIApplication.shared.keyWindow!.safeAreaInsets.bottom)
            } else {
                make.bottom.equalTo(0)
            }
            make.top.equalTo(searchButton.snp.bottom).offset(14)
        }
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: "F9FBFF")
        tableView.separatorColor = tableView.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(cellTypes: [SelectWalletTCell.self])
        tableView.register(SelectWalletTableHeader.self, forHeaderFooterViewReuseIdentifier: "SelectWalletTableHeader")
    }

    func showContent() {
        UIView.animate(withDuration: 0.15) {
            self.contentView.frame = CGRect(x: self.view.bounds.width - 290, y: 0, width: 290, height: self.view.bounds.height)
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.15) {
            self.contentView.frame = CGRect(x: self.view.bounds.width, y: 0, width: 290, height: self.view.bounds.height)
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            let touchPoint = t.location(in: self.view)
            if !self.contentView.frame.contains(touchPoint) {
                hide()
            }
        }
    }

    // MARK: UITableViewDelegate & UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionInfos.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionInfos[section].subWallets.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionInfos[section].isNormalSecion == true {
            return CGFloat.leastNormalMagnitude
        }
        return 31
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionInfos[section].isNormalSecion == true {
            return UIView()
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SelectWalletTableHeader") as! SelectWalletTableHeader
        header.title = sectionInfos[section].wallet?.name ?? ""
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelectWalletTCell.self), for: indexPath) as! SelectWalletTCell
        cell.wallet = sectionInfos[indexPath.section].subWallets[indexPath.row]
        cell.isChoosed = cell.wallet?.address == self.walletAddress
        if cell.isChoosed == true {
            selectedIndexPath = indexPath
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = sectionInfos[indexPath.section].subWallets[indexPath.row].address
        self.walletAddress = address
        guard let callback = self.chooseWalletCallback else {
            return
        }
        callback(address)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hide()
        }
    }

    // MARK: Events

    @objc func searchButtonClick(sender: UIButton) {
        changeHiddenStatus()
    }

    func changeHiddenStatus() {
        isSearchBarHidden = !isSearchBarHidden
        tableView.snp.remakeConstraints { (make) in
            make.left.right.equalTo(contentView)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(-UIApplication.shared.keyWindow!.safeAreaInsets.bottom)
            } else {
                make.bottom.equalTo(0)
            }
            if isSearchBarHidden == false {
                make.top.equalTo(searchBar.snp.bottom).offset(9)
            } else {
                make.top.equalTo(searchButton.snp.bottom).offset(14)
            }
        }
    }

    /// 分类按钮点击时间
    @objc func cateButtonClick(sender: UIButton) {
        let index = sender.tag - 100
        self.selectedCateIndex = index
    }

    /// 刷新分类选中信息并且刷新列表数据
    func reloadCatesInfo() {
        for (i, v) in cateButtons.enumerated() {
            v.isSelected = i == selectedCateIndex
        }
        if selectedCateIndex == 0 {
            // All
            sectionInfos = generatePageDataSource(cate: .all, keyword: self.searchingKeyword)
        } else if selectedCateIndex == 1 {
            // HD
            sectionInfos = generatePageDataSource(cate: .hd, keyword: self.searchingKeyword)
        } else if selectedCateIndex == 2 {
            // Normal
            sectionInfos = generatePageDataSource(cate: .normal, keyword: self.searchingKeyword)
        }
        tableView.reloadData()
    }
}

extension SelectWalletVC {

    /// 展示的钱包分类
    enum WalletCate {
        case all
        case hd
        case normal
    }

    /// 生成当前页面需要展示的数据源
    func generatePageDataSource(cate: WalletCate, keyword: String = "") -> [SelectWalletDisplaySectionInfo] {
        var sectionInfos: [SelectWalletDisplaySectionInfo] = []
        /// 普通组
        var normalSectionInfo = SelectWalletDisplaySectionInfo(wallet: nil, subWallets: [])
        let wallets = AssetVCSharedData.sharedData.walletList as! [Wallet]
        for wallet in wallets {
            let foundable = self.isFoundable(wallet: wallet, keyword: keyword)
            if wallet.isHD == false {
                if cate == .all || cate == .normal {
                    if keyword.count > 0 {
                        // 如果存在关键字，需要筛选钱包模糊名称或地址精确名称
                        if foundable == true {
                            normalSectionInfo.subWallets.append(wallet)
                        }
                    } else {
                        normalSectionInfo.subWallets.append(wallet)
                    }
                }
            } else {
                if cate == .all || cate == .hd {
                    if wallet.parentId == nil {
                        /// 临时的HD分组
                        var tempHDSectionInfo = SelectWalletDisplaySectionInfo(wallet: wallet, subWallets: [])
                        let allSubWallets = WalletHelper.fetchHDSubWallets(from: wallets)
                        let subWallets = allSubWallets.filter { (sWallet) -> Bool in
                            sWallet.parentId == wallet.uuid
                        }
                        if keyword.count > 0 {
                            let fiteredSubWallets = subWallets.filter { (wallet) -> Bool in
                                return self.isFoundable(wallet: wallet, keyword: keyword)
                            }
                            tempHDSectionInfo.subWallets = fiteredSubWallets
                        } else {
                            tempHDSectionInfo.subWallets = subWallets
                        }
                        if tempHDSectionInfo.subWallets.count > 0 {
                            sectionInfos.append(tempHDSectionInfo)
                        }
                    }
                }
            }
        }
        if normalSectionInfo.subWallets.count > 0 {
            /// 普通组作为数据源的第一组数据
            sectionInfos.insert(normalSectionInfo, at: 0)
        }
        return sectionInfos
    }
    
    /// 钱包是否可以被搜索到
    func isFoundable(wallet: Wallet, keyword: String) -> Bool {
        let lWalletAddr = wallet.address.lowercased()
        let lWalletName = wallet.name.lowercased()
        let lKeyword = keyword.lowercased()
        let res = lWalletAddr.hasPrefix(lKeyword) == true || lWalletName.contains(lKeyword)
        return res
    }

    /// 获取当前数据源中初始的选中索引值
    func getInitialSectedIndex() -> IndexPath? {
        for (i, v) in sectionInfos.enumerated() {
            for (j, v2) in v.subWallets.enumerated() {
                if self.walletAddress == v2.address {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
}

struct SelectWalletDisplaySectionInfo {
    var wallet: Wallet?
    var subWallets: [Wallet] = []

    /// 是否是普通钱包分组
    var isNormalSecion: Bool {
        get {
            return wallet == nil
        }
    }

}
