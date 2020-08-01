//
//  DropdownListView.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

struct DropdownCellStyle {

//    var wallets: [Wallet]
    var sectionInfos: [WalletDisplaySectionInfo] {
        return WalletHelper.fetchWalletDisplaySectionInfos()
    }
    
    var isExpand: Bool = false
    var curWallet: Wallet?

    var sectionIsSpreadArr: [Bool]!

//    var cellCount: Int {
//        return wallets.count + 1
//    }

//    var currentWallet: Wallet? {
//        return getWallet(for: selectedIndex)
//    }
//
//    func getWallet(for index: Int) -> Wallet? {
//        return index == 0 ? nil : wallets[index - 1]
//    }
}

class DropdownListView: UIView {
    
    //    var selectedIndex: Int = 0
    var selectedIndexPath: IndexPath = IndexPath(row: -1, section: 0)  /// 约定选中组头是，row为-1
    /// 当前展开的分组， -1则为全部收起
    var spreadingSection: Int = -1

    lazy var walletIconIV = { () -> UIImageView in
        let imageView = UIImageView()
        imageView.image = UIImage(named: "4.icon_AII wallets")
        return imageView
    }()

    lazy var walletLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.text = Localized("transaction_list_all_wallet")
        return label
    }()

    lazy var walletButton = { () -> UIButton in
        let button = UIButton()
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(openWalletListView), for: .touchUpInside)
        button.addSubview(walletIconIV)
        walletIconIV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }

        button.addSubview(walletLabel)
        walletLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(walletIconIV.snp.trailing).offset(8)
        }

        let arrowIV = UIImageView()
        arrowIV.image = UIImage(named: "3.icon_ drop-down")
        button.addSubview(arrowIV)
        arrowIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
            make.leading.equalTo(walletLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }
        return button
    }()

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero, style: .grouped)
        tbView.delegate = self
        tbView.dataSource = self
