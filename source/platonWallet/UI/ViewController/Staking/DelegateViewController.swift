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
    var generateQrCode: QrcodeData<[TransactionQrcode]>?

    var canUseWallets: [Wallet] {
        get {
            let wallets = (AssetVCSharedData.sharedData.walletList as! [Wallet]).sorted(by: <)
            return wallets
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

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelFirstResponser)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initListData()
        getGasPrice()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.DelegateAction, presentedVC: self)
    }

    @objc private func cancelFirstResponser() {
        view.endEditing(true)
    }

    private func fetchCanDelegation(completion: (() -> Void)? = nil) {
        guard
            let nodeId = currentNode?.nodeId,
            let walletAddr = walletStyle?.currentWallet.address else { return }

        showLoadingHUD()
        StakingService.sharedInstance.getCanDelegation(addr: walletAddr, nodeId: nodeId) { [weak self] (result, data) in
                self?.hideLoadingHUD()

                switch result {
                case .success:
                    if let newData = data as? CanDelegation {
                        var walletBalance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == walletAddr.lowercased() })
                        walletBalance?.free = newData.free
                        walletBalance?.lock = newData.lock

                        self?.canDelegation = newData
                        self?.tableView.reloadData()
                    }
                    completion?()
                case .fail:
                    completion?()
                }
        }
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
            index = canUseWallets.firstIndex(where: { $0.address.lowercased() == (AssetVCSharedData.sharedData.selectedWallet as! Wallet).address.lowercased() }) ?? 0
            currentAddress = canUseWallets[index ?? 0].address
        }
        walletStyle = WalletsCellStyle(wallets: canUseWallets, selectedIndex: index ?? 0, isExpand: false)

        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle!.currentWallet.address.lowercased()
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
        listData = [item1, item2, item3, item4, item5, item6]
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
            cell.isTopCell = indexPath.row == 0

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
            cell.isTopCell = indexPath.row == 0

            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self, balanceStyle.balances.count > 1 else { return }
                self.balanceCellDidHandle(cell)
            }
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.inputType = .delegate
            cell.amountView.titleLabel.text = Localized("ATextFieldView_delegate_title")
            cell.minAmountLimit = SettingService.shareInstance.remoteConfig?.minDelegationBInt ?? "10".LATToVon
            cell.maxAmountLimit = BigUInt(balanceStyle?.currentBalance.1 ?? "0")
            cell.amountView.isUserInteractionEnabled = (canDelegation?.canDelegation == true)
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
            cell.canDelegation = canDelegation
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

        fetchCanDelegation { [weak self] in
            guard let self = self else { return }
            self.submitDelgate()
        }
    }

    func submitDelgate() {
        if let canDet = canDelegation, canDet.canDelegation == false {
            showMessage(text: canDet.message?.localizedDesciption ?? "can't delegate", delay: 2.0)
            return
        }

        guard currentAmount > BigUInt.zero else {
            showMessage(text: Localized("staking_delegate_input_amount_minlimit_error"))
            return
        }

        guard currentAmount >= SettingService.shareInstance.remoteConfig?.minDelegationBInt ?? "10".LATToVon else {
            showMessage(text: Localized("staking_input_amount_minlimit_error", arguments: SettingService.shareInstance.remoteConfig?.minDelegation?.vonToLAT.description ?? "10"))
            return
        }

        guard currentAmount <= (BigUInt(balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero) else {
            showMessage(text: Localized("staking_input_amount_maxlimit_error"))
            return
        }

        if currentAmount == (BigUInt(balanceStyle?.currentBalance.1 ?? "0") ?? BigUInt.zero), balanceStyle?.isLock == false {
            currentAmount -= (estimateUseGas ?? BigUInt.zero)
        }

        guard
            let walletObject = walletStyle,
            let balanceObject = balanceStyle,
            let nodeId = currentNode?.nodeId,
            let gasPrice = gasPrice?.description else { return }
        let currentAddress = walletObject.currentWallet.address

        let typ = balanceObject.selectedIndex == 0 ? UInt16(0) : UInt16(1) // 0：自由金额 1：锁仓金额

        if walletObject.currentWallet.type == .observed {

            let funcType = FuncType.createDelegate(typ: typ, nodeId: nodeId, amount: self.currentAmount)

            web3.platon.platonGetNonce(sender: walletObject.currentWallet.address) { [weak self] (result, blockNonce) in
                guard let self = self else { return }
                switch result {
                case .success:
                    guard let nonce = blockNonce else { return }
                    let nonceString = nonce.quantity.description

                    let transactionData = TransactionQrcode(amount: self.currentAmount.description, chainId: web3.properties.chainId, from: walletObject.currentWallet.address, to: PlatonConfig.ContractAddress.stakingContractAddress, gasLimit: funcType.gas.description, gasPrice: gasPrice, nonce: nonceString, typ: typ, nodeId: nodeId, nodeName: self.currentNode?.name, stakingBlockNum: nil, functionType: funcType.typeValue)

                    let qrcodeData = QrcodeData(qrCodeType: 0, qrCodeData: [transactionData], timestamp: Int(Date().timeIntervalSince1970 * 1000), chainId: web3.chainId, functionType: 1004, from: walletObject.currentWallet.address)
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

            StakingService.sharedInstance.createDelgate(typ: typ, nodeId: nodeId, amount: self.currentAmount, sender: currentAddress, privateKey: pri, { [weak self] (result, data) in
                guard let self = self else { return }
                self.hideLoadingHUD()

                switch result {
                case .success:
                    // realm 不能跨线程访问同个实例
                    if let transaction = data as? Transaction {
                        transaction.gasUsed = self.estimateUseGas?.description
                        transaction.nodeName = self.currentNode?.name
                        TransferPersistence.add(tx: transaction)
                        self.doShowTransactionDetail(transaction)
                    }
                case .fail(_, let errMsg):
                    if let message = errMsg, message == "insufficient funds for gas * price + value" {
                        self.showMessage(text: Localized(message), delay: 2.0)
                    } else {
                        self.showMessage(text: errMsg ?? "call web3 error", delay: 2.0)
                    }
                }
            })
        }
    }

    func showOfflineConfirmView(content: String) {
        let qrcodeView = OfflineSignatureQRCodeView()
        let qrcodeWidth = PopUpContentWidth - 32
        let qrcodeImage = UIImage.geneQRCodeImageFor(content, size: qrcodeWidth)
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
                if qrcode.timestamp != self?.generateQrCode?.timestamp {
                    self?.showErrorMessage(text: Localized("offline_signature_invalid"), delay: 2.0)
                    return
                }
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
            guard let qrcodeType = QRCodeDecoder().decode(result) else { return }
            switch qrcodeType {
            case .signedTransaction(let data):
                completion?(data)
            default:
                AssetViewControllerV060.getInstance()?.showMessage(text: Localized("QRScan_failed_tips"))
                completion?(nil)
            }
            (UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController)?.popViewController(animated: true)
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
                            let to = signedTransaction.to?.rawAddress.toHexString() else { return }
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
                        tx.gasUsed = self.estimateUseGas?.description
                        tx.nodeName = self.currentNode?.name
                        tx.txType = .delegateCreate
                        tx.direction = .Sent
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
        listData[indexSection] = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle!)

        let balance = AssetService.sharedInstace.balances.first { (item) -> Bool in
            return item.addr.lowercased() == walletStyle?.currentWallet.address.lowercased()
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
        var needEstimateGas = amountVon
        guard
            let balanceObject = balanceStyle,
            let nodeId = currentNode?.nodeId else { return }

        let typ = balanceObject.selectedIndex == 0 ? UInt16(0) : UInt16(1) // 0：自由金额 1：锁仓金额

        if isDelegateAll, balanceStyle?.isLock == false {
            // 当全部委托的时候把0替换为1，防止出现0字节导致gas不足的情况
            let amountStr = amountVon.description.replacingOccurrences(of: "0", with: "1")
            needEstimateGas = BigUInt(amountStr) ?? BigUInt.zero
        }

        web3.staking.estimateCreateDelegate(typ: typ, nodeId: nodeId, amount: needEstimateGas, gasPrice: gasPrice) { [weak self] (result, data) in
            switch result {
            case .success:
                self?.estimateUseGas = data

                if
                    let delegateAll = self?.isDelegateAll, delegateAll == true, self?.balanceStyle?.isLock == false {
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
            case .fail:
                break
            }
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

extension DelegateViewController {
    private func getGasPrice() {
        web3.platon.gasPrice { [weak self] (response) in
            switch response.status {
            case .success(let result):
                self?.gasPrice = result.quantity
            case .failure:
                break
            }
        }
    }
}
