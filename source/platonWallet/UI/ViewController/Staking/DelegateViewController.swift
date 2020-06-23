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
    var isDelegateAll: Bool = false
    var generateQrCode: QrcodeData<[TransactionQrcode]>?
    var remoteGas: RemoteGas?
    var pollingTimer : Timer?

    var canUseWallets: [Wallet] {
        get {
            let wallets = (AssetVCSharedData.sharedData.walletList as! [Wallet]).sorted(by: <)
            return wallets
        }
    }

    var gasLimit: BigUInt? {
        return remoteGas?.gasLimitBInt
    }

    var gasPrice: BigUInt? {
        return remoteGas?.gasPriceBInt
    }

    var estimateUseGas: BigUInt {
        return remoteGas?.gasUsedBInt ?? BigUInt.zero
    }

    // min delgate amount
    var minDelegateAmountLimit: BigUInt {
        return remoteGas?.minDelegationBInt ?? BigUInt(10).multiplied(by: PlatonConfig.VON.LAT)
    }

    // current account balance amount
    var maxDelegateAmountLimit: BigUInt {
        return balanceStyle?.currentBalanceBInt.convertBalanceDecimalPlaceToZero() ?? BigUInt.zero
    }

    var freeBalanceBInt: BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == walletStyle?.currentWallet.address.lowercased() }),
            let freeBInt = BigUInt(balance.free ?? "0")?.convertBalanceDecimalPlaceToZero() else {
                return BigUInt.zero
        }
        return freeBInt
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

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelFirstResponser)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initListData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.DelegateAction, presentedVC: self)
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    @objc private func cancelFirstResponser() {
        view.endEditing(true)
    }

    func initBalanceStyle() {
        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle!.currentWallet.address.lowercased()
        }
        var balances: [(String, String, Bool)] = []
        balances.append((Localized("staking_balance_can_used"), (BigUInt(balance?.free ?? "0") ?? BigUInt.zero).convertBalanceDecimalPlaceToZero().description, false))
        if let lock = balance?.lock, let convertLock = BigUInt(lock)?.convertBalanceDecimalPlaceToZero(), convertLock > BigUInt.zero {
            balances.append((Localized("staking_balance_locked_position"), convertLock.description, true))
        }

        balanceStyle = BalancesCellStyle(balances: balances, stakingBlockNums: [], selectedIndex: 0, isExpand: false)
        listData[2] = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        tableView.reloadData()
    }

    private func initListData() {
        guard let node = currentNode else { return }

        let item1 = DelegateTableViewCellStyle.nodeInfo(node: node)
        // 每次出现当前页面就会重新生成钱包列表和余额列表，当前选中的地址
        if walletStyle != nil {
            currentAddress = walletStyle?.currentWallet.address
        }

        // 有已选中的钱包则默认选中
        var index: Int? = 0
        if
            let address = currentAddress,
            let wallet = canUseWallets.first(where: { $0.address.lowercased() == address.lowercased() }) {
            index = canUseWallets.firstIndex(of: wallet)
        } else {
            currentAddress = canUseWallets[index ?? 0].address
        }
        walletStyle = WalletsCellStyle(wallets: canUseWallets, selectedIndex: index ?? 0, isExpand: false)

        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle!.currentWallet.address.lowercased()
        }

        var balances: [(String, String, Bool)] = []
        balances.append((Localized("staking_balance_can_used"), (BigUInt(balance?.free ?? "0") ?? BigUInt.zero).convertBalanceDecimalPlaceToZero().description, false))
        if let lock = balance?.lock, let convertLock = BigUInt(lock)?.convertBalanceDecimalPlaceToZero(), convertLock > BigUInt.zero {
            balances.append((Localized("staking_balance_locked_position"), convertLock.description, true))
        }

        balanceStyle = BalancesCellStyle(balances: balances, stakingBlockNums: [], selectedIndex: 0, isExpand: false)

        let item2 = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)
        let item3 = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        let item4 = DelegateTableViewCellStyle.inputAmount
        let item5 = DelegateTableViewCellStyle.singleButton(title: Localized("statking_validator_Delegate"))

        let contents = [
            (Localized("staking_doubt_delegate"), NSMutableAttributedString(string: Localized("staking_doubt_delegate_detail"))),
            (Localized("staking_doubt_reward"), NSMutableAttributedString(string: Localized("staking_doubt_reward_detail")))
        ]
        let item6 = DelegateTableViewCellStyle.doubt(contents: contents)
        listData = [item1, item2, item3, item4, item5, item6]
        tableView.reloadData()

        guard let address = currentAddress, let nodeId = node.nodeId else { return }
        getGas(walletAddr: address, nodeId: nodeId)
    }

    func fetchData() {
        guard let node = currentNode else { return }
        guard let address = currentAddress, let nodeId = node.nodeId else { return }
        getGas(walletAddr: address, nodeId: nodeId)
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
            cell.isTopCell = indexPath.row == 0

            cell.cellDidHandle = { [weak self] (_ cell: WalletTableViewCell) in
                guard let self = self, walletStyle.wallets.count > 1 else { return }
                self.walletCellDidHandle(cell)
            }
            return cell
        case .walletBalances(let balanceStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletBalanceTableViewCell") as! WalletBalanceTableViewCell
            cell.setupBalanceData(balanceStyle.balance(for: indexPath.row))
            cell.bottomlineV.isHidden = true
            cell.isSelectedCell = balanceStyle.balances.count > 1
            cell.rightImageView.image = balanceStyle.balances.count > 1 ? UIImage(named: "3.icon_ drop-down") : nil
            cell.isTopCell = true

            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self, balanceStyle.balances.count > 1 else { return }
                self.balanceCellDidHandle(cell)
            }
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.type = .delegate
            cell.amountView.titleLabel.text = Localized("ATextFieldView_delegate_title")
            cell.amountView.textField.LocalizePlaceholder = Localized("staking_amount_placeholder", arguments: (minDelegateAmountLimit/PlatonConfig.VON.LAT).description)
            cell.maxAmountLimit = maxDelegateAmountLimit
            cell.gas = estimateUseGas
            cell.amountView.feeLabel.text = estimateUseGas.description.vonToLATString?.displayFeeString
            cell.cellDidContentEditingHandler = { [weak self] (amountVON, _) in
//                self?.isDelegateAll = (amountVON == cell.maxAmountLimit)
//                self?.currentAmount = amountVON
//                self?.estimateGas(amountVON, cell)
//                self?.tableView.reloadSections(IndexSet([indexPath.section+1]), with: .none)
            }
            cell.amountView.checkInput(mode: .all, check: { [weak self](text, isDelete) -> (Bool, String) in
                guard let self = self else { return (true, "") }
                var amountVON = BigUInt.mutiply(a: text, by: PlatonConfig.VON.LAT.description) ?? BigUInt.zero
                if amountVON > self.maxDelegateAmountLimit {
                    amountVON = self.maxDelegateAmountLimit
                    cell.amountView.textField.text = amountVON.divide(by: PlatonConfig.VON.LAT.description, round: 8)
                }

                self.isDelegateAll = (amountVON == cell.maxAmountLimit)
                self.currentAmount = amountVON
                self.estimateGas(amountVON, cell)
                self.tableView.reloadSections(IndexSet([indexPath.section+1]), with: .none)

                return CommonService.checkStakingAmoutInput(inputVON: text == "" ? nil : self.currentAmount, balance: self.freeBalanceBInt, minLimit: self.minDelegateAmountLimit, maxLimit: self.maxDelegateAmountLimit, fee: self.estimateUseGas, type: .delegate, isLockAmount: self.balanceStyle?.currentBalance.2)
            }) { [weak self] _ in
                self?.updateHeightOfRow(cell)
            }
            return cell
        case .singleButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonTableViewCell") as! SingleButtonTableViewCell
            cell.button.setTitle(title, for: .normal)
            if balanceStyle?.currentBalance.2 == true {
                cell.disableTapAction = (currentAmount < minDelegateAmountLimit) || currentAmount > maxDelegateAmountLimit || estimateUseGas > remoteGas?.freeBInt ?? BigUInt.zero
            } else {
                cell.disableTapAction = (currentAmount < minDelegateAmountLimit) || currentAmount + estimateUseGas > maxDelegateAmountLimit
            }
            cell.cellDidTapHandle = { [weak self] in
                guard let self = self else { return }
                if cell.button.style != .disable {
                    self.nextButtonCellDidHandle()
                }
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

extension DelegateViewController {
    func nextButtonCellDidHandle() {
        view.endEditing(true)
        submitDelgate()
    }

    func submitDelgate() {
        guard currentAmount >= minDelegateAmountLimit else {
            showMessage(text: Localized("staking_input_amount_minlimit_error", arguments: minDelegateAmountLimit.description))
            return
        }

        guard currentAmount <= maxDelegateAmountLimit else {
            showMessage(text: Localized("staking_input_amount_maxlimit_error"))
            return
        }

        guard
            let walletObject = walletStyle,
            let balanceObject = balanceStyle,
            let nodeId = currentNode?.nodeId,
            let selectedGasPrice = gasPrice,
            let selectedGasLimit = gasLimit else { return }

        let transactions = TransferPersistence.getPendingTransaction(address: walletObject.currentWallet.address)
        if transactions.count >= 0 && (Date().millisecondsSince1970 - (transactions.first?.createTime ?? 0) < 300 * 1000) {
            showErrorMessage(text: Localized("transaction_warning_wait_for_previous"))
            return
        }

        let currentAddress = walletObject.currentWallet.address

        let typ = balanceObject.selectedIndex == 0 ? UInt16(0) : UInt16(1) // 0：自由金额 1：锁仓金额

        guard let nonce = remoteGas?.nonceBInt else { return }
        if walletObject.currentWallet.type == .observed {
            let funcType = FuncType.createDelegate(typ: typ, nodeId: nodeId, amount: self.currentAmount)

            let transactionData = TransactionQrcode(amount: self.currentAmount.description, chainId: web3.properties.chainId, from: walletObject.currentWallet.address, to: WalletUtil.convertBech32(PlatonConfig.ContractAddress.stakingContractAddress), gasLimit: selectedGasLimit.description, gasPrice: selectedGasPrice.description, nonce: nonce.description, typ: typ, nodeId: nodeId, nodeName: self.currentNode?.name, stakingBlockNum: nil, functionType: funcType.typeValue, rk: nil)

            let qrcodeData = QrcodeData(qrCodeType: 0, qrCodeData: [transactionData], chainId: web3.chainId, functionType: 1004, from: walletObject.currentWallet.address, nodeName: self.currentNode?.name, rn: nil, timestamp: Int(Date().timeIntervalSince1970 * 1000), rk: nil, si: nil, v: 1)
            guard
                let data = try? JSONEncoder().encode(qrcodeData),
                let content = String(data: data, encoding: .utf8) else { return }
            self.generateQrCode = qrcodeData

            DispatchQueue.main.async {
                self.showOfflineConfirmView(content: content)
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

            self.sendCreateDelegate(privateKey: pri, typ: typ, nodeId: nodeId, amount: self.currentAmount, sender: currentAddress, nonce: nonce, minDelegate: self.minDelegateAmountLimit, selectedGasLimit: selectedGasLimit, selectedGasPrice: selectedGasPrice)
        }
    }

    func sendCreateDelegate(privateKey: String, typ: UInt16, nodeId: String, amount: BigUInt, sender: String, nonce: BigUInt, minDelegate: BigUInt, selectedGasLimit: BigUInt, selectedGasPrice: BigUInt) {
        showLoadingHUD()
        TransactionService.service.createDelgate(typ: typ, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey, gas: selectedGasLimit, gasPrice: selectedGasPrice, nonce: nonce, minDelegate: minDelegate, completion: { [weak self] (result, data) in
            guard let self = self else { return }
            self.hideLoadingHUD()

            switch result {
            case .success:
                // realm 不能跨线程访问同个实例
                if let transaction = data as? Transaction {
                    transaction.gasUsed = self.estimateUseGas.description
                    transaction.nodeName = self.currentNode?.name
                    transaction.to = WalletUtil.convertBech32(transaction.to ?? "")
                    TransferPersistence.add(tx: transaction)
                    self.doShowTransactionDetail(transaction)
                }
            case .fail(let code, let errMsg):
                guard let c = code, let m = errMsg else { return }
                self.showMessage(text: m, delay: 2.0)
                switch c {
                case 3001,
                     3002,
                     3003,
                     3004,
                     3005,
                     3009:
                    self.getGas(walletAddr: sender, nodeId: nodeId)
                default:
                    break
                }
            }
        })
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
        controller.setUpConfirmView(view: offlineConfirmView)
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
        controller.setUpConfirmView(view: offlineConfirmView)
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
            case .error(let data):
                AssetViewControllerV060.getInstance()?.showMessage(text: data)
                completion?(nil)
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
            let from = qrcode.from,
            let sign = qrcode.si else { return }
        for (_, signature) in signatureArr.enumerated() {
            let bytes = signature.hexToBytes()
            let rlpItem = try? RLPDecoder().decode(bytes)

            if
                let signedTransactionRLP = rlpItem,
                let signedTransaction = try? EthereumSignedTransaction(rlp: signedTransactionRLP) {

                guard
                    let to = signedTransaction.to?.rawAddress.toHexString().add0xBech32() else { return }
                let gasPrice = signedTransaction.gasPrice.quantity
                let gasLimit = signedTransaction.gasLimit.quantity
                let gasUsed = gasPrice.multiplied(by: gasLimit).description
                let amount = self.currentAmount.description
                let tx = Transaction()
                tx.from = from
                tx.to = WalletUtil.convertBech32(to.add0xBech32())
                tx.gasUsed = gasUsed
                tx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                tx.txReceiptStatus = -1
                tx.value = amount
                tx.transactionType = Int(type)
                tx.toType = .contract
                tx.nodeName = self.currentNode?.name
                tx.txType = .delegateCreate
                tx.direction = .Sent
                tx.nodeId = self.currentNode?.nodeId
                tx.txhash = signedTransaction.hash?.add0x()

                self.showLoadingHUD()
                if (qrcode.v ?? 0) >= 1 {
                    let signedTx = SignedTransaction(signedData: signature, remark: qrcode.rk ?? "")
                    guard
                        let signedTxJsonString = signedTx.jsonString
                        else { break }
                    TransactionService.service.sendSignedTransaction(txType: .delegateCreate, minDelgate: minDelegateAmountLimit.description, isObserverWallet: true, data: signedTxJsonString, sign: sign) { (result, response) in
                        switch result {
                        case .success:
                            self.sendTransactionSuccess(tx: tx)
                        case .failure(let error):
                            self.sendTransactionFailure(message: error?.message ?? "server error")
                        }
                    }
                } else {
                    web3.platon.sendRawTransaction(transaction: signedTransaction) { (response) in
                        switch response.status {
                        case .success:
                            self.sendTransactionSuccess(tx: tx)
                        case .failure(let err):
                            switch err {
                            case .reponseTimeout:
                                self.sendTransactionSuccess(tx: tx)
                            case .requestTimeout:
                                self.sendTransactionFailure(message: Localized("RPC_Response_connectionTimeout"))
                            default:
                                self.sendTransactionFailure(message: err.message)
                            }

                        }
                    }
                }
            }
        }
    }

    func sendTransactionSuccess(tx: Transaction) {
        hideLoadingHUD()
        TransferPersistence.add(tx: tx)
        doShowTransactionDetail(tx)
    }

    func sendTransactionFailure(message: String) {
        hideLoadingHUD()
        showErrorMessage(text: message)
    }

    func walletCellDidHandle(_ cell: WalletTableViewCell) {
        guard let wStyle = walletStyle else { return }

        let indexPath = tableView.indexPath(for: cell)
        var newWalletStyle = wStyle
        newWalletStyle.isExpand = !newWalletStyle.isExpand
        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
        if indexRow != 0 {
            newWalletStyle.selectedIndex = indexRow - 1
            if newWalletStyle.selectedIndex != walletStyle?.selectedIndex {
                currentAmount = .zero
            }
        }
        walletStyle = newWalletStyle
        listData[indexSection] = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)

        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle?.currentWallet.address.lowercased()
        }

        var balances: [(String, String, Bool)] = []
        balances.append((Localized("staking_balance_can_used"), balance?.free ?? "0", false))
        if let lock = balance?.lock, (BigUInt(lock) ?? BigUInt.zero) > BigUInt.zero {
            balances.append((Localized("staking_balance_locked_position"), lock, false))
        }
        balanceStyle = BalancesCellStyle(balances: balances, stakingBlockNums: [], selectedIndex: 0, isExpand: false)
        listData[indexSection + 1] = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
        tableView.reloadSections(IndexSet([indexSection, indexSection+1, indexSection+2, indexSection+3]), with: .fade)
        guard indexRow != 0 else { return }

        currentAddress = walletStyle?.currentWallet.address.lowercased()
        fetchData()
    }

    func balanceCellDidHandle(_ cell: WalletBalanceTableViewCell) {
//        guard let bStyle = balanceStyle else { return }
//
//        let indexPath = tableView.indexPath(for: cell)
//        var newBalanceStyle = bStyle
//        newBalanceStyle.isExpand = !newBalanceStyle.isExpand
//        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
//        if indexRow != 0 {
//            newBalanceStyle.selectedIndex = indexRow - 1
//        }
//        balanceStyle = newBalanceStyle
//
//        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle!)
//        tableView.reloadSections(IndexSet([indexSection, indexSection+1]), with: .fade)
//
//        if currentAmount != .zero {
//            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: indexSection+1)) as? SendInputTableViewCell
//            cell?.amountView.checkInvalidNow(showErrorMsg: true)
//        }

        view.endEditing(true)
        guard
            let balances = balanceStyle?.balances,
            let selected = balanceStyle?.selectedIndex,
            let indexPath = tableView.indexPath(for: cell)
            else { return }

        let type = PopSelectedViewType.delegate(datasource: balances, selected: selected)
        let contentView = ThresholdValueSelectView(title: Localized("pop_selection_title_delegate"), type: type)
//        contentView.show(viewController: self)
        contentView.valueChangedHandler = { [weak self] value in
            switch value {
            case .delegate(_, let newSelected):
                guard selected != newSelected else {
                    return
                }
                self?.balanceStyle?.selectedIndex = newSelected
                self?.refreshBalanceAndInputAmountCell(indexPath)
            default:
                break
            }
        }
        let popUpVC = PopUpViewController()
        popUpVC.setUpContentView(view: contentView, size: CGSize(width: PopUpContentWidth, height: CGFloat(type.count) * contentView.cellHeight + 64.0))
        popUpVC.setCloseEvent(button: contentView.closeButton)
        popUpVC.show(inViewController: self)
    }

    func refreshBalanceAndInputAmountCell(_ indexPath: IndexPath) {
        let indexSection = indexPath.section
        guard let bStyle = balanceStyle else { return }
        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: bStyle)
        tableView.reloadSections(IndexSet([indexSection, indexSection+1, indexSection+2]), with: .fade)

        if currentAmount != .zero {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: indexSection+1)) as? SendInputTableViewCell
            cell?.amountView.checkInvalidNow(showErrorMsg: true)
        }
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
        if isDelegateAll == true, balanceStyle?.currentBalance.2 == false {
            if currentAmount > estimateUseGas {
                // 非锁仓余额才可以相减
                currentAmount -= estimateUseGas
                cell.amountView.textField.text = currentAmount.divide(by: ETHToWeiMultiplier, round: 8)
                cell.amountView.checkInvalidNow(showErrorMsg: true)
            }
            isDelegateAll = false
        }