//        tbView.register(DropdownTableViewCell.self, forCellReuseIdentifier: "DropdownTableViewCell")
        tbView.register(DropdownSubWalletTCell.self, forCellReuseIdentifier: "DropdownSubWalletTCell")
        tbView.register(DropdownTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "DropdownTableViewHeader")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        tbView.layer.shadowRadius = 4.0
        tbView.layer.shadowOffset = CGSize(width: 2, height: 2)
        tbView.layer.shadowOpacity = 0.2
        tbView.isUserInteractionEnabled = true
        if #available(iOS 11.0, *) {
            // 防止tableView抖动
            tbView.estimatedRowHeight = 0
            tbView.estimatedSectionFooterHeight = 0
            tbView.estimatedSectionHeaderHeight = 0
            tbView.contentInsetAdjustmentBehavior = .never
        }
        return tbView
    }()

    var selectedWallet: Wallet?

    lazy var walletsObject = { () -> DropdownCellStyle in
        let selectedIndex = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.firstIndex(where: { (wallet) -> Bool in
            return wallet.address == selectedWallet?.address
        })

//        let style = DropdownCellStyle(wallets: AssetVCSharedData.sharedData.walletList as! [Wallet], selectedIndex: selectedIndex ?? 0, isExpand: false)
        let style = DropdownCellStyle()
        return style
    }()

    lazy var dimView = { () -> UIView in
        let dimView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        dimView.backgroundColor = .clear
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapActionForDismiss(gestureRecognizer:))))
        return dimView
    }()

    var tableViewHeightConstaint: Constraint?
    var dropdownListDidHandle: ((_ selectedWallet: Wallet?,_ dataSourceWallets: [Wallet]?) -> Void)?

    convenience init(for selectedWallet: Wallet?) {
        self.init(frame: .zero)

        self.selectedWallet = selectedWallet

        if let wallet = selectedWallet {
            walletIconIV.image = UIImage(named: wallet.avatar)
            walletLabel.text = wallet.name
        } else {
            walletIconIV.image = UIImage(named: "4.icon_AII wallets")
            walletLabel.text = Localized("transaction_list_all_wallet")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    

        layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.2

        addSubview(walletButton)
        walletButton.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().offset(0)
            make.height.equalTo(50)
        }

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(walletButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priorityLow()
            tableViewHeightConstaint = make.height.equalTo(0).constraint
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tapActionForDismiss(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.view == tableView {
            return
        }
        dismiss()
    }

    private func showDimView() {
        guard let superView = self.superview, dimView.superview == nil else { return }
        superView.insertSubview(dimView, belowSubview: self)
    }

    private func hideDimView() {
        guard dimView.superview != nil else { return }
        dimView.removeFromSuperview()
    }

    private func dismiss() {
        walletsObject.isExpand = false
        UIView.animate(withDuration: 0.3, animations: {
            self.tableViewHeightConstaint?.update(offset: 0)
            self.layoutIfNeeded()
        }) { (_) in
            self.hideDimView()
        }
    }

    private func show() {
        walletsObject.isExpand = true
        UIView.animate(withDuration: 0.3, animations: {
            self.tableViewHeightConstaint?.update(offset: min((AssetVCSharedData.sharedData.walletList.count + 1) * 60, 240))
            self.layoutIfNeeded()
        }) { (_) in
            self.showDimView()
        }
    }

    @objc func openWalletListView() {
        if walletsObject.isExpand {
            dismiss()
        } else {
            show()
        }
        tableView.reloadData()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let point1 = self.convert(point, to: tableView)
        if tableView.point(inside: point1, with: event) {
            return tableView.hitTest(point1, with: event)
        }
        return super.hitTest(point, with: event)
    }
}

extension DropdownListView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return  walletsObject.sectionInfos.count + 1 // 首组用于显示全部
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            if spreadingSection == section {
                return walletsObject.sectionInfos[section - 1].subWallets.count // walletsObject.cellCount
            } else {
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DropdownTableViewHeader") as! DropdownTableViewHeader
        if section == 0 {
            header.setupDataSource(for: nil)
            header.expandingButton.isHidden = true
        } else {
            let wallet = walletsObject.sectionInfos[section - 1].wallet
            header.expandingButton.isHidden = walletsObject.sectionInfos[section - 1].subWallets.count == 0
            header.expandingButton.imageView?.transform = CGAffineTransform(rotationAngle: spreadingSection == section ? CGFloat(Double.pi) : 0)
            header.setupDataSource(for: wallet)
        }
        header.contentTappedCallback = {[weak self] in
            guard let self = self else {
                return
            }
            self.selectedIndexPath = IndexPath(row: -1, section: section)
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss()
            }
            if section == 0 {
                self.dropdownListDidHandle?(nil, nil)
                self.walletIconIV.image = UIImage(named: "4.icon_AII wallets")
                self.walletLabel.text = Localized("transaction_list_all_wallet")
            } else {
                let wallet = self.walletsObject.sectionInfos[section - 1].wallet
                let subWallets = Array(wallet.subWallets)
                self.dropdownListDidHandle?(wallet, subWallets.count == 0 ? [wallet] : subWallets)
                self.walletIconIV.image = UIImage(named: wallet.avatar)
                self.walletLabel.text = wallet.name
            }
        }
        header.expandButtonClickCallback = {[weak self] (button) in
            guard let self = self else { return }
            let lastSpreadingSection = self.spreadingSection
            if self.spreadingSection == section {
                self.spreadingSection = -1 // 若当前组展开时点击。则收起当前组，即所有组都收起
            } else {
                self.spreadingSection = section  // 展开当前组
            }
//            self.tableView.reloadData()
            var indexSet: IndexSet!
            if lastSpreadingSection >= 0 {
                if self.spreadingSection >= 0 {
                    indexSet = IndexSet([self.spreadingSection, lastSpreadingSection]) // 新组旧组都存在，一起刷新
                } else {
                    indexSet = IndexSet([lastSpreadingSection]) // 只存在旧组，则刷新旧组
                }
            } else {
                if self.spreadingSection >= 0 {
                    indexSet = IndexSet([self.spreadingSection]) // 只存在新选中组，刷新选中组
                } else {
                    self.tableView.reloadData() // 都不存在，刷新整个表格
                    return
                }
            }
            if let indexSet = indexSet {
                self.tableView.reloadSections(indexSet, with: .fade)
                if section > 0 && self.spreadingSection == section {
                    // 展开组后tableView滚动到当前组
                    let frame = self.tableView.rect(forSection: section)
                    self.tableView.setContentOffset(CGPoint(x: 0, y: frame.origin.y), animated: true)
                }
            }
        }
        header.selectingImageView.isHidden = self.selectedIndexPath != IndexPath(row: -1, section: section)
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownSubWalletTCell") as! DropdownSubWalletTCell
        let wallet = walletsObject.sectionInfos[indexPath.section - 1].subWallets[indexPath.row]
        cell.selectingImageView.isHidden = self.selectedIndexPath != indexPath
        cell.setupCellData(for: wallet)
//        cell.setupCellData(for: walletsObject.getWallet(for: indexPath.row))

//        cell.toplineV.isHidden = true
//        cell.bottomlineV.isHidden = true
//        cell.bottomlineV.isHidden = (indexPath.row == walletsObject.cellCount - 1)
//        cell.rightImageView.image = (indexPath.row == walletsObject.selectedIndex) ? UIImage(named: "iconApprove") : nil
//        cell.walletNameLabel.textColor = (indexPath.row == walletsObject.selectedIndex) ? .black : UIColor(rgb: 0x898c9e)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.tableView.reloadData()
        if indexPath.section > 0 {
            let wallet = walletsObject.sectionInfos[indexPath.section - 1].subWallets[indexPath.row]
            dropdownListDidHandle?(wallet, [wallet])
            walletIconIV.image = UIImage(named: wallet.avatar)
            walletLabel.text = wallet.name
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss()
        }
//        walletsObject.selectedIndex = indexPath.row
//
//        if let wallet = walletsObject.getWallet(for: indexPath.row) {
//            walletIconIV.image = UIImage(named: wallet.avatar)
//            walletLabel.text = wallet.name
//            dropdownListDidHandle?(wallet)
//        } else {
//            walletIconIV.image = UIImage(named: "4.icon_AII wallets")
//            walletLabel.text = Localized("transaction_list_all_wallet")
//            dropdownListDidHandle?(nil)
//        }
//
//        tableView.reloadData()
    }
}

