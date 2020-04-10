//
//  SendAssetViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt
import platonWeb3
import SnapKit

// MARK: - UI

class MultiGestureScrollView: UIScrollView {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class AssetSendViewControllerV060: BaseViewController, UITextFieldDelegate {

    weak var assetController: AssetController?
    let maxGasLimit = BigUInt(999999999)
    var gasPriceLevel: Float?
    var txfeeViewBottomConstraint: Constraint?
    var inputGasLimit: BigUInt?
    var toAddress: String?
    var gas: RemoteGas?

    var gasPrice: BigUInt? {
        get {
            //gas prise: 1gwei ~ 10gwei
            let defaultGasPrice = gas?.gasPriceBInt ?? TransactionService.service.defaultGasPrice
            let minGasPrice = TransactionService.service.minGasPrice
            let maxGasPrice = defaultGasPrice.multiplied(by: BigUInt(6))

            guard let priceLevel = gasPriceLevel else {
                return defaultGasPrice.convertLastTenDecimalPlaceToZero()
            }

            let price = minGasPrice + (((maxGasPrice - minGasPrice) * BigUInt(Int(priceLevel * 10000000)) / BigUInt(10000000)))
            return price.convertLastTenDecimalPlaceToZero()
        }
    }

    var useGasLimit: BigUInt {
        return inputGasLimit ?? gas?.gasLimitBInt ?? PlatonConfig.FuncGas.defaultGas
    }

    var generateQrCode: QrcodeData<[TransactionQrcode]>?

    lazy var scrollView = { () -> UIScrollView in
        let view = UIScrollView(frame: .zero)
        view.delegate = self
        return view
    }()

    lazy var amountView = { () -> ATextFieldView in
        let amountView = ATextFieldView.create(title: "send_amout_colon")
        amountView.textField.LocalizePlaceholder = "send_amount_placeholder"
        amountView.textField.keyboardType = .decimalPad
        amountView.textField.font = .systemFont(ofSize: 20, weight: .medium)
        amountView.addAction(title: "send_sendAll", action: {[weak self] in
            self?.onSendAll()
        })
        amountView.checkInput(mode: .all, check: { [weak self] (text, _) -> (Bool, String) in
            let balance = self?.getAvailbleBalance()
            let inputformat = CommonService.checkStakingAmoutInput(text: text, balance: balance ?? BigUInt.zero, type: .transfer)
            if !inputformat.0 {
                return inputformat
            }
            return (self?.checkSufficient(text: text))!

            }, heightChange: { [weak self](view) in
                self?.textFieldViewUpdateHeight(atextFieldView: view)
        })

        amountView.shouldChangeCharactersCompletion = { (concatenated, replacement) in
            if replacement == ""{
                return true
            }
            if !replacement.validFloatNumber() {
                return false
            }
            return concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace()
        }

        amountView.endEditCompletion = { [weak self] text in
            _ = self?.checkConfirmButtonAvailable()
            _ = amountView.checkInvalidNow(showErrorMsg: false)
        }

        return amountView
    }()

    lazy var walletAddressView = { () -> PTextFieldView in
        let walletView = PTextFieldView.create(title: "send_wallet_colon")
        walletView.textField.LocalizePlaceholder = "send_address_placeholder"
        walletView.textField.adjustsFontSizeToFitWidth = true
        walletView.textField.minimumFontSize = 10.0
        walletView.checkInput(mode: .endEdit, check: { (text) -> (Bool, String) in
            return CommonService.checkTransferAddress(text: text)
        }, heightChange: { [weak self](view) in
            self?.textFieldViewUpdateHeight(view: view)
        })
        //walletView.textField.textAlignment = .center

        walletView.shouldChangeCharactersCompletion = { (concatenated, replacement) in
            return true
        }
        walletView.endEditCompletion = {[weak self] text in
            _ = self?.checkConfirmButtonAvailable()
            _ = self?.amountView.checkInvalidNow(showErrorMsg: false)
        }
        return walletView

    }()

    lazy var remarkView = { () -> RemarkTextView in
        let remarkView = RemarkTextView()
        remarkView.textField.LocalizePlaceholder = "send_remark_placeholder"
        return remarkView
    }()

