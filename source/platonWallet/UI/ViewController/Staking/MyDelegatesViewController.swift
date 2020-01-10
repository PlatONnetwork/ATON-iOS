//
//  MyDelegatesViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import EmptyDataSet_Swift
import MJRefresh
import BigInt

class MyDelegatesViewController: BaseViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = IndicatorInfo(title: "staking_main_mydelegate_text")

    lazy var tableView = { () -> ATableView in
        let tbView = ATableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(MyDelegateViewCell.self, forCellReuseIdentifier: "MyDelegateViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    let headerView = MyDelegateHeaderView()
    lazy var footerView = { () -> MyDelegateFooterView in
        let fView = MyDelegateFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        fView.faqButton.addTarget(self, action: #selector(faqTapAction), for: .touchUpInside)
        fView.turButton.addTarget(self, action: #selector(tutorialTapAction), for: .touchUpInside)
        return fView
    }()

    lazy var refreshHeader = { () -> MJRefreshHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    var listData: [Delegate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height)
            make.bottom.leading.trailing.equalToSuperview()
        }

        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        headerView.frame.size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = headerView
        headerView.delegateRecordHandler = { [weak self] in
            self?.gotoDelegateRecordVC()
        }
        headerView.rewardRecordHandler = { [weak self] in
            self?.gotoRewardDetailVC()
        }

        tableView.tableFooterView = footerView

        let attributed = NSAttributedString(string: "empty_string_my_delegates_left")
        let actionAttributed = NSAttributedString(string: "empty_string_my_delegates_right", attributes: [NSAttributedString.Key.foregroundColor: common_blue_color])
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableview(forEmptyDataSet: (self?.tableView)!, [attributed, actionAttributed], "3.img-No trust") as? TableViewNoDataPlaceHolder
            holder?.textTapHandler = { [weak self] in
                self?.doShowValidatorListController()
            }
            view.customView(holder)
            view.isScrollAllowed(true)
            if let frame = self?.tableView.tableHeaderView?.frame {
                view.verticalOffset(frame.height/2.0)
            }
        }

        tableView.mj_header = refreshHeader

        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateDelegateData), name: Notification.Name.ATON.updateWalletList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name: Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdateDelegateData()
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.MyDelegatesViewController, presentedVC: UIApplication.shared.keyWindow?.rootViewController ?? self)
    }

    @objc func shouldUpdateDelegateData() {
        if AssetVCSharedData.sharedData.walletList.count == 0 {
            listData.removeAll()
            updateDelagateHeader()
            tableView.reloadData()
            return
        }
        tableView.mj_header.beginRefreshing()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func faqTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_faq_title")
        controller.requestUrl = AppConfig.H5URL.FAQURL.faqurl
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func tutorialTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_tutorial_title")
        controller.requestUrl = AppConfig.H5URL.TutorialURL.tutorialurl
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    func updateDelagateHeader() {
        guard listData.count > 0 else {
            headerView.totalDelegateLabel.text = "--"
            return
        }
        let total = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.delegated ?? "0")!
        }
        let totalReward = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.cumulativeReward ?? "0")!
        }
        let totalUnClaim = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.withdrawReward ?? "0")!
        }
        headerView.totalDelegateLabel.text = (total.description.vonToLATString ?? "0").ATPSuffix()
        headerView.totalRewardLabel.text = (totalReward.description.vonToLATString ?? "0").ATPSuffix()
        headerView.unclaimedRewardLabel.text = (totalUnClaim.description.vonToLATString ?? "0").ATPSuffix()
    }

    private func gotoDelegateRecordVC() {
        let viewController = DelegateRecordMainViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func gotoDelegateDetailVC(_ delegate: Delegate) {
        let controller = DelegateDetailViewController()
        controller.delegate = delegate
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func gotoRewardDetailVC() {
        let viewController = RewardRecordViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func doShowValidatorListController() {
        guard let tabController = self.parent as? StakingMainViewController else { return }
        tabController.moveToValidatorListController()
    }

    func claimRewardAction(_ indexPath: IndexPath) {
        showLoadingHUD()
        let delegate = listData[indexPath.row]
        TransactionService.service.getContractGas(from: delegate.walletAddress, txType: TxType.claimReward) { [weak self] (result, remoteGas) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let gas = remoteGas else {
                    self?.showErrorMessage(text: "get gas api error", delay: 2.0)
                    return
                }
                self?.showClaimConfirmView(delegate: delegate, gas: gas)
            case .fail(_, let errMsg):
                self?.showErrorMessage(text: errMsg ?? "get gas api error", delay: 2.0)
            }
        }

//        let confirmView = UIView.viewFromXib(theClass: TransferConfirmView.self) as! TransferConfirmView
//        confirmView.hideExecutor()
//        let unionAttr = NSAttributedString(string: " LAT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
//        let amountAttr = NSMutableAttributedString(string: amountView.textField.text!.displayForMicrometerLevel(maxRound: 8))
//        amountAttr.append(unionAttr)
//        confirmView.totalLabel.attributedText = amountAttr
//        confirmView.toAddressLabel.text = walletAddressView.textField.text!.addressDisplayInLocal() ?? "--"
//        confirmView.walletName.text = wallet.address.addressDisplayInLocal() ?? "--"
//        let feeString = self.totalFee().divide(by: ETHToWeiMultiplier, round: 8)
//        confirmView.feeLabel.text = feeString.ATPSuffix()
//        if wallet.type == .observed {
//            confirmView.submitBtn.localizedNormalTitle =  "confirm_button_next"
//        }
//

    }

    func showClaimConfirmView(delegate: Delegate, gas: RemoteGas) {
        let controller = PopUpViewController()
        let confirmView = RewardClaimComfirmView()
        confirmView.valueLabel.text = delegate.withdrawRewardValue
        confirmView.walletLabel.text = delegate.walletName
        confirmView.balanceLabel.text = delegate.freeBalanceValue
        confirmView.feeLabel.text = (gas.gasUsed.vonToLATString ?? "0.00").ATPSuffix()
        confirmView.comfirmBtn.style = (delegate.freeBalanceBInt >= gas.gasUsedBInt) ? .blue : .disable
        confirmView.onCompletion = { [weak self] in
            controller.onDismissViewController()
            self?.inputPasswordForClaimTransaction(delegate: delegate, gas: gas)
        }
        controller.setUpConfirmView(view: confirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
    }

    func inputPasswordForClaimTransaction(delegate: Delegate, gas: RemoteGas) {
        guard let wallet = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.first(where: { $0.address.lowercased() == delegate.walletAddress.lowercased() }) else {
            showMessage(text: "notfound wallet", delay: 2.0)
            return
        }

        if wallet.type == .observed {
            return
        }

        showPasswordInputPswAlert(for: wallet) { [weak self] (privateKey, _, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }
            self.sendClaimTransaction(delegate: delegate, gas: gas, privateKey: pri)
        }
    }

    func sendClaimTransaction(delegate: Delegate, gas: RemoteGas, privateKey: String) {
        showLoadingHUD()
        StakingService.sharedInstance.rewardClaim(from: delegate.walletAddress, privateKey: privateKey, gas: gas) { [weak self] (result, transaction) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let newTx = transaction else {
                    self?.showMessage(text: "not repsonse transaction object", delay: 2.0)
                    return
                }
                newTx.totalReward = delegate.withdrawReward
                TransferPersistence.add(tx: newTx)
                self?.tableView.mj_header.beginRefreshing()
            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg ?? "network error", delay: 2.0)
            }
        }
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        // 由于余额发生变化时会更新交易记录，因此，这里并需要再次更新

        guard let txStatus = notification.object as? TransactionsStatusByHash, let status = txStatus.localStatus, status != .pending else { return }
        tableView.mj_header.beginRefreshing()
    }
}

