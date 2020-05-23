//
//  AssetViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import RTRootNavigationController
import MJRefresh
import platonWeb3
import SnapKit
import EmptyDataSet_Swift

let AssetHeaderViewH = 168 - 44 + 20
let AssetSectionViewH: CGFloat = 124

class AssetViewControllerV060: UIViewController, PopupMenuTableDelegate {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = normal_background_color
        tableView.register(AssetTransactionCell.self, forCellReuseIdentifier: AssetTransactionCell.cellIdentifier())
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tableView.estimatedRowHeight = 69
        }
        tableView.emptyDataSetSource = self
        return tableView
    }()

    var viewModel: AssetViewModel {
        return controller.viewModel
    }

    let controller: AssetController = {
        return AssetController()
    }()

    lazy var assetWalletsView: AssetWalletsHeaderView = {
        let view = AssetWalletsHeaderView(controller: controller.headerController)
        return view
    }()

    lazy var sectionView: AssetWalletsSectionView = {
        let view = AssetWalletsSectionView(controller: controller.sectionController)
        return view
    }()

    lazy var refreshHeader = { () -> MJRefreshNormalHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()

    lazy var refreshFooterView: MJExtensionLoadMoreFooterView = {
        let view = MJExtensionLoadMoreFooterView(refreshingTarget: self, refreshingAction: nil)!
        return view
    }()

    lazy var backupPromptView: AssetPromptView = {
        let view = AssetPromptView(type: AssetPromptType.backup)
        view.isHidden = true
        return view
    }()

    lazy var offlinePromptView: AssetPromptView = {
        let view = AssetPromptView(type: AssetPromptType.offline)
        view.isHidden = true
        return view
    }()

    let tableHeaderView = UIView()
    let headerForFixTop = UIView()

    var localDataSource = [String: [Transaction]]()

    var walletAddress: String? {
        return (AssetVCSharedData.sharedData.selectedWallet as? Wallet)?.address
    }
    var isShowNavigationBar: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        TransactionService.service.startTimerFire()

        // 先获取一次gasprice
        TransactionService.service.getGasPrice()

        initData()
        initUI()
        initBinding()
        shouldUpdateWalletStatus()

        refreshHeader.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(!isShowNavigationBar, animated: false)
        controller.fetchLatestData()
//        headerView.shouldUpdateWalletList()
    }

    func initBinding() {
        controller.headerController.viewModel.menuBtnPressed = { [weak self] in
            self?.onMenu()
        }

        controller.headerController.viewModel.scanBtnPressed = { [weak self] in
            self?.onScan()
        }

        controller.headerController.onCreatePressed = { [weak self] in
            self?.createIndividualWallet()
        }

        controller.headerController.onImportPressed = { [weak self] in
            self?.importIndividualWallet()
        }

        controller.sectionController.onReceivePressed = { [weak self] in
            self?.onReceivePressed()
        }

        controller.sectionController.onSendPressed = { [weak self] in
            self?.onSendPressed()
        }

        controller.sectionController.onSignaturePressed = { [weak self] in
            self?.onScan()
        }

        controller.sectionController.onManagerPressed = { [weak self] in
            self?.onWalletManagerPressed()
        }

        viewModel.transactionsData.addObserver { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.isFetching.addObserver { [weak self] (isFetching) in
            if !isFetching {
                self?.tableView.mj_header.endRefreshing()
            }
        }

        viewModel.isShowFooterMore.addObserver { [weak self] (isShowMore) in
            self?.tableView.mj_footer.isHidden = !isShowMore
        }

        viewModel.isHideSectionView.addObserver { [weak self] (isHide) in
            self?.sectionView.isHidden = isHide
            self?.tableView.reloadEmptyDataSet()
        }

        viewModel.isShowBackupPromptView.addObserver { [weak self] (isShow) in
            self?.backupPromptView.isHidden = !isShow
        }

        viewModel.isShowOfflinePromptView.addObserver { [weak self] (isShow) in
            self?.offlinePromptView.isHidden = !isShow
        }
    }

    func onWalletManagerPressed() {
        guard let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }
        let detailVC = WalletManagerDetailViewController()
        detailVC.wallet = wallet
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func initUI() {
        view.backgroundColor = normal_background_color

        let barImage = UIImage(named: "asset_bj3")?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 120, right: 300))
            navigationController?.navigationBar.setBackgroundImage(barImage, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        let contentView = UIView()
        navigationController?.navigationBar.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let walletNameLabel = UILabel()
        walletNameLabel.setContentHuggingPriority(.required, for: .vertical)
        walletNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        walletNameLabel.localizedText = "asset_header_title"
        walletNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        walletNameLabel.textColor = .black
        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(0)
        }

        let menuButton = UIButton()
        menuButton.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        menuButton.setImage(UIImage(named: "1.icon_add"), for: .normal)
        contentView.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(walletNameLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
            make.height.width.equalTo(30)
        }

        let scanButton = UIButton()
        scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        scanButton.setImage(UIImage(named: "1.icon_scanning"), for: .normal)
        contentView.addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.centerY.equalTo(walletNameLabel.snp.centerY)
            make.height.width.equalTo(30)
            make.trailing.equalTo(menuButton.snp.leading).offset(-10)
            make.leading.greaterThanOrEqualTo(walletNameLabel.snp.trailing).offset(5)
        }

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }

        refreshFooterView.loadMoreTapHandle = { [weak self] in
            self?.goTransactionList()
        }
        tableView.mj_footer = refreshFooterView
        tableView.mj_header = refreshHeader

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
            make.leading.trailing.bottom.top.equalToSuperview()
        }

        tableHeaderView.backgroundColor = .clear
        tableView.tableHeaderView = tableHeaderView

        tableHeaderView.addSubview(assetWalletsView)
        assetWalletsView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(view)
            make.bottom.equalToSuperview()
        }

        if let tHeaderView = tableView.tableHeaderView {
            tHeaderView.setNeedsLayout()
            tHeaderView.layoutIfNeeded()
            tHeaderView.frame.size = tHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            tableView.tableHeaderView = tHeaderView
        }

        tableView.emptyDataSetView { [weak self] view in
            guard let self = self else { return }
            let holderView = self.factoryEmptyHolderView()
            view.customView(holderView)
        }

        backupPromptView.onComplete = { [weak self] in
            self?.onBackup()
        }
        view.addSubview(backupPromptView)
        backupPromptView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        offlinePromptView.onComplete = { [weak self] in
            self?.offlinePromptView.dismiss()
        }
        view.addSubview(offlinePromptView)
        offlinePromptView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