    lazy var gasLimitNoteLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = common_darkGray_color
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byClipping
        label.localizedText = "gaslimit_note"
        return label
    }()

    lazy var gasLimitNoteView = { () -> UIView in
        let noteView = UIView()
        noteView.backgroundColor = UIColor(rgb: 0xF4F5FA)
        noteView.layer.borderWidth = 1/UIScreen.main.scale
        noteView.layer.borderColor = UIColor(rgb: 0xd5d8df).cgColor
        noteView.layer.cornerRadius = 4.0
        return noteView
    }()

    lazy var gasLimitView = { () -> ATextFieldView in
        let gasLimitView = ATextFieldView.create(title: "Gas Limit:")
        gasLimitView.textField.keyboardType = .numberPad
        gasLimitView.isValidUInt = true
        gasLimitView.isValidMagitude = false
        gasLimitView.maxBinUIntValue = self.maxGasLimit
        gasLimitView.checkInput(mode: .all, check: { [weak self] (text, _) -> (Bool, String) in
            let result = CommonService.checkGasLimit(value: text, minGasLimit: PlatonConfig.FuncGas.defaultGas, maxGasLimit: self?.maxGasLimit ?? BigUInt(999999999))
            self?.inputGasLimit = BigUInt(text) ?? BigUInt.zero
            self?.DidNodeGasPriceUpdate()
            _ = self?.amountView.checkInvalidNow(showErrorMsg: true)
            _ = self?.checkConfirmButtonAvailable()

            return (result.0, result.1 ?? "")
            }, heightChange: { _ in
        })

        gasLimitView.endEditCompletion = { [weak self] text in
            _ = self?.checkConfirmButtonAvailable()
            _ = gasLimitView.checkInvalidNow(showErrorMsg: false)
        }

        return gasLimitView
    }()

    lazy var balanceLabel = { () -> UILabel in
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = common_lightGray_color
        label.textAlignment = .right
        label.text = Localized("transferVC_transfer_balance") + "- LAT"
        return label
    }()

    lazy var feeView = { () -> AssetFeeViewV060 in
        let view = AssetFeeViewV060(frame: .zero)
        return view
    }()

