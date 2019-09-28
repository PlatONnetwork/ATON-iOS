//
//  WithDrawViewController.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt
import platonWeb3

class WithDrawViewController: BaseViewController {
    
    var currentNode: Node?
    var walletStyle: WalletsCellStyle?
    var balanceStyle: BalancesCellStyle?
    var currentAddress: String?
    var currentAmount: BigUInt = BigUInt.zero
    var delegateValue: [DelegationValue] = []
    
    var listData: [DelegateTableViewCellStyle] = []
    var gasPrice: BigUInt?
    var estimateUseGas: BigUInt?
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeInfoTableViewCell.self, forCellReuseIdentifier: "NodeInfoTableViewCell")
        tbView.register(WalletTableViewCell.self, forCellReuseIdentifier: "WalletTableViewCell")
        tbView.register(WalletBalanceTableViewCell.self, forCellReuseIdentifier: "WalletBalanceTableViewCell")
        tbView.register(SendInputTableViewCell.self, forCellReuseIdentifier: "SendInputTableViewCell")
        tbView.register(SingleButtonTableViewCell.self, forCellReuseIdentifier: "SingleButtonTableViewCell")
        tbView.register(DoubtTableViewCell.self, forCellReuseIdentifier: "DoubtTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 50
        }
        return tbView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "delegate_withdraw_title"
        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelFirstResponser)))
        
        fetchDelegateValue()
        getGasPrice()
    }
    
    @objc private func cancelFirstResponser() {
        view.endEditing(true)
    }
    
    private func fetchDelegateValue() {
        showLoadingHUD()
        
        guard
            let node = currentNode,
            let nodeId = node.nodeId,
            let addr = currentAddress else { return }
        StakingService.sharedInstance.getDelegationValue(addr: addr, nodeId: nodeId) { [weak self] (result, data) in
            self?.hideLoadingHUD()
            
            switch result {
            case .success:
                if let newData = data as? [DelegationValue] {
                    self?.delegateValue = newData
                    self?.initBalanceStyle()
                }
            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg ?? "error")
            }
        }
    }
    
    private func initBalanceStyle() {
        guard delegateValue.count > 0 else { return }
        
        let totalLocked = delegateValue.reduce(BigUInt.zero) { (result, dValue) -> BigUInt in
            return result + BigUInt(dValue.locked ?? "0")!
        }
        
        let totalUnLocked = delegateValue.reduce(BigUInt.zero) { (result, dValue) -> BigUInt in
            return result + BigUInt(dValue.unLocked ?? "0")!
        }
        
        let totalDelegate = totalLocked + totalUnLocked
        
        let totalReleased = delegateValue.reduce(BigUInt.zero) { (result, dValue) -> BigUInt in
            return result + BigUInt(dValue.released ?? "0")!
        }
        
        let bStyle = BalancesCellStyle(balances: [
            (Localized("staking_balance_Delegated"), totalDelegate.description),
            (Localized("staking_balance_unlocked_Delegated"), totalUnLocked.description),
            (Localized("staking_balance__release_Delegated"), totalReleased.description)], selectedIndex: 0, isExpand: false)
        balanceStyle = bStyle
        
        initListData()
    }
    
    private func initListData() {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).first { $0.key?.address.lowercased() == currentAddress?.lowercased() }
        guard
            let node = currentNode,
            let bStyle = balanceStyle,
            let wallet = localWallet else { return }
        
        let item1 = DelegateTableViewCellStyle.nodeInfo(node: node)
        walletStyle = WalletsCellStyle(wallets: [wallet], selectedIndex: 0, isExpand: false)
        let item2 = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)
        let item3 = DelegateTableViewCellStyle.walletBalances(balanceStyle: bStyle)
        let item4 = DelegateTableViewCellStyle.inputAmount
        let item5 = DelegateTableViewCellStyle.singleButton(title: Localized("statking_validator_Withdraw"))
        
        let contents = [
            (Localized("staking_doubt_undelegate"), Localized("staking_doubt_undelegate_detail"))
        ]
        let item6 = DelegateTableViewCellStyle.doubt(contents: contents)
        listData.append(contentsOf: [item1, item2, item3, item4, item5, item6])
        
        tableView.reloadData()
    }
}