//        sectionView.onLockedBalanceTapAction = { [weak self] in
//            self?.showMessage(text: Localized("wallet_balance_restricted_doubt"), delay: 2.0)
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
    }

    @objc func fetchData() {
        controller.fetchTransactionLastest()
        refreshData()
    }

    @objc func shouldUpdateWalletStatus() {
//        headerView.updateWalletStatus()
//        sectionView.updateSendTabUIStatus()
    }

    func endFetchData() {
        refreshHeader.endRefreshing()
    }

    func initData() {
        AssetVCSharedData.sharedData.reloadWallets()
    }

    func showRestrctedInfoDoubt() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10

        let titleAttr = NSAttributedString(string: Localized("wallet_balance_restricted") + "\n", attributes: [NSAttributedString.Key.foregroundColor: text_blue_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let detailAttr = NSAttributedString(string: Localized("asset_alert_restricted_info") + "\n", attributes: [NSAttributedString.Key.foregroundColor: common_darkGray_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.paragraphStyle: paragraphStyle])

        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithText(attributedStrings: [titleAttr, detailAttr])
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }

}

// MARK: - UIScrollViewDelegate

extension AssetViewControllerV060 {
    // MARK: - User Interaction
    func onReceivePressed() {
        let receiveController = AssetReceiveViewControllerV060()
        receiveController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(receiveController, animated: true)
    }

    func onSendPressed(toAddress: String? = nil) {
        let sendController = AssetSendViewControllerV060()
        sendController.assetController = controller
        sendController.toAddress = toAddress
        sendController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(sendController, animated: true)
    }