    lazy var txFeeView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(showGasLimitAction), for: .touchUpInside)
        return button
    }()

    lazy var txFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    lazy var sendBtn = { () -> PButton in
        let btn = PButton(frame: .zero)
        btn.localizedNormalTitle = "walletDetailVC_send_button"
        btn.style = .plain
        btn.addTarget(self, action: #selector(onSendButton(_:)), for: .touchUpInside)
        return btn
    }()

    lazy var arrowIV: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(showGasLimitAction), for: .touchUpInside)
        button.setImage(UIImage(named: "6.icon_under"), for: .normal)
        button.setImage(UIImage(named: "7.icon_on"), for: .selected)
        return button
    }()

    lazy var promptView: AssetPromptView = {
        let view = AssetPromptView(type: AssetPromptType.notConnect) {

        }
        view.isHidden = true
        return view
    }()

    var popController: PopUpViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(DidUpdateAllAsset), name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        initialUI()
        initdata()
        initialObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if sendBtn.style == .plain && !sendBtn.frame.equalTo(.zero) {
            _ = self.checkConfirmButtonAvailable()
        }
    }

    // MARK: - Data init

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()

        NotificationCenter.default.addObserver(self, selector: #selector(DidNodeGasPriceUpdate), name: Notification.Name.ATON.DidNodeGasPriceUpdate, object: nil)

        fetchGasData()
        _ = self.checkConfirmButtonAvailable()


        AnalysisHelper.handleEvent(id: event_send, operation: .begin)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ATON.DidNodeGasPriceUpdate, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cleanInputEmptyErrorState()

        AnalysisHelper.handleEvent(id: event_send, operation: .cancel)
    }

    @objc func showGasLimitAction() {
        txFeeView.isSelected = !txFeeView.isSelected
        if txFeeView.isSelected {
            txfeeViewBottomConstraint?.update(priority: .high)
        } else {
            txfeeViewBottomConstraint?.update(priority: .low)
        }
        gasLimitView.isHidden = !txFeeView.isSelected
        gasLimitNoteView.isHidden = !txFeeView.isSelected
        feeView.isHidden = !txFeeView.isSelected
        arrowIV.isSelected = txFeeView.isSelected
        view.layoutIfNeeded()
    }

    func cleanInputEmptyErrorState() {
        if self.amountView.textField.text?.length == 0 {
            self.amountView.cleanErrorState()
        }
        if self.walletAddressView.textField.text?.length == 0 {
            self.walletAddressView.cleanErrorState()
        }
    }

    func initdata() {
        self.refreshData()
        AssetVCSharedData.sharedData.registerHandler(object: self) {
            self.refreshData()
            if let count = self.walletAddressView.textField.text?.count, count > 0 {
                _ = self.walletAddressView.checkInvalidNow(showErrorMsg: true)
            }
            if let count = self.amountView.textField.text?.count, count > 0 {
                _ = self.amountView.checkInvalidNow(showErrorMsg: true)
            }
            if let count = self.gasLimitView.textField.text?.count, count > 0 {
                _ = self.gasLimitView.checkInvalidNow(showErrorMsg: true)
            }
            _ = self.checkConfirmButtonAvailable()
        }
    }

    func initialObserver() {
        NetworkStatusService.shared.registerHandler(object: self) { [weak self] in
            guard let self = self else { return }
            if NetworkStatusService.shared.isConnecting == true {
                self.promptView.isHidden = true
            } else {
                self.promptView.isHidden = false
            }
        }
    }

    func refreshData() {
        guard AssetVCSharedData.sharedData.selectedWallet != nil else {
            return
        }

        if let obj = AssetVCSharedData.sharedData.selectedWallet as? Wallet {
            self.balanceLabel.text = Localized("transferVC_transfer_balance") + obj.balanceDescription()
        }
    }

    // MARK: - Notification

    @objc func DidUpdateAllAsset() {
        self.refreshData()
    }

    func initialUI() {
        leftNavigationTitle = "transferVC_nav_title"

        view.backgroundColor = .white

        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "1.icon_scanning"), for: .normal)
        scanButton.addTarget(self, action: #selector(onNavRightBtnClick), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem

        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-20)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(sendBtn.snp.top).offset(-20)
        }

        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        walletAddressView.textField.text = toAddress
        containerView.addSubview(walletAddressView)
        walletAddressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(walletAddressView.internalHeight)
        }

        containerView.addSubview(amountView)
        amountView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(walletAddressView.snp.bottom).offset(20)
        }

        containerView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountView.snp.top).offset(2)
            make.right.equalToSuperview().offset(-16)
        }

        containerView.addSubview(remarkView)
        remarkView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(amountView.snp.bottom).offset(10)
        }

        containerView.addSubview(txFeeView)
        txFeeView.snp.makeConstraints { (make) in
            make.top.equalTo(remarkView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(remarkView)
        }

        let txFeeTitleLabel = UILabel()
        txFeeTitleLabel.text = Localized("asset_send_fee_title")
        txFeeTitleLabel.textColor = common_darkGray_color
        txFeeTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        txFeeView.addSubview(txFeeTitleLabel)
        txFeeTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }

        txFeeView.addSubview(txFeeLabel)
        txFeeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(txFeeTitleLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-12).priorityMedium()
        }

        txFeeView.addSubview(arrowIV)
        arrowIV.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(11)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(txFeeTitleLabel.snp.bottom).offset(8)
        }

        feeView.backgroundColor = .white
        txFeeView.addSubview(feeView)
        feeView.snp.makeConstraints { (make) in
            make.top.equalTo(txFeeLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        txFeeView.addSubview(gasLimitNoteView)
        gasLimitNoteView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(feeView.snp.bottom).offset(12)
        }

        gasLimitNoteView.addSubview(gasLimitNoteLabel)
        gasLimitNoteLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }

        gasLimitView.textField.text = gas?.gasLimitBInt.description ?? PlatonConfig.FuncGas.defaultGas.description
        txFeeView.addSubview(gasLimitView)
        gasLimitView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(gasLimitNoteView.snp.bottom).offset(16)
            txfeeViewBottomConstraint = make.bottom.equalToSuperview().offset(-12).priority(.low).constraint
        }

        txFeeView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        txFeeView.layer.shadowRadius = 4.0
        txFeeView.layer.shadowOffset = CGSize(width: 2, height: 2)
        txFeeView.layer.shadowOpacity = 0.2

        containerView.snp.makeConstraints { make in
            make.bottom.equalTo(txFeeView.snp.bottom).offset(20)
        }

        view.addSubview(promptView)
        promptView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(sendBtn.snp.top).offset(-20)
        }

        walletAddressView.addAction(icon: UIImage(named: "textField_icon_addressBook"), action: {
            let addressBookVC = AddressBookViewController()
            addressBookVC.isHideAddButton = true
            addressBookVC.selectionCompletion = { [weak self](_ addressInfo: AddressInfo?) -> Void in
                if let weakSelf = self {
                    weakSelf.walletAddressView.textField.text = addressInfo!.walletAddress
                    weakSelf.walletAddressView.cleanErrorState()
                    _ = weakSelf.checkConfirmButtonAvailable()
                }
            }
            AssetViewControllerV060.pushViewController(viewController: addressBookVC)

        })

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)

        self.feeView.levelView.curLevel = gasPriceLevel ?? TransactionService.service.getSliderDefaultValue(min: TransactionService.service.minGasPrice, value: gas?.gasPriceBInt ?? TransactionService.service.defaultGasPrice)
        self.feeView.levelView.levelChanged = { [weak self] level in
            self?.gasPriceLevel = level
            self?.DidNodeGasPriceUpdate()
            _ = self?.amountView.checkInvalidNow(showErrorMsg: true)
            _ = self?.checkConfirmButtonAvailable()
        }
        self.DidNodeGasPriceUpdate()

        walletAddressView.textFieldShouldReturnCompletion = {[weak self] textField in
            self?.amountView.textField.becomeFirstResponder()
            return true
        }
        amountView.textFieldShouldReturnCompletion = {[weak self] textField in
            self?.gasLimitView.textField.becomeFirstResponder()
            return true
        }
        gasLimitView.textFieldShouldReturnCompletion = {[weak self] textField in
            self?.gasLimitView.textField.resignFirstResponder()
            return true
        }
