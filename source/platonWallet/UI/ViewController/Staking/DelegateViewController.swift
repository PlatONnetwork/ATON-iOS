//
//  DelegateViewController.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt
import platonWeb3

class DelegateViewController: BaseViewController {
    
    var currentNode: Node?
    var listData: [DelegateTableViewCellStyle] = []
    var currentAddress: String?
    var walletStyle: WalletsCellStyle?
    var balanceStyle: BalancesCellStyle?
    var currentAmount: BigUInt = BigUInt.zero
    var canDelegation: CanDelegation?
    var gasPrice: BigUInt?
    var estimateUseGas: BigUInt?
    var isDelegateAll: Bool = false
    
    var canUseWallets: [Wallet] {
        get {
            let canUseWallets = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { (wallet) -> Bool in
                let walletBalance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == wallet.key?.address.lowercased() })
                if let balance = walletBalance {
                    let free = BigUInt(balance.free ?? "0")
                    let lock = BigUInt(balance.lock ?? "0")
                    return free! + lock! > BigUInt.zero
                }
                return false
            }
            return canUseWallets
        }
    }
    
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
        super.leftNavigationTitle = "delegate_delegate_title"
        // Do any additional setup after loading the view.
        fetchWalletsBalance()
        getGasPrice()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelFirstResponser)))
    }
    
    @objc private func cancelFirstResponser() {
        view.endEditing(true)
    }
    
    private func fetchCanDelegation() {
        guard
            let nodeId = currentNode?.nodeId,
            let walletAddr = walletStyle?.currentWallet.key?.address else { return }
        
        showLoadingHUD()
        StakingService.sharedInstance.getCanDelegation(addr: walletAddr, nodeId: nodeId) { [weak self] (result, data) in
                self?.hideLoadingHUD()
                
                switch result {
                case .success:
                    if let newData = data as? CanDelegation {
                        self?.canDelegation = newData
                        self?.tableView.reloadData()
                    }
                case .fail(_, _):
                    break
                }
        }
    }
    
    private func fetchWalletsBalance() {
        
        showLoadingHUD()
        
        AssetService.sharedInstace.fetchWalletBalanceForV7 { [weak self] (result, data) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                self?.initListData()
            case .fail(_, _):
                break
            }
        }
    }
    

    private func initListData() {
        guard let node = currentNode else { return }
        
        let item1 = DelegateTableViewCellStyle.nodeInfo(node: node)
        
        // 有已选中的钱包则默认选中
        var index: Int? = 0
        if
            let address = currentAddress,
            let wallet = canUseWallets.first(where: { $0.key?.address.lowercased() == address.lowercased() }) {
            index = canUseWallets.firstIndex(of: wallet)
        } else {
            index = canUseWallets.firstIndex(where: { $0.key?.address.lowercased() == (AssetVCSharedData.sharedData.selectedWallet as! Wallet).key?.address.lowercased() }) ?? 0
            currentAddress = canUseWallets[index ?? 0].key?.address
        }
        walletStyle = WalletsCellStyle(wallets: canUseWallets, selectedIndex: index ?? 0, isExpand: false)
        
        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle!.currentWallet.key?.address.lowercased()
        }
        
        var balances: [(String, String)] = []
        balances.append((Localized("staking_balance_can_used"), balance?.free ?? "0"))
        if let lock = balance?.lock, (BigUInt(lock) ?? BigUInt.zero) > BigUInt.zero {
            balances.append((Localized("staking_balance_locked_position"), lock))
        }
        
        balanceStyle = BalancesCellStyle(balances: balances, selectedIndex: 0, isExpand: false)
        
        let item2 = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)
        let item3 = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        let item4 = DelegateTableViewCellStyle.inputAmount
        let item5 = DelegateTableViewCellStyle.singleButton(title: Localized("statking_validator_Delegate"))
        
        let contents = [
            (Localized("staking_doubt_delegate"), Localized("staking_doubt_delegate_detail")),
            (Localized("staking_doubt_reward"), Localized("staking_doubt_reward_detail")),
            (Localized("staking_doubt_risk"), Localized("staking_doubt_risk_detail"))
        ]
        let item6 = DelegateTableViewCellStyle.doubt(contents: contents)
        listData.append(contentsOf: [item1, item2, item3, item4, item5, item6])
        tableView.reloadData()
        
        fetchCanDelegation()
    }

}