    @objc func onMenu() {
        var menuArray: [MenuItem] = []
        let menu1 = MenuItem(icon: UIImage(named: "img-more-classic-create"), title: Localized("AddWalletMenuVC_createIndividualWallet_title"))
        let menu3 = MenuItem(icon: UIImage(named: "img-more-classic-import"), title: Localized("AddWalletMenuVC_importIndividualWallet_title"))
        menuArray = [menu1, menu3]
        let menu = PopupMenuTable(menuArray: menuArray, arrowPoint: CGPoint(x: UIScreen.main.bounds.width - 30, y: 64 + UIDevice.notchHeight))
        menu.popUp()
        menu.delegate = self
    }

    @objc func onScan() {
        let controller = QRScannerViewController()
        controller.scanCompletion = { [weak self] (res) in
            guard let self = self else { return }
            self.handleScanResp(res)
        }
        controller.hidesBottomBarWhenPushed = true
        (UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController)?.pushViewController(controller, animated: true)
    }

    @objc func onBackup() {
        guard let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet, wallet.canBackupMnemonic else {
            return
        }
        self.showWalletBackup(wallet: wallet)
    }

    // MARK: - Login

    func handleScanResp(_ res: String) {
        let qrcodeType = QRCodeDecoder().decode(res)
        switch qrcodeType {
        case .transaction(let data):
            doShowConfirmViewController(qrcode: data)
        case .signedTransaction(let data):
            showQrcodeScan(scanData: data)
        case .address(let data):
            if (AssetVCSharedData.sharedData.walletList.isEmpty) {
                let targetVC = MainImportWalletViewController(type: .observer, text: data)
                targetVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(targetVC, animated: true)
            } else {
                onSendPressed(toAddress: data)
            }
        case .keystore(let data):
            let targetVC = MainImportWalletViewController(type: .keystore, text: data)
            targetVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC, animated: true)
        case .privatekey(let data):
            let targetVC = MainImportWalletViewController(type: .privateKey, text: data)
            targetVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC, animated: true)
        case .error(let data):
            showMessage(text: data)
        default:
            showMessage(text: Localized("QRScan_failed_tips"))
        }
    }

    func doShowConfirmViewController(qrcode: QrcodeData<[TransactionQrcode]>) {
        guard let codes = qrcode.qrCodeData, codes.count > 0, codes.first?.chainId == web3.chainId else {
            showErrorMessage(text: Localized("offline_signature_invalid"), delay: 2.0)
            return
        }

        let wallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).first(where: { $0.address.lowercased() == codes.first?.from?.lowercased() })
        guard wallet != nil else {
            showErrorMessage(text: Localized("offline_signature_not_privatekey"), delay: 2.0)
            return
        }

        let controller = OfflineSignatureTransactionViewController()
        controller.qrcode = qrcode
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    func showQrcodeScan(scanData: QrcodeData<[String]>? = nil) {
        let scanView = OfflineSignatureScanView()
        var qrcodeData: QrcodeData<[String]>? = scanData

        if let data = qrcodeData, let signedString = data.qrCodeData {
            scanView.textView.text = signedString.joined(separator: ";")
        }

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
            AssetViewControllerV060.sendSignatureTransaction(qrcode: qrcode)
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

    func doShowTransactionDetail(_ transaction: Transaction) {
        // 重置输入框
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let controller = TransactionDetailViewController()
            controller.transaction = transaction
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: - PopupMenuTableDelegate

    func popupMenu(_ popupMenu: PopupMenuTable, didSelectAt index: Int) {
        switch index {
        case 0:
            createIndividualWallet()
        case 1:
            importIndividualWallet()
        default:
            do {}
        }
    }

    func createIndividualWallet() {
        let createWalletVC = CreateIndividualWalletViewController()
        createWalletVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createWalletVC, animated: true)
    }

    func importIndividualWallet() {
        let importWallet = MainImportWalletViewController()
        importWallet.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(importWallet, animated: true)
    }
}

