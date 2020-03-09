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

    let transactionVC = AssetTransactionViewControllerV060()
    let sendVC =  AssetSendViewControllerV060()
    let recvVC = AssetReceiveViewControllerV060()

    lazy var scrollView = { () -> UIScrollView in
        let view = UIScrollView(frame: .zero)
        view.delegate = self
        view.backgroundColor = .white
        view.showsVerticalScrollIndicator = false
        return view
    }()

    lazy var headerView = { () -> AssetHeaderViewV060 in
        let headerView = UIView.viewFromXib(theClass: AssetHeaderViewV060.self) as! AssetHeaderViewV060
        headerView.menuButton.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        headerView.scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        return headerView
    }()

    lazy var sectionView = { () -> AssetSectionViewV060 in
        let view = UIView.viewFromXib(theClass: AssetSectionViewV060.self) as! AssetSectionViewV060
        view.backUpbtn.addTarget(self, action: #selector(onBackup), for: .touchUpInside)
        return view
    }()

    lazy var pageVC = { () -> AssetPageViewController in
        let vc = AssetPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        return vc
    }()

    lazy var viewControllers: [BaseViewController] = {
        return [transactionVC, sendVC, recvVC]
    }()

    lazy var refreshHeader = { () -> MJRefreshNormalHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()

    var tmpChildVCIndex: Int = 0
    var pageViewCurrentIndex: Int = 0

    var scrollViewScrollEnableInChildVCs = [true, true, true]

    var scrollEnable: Bool {
        get {
            return scrollViewScrollEnableInChildVCs[tmpChildVCIndex]
        }set {
            scrollViewScrollEnableInChildVCs[tmpChildVCIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        transactionVC.parentController = self
        TransactionService.service.startTimerFire()

        // 先获取一次gasprice
        TransactionService.service.getGasPrice()

        initData()
        initUI()
        shouldUpdateWalletStatus()

        scrollView.mj_header = refreshHeader
        refreshHeader.beginRefreshing()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        headerView.shouldUpdateWalletList()
        sendVC.refreshData()
        transactionVC.refreshData()
    }

    func initUI() {

        self.statusBarNeedTruncate = true
        view.backgroundColor = .white
        view.addSubview(UIView(frame: .zero))
        view.addSubview(scrollView)
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .always
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        let usingsafeAutoLaoutGuide = true
        scrollView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            if usingsafeAutoLaoutGuide {
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalTo(bottomLayoutGuide.snp.top)
//                    make.bottom.equalToSuperview()
                    make.top.equalTo(topLayoutGuide.snp.bottom)
                }
            } else {
                make.edges.equalToSuperview()
            }
        }

        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(AssetHeaderViewH)
            make.width.equalTo(view)
        }

        scrollView.addSubview(sectionView)
        sectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(AssetSectionViewH)
            make.width.equalTo(view)
        }
        sectionView.restrictedIconTapHandler = { [weak self] in
            self?.showRestrctedInfoDoubt()
        }

        pageVC.setViewControllers([viewControllers[tmpChildVCIndex]], direction: .forward, animated: false, completion: nil)
        addChild(pageVC)
        scrollView.addSubview(pageVC.view)
        let tabbarHeight = (navigationController?.tabBarController?.tabBar.frame.size.height ?? 0)
        pageVC.view.snp.makeConstraints { make in
            make.top.equalTo(sectionView.snp.bottom).offset(0)
            make.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(view)
            make.height.equalTo(kUIScreenHeight - 70 - tabbarHeight - CGFloat(AssetSectionViewH))
        }
        //        self.updatePageViewConstraint(headerHide: false)

        pageVC.didScrolling = { offset in
            //self?.sectionView.changingOffset(offset: offset, currentIndex: (self?.pageViewCurrentIndex)!,draging: (self?.pageVC.pagesScrollview?.isDragging)!)

        }

        sendVC.delegate = self
        transactionVC.delegate = self
        sectionView.onSelectItem = { [weak self] (index) -> Bool in
            if index == 1 && NetworkManager.shared.reachabilityManager?.isReachable == false {
                self?.onScan()
                return false
            }
            let target = self?.viewControllers[index]

            if (self?.pageViewCurrentIndex)! < index {
                //self?.pageVC.goToNextPage()
                self?.pageVC.setViewControllers([target!], direction: .forward, animated: true, completion: nil)
            } else if (self?.pageViewCurrentIndex)! > index {
                //self?.pageVC.goToPreviousPage()
                self?.pageVC.setViewControllers([target!], direction: .reverse, animated: true, completion: nil)
            }
            self?.pageViewCurrentIndex = index
            return true

        }

        sectionView.onWalletAvatarTapAction = { [weak self] in
            guard let self = self, let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }
            let detailVC = WalletManagerDetailViewController()
            detailVC.wallet = wallet
            detailVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        sectionView.onLockedBalanceTapAction = { [weak self] in
            self?.showMessage(text: Localized("wallet_balance_restricted_doubt"), delay: 2.0)
        }

        assetHeaderStyle = (false, false)

        NotificationCenter.default.addObserver(self, selector: #selector(OnBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateWalletStatus), name: Notification.Name.ATON.DidNetworkStatusChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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

    @objc func shouldUpdateWalletStatus() {
        headerView.updateWalletStatus()
        sectionView.updateSendTabUIStatus()
        updatePageControllerDataSource()
        resetCurrentTab()
    }

    func resetCurrentTab() {
        if NetworkManager.shared.reachabilityManager?.isReachable == false && pageViewCurrentIndex == 1 {
            AssetViewControllerV060.setPageViewController(index: 0)
        }
    }

    // 禁用UIPageController 在离线状态下的拖动手势
    func updatePageControllerDataSource() {
        if NetworkManager.shared.reachabilityManager?.isReachable == false {
            pageVC.dataSource = nil
        } else {
            pageVC.dataSource = self
        }
    }

    @objc func fetchData() {
        updateWalletList()
        //        transactionVC.fetchTransactionLastest()
    }

    func endFetchData() {
        refreshHeader.endRefreshing()
    }

    func checkAndSetNoWalletViewStyle() {

        if AssetVCSharedData.sharedData.walletList.count == 0 {
            sectionView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            sectionView.setSectionSelectedIndex(index: 0)
            sectionView.isHidden = true
            scrollView.isScrollEnabled = false
            pageVC.pagesScrollview?.isScrollEnabled = false
            transactionVC.tableNodataHolderView.imageView.image = UIImage(named: "empty_no_wallet_icon")
        } else {
            sectionView.snp.updateConstraints { (make) in
                make.height.equalTo(AssetSectionViewH)
            }
            sectionView.isHidden = false
            scrollView.isScrollEnabled = true
            pageVC.pagesScrollview?.isScrollEnabled = true
            transactionVC.tableNodataHolderView.imageView.image = UIImage(named: "empty_no_data_img")
        }
    }

    func initData() {
        AssetVCSharedData.sharedData.reloadWallets()
    }

    //hide animate
    var assetHeaderStyle: (hide: Bool, animated: Bool)? {
        didSet {
            let hide = assetHeaderStyle?.0 ?? false

            if hide {
                //                scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH), animated: animated)
                sectionView.backgroundColor = .white
                DispatchQueue.main.async {
                    self.scrollView.isScrollEnabled = true
                }

                view.backgroundColor = .white
                sectionView.backgroundColor = .white
                sectionView.grayoutBackground.backgroundColor = .white
                sectionView.bottomSepline.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
            } else {
                sectionView.backgroundColor = UIColor(red: 247, green: 250, blue: 255, alpha: 1)

                //                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
                DispatchQueue.main.async {
                    self.scrollView.isScrollEnabled = true
                }
                view.backgroundColor = .white
                sectionView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
                sectionView.grayoutBackground.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
                sectionView.bottomSepline.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9333333333, blue: 0.9568627451, alpha: 1)
            }

            transactionVC.setHeaderStyle(hide: hide)
            //            self.updatePageViewConstraint(headerHide: hide)

        }
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

extension AssetViewControllerV060: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        var curIndex: Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }

        if curIndex == 0 {
            return nil
        }
        curIndex -= 1
        tmpChildVCIndex = curIndex

        return viewControllers[curIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        var curIndex: Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }

        if curIndex == viewControllers.count - 1 {
            return nil
        }
        curIndex += 1
        tmpChildVCIndex = curIndex
        return viewControllers[curIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        for (index, obj) in viewControllers.enumerated() {
            if pageViewController.viewControllers!.first! == obj {
                self.pageViewCurrentIndex = index
            }
        }

        sectionView.didFinishAnimating(index: self.pageViewCurrentIndex)
    }
}