//final class DropdownTableViewCell: UITableViewCell {
//
//    public let walletAvatarIV = UIImageView()
//    public let walletNameLabel = UILabel()
//    public let bottomlineV = UIView()
//    public let toplineV = UIView()
//    public let rightImageView = UIImageView()
//
//    func setupCellData(for wallet: Wallet?) {
//        guard let wal = wallet else {
//            walletNameLabel.text = Localized("transaction_list_all_wallet")
//            walletAvatarIV.image = UIImage(named: "4.icon_AII wallets")
//            return
//        }
//        walletNameLabel.text = wal.name
//        walletAvatarIV.image = UIImage(named: wal.avatar)
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        selectionStyle = .none
//
//        let containerView = UIButton()
//        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
//        containerView.backgroundColor = .white
//        contentView.addSubview(containerView)
//        containerView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(60)
//            make.bottom.equalToSuperview()
//        }
//
//        //        walletAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
//        walletAvatarIV.image = UIImage(named: "walletAvatar_1")
//        containerView.addSubview(walletAvatarIV)
//        walletAvatarIV.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview().offset(5)
//            make.width.height.equalTo(42)
//        }
//
//        walletNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
//        walletNameLabel.textColor = .black
//        walletNameLabel.text = Localized("staking_main_wallet_name")
//        containerView.addSubview(walletNameLabel)
//        walletNameLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(5)
//            make.height.equalTo(18)
//        }
//
//        toplineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
//        containerView.addSubview(toplineV)
//        toplineV.snp.makeConstraints { make in
//            make.height.equalTo(1/UIScreen.main.scale)
//            make.leading.equalToSuperview().offset(10)
//            make.trailing.equalToSuperview().offset(-10)
//            make.top.equalToSuperview()
//        }
//
//        bottomlineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
//        containerView.addSubview(bottomlineV)
//        bottomlineV.snp.makeConstraints { make in
//            make.height.equalTo(1/UIScreen.main.scale)
//            make.leading.equalToSuperview().offset(10)
//            make.trailing.equalToSuperview().offset(-10)
//            make.bottom.equalToSuperview()
//        }
//
//        containerView.addSubview(rightImageView)
//        rightImageView.snp.makeConstraints { make in
//            make.leading.equalTo(walletNameLabel.snp.trailing).offset(10)
//            make.trailing.equalToSuperview().offset(-16)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(20)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func containerTapAction() {
//
//    }
//}