extension AssetViewControllerV060 {
    static func sendSignatureTransaction(qrcode: QrcodeData<[String]>) {

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
                AssetViewControllerV060.getInstance()?.showLoadingHUD()

                guard
                    let to = signedTransaction.to?.rawAddress.toHexString() else { return }
                let gasPrice = signedTransaction.gasPrice.quantity
                let gasLimit = signedTransaction.gasLimit.quantity
                let gasUsed = gasPrice.multiplied(by: gasLimit).description
                let amount = signedTransaction.value.quantity.description

                let rlpResult = try? QRCodeRLPDecoder().decode(signedTransaction.data.bytes)

                let tx = Transaction()
                tx.senderAddress = from
                tx.from = from.add0xBech32()
                tx.to = to.add0xBech32()
                tx.gasUsed = gasUsed
                tx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                tx.txhash = signedTransaction.hash?.add0x()
                tx.txReceiptStatus = -1
                tx.value = (type == 5000) ? qrcode.rn ?? "0" : amount
                tx.transactionType = Int(type)
                tx.toType = (type != 0) ? .contract : .address
                if let resultDetail = rlpResult {
                    tx.nodeId = resultDetail.1 ?? ""
                    if type == 1004 || type == 1005 {
                        tx.value = (resultDetail.2 ?? BigUInt.zero).description
                    }
                    if type == 1005 {
                        tx.unDelegation = (resultDetail.2 ?? BigUInt.zero).description
                    }
                }
                if type == 5000 {
                    tx.totalReward = qrcode.rn ?? "0"
                }
                tx.nodeName = qrcode.nodeName ?? ""
                tx.direction = tx.getTransactionDirection()
                tx.txType = TxType(rawValue: String(type))
                tx.memo = qrcode.rk

                let thTx = TwoHourTransaction()
                thTx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                thTx.to = to.add0xBech32().lowercased()
                thTx.from = from.add0xBech32().lowercased()
                thTx.value = amount

                if (qrcode.v ?? 0) >= 1 {
                    let signedTx = SignedTransaction(signedData: signature, remark: qrcode.rk ?? "")
                    guard
                        let signedTxJsonString = signedTx.jsonString
                        else { break }
                    TransactionService.service.sendSignedTransaction(txType: .transfer, isObserverWallet: true, data: signedTxJsonString, sign: sign) { (result, response) in
                        switch result {
                        case .success:
                            tx.to = WalletUtil.convertBech32(tx.to!)
                            thTx.to = WalletUtil.convertBech32(thTx.to!)
                            sendTransactionSuccess(tx: tx, thTx: thTx)
                        case .failure(let error):
                            sendTransactionFailure(message: error?.message ?? "server error")
                        }
                    }
                } else {
                    web3.platon.sendRawTransaction(transaction: signedTransaction) { (response) in
                        switch response.status {
                        case .success:
                            sendTransactionSuccess(tx: tx, thTx: thTx)
                        case .failure(let error):
                            sendTransactionFailure(message: error.message)
                        }
                    }
                }
            }
        }
    }

    static func sendTransactionSuccess(tx: Transaction, thTx: TwoHourTransaction) {
        getInstance()?.hideLoadingHUD()
        TransferPersistence.add(tx: tx)
        TwoHourTransactionPersistence.add(tx: thTx)
        DispatchQueue.main.async {
            getInstance()?.doShowTransactionDetail(tx)
        }
    }

    static func sendTransactionFailure(message: String) {
        getInstance()?.hideLoadingHUD()
        getInstance()?.showErrorMessage(text: message)
    }

    static func pushViewController(viewController: UIViewController) {
        guard
            let tabNav = UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController,
            let tabvc = tabNav.rt_topViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else {
                return
        }
        viewController.hidesBottomBarWhenPushed = true
        nav.pushViewController(viewController, animated: true)
    }

    static func popViewController() {
        guard
            let tabNav = UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController,
            let tabvc = tabNav.rt_topViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else {
                return
        }
        nav.popViewController(animated: true)
    }

    static func getInstance() -> AssetViewControllerV060? {
        guard
            let tabNav = UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController,
            let tabvc = tabNav.rt_topViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else {
                return nil
        }

        guard let navofAssetV60 = nav.viewControllers.first as? RTContainerController else {
            return nil
        }

        guard let vc = navofAssetV60.contentViewController as? AssetViewControllerV060 else {
            return nil
        }
        return vc
    }

    static func gotoCreateClassicWallet() {
        guard let vc = self.getInstance() else {
            return
        }
        vc.createIndividualWallet()
    }

    static func gotoImportClassicWallet() {
        guard let vc = self.getInstance() else {
            return
        }
        vc.importIndividualWallet()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.AssetViewControllerV060, presentedVC: UIApplication.shared.keyWindow?.rootViewController ?? self)
    }
}