extension WithDrawViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let style = listData[section]
        switch style {
        case .wallets(let walletStyle):
            return walletStyle.cellCount
        case .walletBalances(let balanceStyle):
            return balanceStyle.cellCount
        case .doubt(let contents):
            return contents.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let style = listData[indexPath.section]
        switch style {
        case .nodeInfo(let node):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NodeInfoTableViewCell") as! NodeInfoTableViewCell
            cell.node = node
            return cell
        case .wallets(let walletStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell") as! WalletTableViewCell
            cell.setupCellData(for: walletStyle.getWallet(for: indexPath.row))
            cell.walletBackgroundView.isHidden = indexPath.row != 0
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == walletStyle.cellCount - 1)
            cell.rightImageView.image =
                (walletStyle.wallets.count <= 1) ? nil :
                indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") :
                indexPath.row == walletStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            cell.cellDidHandle = { [weak self] (_ cell: WalletTableViewCell) in
                guard let self = self, walletStyle.wallets.count > 1 else { return }
                self.walletCellDidHandle(cell)
            }
            return cell
        case .walletBalances(let balanceStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletBalanceTableViewCell") as! WalletBalanceTableViewCell
            cell.setupBalanceData(balanceStyle.balance(for: indexPath.row))
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == balanceStyle.cellCount - 1)
            cell.rightImageView.image = indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") : indexPath.row == balanceStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            
            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self else { return }
                self.balanceCellDidHandle(cell)
            }
            cell.isUserInteractionEnabled = indexPath.row == 0 ? true : (BigUInt(balanceStyle.balance(for: indexPath.row).1) ?? BigUInt.zero > BigUInt.zero)
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.amountView.titleLabel.text = Localized("ATextFieldView_withdraw_title")
            cell.minAmountLimit = "10".LATToVon
            cell.maxAmountLimit = BigUInt(balanceStyle?.currentBalance.1 ?? "0")
            cell.cellDidContentChangeHandler = { [weak self] in
                self?.updateHeightOfRow(cell)
            }
            cell.cellDidContentEditingHandler = { [weak self] (amountVON, isRegular) in
                var inputAmountVON = amountVON
                
                let amount10 = BigUInt("10").multiplied(by: BigUInt(ETHToWeiMultiplier)!)
                if let cAmount = BigUInt(self?.balanceStyle?.currentBalance.1 ?? "0"), cAmount >= amount10, inputAmountVON >= amount10, cAmount > inputAmountVON, isRegular == true {
                    if cAmount - inputAmountVON < amount10 {
                        inputAmountVON = cAmount
                        DispatchQueue.main.async {
                            cell.amountView.textField.text = inputAmountVON.divide(by: ETHToWeiMultiplier, round: 8)
                        }
                    }
                }
                self?.estimateGas(inputAmountVON, cell)
                self?.currentAmount = inputAmountVON
                self?.tableView.reloadSections(IndexSet([indexPath.section + 1]), with: .none)
            }
            if let bStyle = balanceStyle, bStyle.selectedIndex == 2 {
                cell.amountView.textField.isUserInteractionEnabled = false
                self.currentAmount = BigUInt(bStyle.currentBalance.1) ?? BigUInt.zero
                cell.amountView.textField.text = BigUInt(bStyle.currentBalance.1)?.divide(by: ETHToWeiMultiplier, round: 8)
                self.estimateGas(self.currentAmount, cell)
            } else {
                cell.amountView.textField.isUserInteractionEnabled = true
                cell.amountView.textField.text = self.currentAmount > BigUInt.zero ?  self.currentAmount.divide(by: ETHToWeiMultiplier, round: 8) : ""
            }
            return cell
        case .singleButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonTableViewCell") as! SingleButtonTableViewCell
            cell.unavaliableTapAction = (currentAmount <= BigUInt.zero)
            cell.button.setTitle(title, for: .normal)
            cell.cellDidTapHandle = { [weak self] in
                guard let self = self else { return }
                self.nextButtonCellDidHandle()
            }
            return cell
        case .doubt(let contents):
            let content = contents[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoubtTableViewCell") as! DoubtTableViewCell
            cell.titleLabel.text = content.0
            cell.contentLabel.text = content.1
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}

extension WithDrawViewController {
    func withdrawDelegateAction(
        stakingBlockNum: UInt64,
        nodeId: String,
        amount: BigUInt,
        sender: String,
        privateKey: String,
        _ completion: ((Transaction) -> Void)?) {
        showLoadingHUD()
        StakingService.sharedInstance.withdrawDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey) { [weak self] (result, data) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                if let transaction = data as? Transaction {
                    completion?(transaction)
                }
            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg ?? "call web3 error", delay: 2.0)
            }
        }
    }
    
    func nextButtonCellDidHandle() {
        view.endEditing(true)
        
        guard currentAmount > BigUInt.zero else {
            showMessage(text: "提交的数量应大于0")
            return
        }
        
        guard currentAmount >= BigUInt("10").multiplied(by: PlatonConfig.VON.LAT) else {
            showMessage(text: Localized("staking_input_amount_minlimit_error"))
            return
        }
        
        guard currentAmount <= (BigUInt(balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero) else {
            showMessage(text: Localized("staking_input_amount_maxlimit_error"))
            return
        }
        
        guard
            let walletObject = walletStyle,
            let balanceSelectedIndex = balanceStyle?.selectedIndex,
            let nodeId = currentNode?.nodeId,
            let currentAddress = walletObject.currentWallet.key?.address else { return }
        
        var tempPrivateKey: String?
        
        showPasswordInputPswAlert(for: walletObject.currentWallet) { [weak self] (privateKey, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }

            tempPrivateKey = pri
            var usedAmount = BigUInt.zero
            
            for (index, dValue) in self.delegateValue.enumerated() {
                if
                    let stakingBlockNum = dValue.stakingBlockNum,
                    let sBlockNum = UInt64(stakingBlockNum),
                    let canUsedAmount = dValue.getDelegationValueAmount(index: balanceSelectedIndex),
                    let tempPri = tempPrivateKey {
                    var amount = BigUInt.zero
                    
                    if canUsedAmount > self.currentAmount - usedAmount {
                        amount = self.currentAmount - usedAmount
                        usedAmount += amount
                    } else {
                        amount = canUsedAmount
                        usedAmount += amount
                    }
                    
                    if amount <= BigUInt.zero {
                        return
                    }
                    
                    self.withdrawDelegateAction(stakingBlockNum: sBlockNum, nodeId: nodeId, amount: amount, sender: currentAddress, privateKey: tempPri, { [weak self] (transaction) in
                        guard let self = self else { return }
                        transaction.gasUsed = self.estimateUseGas?.description
                        transaction.nodeName = self.currentNode?.name
                        let newTransaction = transaction.copyTransaction()
                        TransferPersistence.add(tx: newTransaction)
                        if index == self.delegateValue.count - 1 {
                            self.doShowTransactionDetail(transaction)
                        }
                    })
                }
            }
        }
    }
    
    func walletCellDidHandle(_ cell: WalletTableViewCell) {
        guard let wStyle = walletStyle else { return }
        
        let indexPath = tableView.indexPath(for: cell)
        var newWalletStyle = wStyle
        newWalletStyle.isExpand = !newWalletStyle.isExpand
        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
        if indexRow != 0 {
            newWalletStyle.selectedIndex = indexRow - 1
        }
        walletStyle = newWalletStyle
        listData[indexSection] = DelegateTableViewCellStyle.wallets(walletStyle: newWalletStyle)
        tableView.reloadSections(IndexSet([indexSection]), with: .fade)
    }
    
    func balanceCellDidHandle(_ cell: WalletBalanceTableViewCell) {
        guard let bStyle = balanceStyle else { return }
        
        let indexPath = tableView.indexPath(for: cell)
        var newBalanceStyle = bStyle
        newBalanceStyle.isExpand = !newBalanceStyle.isExpand
        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
        if indexRow != 0 {
            newBalanceStyle.selectedIndex = indexRow - 1
        }
        balanceStyle = newBalanceStyle
        
        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: newBalanceStyle)
        tableView.reloadSections(IndexSet([indexSection, indexSection+1, indexSection+2]), with: .fade)
    }
    
    func updateHeightOfRow(_ cell: SendInputTableViewCell) {
        let size = cell.amountView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                    height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func estimateGas(_ amountVon: BigUInt, _ cell: SendInputTableViewCell) {
        
        guard
            let balanceSelectedIndex = balanceStyle?.selectedIndex,
            let nodeId = currentNode?.nodeId else { return }
        
        var estimateTotalGas: BigUInt = BigUInt.zero
        
        var usedAmount = BigUInt.zero
        for (index, dValue) in self.delegateValue.enumerated() {
            if
                let stakingBlockNum = dValue.stakingBlockNum,
                let sBlockNum = UInt64(stakingBlockNum),
                let canUsedAmount = dValue.getDelegationValueAmount(index: balanceSelectedIndex) {
                var amount = BigUInt.zero
                
                if canUsedAmount > amountVon - usedAmount {
                    amount = amountVon - usedAmount
                    usedAmount += amount
                } else {
                    amount = canUsedAmount
                    usedAmount += amount
                }
                
                if amount <= BigUInt.zero {
                    return
                }
                
                web3.staking.estimateWithdrawDelegate(stakingBlockNum: sBlockNum, nodeId: nodeId, amount: amount, gasPrice: gasPrice) { [weak self] (result, data) in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        if let estimateGas = data {
                            estimateTotalGas += estimateGas
                        }
                        self.estimateUseGas = estimateTotalGas
                        if index == self.delegateValue.count - 1 {
                            cell.amountView.feeLabel.text = (estimateTotalGas.description.vonToLATString ?? "0.00").displayFeeString
                        }
                    case .fail(_, _):
                        break
                    }
                }
            }
        }
    }
    
    func doShowTransactionDetail(_ transaction: Transaction) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let controller = TransactionDetailViewController()
            controller.transaction = transaction
            controller.backToViewController = self.navigationController?.viewController(self.indexOfViewControllers - 1)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension WithDrawViewController {
    private func getGasPrice() {
        web3.platon.gasPrice { [weak self] (response) in
            switch response.status {
            case .success(let result):
                self?.gasPrice = result.quantity
            case .failure(_):
                break
            }
        }
    }
}
