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

let AssetHeaderViewH = 168 - 44 + 20
let AssetSectionViewH: CGFloat = 124

class AssetViewControllerV060: BaseViewController, PopupMenuTableDelegate {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetSource = self
        tableView.registerCell(cellTypes: [WalletDetailCell.self])
        return tableView
    }()

    var viewModel: AssetViewModel {
        return controller.viewModel
    }

    let controller: AssetController = {
        return AssetController()
    }()

    lazy var headerView: AssetWalletsHeaderView = {
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

    let tableHeaderView = UIView()

    var dataSource = [String: [Transaction]]() {
        didSet {
            if
                let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress,
                let dataCount = dataSource[selectedAddress]?.count, dataCount >= 20 {
                tableView.mj_footer.isHidden = false
            } else {
                tableView.mj_footer.isHidden = true
            }
        }
    }

    var localDataSource = [String: [Transaction]]()

    var walletAddress: String? {
        return (AssetVCSharedData.sharedData.selectedWallet as? Wallet)?.address
    }

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
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    }

    func initUI() {

        statusBarNeedTruncate = true
        view.backgroundColor = .white

        refreshFooterView.loadMoreTapHandle = { [weak self] in
            self?.goTransactionList()
        }
        tableView.mj_footer = refreshFooterView
        tableView.mj_header = refreshHeader

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableHeaderView.backgroundColor = .white
        tableView.tableHeaderView = tableHeaderView

        tableHeaderView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.width.equalTo(view)
        }

        tableHeaderView.addSubview(sectionView)
        sectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
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
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil, "empty_no_data_img") as? TableViewNoDataPlaceHolder
            view.customView(holder)
            view.isScrollAllowed(true)
        }


//        view.addSubview(scrollView)
//
//        scrollView.canCancelContentTouches = true
//        scrollView.delaysContentTouches = true
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
//
//        if #available(iOS 11.0, *) {
//            scrollView.contentInsetAdjustmentBehavior = .always
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }

//        let usingsafeAutoLaoutGuide = true
//        scrollView.snp.makeConstraints { (make) in
//            make.leading.trailing.equalToSuperview()
//            if usingsafeAutoLaoutGuide {
//                if #available(iOS 11.0, *) {
//                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//                } else {
//                    make.bottom.equalTo(bottomLayoutGuide.snp.top)
////                    make.bottom.equalToSuperview()
//                    make.top.equalTo(topLayoutGuide.snp.bottom)
//                }
//            } else {
//                make.edges.equalToSuperview()
//            }
//        }

//        scrollView.addSubview(headerView)
//        headerView.snp.makeConstraints { (make) in
//            make.leading.trailing.top.equalToSuperview()
//            make.width.equalTo(view)
//        }
//
//        scrollView.addSubview(sectionView)
//        sectionView.snp.makeConstraints { (make) in
//            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(headerView.snp.bottom)
//            make.width.equalTo(view)
//        }
//        sectionView.restrictedIconTapHandler = { [weak self] in
//            self?.showRestrctedInfoDoubt()
//        }

        //        self.updatePageViewConstraint(headerHide: false)

