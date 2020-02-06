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
    var delegation: Delegation?

    var listData: [DelegateTableViewCellStyle] = []
    var remoteGas: RemoteGas?
    var generateQrCode: QrcodeData<[TransactionQrcode]>?
    var pollingTimer : Timer?

    var gasLimit: BigUInt? {
        return remoteGas?.gasLimitBInt
    }

    var gasPrice: BigUInt? {
        return remoteGas?.gasPriceBInt
    }

    var estimateUseGas: BigUInt {
        return remoteGas?.gasUsedBInt ?? BigUInt.zero
    }

    var minDelegateAmountLimit: BigUInt {
        return delegation?.minDelegationBInt ?? BigUInt(10).multiplied(by: PlatonConfig.VON.LAT)
    }

    var amountBalance: BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == walletStyle?.currentWallet.address.lowercased() }),
            let freeBalance = BigUInt(balance.free ?? "0")?.convertBalanceDecimalPlaceToZero() else { return BigUInt.zero }
        return freeBalance
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
        super.leftNavigationTitle = "delegate_withdraw_title"
        // Do any additional setup after loading the view.

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelFirstResponser)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDelegateValue()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.RedeemAction, presentedVC: self)
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
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
                if let newData = data as? Delegation {
                    self?.delegation = newData
                    self?.initBalanceStyle()
                }

            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg ?? "error")
            }
        }
    }

    private func initBalanceStyle() {
        guard let dele = delegation, dele.deleList.count > 0 else {
            navigationController?.popViewController(animated: true)
            showMessage(text: Localized("delegate_no_withdraw_message"), delay: 2.0)
            return
        }

        var balances: [(String, String)] = []
        var stakingBlockNums: [UInt64] = []
        var selectedIndex: Int = 0
        var releasedIndex: Int = 1
        for (index, deleItem) in dele.deleList.enumerated() {
            if let delegated = deleItem.delegated, let delegatedBInt = BigUInt(delegated), delegatedBInt > BigUInt.zero {
                balances.append((Localized("staking_balance_Delegated"), delegatedBInt.description))
                stakingBlockNums.append(UInt64(deleItem.stakingBlockNum ?? "0") ?? 0)
            } else if let released = deleItem.released, let releasedBInt = BigUInt(released), releasedBInt > BigUInt.zero {
                balances.append((Localized("staking_balance_release_Delegated") + "(" + Localized("staking_balance_release_Delegated_index", arguments: releasedIndex) + ")" , releasedBInt.description))
                stakingBlockNums.append(UInt64(deleItem.stakingBlockNum ?? "0") ?? 0)
                if selectedIndex == 0 {
                    selectedIndex = index
                }
                releasedIndex += 1
            }
        }

        let bStyle = BalancesCellStyle(balances: balances, stakingBlockNums: stakingBlockNums, selectedIndex: selectedIndex, isExpand: false)
        balanceStyle = bStyle

        initListData()
    }

    private func initListData() {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).first { $0.address.lowercased() == currentAddress?.lowercased() }
        guard
            let node = currentNode,
            let bStyle = balanceStyle,
            let wallet = localWallet else { return }

        if let nodeId = node.nodeId {
            getGas(walletAddr: wallet.address, nodeId: nodeId, stakingBlockNum: String(bStyle.currentBlockNum))
        }

        let item1 = DelegateTableViewCellStyle.nodeInfo(node: node)
        walletStyle = WalletsCellStyle(wallets: [wallet], selectedIndex: 0, isExpand: false)
        let item2 = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)
        let item3 = DelegateTableViewCellStyle.walletBalances(balanceStyle: bStyle)
        let item4 = DelegateTableViewCellStyle.inputAmount
        let item5 = DelegateTableViewCellStyle.singleButton(title: Localized("statking_validator_Withdraw"))

        let noteAttribute = NSAttributedString(string: "\n" + Localized("staking_doubt_undelegate_note"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        let mutableAttribute = NSMutableAttributedString(string: Localized("staking_doubt_undelegate_detail", arguments: (minDelegateAmountLimit/PlatonConfig.VON.LAT).description))
        mutableAttribute.append(noteAttribute)

        let contents = [
            (Localized("staking_doubt_undelegate"), mutableAttribute)
        ]
        let item6 = DelegateTableViewCellStyle.doubt(contents: contents)
        listData = [item1, item2, item3, item4, item5, item6]

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
            cell.setupCellData(for: walletStyle.getWallet(for: indexPath.row), isWithdraw: true)
            cell.walletBackgroundView.isHidden = indexPath.row != 0
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == walletStyle.cellCount - 1)
            cell.rightImageView.image =
                (walletStyle.wallets.count <= 1) ? nil :
                indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") :
                indexPath.row == walletStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            cell.isTopCell = indexPath.row == 0

            cell.cellDidHandle = { [weak self] (_ cell: WalletTableViewCell) in
                guard let self = self, walletStyle.wallets.count > 1 else { return }
                self.walletCellDidHandle(cell)
            }
            return cell
        case .walletBalances(let balanceStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletBalanceTableViewCell") as! WalletBalanceTableViewCell
            cell.shadowView.isHidden = indexPath.row != 0
            cell.setupBalanceData(balanceStyle.balance(for: indexPath.row))
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == balanceStyle.cellCount - 1)
            cell.isSelectedCell = indexPath.row == 0 ? true : indexPath.row == balanceStyle.selectedIndex + 1 ? true : false
            cell.rightImageView.image = indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") : indexPath.row == balanceStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            cell.isTopCell = indexPath.row == 0

            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self else { return }
                self.balanceCellDidHandle(cell)
            }
            cell.isUserInteractionEnabled = indexPath.row == 0 ? true : (BigUInt(balanceStyle.balance(for: indexPath.row).1) ?? BigUInt.zero > BigUInt.zero)
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.type = .withdraw
            cell.amountView.titleLabel.text = Localized("ATextFieldView_withdraw_title")
            cell.amountView.textField.LocalizePlaceholder = Localized("staking_amount_placeholder", arguments: (minDelegateAmountLimit/PlatonConfig.VON.LAT).description)
            cell.maxAmountLimit = BigUInt(balanceStyle?.currentBalance.1 ?? "0")
            cell.amountView.feeLabel.text = (estimateUseGas.description.vonToLATString ?? "0.00").displayFeeString

            cell.amountView.checkInput(mode: .all, check: { [weak self] (text, isDelete) -> (Bool, String) in
                guard let self = self else { return (true, "") }
                var amountVON = BigUInt.mutiply(a: text, by: PlatonConfig.VON.LAT.description) ?? BigUInt.zero
                let maxDelegateAmountLimit = BigUInt(self.balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero

                if !isDelete && amountVON > self.minDelegateAmountLimit && maxDelegateAmountLimit < self.minDelegateAmountLimit + amountVON {
                    amountVON = maxDelegateAmountLimit
                    cell.amountView.textField.text = amountVON.divide(by: PlatonConfig.VON.LAT.description, round: 8)
                }
                self.currentAmount = amountVON
                self.tableView.reloadSections(IndexSet([indexPath.section + 1]), with: .none)

                let regularText = amountVON > BigUInt.zero ? amountVON.divide(by: PlatonConfig.VON.LAT.description, round: 8) : ""

                return CommonService.checkStakingAmoutInput(text: regularText, balance: self.amountBalance, minLimit: self.minDelegateAmountLimit, maxLimit: BigUInt(self.balanceStyle?.currentBalance.1 ?? "0"), fee: self.estimateUseGas, type: .withdraw, isLockAmount: false)
            }) { [weak self] _ in
                self?.updateHeightOfRow(cell)
            }

            cell.cellDidContentEditingHandler = { [weak self] (amountVON, isRegular) in
//                var inputAmountVON = amountVON
//
//                let minAMountLimit = self?.minDelegateAmountLimit ?? BigUInt(10).multiplied(by: PlatonConfig.VON.LAT)
//
//                if let cAmount = BigUInt(self?.balanceStyle?.currentBalance.1 ?? "0"), cAmount >= minAMountLimit, inputAmountVON >= minAMountLimit, cAmount > inputAmountVON, isRegular == true {
//                    if cAmount - inputAmountVON < minAMountLimit {
//                        inputAmountVON = cAmount
//                        DispatchQueue.main.async {
//                            cell.amountView.textField.text = inputAmountVON.divide(by: ETHToWeiMultiplier, round: 8)
//                        }
//                    }
//                }
//                self?.estimateGas(inputAmountVON, cell)
//                self?.currentAmount = inputAmountVON
//                self?.tableView.reloadSections(IndexSet([indexPath.section + 1]), with: .none)
            }
            if let bStyle = balanceStyle, bStyle.selectedIndex > 0 {
                cell.amountView.textField.isEnabled = false
                self.currentAmount = BigUInt(bStyle.currentBalance.1) ?? BigUInt.zero
                cell.amountView.textField.text = BigUInt(bStyle.currentBalance.1)?.divide(by: ETHToWeiMultiplier, round: 8)
            } else {
                cell.amountView.textField.isEnabled = true
                cell.amountView.textField.text = self.currentAmount > BigUInt.zero ?  self.currentAmount.divide(by: ETHToWeiMultiplier, round: 8) : ""
            }
            return cell
        case .singleButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonTableViewCell") as! SingleButtonTableViewCell
            cell.disableTapAction = (currentAmount <= BigUInt.zero)
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
            cell.contentLabel.attributedText = content.1
            return cell
        default:
            return UITableViewCell()
        }
    }

}