//        cell.amountView.feeLabel.text = (estimateUseGas.description.vonToLATString ?? "0.00").displayFeeString
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

extension DelegateViewController {
    private func getGas(walletAddr: String, nodeId: String, completion: ((Bool) -> Void)? = nil) {
        showLoadingHUD()
        TransactionService.service.getContractGas(from: walletAddr, txType: TxType.delegateCreate, nodeId: nodeId) { [weak self] (result, remoteGas) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let gas = remoteGas else {
                    self?.showErrorMessage(text: "get gas api error", delay: 2.0)
                    return
                }
                self?.remoteGas = gas
                self?.tableView.reloadData()
                completion?(true)
            case .failure(let error):
                self?.showErrorMessage(text: error?.message ?? "get gas api error")
                completion?(false)
            }
        }
    }
}

extension DelegateViewController {
    func startTimer() {
        pollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.viewControllerUpdateInterval), target: self, selector: #selector(viewControllerPolling), userInfo: nil, repeats: true)
        pollingTimer?.fire()
    }

    @objc func viewControllerPolling() {
        guard
            let walletObject = walletStyle,
            let nodeId = currentNode?.nodeId else { return }

        let transactions = TransferPersistence.getDelegateCreatePendingTransaction(address: walletObject.currentWallet.address, nodeId: nodeId)
        guard transactions.count > 0 else {
            stopTimer()
            return
        }

        fetchData()
    }

    func stopTimer() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}