class DropdownTableViewHeader: UITableViewHeaderFooterView {
    
    /// 内容被点击后的回调
    var contentTappedCallback: (() -> Void)?
    var expandButtonClickCallback: ((UIButton) -> Void)?
    var contentBackView = UIView()
    var avatarImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var selectingImageView = UIImageView()
    var expandingButton = UIButton()
    var floatingControl = UIControl()
    
    func setupDataSource(for wallet: Wallet?) {
        guard let wal = wallet else {
            titleLabel.text = Localized("transaction_list_all_wallet")
            avatarImageView.image = UIImage(named: "4.icon_AII wallets")
            return
        }
        titleLabel.text = wal.name
        avatarImageView.image = UIImage(named: wal.avatar)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentBackView)
        
        contentBackView.addSubview(avatarImageView)
        contentBackView.addSubview(titleLabel)
        contentBackView.addSubview(selectingImageView)
        contentBackView.addSubview(floatingControl)
        contentBackView.addSubview(expandingButton)
    
        contentBackView.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }

        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(42)
            make.centerY.equalToSuperview()
            make.leading.equalTo(5)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(55)
            make.centerY.equalToSuperview()
        }

        selectingImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        selectingImageView.image = UIImage(named: "iconApprove")
        
        floatingControl.snp.makeConstraints { (make) in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        floatingControl.addTarget(self, action: #selector(contentBackViewTapped(sender:)), for: .touchUpInside)
        
        expandingButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
//        expandingButton.image = UIImage(named: "3.icon_ drop-down")
        expandingButton.setImage(UIImage(named: "3.icon_ drop-down"), for: .normal)
        expandingButton.addTarget(self, action: #selector(expandingButtonClick(sender:)), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func contentBackViewTapped(sender: UIControl) {
        guard let callback = self.contentTappedCallback else {
            return
        }
        callback()
    }
    
    @objc func expandingButtonClick(sender: UIButton) {
        guard let callback = self.expandButtonClickCallback else {
            return
        }
        callback(sender)
    }
}

class DropdownSubWalletTCell: UITableViewCell {

    fileprivate var contentBackView = UIView()
    fileprivate var avatarImageView = UIImageView()
    fileprivate var titleLabel: UILabel = UILabel()
    fileprivate var selectingImageView = UIImageView()
    
    func setupCellData(for wallet: Wallet?) {
        guard let wal = wallet else {
            return
        }
        titleLabel.text = wal.name
        avatarImageView.image = UIImage(named: wal.avatar)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(contentBackView)
        contentBackView.addSubview(avatarImageView)
        contentBackView.addSubview(titleLabel)
        contentBackView.addSubview(selectingImageView)
        
        contentBackView.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }

        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(33)
            make.centerY.equalToSuperview()
            make.leading.equalTo(55)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        titleLabel.text = "hehehe"
        
        selectingImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        selectingImageView.image = UIImage(named: "iconApprove")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