extension WithDrawViewController {

    func nextButtonCellDidHandle() {
        view.endEditing(true)

        guard currentAmount > BigUInt.zero else {
            showMessage(text: Localized("staking_withdraw_input_amount_minlimit_error", arguments: (minDelegateAmountLimit/PlatonConfig.VON.LAT).description))
            return
        }

        guard currentAmount >= minDelegateAmountLimit else {
            showMessage(text: Localized("staking_withdraw_input_amount_minlimit_error", arguments: (minDelegateAmountLimit/PlatonConfig.VON.LAT).description))
            return
        }

        guard currentAmount <= (BigUInt(balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero) else {
            showMessage(text: Localized("staking_withdraw_input_amount_maxlimit_error"))
            return
        }

        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == walletStyle?.currentWallet.address.lowercased() }),
            let freeBalance = BigUInt(balance.free ?? "0"),
            let selectedGasPrice = gasPrice,
            let selectedGasLimit = gasLimit,
            freeBalance >= estimateUseGas else {
                showMessage(text: Localized("staking_withdraw_balance_Insufficient_error"))
                return
        }

        guard
            let walletObject = walletStyle,
            let balanceSelectedIndex = balanceStyle?.selectedIndex,
            let nodeId = currentNode?.nodeId,
            let stakingBlockNum = balanceStyle?.currentBlockNum else { return }
        let currentAddress = walletObject.currentWallet.address