//        transactionVC.delegate = self
//        addChild(transactionVC)
//        scrollView.addSubview(transactionVC.view)
//        transactionVC.didMove(toParent: self)
//        transactionVC.view.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(sectionView.snp.bottom)
//        }
//        sectionView.onSelectItem = { [weak self] (index) -> Bool in
//            if index == 1 && NetworkManager.shared.reachabilityManager?.isReachable == false {
//                self?.onScan()
//                return false
//            }
//            let target = self?.viewControllers[index]
//
//            if (self?.pageViewCurrentIndex)! < index {
//                //self?.pageVC.goToNextPage()
//                self?.pageVC.setViewControllers([target!], direction: .forward, animated: true, completion: nil)
//            } else if (self?.pageViewCurrentIndex)! > index {
//                //self?.pageVC.goToPreviousPage()
//                self?.pageVC.setViewControllers([target!], direction: .reverse, animated: true, completion: nil)
//            }
//            self?.pageViewCurrentIndex = index
//            return true
//
//        }
//
//        sectionView.onWalletAvatarTapAction = { [weak self] in
//            guard let self = self, let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }
//            let detailVC = WalletManagerDetailViewController()
//            detailVC.wallet = wallet
//            detailVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(detailVC, animated: true)
//        }
//        sectionView.onLockedBalanceTapAction = { [weak self] in
//            self?.showMessage(text: Localized("wallet_balance_restricted_doubt"), delay: 2.0)
//        }

        NotificationCenter.default.addObserver(self, selector: #selector(OnBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateWalletStatus), name: Notification.Name.ATON.DidNetworkStatusChange, object: nil)
    }

    // MARK: - Constraint

    //    func updatePageViewConstraint(headerHide: Bool){
    //        let tabbarHeight = (navigationController?.tabBarController?.tabBar.frame.size.height ?? 0)
    //        if headerHide{
    //            pageVC.view.snp.remakeConstraints { (make) in
    //                make.leading.trailing.bottom.equalToSuperview()
    //                make.width.equalTo(view)
    //                make.top.equalTo(sectionView.snp.bottom).offset(0)
    //                make.height.equalTo(kUIScreenHeight - 70 - tabbarHeight - CGFloat(AssetSectionViewH))
    //            }
    //        }else{
    //            pageVC.view.snp.remakeConstraints { (make) in
    //                make.leading.trailing.bottom.equalToSuperview()
    //                make.width.equalTo(view)
    //                make.top.equalTo(sectionView.snp.bottom).offset(0)
    //                make.height.equalTo(kUIScreenHeight - 0 - tabbarHeight - CGFloat(AssetSectionViewH))
    //            }
    //        }
    //    }

    @objc func fetchData() {
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

extension AssetViewControllerV060: UIScrollViewDelegate, ChildScrollViewDidScrollDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollview Didcroll:\(scrollView.contentOffset.y)")

        //let rec = sectionView.convert(sectionView.bounds, to: view)
        //print("sectionView y:\(rec.origin.y)")

        if (scrollView.contentOffset.y >= CGFloat(AssetHeaderViewH)) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH - 20), animated: false)
            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH), animated: false)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func childScrollViewDidScroll(childScrollView: UIScrollView) {
//        let yoffset = childScrollView.contentOffset.y
//        if yoffset <= 0 {
//            childScrollView.setContentOffset(.zero, animated: false)
//        } else {
//            let rec = sectionView.convert(sectionView.bounds, to: view)
//            if rec.origin.y > 0 && !(self.assetHeaderStyle?.hide)! {
//                childScrollView.setContentOffset(.zero, animated: false)
//            } else {
//                //                scrollEnable = false
//            }
//        }
        //        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: childScrollView.contentSize.height + CGFloat(AssetHeaderViewH) + CGFloat(AssetSectionViewH))
    }

    // MARK: - User Interaction

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
//            sectionView.setSectionSelectedIndex(index: 1)
            break
        case .keystore(let data):
            let targetVC = MainImportWalletViewController(type: .keystore, text: data)
            targetVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC, animated: true)
        case .privatekey(let data):
            let targetVC = MainImportWalletViewController(type: .privateKey, text: data)
            targetVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC, animated: true)
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

        if let data = qrcodeData, let signedString = data.qrCodeData  {
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
                tx.from = from.add0x()
                tx.to = to.add0x()
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
                thTx.to = to.add0x().lowercased()
                thTx.from = from.add0x().lowercased()
                thTx.value = amount

                if (qrcode.v ?? 0) >= 1 {
                    let signedTx = SignedTransaction(signedData: signature, remark: qrcode.rk ?? "")
                    guard
                        let signedTxJsonString = signedTx.jsonString
                        else { break }
                    TransactionService.service.sendSignedTransactionToServer(data: signedTxJsonString, sign: sign) { (result, response) in
                        switch result {
                        case .success:
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

    static func setScrollViewScrollEnable(enable: Bool) {
        guard
            let tabNav = UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController,
            let tabvc = tabNav.rt_topViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else {
                return
        }

        guard let navofAssetV60 = nav.viewControllers.first as? RTContainerController else {
            return
        }

        guard let vc = navofAssetV60.contentViewController as? AssetViewControllerV060 else {
            return
        }
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

    static func setPageViewController(index: Int) {
        guard let vc = self.getInstance() else {
            return
        }
//        vc.sectionView.setSectionSelectedIndex(index: index)
    }

    static func reloadTransactionList() {
        guard let vc = self.getInstance() else {
            return
        }
        //wait for db writing
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            vc.transactionVC.refreshData()
//        }
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

    @objc func OnBeginEditing(_ no: Notification) {
        guard let textFiled = no.object as? UITextField else {
            return
        }
    }

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
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        dataSource[selectedAddress] = dataSource[selectedAddress]?.filter { !$0.isInvalidated }
        commonInit()
        refreshPendingData()
        fetchTransactionLastest()

        if AssetVCSharedData.sharedData.walletList.count == 0 {
            self.tableNodataHolderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
        } else {
            self.tableNodataHolderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
        }
    }

    func commonInit() {
//        if pollingTimer == nil {
//            pollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.balancePollingTimerInterval), target: self, selector: #selector(pollingGetBalance), userInfo: nil, repeats: true)
//        }
    }

    @objc func pollingGetBalance() {
        AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
    }

    func refreshPendingData() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let pendingTransactions = getPendingTransation()
        dataSource[selectedAddress] = dataSource[selectedAddress]?.filter { $0.sequence != nil && $0.sequence != 0 }
        guard dataSource[selectedAddress] != nil else {
            dataSource[selectedAddress] = pendingTransactions
            return
        }
        dataSource[selectedAddress]!.insert(contentsOf: pendingTransactions, at: 0)
        tableView.reloadData()
    }

    func getPendingTransation() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }

        var pendingTxsInDB = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.pending)
//        pendingTxsInDB.txSort()
        for tx in pendingTxsInDB {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return pendingTxsInDB
    }

    func getTimeoutTransaction() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }
        var transactions = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.timeout, detached: true)
        transactions.txSort()
        for tx in transactions {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return transactions
    }

    // MARK: - Notification

    @objc func willDeleteWallet(_ notification: Notification) {
        guard self.walletAddress != nil else {
            return
        }
        if let cwallet = notification.object as? Wallet {
            if (self.walletAddress?.ishexStringEqual(other: cwallet.address))! {
                self.dataSource[self.walletAddress!]?.removeAll()
                self.tableView.reloadData()
            }
        }
    }

    @objc func nodeDidSwitch() {
        dataSource = [String: [Transaction]]()
        self.tableView.reloadData()
    }

    func fetchTransaction(beginSequence: Int64, completion: (() -> Void)?) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else {
            tableView.mj_header.endRefreshing()
            return
        }
        TransactionService.service.getBatchTransaction(addresses: [selectedAddress], beginSequence: beginSequence, listSize: 20, direction: "new") { [weak self] (result, response) in
            guard let self = self else {
                return
            }
            self.tableView.mj_header.endRefreshing()
            switch result {
            case .success:
                // 返回的交易数据条数为0，则显示无加载更多
                guard let remoteTransactions = response, remoteTransactions.count > 0 else {
                    self.tableView.mj_footer.isHidden = (self.dataSource[selectedAddress]?.count ?? 0 < 20)
                    return
                }

                for tx in remoteTransactions {
                    tx.direction = tx.getTransactionDirection(selectedAddress)
                }

                var pendingexcludedTxs: [Transaction] = []
                pendingexcludedTxs.append(contentsOf: remoteTransactions)

                let txHashes = remoteTransactions.map { $0.txhash!.add0x() }

                var timeouttxs = self.getTimeoutTransaction()
                timeouttxs = timeouttxs.filter { !txHashes.contains($0.txhash!.add0x()) }

                if timeouttxs.count > 0 {
                    let mappedTimeoutTxs = timeouttxs.map({ (t) -> Transaction in
                        //交易时间临时赋值给确认时间，仅用于交易的排序
                        if t.createTime != 0 {
                            t.confirmTimes = t.createTime
                        } else if t.confirmTimes != 0 && t.createTime == 0 {
                            t.createTime = t.confirmTimes
                        }
                        return t
                    })
                    pendingexcludedTxs.append(contentsOf: mappedTimeoutTxs)
                    pendingexcludedTxs.sortByConfirmTimes()
                }
                var pendingTransaction = self.getPendingTransation()
                pendingTransaction = pendingTransaction.filter { !txHashes.contains($0.txhash!.add0x()) }
                pendingTransaction.append(contentsOf: pendingexcludedTxs)
                self.dataSource[selectedAddress] = pendingTransaction
                AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
                print(self.dataSource)
                self.tableView.mj_footer.isHidden = (self.dataSource[selectedAddress]?.count ?? 0 < 20)
                self.tableView.reloadData()
                completion?()
            case .failure(let error):
                completion?()
            }
        }
    }

    private func goTransactionList() {

        let controller = TransactionListViewController()
        controller.selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        // 由于余额发生变化时会更新交易记录，因此，这里并需要再次更新

        guard let txStatus = notification.object as? TransactionsStatusByHash, let status = txStatus.txReceiptStatus else { return }
        fetchTransaction(beginSequence: -1) { [weak self] in
            guard let self = self else { return }
            for txObj in self.dataSource {
                for tx in txObj.value {
                    if tx.txhash?.lowercased() == txStatus.hash?.lowercased() {
                        tx.txReceiptStatus = status.rawValue
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
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

    func fetchTransactionLastest() {
        fetchTransaction(beginSequence: -1, completion: nil)
    }

    @objc func pollingWalletTransactions() {
        guard AssetVCSharedData.sharedData.walletList.count > 0 else { return }
        fetchTransactionLastest()
    }
}

extension AssetViewControllerV060: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return 0 }
        return dataSource[selectedAddress]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = AssetVCSharedData.sharedData.selectedWallet
        let cell: WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailCell.self)) as! WalletDetailCell
        if let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress, let count = dataSource[selectedAddress]?.count, count > indexPath.row {
            let tx = dataSource[selectedAddress]?[indexPath.row]
            cell.updateTransferCell(transaction: tx, wallet: wallet as? Wallet)
            cell.updateCellStyle(count: dataSource[selectedAddress]?.count ?? 0, index: indexPath.row)
        }

        return cell
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        delegate?.childScrollViewDidScroll(childScrollView: scrollView)
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let tx = dataSource[selectedAddress]?[indexPath.row]
        if tx?.txReceiptStatus == TransactionReceiptStatus.pending.rawValue {
            tx?.direction = .Sent
        }
        let transferVC = TransactionDetailViewController()
        transferVC.transaction = tx
        AssetViewControllerV060.pushViewController(viewController: transferVC)
    }

}

// MARK: - Asset60

extension AssetViewControllerV060 {

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        let edgeToTop = (self.tableView.frame.size.height - self.tableNodataHolderView.frame.size.height) * 0.5
        return -edgeToTop
    }
}