//        gasLimitView.isOnlyShowFeeTip = false

        gasLimitView.isHidden = true
        gasLimitNoteView.isHidden = true
        feeView.isHidden = true
    }

    @objc func onNavRightBtnClick() {
        let scanner = QRScannerViewController()
        scanner.hidesBottomBarWhenPushed = true
        scanner.scanCompletion = { [weak self] result in
            let qrcodeType = QRCodeDecoder().decode(result)
            switch qrcodeType {
            case .address(let data):
                self?.walletAddressView.textField.text = data
                self?.walletAddressView.cleanErrorState()
                _ = self?.checkConfirmButtonAvailable()
            default:
                AssetViewControllerV060.getInstance()?.showMessage(text: Localized("QRScan_failed_tips"))
            }
        }
        AssetViewControllerV060.pushViewController(viewController: scanner)
    }

    @objc func onSendButton(_ sender: UIButton) {
        view.endEditing(true)

        if !self.checkConfirmButtonAvailable() {
            return
        }

        guard
            let toAddress = walletAddressView.textField.text,
            let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet,
            toAddress.ishexStringEqual(other: wallet.address) == false
        else {
            AssetViewControllerV060.getInstance()?.showMessage(text: Localized("cannot_send_itself"))
            return
        }

        guard let amount = amountView.textField.text, let amountBInt = BigUInt.mutiply(a: amount, by: PlatonConfig.VON.LAT.description) else { return }
        guard amountBInt < SettingService.shareInstance.thresholdValue else {
            showThresholdConfirmView()
            return
        }

        guard SettingService.shareInstance.isResendReminder else {
            TwoHourTransactionPersistence.deleteOverTwoHourTransaction()
            sendTransfer()
            return
        }

        let transactions = TransferPersistence.getPendingTransaction(address: wallet.address)
        if transactions.count >= 0 && (Date().millisecondsSince1970 - (transactions.first?.createTime ?? 0) < 300 * 1000) {
            showErrorMessage(text: Localized("transaction_warning_wait_for_previous"))
            return
        }

        let twoHourTxs = TwoHourTransactionPersistence.getTwoHourTransactions(from: wallet.address, to: toAddress, value: amountBInt.description)
        let currentTimeInterval =  Date().millisecondsSince1970
        let twoHourTimeInterval = currentTimeInterval-AppConfig.OvertimeTranction.overtime

        guard
            let tx = twoHourTxs.first,
            tx.createTime > twoHourTimeInterval && tx.createTime < currentTimeInterval
        else {
            TwoHourTransactionPersistence.deleteOverTwoHourTransaction()
            sendTransfer()
            return
        }

        showResendConfirmView()
        TwoHourTransactionPersistence.deleteOverTwoHourTransaction()
    }

    func sendTransfer() {
        guard let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }

        let controller = PopUpViewController()
        let confirmView = TransferConfirmsView()
        confirmView.titleLabel.text = Localized("Send_transaction_alert_title")
        let unionAttr = NSAttributedString(string: " LAT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let amountAttr = NSMutableAttributedString(string: amountView.textField.text!.displayForMicrometerLevel(maxRound: 8))
        amountAttr.append(unionAttr)
        confirmView.totalLabel.attributedText = amountAttr
        confirmView.toAddressLabel.text = walletAddressView.textField.text!.addressDisplayInLocal() ?? "--"
        confirmView.walletName.text = wallet.address.addressDisplayInLocal() ?? "--"
        let feeString = self.totalFee().divide(by: ETHToWeiMultiplier, round: 8)
        confirmView.feeLabel.text = feeString.ATPSuffix()
        confirmView.transactionTypeLabel.text = Localized("transferVC_confirm_ATP_send")
        if wallet.type == .observed {
            confirmView.submitBtn.localizedNormalTitle =  "confirm_button_next"
        }

        controller.onCompletion = { [weak self] in
            self?.doInitTransferData()
        }
        controller.setUpConfirmView(view: confirmView)
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
        controller.onCompletion = {
            AssetViewControllerV060.getInstance()?.showQrcodeScan()
        }
        controller.setUpConfirmView(view: offlineConfirmView)
        controller.show(inViewController: self)
    }

    func doInitTransferData() {
        guard
            let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }

        if wallet.type == .observed {
            guard
                let to = walletAddressView.textField.text, to.count > 0,
                let amountLATString = amountView.textField.text,
                let inputGasPrice = gasPrice
                else { return }
            let gasPrice = inputGasPrice.description
            let gasLimit = useGasLimit.description
            let amount = (BigUInt.mutiply(a: amountLATString, by: ETHToWeiMultiplier) ?? BigUInt.zero).description

            web3.platon.platonGetNonce(sender: wallet.address) { [weak self] (result, blockNonce) in
                guard let self = self else { return }
                switch result {
                case .success:
                    guard let nonce = blockNonce else { return }
                    let nonceString = nonce.quantity.description

                    let transactionData = TransactionQrcode(amount: amount, chainId: web3.properties.chainId, from: wallet.address, to: to, gasLimit: gasLimit, gasPrice: gasPrice, nonce: nonceString, typ: nil, nodeId: nil, nodeName: nil, stakingBlockNum: nil, functionType: 0, rk: self.remarkView.textField.text)
                    let qrcodeData = QrcodeData(qrCodeType: 0, qrCodeData: [transactionData], chainId: web3.chainId, functionType: nil, from: nil, nodeName: nil, rn: nil, timestamp: Int(Date().timeIntervalSince1970 * 1000), rk: nil, si: nil, v: 1)
                    guard
                        let data = try? JSONEncoder().encode(qrcodeData),
                        let content = String(data: data, encoding: .utf8) else { return }
                    self.generateQrCode = qrcodeData
                    DispatchQueue.main.async {
                        self.showOfflineConfirmView(content: content)
                    }
                case .fail(_, let message):
                    self.showErrorMessage(text: message ?? "get nonce error")
                }
            }
        } else {
            showPasswordInputPswAlert(for: wallet) { [weak self] (privateKey, _, error) in
                guard let self = self else { return }
                guard let pri = privateKey else {
                    if let errorMsg = error?.localizedDescription {
                        self.showErrorMessage(text: errorMsg, delay: 2.0)
                    }
                    return
                }
                self.doClassicTransfer(pri: pri, data: nil)
            }
        }
    }

    func showThresholdConfirmView() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.ChoiceView(message: Localized("threshold_confirm_value", arguments: (SettingService.shareInstance.thresholdValue/PlatonConfig.VON.LAT).description.ATPSuffix()))
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            self.sendTransfer()
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    func showResendConfirmView() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.ChoiceView(message: "resend_transfer_confirm_value")
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            self.sendTransfer()
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    // MARK: - Check method

    func checkConfirmButtonAvailable() -> Bool {
        if amountView.textField.text?.count == 0 {
            sendBtn.style = .disable
            return false
        }

        if amountView.checkInvalidNow(showErrorMsg: false)!.0 && walletAddressView.checkInvalidNow(showErrorMsg: false)!.0 && CommonService.checkGasLimit(value: gasLimitView.textField.text ?? "", minGasLimit: PlatonConfig.FuncGas.defaultGas, maxGasLimit: maxGasLimit).0
            {
            self.sendBtn.style = .blue
            return true
        }
        self.sendBtn.style = .disable
        return false
    }

    @objc func onTap(gesture: UITapGestureRecognizer) {
        if amountView.textField.isFirstResponder {
            amountView.textField.resignFirstResponder()
        }
        if walletAddressView.textField.isFirstResponder {
            walletAddressView.textField.resignFirstResponder()
        }
        if gasLimitView.textField.isFirstResponder {
            gasLimitView.textField.resignFirstResponder()
        }
        if self.remarkView.textField.isFirstResponder {
            self.remarkView.textField.resignFirstResponder()
        }
    }

    func textFieldViewUpdateHeight(view: PTextFieldView) {
        view.snp.updateConstraints { (make) in
            make.height.equalTo(view.internalHeight)
        }
    }

    func textFieldViewUpdateHeight(atextFieldView: ATextFieldView) {
//        view.snp.updateConstraints { (make) in
//            make.height.equalTo(atextFieldView.internalHeight)
//        }
//        view.layoutIfNeeded()
    }

    func updateBalance(balance: BigUInt) {
        let ret = balance.divide(by: ETHToWeiMultiplier, round: 8)
        self.balanceLabel.text = ret.balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }

    func resportSufficiency(isSufficient: Bool) {

    }

    func didTransferSuccess() {
        assetController?.fetchLatestData()
        resetTextFieldAndButton()
    }

    func resetTextFieldAndButton() {
        walletAddressView.textField.text = ""
        amountView.textField.text = ""
        remarkView.textField.text = ""
        gasLimitView.textField.text = gas?.gasLimitBInt.description ?? PlatonConfig.FuncGas.defaultGas.description

        _ = checkConfirmButtonAvailable()
    }

    func fetchGasData() {
        guard let address = AssetVCSharedData.sharedData.currentWalletAddress else { return }
        showLoadingHUD()
        TransactionService.service.getContractGas(from: address, txType: TxType.transfer) { [weak self] (result, remoteGas) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                self?.gas = remoteGas
                self?.DidNodeGasPriceUpdate()
            case .failure(let error):
                self?.showErrorMessage(text: error?.message ?? "get gas api error", delay: 2.0)
            }
        }
    }

}