extension DelegateViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.rightImageView.image = (balanceStyle.balances.count <= 1) ? nil :
                indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") : indexPath.row == balanceStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            
            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self, balanceStyle.balances.count > 1 else { return }
                self.balanceCellDidHandle(cell)
            }
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.amountView.titleLabel.text = Localized("ATextFieldView_delegate_title")
            cell.minAmountLimit = "10".LATToVon
            cell.maxAmountLimit = BigUInt(balanceStyle?.currentBalance.1 ?? "0")
            cell.cellDidContentChangeHandler = { [weak self] in
                self?.updateHeightOfRow(cell)
            }
            cell.cellDidContentEditingHandler = { [weak self] (amountVON, _) in
                self?.isDelegateAll = (amountVON == cell.maxAmountLimit)
                self?.estimateGas(amountVON, cell)
                self?.currentAmount = amountVON
                self?.tableView.reloadSections(IndexSet([indexPath.section + 1]), with: .none)
            }
            return cell
        case .singleButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonTableViewCell") as! SingleButtonTableViewCell
            cell.button.setTitle(title, for: .normal)
            cell.unavaliableTapAction = (currentAmount <= BigUInt.zero || canDelegation == nil || canDelegation?.canDelegation == false)
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

extension DelegateViewController {
    func nextButtonCellDidHandle() {
        
        view.endEditing(true)
        
        if let canDet = canDelegation, canDet.canDelegation == false {
            showMessage(text: canDet.message?.localizedDesciption ?? "can't delegate", delay: 2.0)
            return
        }
        
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
        
        if currentAmount == (BigUInt(balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero) {
            currentAmount = currentAmount - (estimateUseGas ?? BigUInt.zero)
        }
        
        guard
            let walletObject = walletStyle,
            let balanceObject = balanceStyle,
            let nodeId = currentNode?.nodeId,
            let currentAddress = walletObject.currentWallet.key?.address else { return }

        let typ = balanceObject.selectedIndex == 0 ? UInt16(0) : UInt16(1) // 0：自由金额 1：锁仓金额

        showPasswordInputPswAlert(for: walletObject.currentWallet) { [weak self] (privateKey, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }
            self.showLoadingHUD()
            
            StakingService.sharedInstance.createDelgate(typ: typ, nodeId: nodeId, amount: self.currentAmount, sender: currentAddress, privateKey: pri, { [weak self] (result, data) in
                guard let self = self else { return }
                self.hideLoadingHUD()
                
                switch result {
                case .success:
                    // realm 不能跨线程访问同个实例
                    if let transaction = data as? Transaction {
                        transaction.gasUsed = self.estimateUseGas?.description
                        transaction.nodeName = self.currentNode?.name
                        let newTransaction = transaction.copyTransaction()
                        
                        TransferPersistence.add(tx: newTransaction)
                        self.doShowTransactionDetail(transaction)
                    }
                case .fail(_, let errMsg):
                    self.showMessage(text: errMsg ?? "call web3 error", delay: 2.0)
                }
            })
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
        listData[indexSection] = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)
        
        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle?.currentWallet.key?.address.lowercased()
        }
        
        var balances: [(String, String)] = []
        balances.append((Localized("staking_balance_can_used"), balance?.free ?? "0"))
        if let lock = balance?.lock, (BigUInt(lock) ?? BigUInt.zero) > BigUInt.zero {
            balances.append((Localized("staking_balance_locked_position"), lock))
        }
        balanceStyle = BalancesCellStyle(balances: balances, selectedIndex: 0, isExpand: false)
        
        listData[indexSection + 1] = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        
        tableView.reloadSections(IndexSet([indexSection, indexSection+1, indexSection+2]), with: .fade)
        
        guard indexRow != 0 else { return }
        fetchCanDelegation()
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
        
        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        tableView.reloadSections(IndexSet([indexSection, indexSection+1]), with: .fade)
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
            let balanceObject = balanceStyle,
            let nodeId = currentNode?.nodeId else { return }
        
        let typ = balanceObject.selectedIndex == 0 ? UInt16(0) : UInt16(1) // 0：自由金额 1：锁仓金额
        
        web3.staking.estimateCreateDelegate(typ: typ, nodeId: nodeId, amount: amountVon, gasPrice: gasPrice) { [weak self] (result, data) in
            switch result {
            case .success:
                self?.estimateUseGas = data
                if let delegateAll = self?.isDelegateAll, delegateAll == true {
                    if
                        let amount = self?.currentAmount,
                        let useGas = data,
                        amount > useGas {
                        cell.amountView.textField.text = (amount - useGas).divide(by: ETHToWeiMultiplier, round: 8)
                    }
                    
                    self?.isDelegateAll = false
                }
                
                if let feeString = data?.description {
                    cell.amountView.feeLabel.text = (feeString.vonToLATString ?? "0.00").displayFeeString
                }
            case .fail(_, _):
                break
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

extension DelegateViewController {
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
