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
    var wallets: [Wallet]
    var selectedIndex: Int = 0
    var isExpand: Bool = false
    
    var cellCount: Int {
        return wallets.count + 1
    }
    
    var currentWallet: Wallet? {
        return getWallet(for: selectedIndex)
    }
    
    func getWallet(for index: Int) -> Wallet? {
        return index == 0 ? nil : wallets[index - 1]
    }
}

class DropdownListView: UIView {
    
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
        walletLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(walletIconIV.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        let arrowIV = UIImageView()
        arrowIV.image = UIImage(named: "3.icon_ drop-down")
        button.addSubview(arrowIV)
        arrowIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
            make.trailing.equalToSuperview().offset(-20)
        }
        return button
    }()
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(DropdownTableViewCell.self, forCellReuseIdentifier: "DropdownTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        tbView.layer.shadowRadius = 4.0
        tbView.layer.shadowOffset = CGSize(width: 2, height: 2)
        tbView.layer.shadowOpacity = 0.2
        return tbView
    }()
    
    var selectedWallet: Wallet?
    
    lazy var walletsObject = { () -> DropdownCellStyle in
        let selectedIndex = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.firstIndex(where: { (wallet) -> Bool in
            return wallet.address == selectedWallet?.address
        })
        
        let style = DropdownCellStyle(wallets: AssetVCSharedData.sharedData.walletList as! [Wallet], selectedIndex: selectedIndex ?? 0, isExpand: false)
        return style
    }()
    
    lazy var dimView = { () -> UIView in
        let dimView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        dimView.backgroundColor = .clear
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapActionForDismiss(gestureRecognizer:))))
        return dimView
    }()
    
    var tableViewHeightConstaint: Constraint?
    var dropdownListDidHandle: ((Wallet?) -> Void)?
    
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
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 2, height: 2)
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
            return tableView
        }
        return super.hitTest(point, with: event)
    }
    
}

extension DropdownListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletsObject.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownTableViewCell") as! DropdownTableViewCell
        cell.setupCellData(for: walletsObject.getWallet(for: indexPath.row))
        
        cell.toplineV.isHidden = indexPath.row != 0
        cell.bottomlineV.isHidden = (indexPath.row == walletsObject.cellCount - 1)
        cell.rightImageView.image = (indexPath.row == walletsObject.selectedIndex) ? UIImage(named: "iconApprove") : nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss()
        walletsObject.selectedIndex = indexPath.row
        
        if let wallet = walletsObject.getWallet(for: indexPath.row) {
            walletIconIV.image = UIImage(named: wallet.avatar)
            walletLabel.text = wallet.name
            dropdownListDidHandle?(wallet)
        } else {
            walletIconIV.image = UIImage(named: "4.icon_AII wallets")
            walletLabel.text = Localized("transaction_list_all_wallet")
            dropdownListDidHandle?(nil)
        }
        
        tableView.reloadData()
    }
}

final class DropdownTableViewCell: UITableViewCell {
    public let walletAvatarIV = UIImageView()
    public let walletNameLabel = UILabel()
    public let bottomlineV = UIView()
    public let toplineV = UIView()
    public let rightImageView = UIImageView()
    
    func setupCellData(for wallet: Wallet?) {
        guard let wal = wallet else {
            walletNameLabel.text = Localized("transaction_list_all_wallet")
            walletAvatarIV.image = UIImage(named: "4.icon_AII wallets")
            return
        }
        walletNameLabel.text = wal.name
        walletAvatarIV.image = UIImage(named: wal.avatar)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let containerView = UIButton()
        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        
//        walletAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        walletAvatarIV.image = UIImage(named: "walletAvatar_1")
        containerView.addSubview(walletAvatarIV)
        walletAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }
        
        walletNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        walletNameLabel.textColor = .black
        walletNameLabel.text = Localized("staking_main_wallet_name")
        containerView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }
        
        toplineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        containerView.addSubview(toplineV)
        toplineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
        }
        
        bottomlineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        containerView.addSubview(bottomlineV)
        bottomlineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
        
        containerView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.leading.equalTo(walletNameLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func containerTapAction() {
        
    }
}