extension MyDelegatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyDelegateViewCell") as! MyDelegateViewCell
        let delegate = listData[indexPath.row]
        cell.delegate = delegate
        cell.cellDidHandle = { [weak self] tapCell in
            self?.gotoDelegateDetailVC(delegate)
        }
        cell.claimDidHandle = { [weak self] _ in
            self?.claimRewardAction(indexPath)
        }
        return cell
    }
}

extension MyDelegatesViewController {
    @objc func fetchData() {
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.address }
        guard addresses.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            return
        }

        StakingService.sharedInstance.getMyDelegate(adddresses: addresses) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()

            switch result {
            case .success:
                self?.listData.removeAll()
                if let newData = data as? [Delegate] {
                    self?.listData.append(contentsOf: newData)
                    self?.tableView.reloadData()
                    self?.updateDelagateHeader()
                }
                self?.tableView.reloadData()
            case .fail:
                break
            }
        }
    }
}

class ATableView: UITableView {
    override func reloadData() {
        super.reloadData()
        adjustTableFooterView()
    }

    func adjustTableFooterView() {
        if let footerView = tableFooterView {

            if frame.height > 0.0 {
                layoutIfNeeded()

                if contentSize.height < frame.height {
                    var tframe = footerView.frame
                    let height = max(80, frame.height - (contentSize.height - tframe.height))
                    if height != tframe.size.height {
                        tframe.size.height = height
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                } else if contentSize.height > frame.height {
                    var tframe = footerView.frame
                    if tframe.size.height != 80 {
                        tframe.size.height = 80
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                }
            }
        }
    }
}