        let transactions = TransferPersistence.getDelegateWithdrawPendingTransaction(address: walletObject.currentWallet.address, nodeId: nodeId)
        guard transactions.count == 0 else {
            showErrorMessage(text: Localized("transaction_warning_wait_for_previous"))
            return
        }

        if walletObject.currentWallet.type == .observed {
            let funcType = FuncType.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: self.currentAmount)
            web3.platon.platonGetNonce(sender: walletObject.currentWallet.address) { [weak self] (result, blockNonce) in
                guard let self = self else { return }
                switch result {
                case .success:
                    guard let nonce = blockNonce else { return }
                    let nonceString = nonce.quantity.description

                    let transactionData = TransactionQrcode(amount: self.currentAmount.description, chainId: web3.properties.chainId, from: walletObject.currentWallet.address, to: PlatonConfig.ContractAddress.stakingContractAddress, gasLimit: selectedGasLimit.description, gasPrice: selectedGasPrice.description, nonce: nonceString, typ: nil, nodeId: nodeId, nodeName: self.currentNode?.name, stakingBlockNum: String(stakingBlockNum), functionType: funcType.typeValue)

                    let qrcodeData = QrcodeData(qrCodeType: 0, qrCodeData: [transactionData], chainId: web3.chainId, functionType: 1005, from: walletObject.currentWallet.address, nodeName: self.currentNode?.name, rn: nil, timestamp: Int(Date().timeIntervalSince1970 * 1000))
                    guard
                        let data = try? JSONEncoder().encode(qrcodeData),
                        let content = String(data: data, encoding: .utf8) else { return }
                    self.generateQrCode = qrcodeData
                    DispatchQueue.main.async {
                        self.showOfflineConfirmView(content: content)
                    }
                case .fail:
                    break
                }
            }
            return
        }
        
        showPasswordInputPswAlert(for: walletObject.currentWallet) { [weak self] (privateKey, _, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }

            self.showLoadingHUD()
            StakingService.sharedInstance.withdrawDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: self.currentAmount, sender: currentAddress, privateKey: pri, gas: selectedGasLimit, gasPrice: selectedGasPrice) { [weak self] (result, data) in
                self?.hideLoadingHUD()
                switch result {
                case .success:
                    if let transaction = data as? Transaction {
                        transaction.gasUsed = self?.estimateUseGas.description
                        transaction.nodeName = self?.currentNode?.name
                        TransferPersistence.add(tx: transaction)
                        self?.doShowTransactionDetail(transaction)
                    }
                case .fail(_, let errMsg):
                    if let message = errMsg, message == "insufficient funds for gas * price + value" {
                        self?.showMessage(text: Localized(message), delay: 2.0)
                    } else {
                        self?.showMessage(text: errMsg ?? "call web3 error", delay: 2.0)
                    }
                }
            }
        }
    }

    func showOfflineConfirmView(content: String) {
        let qrcodeView = OfflineSignatureQRCodeView()
        let qrcodeWidth = PopUpContentWidth - 32
        let qrcodeImage = UIImage.geneQRCodeImageFor(content, size: qrcodeWidth, isGzip: true)
        qrcodeView.imageView.image = qrcodeImage

        let type = ConfirmViewType.qrcodeGenerate(contentView: qrcodeView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_generate_qrcode_for_transaction"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_generate_qrcode_for_transaction_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_next"

        let controller = PopUpViewController()
        controller.onCompletion = { [weak self] in
            self?.showQrcodeScan()
        }
        controller.setUpConfirmView(view: offlineConfirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
    }

    func showQrcodeScan() {
        var qrcodeData: QrcodeData<[String]>?
        let scanView = OfflineSignatureScanView()
        scanView.scanCompletion = { [weak self] in
            self?.doShowScanController(completion: { (data) in
                guard
                    let qrcode = data,
                    let signedDatas = qrcode.qrCodeData, qrcode.chainId == web3.chainId else { return }
                DispatchQueue.main.async {
                    scanView.textView.text = signedDatas.joined(separator: ";")
                }
                qrcodeData = qrcode
            })
        }
        let type = ConfirmViewType.qrcodeScan(contentView: scanView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_scan_qrcode_for_read"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_scan_qrcode_for_read_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_send"

        let controller = PopUpViewController()
        controller.onCompletion = {
            guard let qrcode = qrcodeData else { return }
            self.sendSignatureTransaction(qrcode: qrcode)
        }
        controller.setUpConfirmView(view: offlineConfirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
    }

    func doShowScanController(completion: ((QrcodeData<[String]>?) -> Void)?) {
        let controller = QRScannerViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.scanCompletion = { result in
            let qrcodeType = QRCodeDecoder().decode(result)
            switch qrcodeType {
            case .signedTransaction(let data):
                completion?(data)
            default:
                AssetViewControllerV060.getInstance()?.showMessage(text: Localized("QRScan_failed_tips"))
                completion?(nil)
            }
        }

        (UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController)?.pushViewController(controller, animated: true)
    }

    func sendSignatureTransaction(qrcode: QrcodeData<[String]>) {

        guard
            let signatureArr = qrcode.qrCodeData,
            let type = qrcode.functionType,
            let from = qrcode.from else { return }
        for (index, signature) in signatureArr.enumerated() {
            let bytes = signature.hexToBytes()
            let rlpItem = try? RLPDecoder().decode(bytes)

            if
                let signedTransactionRLP = rlpItem,
                let signedTransaction = try? EthereumSignedTransaction(rlp: signedTransactionRLP) {
                web3.platon.sendRawTransaction(transaction: signedTransaction) { (response) in
                    switch response.status {
                    case .success(let result):
                        guard
                            let to = signedTransaction.to?.rawAddress.toHexString().add0x() else { return }
                        let gasPrice = signedTransaction.gasPrice.quantity
                        let gasLimit = signedTransaction.gasLimit.quantity
                        let gasUsed = gasPrice.multiplied(by: gasLimit).description
                        let amount = self.currentAmount.description
                        let tx = Transaction()
                        tx.from = from
                        tx.to = to
                        tx.gasUsed = gasUsed
                        tx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                        tx.txhash = result.bytes.toHexString().add0x()
                        tx.txReceiptStatus = -1
                        tx.value = amount
                        tx.transactionType = Int(type)
                        tx.toType = .contract
                        tx.nodeName = self.currentNode?.name
                        tx.txType = .delegateWithdraw
                        tx.direction = .Receive
                        tx.nodeId = self.currentNode?.nodeId
                        TransferPersistence.add(tx: tx)

                        if index == signatureArr.count - 1 {
                            self.doShowTransactionDetail(tx)
                        }
                    case .failure:
                        break
                    }
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
//        currentAmount = BigUInt.zero

        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: newBalanceStyle)
        tableView.reloadSections(IndexSet([indexSection, indexSection+1, indexSection+2]), with: .fade)

        if currentAmount != .zero {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: indexSection+1)) as? SendInputTableViewCell
            cell?.amountView.checkInvalidNow(showErrorMsg: true)
        }

        guard
            let nodeId = currentNode?.nodeId,
            let address = walletStyle?.currentWallet.address,
            indexRow != 0
        else { return }

        getGas(walletAddr: address, nodeId: nodeId, stakingBlockNum: String(bStyle.currentBlockNum))
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

    func doShowTransactionDetail(_ transaction: Transaction) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let controller = TransactionDetailViewController()
            controller.txSendAddress = transaction.from
            controller.transaction = transaction
            controller.backToViewController = self.navigationController?.viewController(self.indexOfViewControllers - 1)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension WithDrawViewController {
    private func getGas(walletAddr: String, nodeId: String, stakingBlockNum: String) {
        TransactionService.service.getContractGas(from: walletAddr, txType: TxType.delegateWithdraw, nodeId: nodeId, stakingBlockNum: stakingBlockNum) { [weak self] (result, remoteGas) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let gas = remoteGas else {
                    self?.showErrorMessage(text: "get gas api error", delay: 2.0)
                    return
                }
                self?.remoteGas = gas
                self?.tableView.reloadData()
            case .fail(_, let errMsg):
                self?.showErrorMessage(text: errMsg ?? "get gas api error", delay: 2.0)
            }
        }
    }
}

extension WithDrawViewController {
    func startTimer() {
        pollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.viewControllerUpdateInterval), target: self, selector: #selector(viewControllerPolling), userInfo: nil, repeats: true)
        pollingTimer?.fire()
    }

    @objc func viewControllerPolling() {
        guard
            let walletObject = walletStyle,
            let nodeId = currentNode?.nodeId else { return }

        let transactions = TransferPersistence.getDelegateWithdrawPendingTransaction(address: walletObject.currentWallet.address, nodeId: nodeId)
        guard transactions.count > 0 else {
            stopTimer()
            return
        }

        fetchDelegateValue()
    }

    func stopTimer() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}