// MARK: - Classic transfer Logic

extension AssetSendViewControllerV060 {

    // MARK: - Notification

    @objc func DidNodeGasPriceUpdate() {
        DispatchQueue.global().async {
            let feeString = self.totalFee().divide(by: ETHToWeiMultiplier, round: 8)
            DispatchQueue.main.async {
                self.txFeeLabel.text = feeString
                let value = self.gasPriceLevel ?? TransactionService.service.getSliderDefaultValue(min: TransactionService.service.minGasPrice, value: self.gas?.gasPriceBInt ?? TransactionService.service.defaultGasPrice)
                self.feeView.levelView.setSliderValue(value: value)
                if self.gasLimitView.textField.text == nil {
                    self.gasLimitView.textField.text = self.gas?.gasLimitBInt.description ?? PlatonConfig.FuncGas.defaultGas.description
                }
            }
        }
    }

    @objc func keyboardWillChangeFrame(_ notify:Notification) {

        guard
            let responderView = scrollView.firstResponder,
            let rect = responderView.superview?.convert(responderView.frame, to: view)
            else { return }

        let endFrame = notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        if rect.maxY > endFrame.origin.y {
            view.transform = CGAffineTransform(translationX: 0, y: -(rect.maxY - endFrame.origin.y + rect.height))
        } else {
            view.transform = .identity
        }
    }