// MARK: - Notification

extension AssetViewControllerV060 {

    @objc func updateWalletList() {
//        headerView.shouldUpdateWalletList()

        AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
        refreshData()
    }

}

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}

extension AssetViewControllerV060 {

    func refreshData() {
//        if AssetVCSharedData.sharedData.walletList.count == 0 {
//            self.tableNodataHolderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
//        } else {
//            self.tableNodataHolderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
//        }
    }

    private func goTransactionList() {

        let controller = TransactionListViewController()
        controller.selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

// 下拉刷新及加载更多
extension AssetViewControllerV060 {
//    func fetchDataByWalletChanged() {
//        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
//        guard let count = self.dataSource[selectedAddress]?.count, count <= 0 else {
//            pollingWalletTransactions()
//            return
//        }
//    }
}

extension AssetViewControllerV060: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return 0 }
        return viewModel.transactionsData.value[selectedAddress]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = AssetVCSharedData.sharedData.selectedWallet
        let cell: AssetTransactionCell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionCell.cellIdentifier()) as! AssetTransactionCell
        if let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress, let count = viewModel.transactionsData.value[selectedAddress]?.count, count > indexPath.row {
            let tx = viewModel.transactionsData.value[selectedAddress]?[indexPath.row]
            cell.updateTransferCell(transaction: tx, wallet: wallet as? Wallet)
            cell.updateCellStyle(count: viewModel.transactionsData.value[selectedAddress]?.count ?? 0, index: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let tx = viewModel.transactionsData.value[selectedAddress]?[indexPath.row]
        if tx?.txReceiptStatus == TransactionReceiptStatus.pending.rawValue {
            tx?.direction = .Sent
        }
        let transferVC = TransactionDetailViewController()
        transferVC.transaction = tx
        AssetViewControllerV060.pushViewController(viewController: transferVC)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionView
    }

}

extension AssetViewControllerV060: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0 {
            isShowNavigationBar = false
            navigationController?.setNavigationBarHidden(true, animated: false)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .never
            } else {
                // Fallback on earlier versions
                automaticallyAdjustsScrollViewInsets = false
            }
        } else {
            isShowNavigationBar = true
            navigationController?.setNavigationBarHidden(false, animated: false)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .automatic
            } else {
                // Fallback on earlier versions
                automaticallyAdjustsScrollViewInsets = true
            }
        }
    }
}

// MARK: - Asset60

extension AssetViewControllerV060: EmptyDataSetSource {

    func factoryEmptyHolderView() -> UIView {
        let holderView = UIView.viewFromXib(theClass: TableViewNoDataPlaceHolder.self) as! TableViewNoDataPlaceHolder
        
        if AssetVCSharedData.sharedData.walletList.count == 0 {
            holderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
            holderView.imageView.image = UIImage(named: "empty_no_wallet_icon")
        } else {
            holderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
            holderView.imageView.image = UIImage(named: "empty_no_data_img")
        }
        return holderView
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        if viewModel.isHideSectionView.value {
            let edgeToTop = (assetWalletsView.frame.height)*0.5
            return edgeToTop
        } else {
            let edgeToTop = (assetWalletsView.frame.height + sectionView.frame.height)*0.5
            return edgeToTop
        }
    }
}