// MARK: - UIScrollViewDelegate

extension AssetViewControllerV060: UIScrollViewDelegate, ChildScrollViewDidScrollDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollview Didcroll:\(scrollView.contentOffset.y)")

        //let rec = sectionView.convert(sectionView.bounds, to: view)
        //print("sectionView y:\(rec.origin.y)")
        if (!scrollEnable || scrollView.contentOffset.y >= CGFloat(AssetHeaderViewH)) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH - 20), animated: false)
            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH), animated: false)
            }
            if !(self.assetHeaderStyle?.hide)! {
                self.assetHeaderStyle = (true, false)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func childScrollViewDidScroll(childScrollView: UIScrollView) {
        let yoffset = childScrollView.contentOffset.y
        if yoffset <= 0 {
            scrollEnable = true
            childScrollView.setContentOffset(.zero, animated: false)
        } else {
            let rec = sectionView.convert(sectionView.bounds, to: view)
            if scrollEnable && rec.origin.y > 0 && !(self.assetHeaderStyle?.hide)! {
                childScrollView.setContentOffset(.zero, animated: false)
            } else {
                //                scrollEnable = false
            }
        }
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
            sectionView.setSectionSelectedIndex(index: 1)
            sendVC.walletAddressView.textField.text = data
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
        sendVC.resetTextFieldAndButton()
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
            let from = qrcode.from else { return }
        for (index, signature) in signatureArr.enumerated() {
            let bytes = signature.hexToBytes()
            let rlpItem = try? RLPDecoder().decode(bytes)

            if
                let signedTransactionRLP = rlpItem,
                let signedTransaction = try? EthereumSignedTransaction(rlp: signedTransactionRLP) {
                AssetViewControllerV060.getInstance()?.showLoadingHUD()
                web3.platon.sendRawTransaction(transaction: signedTransaction) { (response) in
                    AssetViewControllerV060.getInstance()?.hideLoadingHUD()
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

                    let thTx = TwoHourTransaction()
                    thTx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                    thTx.to = to.add0x().lowercased()
                    thTx.from = from.add0x().lowercased()
                    thTx.value = amount
                    
                    switch response.status {
                    case .success:
                        TransferPersistence.add(tx: tx)
                        TwoHourTransactionPersistence.add(tx: thTx)
                        if index == signatureArr.count - 1 {
                            DispatchQueue.main.async {
                                getInstance()?.doShowTransactionDetail(tx)
                            }
                        }
                    case .failure(let err):
                        switch err {
                        case .reponseTimeout:
                            TransferPersistence.add(tx: tx)
                            TwoHourTransactionPersistence.add(tx: thTx)
                            if index == signatureArr.count - 1 {
                                DispatchQueue.main.async {
                                    getInstance()?.doShowTransactionDetail(tx)
                                }
                            }
                        case .requestTimeout:
                            getInstance()?.showErrorMessage(text: Localized("RPC_Response_connectionTimeout"), delay: 2.0)
                        default:
                            getInstance()?.showErrorMessage(text: err.message)
                        }
                    }
                }
            }
        }
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

        vc.scrollView.isScrollEnabled = enable
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
        vc.sectionView.setSectionSelectedIndex(index: index)
    }

    static func reloadTransactionList() {
        guard let vc = self.getInstance() else {
            return
        }
        //wait for db writing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            vc.transactionVC.refreshData()
        }
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
        if textFiled == sendVC.amountView.textField {
            self.assetHeaderStyle = (true, true)
        } else if textFiled == sendVC.walletAddressView.textField {
            self.assetHeaderStyle = (true, true)
        }
    }

    ///keyboard notification
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

    @objc func updateWalletList() {
        headerView.shouldUpdateWalletList()

        AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
        sendVC.refreshData()
        transactionVC.refreshData()
        self.checkAndSetNoWalletViewStyle()
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