    func checkSufficient(text: String?) -> (Bool, String) {
        if text == nil {
            return (true, "")
        }
        guard let amountOfwei = BigUInt.mutiply(a: text!, by: ETHToWeiMultiplier) else {
            return (true, "")
        }
        var overflow = false

        let balance = getAvailbleBalance()
        var newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(amountOfwei, shiftedBy: 0))!
        if overflow {
            //amount < balance
            self.resportSufficiency(isSufficient: false)
            return (false, Localized("transferVC_Insufficient_balance"))
        }

        newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(self.totalFee() + amountOfwei, shiftedBy: 0))!
        if overflow {
            //balance < fee
            self.resportSufficiency(isSufficient: false)
            return (false, Localized("transferVC_Insufficient_balance_for_gas"))
        }

        self.resportSufficiency(isSufficient: true)
        return (true, "")
    }

    func totalFee() -> BigUInt {
        guard (AssetVCSharedData.sharedData.selectedWallet as? Wallet) != nil else {
            return BigUInt("0")!
        }
        return (self.gasPrice?.multiplied(by: self.useGasLimit))!
    }

    func onSendAll() {
        let balance = getAvailbleBalance()
        if String((balance)) == "0"{
            amountView.textField.text = "0"
            showMessage(text: Localized("transferVC_Insufficient_balance"))
            return
        }
        var maxSendAmout = BigUInt(String((balance)))
        //let overflow = maxSendAmout?.subtractingReportingOverflow(fee!)
        let overflow = maxSendAmout?.subtractReportingOverflow(self.totalFee())
        if overflow! {
            self.resportSufficiency(isSufficient: false)
            return
        }

        self.resportSufficiency(isSufficient: true)
        amountView.textField.text = maxSendAmout?.divide(by: ETHToWeiMultiplier, round: 8)
        _ = amountView.checkInvalidNow(showErrorMsg: true)
        _ = self.checkConfirmButtonAvailable()
    }

    func getAvailbleBalance() -> BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == AssetVCSharedData.sharedData.selectedWalletAddress?.lowercased() }),
            let freeString = balance.free,
            let freeBalanceValue = BigUInt(freeString) else { return BigUInt.zero }

        return freeBalanceValue.floorToDecimal(round: (18 - 8))
    }

    // MARK: - Transfer

    func doClassicTransfer(pri: String, data: AnyObject?) {

        AnalysisHelper.handleEvent(id: event_send, operation: .end)

        AssetViewControllerV060.getInstance()?.showLoadingHUD()
        let from = AssetVCSharedData.sharedData.cWallet?.address
        let to = self.walletAddressView.textField.text!
        let remark = remarkView.textField.text

        guard let amount = self.amountView.textField.text, amount.count > 0 else {
            showErrorMessage(text: "amount value is nil")
            return
        }

        guard let nonce = gas?.nonceBInt else { return }

        _ = TransactionService.service.sendAPTTransfer(from: from!, to: to, amount: amount, InputGasPrice: self.gasPrice!, estimatedGas: String(self.useGasLimit), remark: remark, nonce: nonce, pri: pri, completion: {[weak self] (result, _) in
            AssetViewControllerV060.getInstance()?.hideLoadingHUD(delay: 0.2)
            switch result {
            case .success:
                self?.didTransferSuccess()
                self?.navigationController?.popViewController(animated: true)
            case .fail(let code, let des):
                self?.showMessageWithCodeAndMsg(code: code!, text: des!)
            }

        })
    }
}

extension AssetSendViewControllerV060 : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
