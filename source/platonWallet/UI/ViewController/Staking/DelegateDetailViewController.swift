//
//  DelegateDetailViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import MJRefresh
import BigInt

enum RefreshDirection: String {
    case new = "new"
    case old = "old"
}

class DelegateDetailViewController: BaseViewController {

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeAboutDelegateTableViewCell.self, forCellReuseIdentifier: "NodeAboutDelegateTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        tbView.mj_header = refreshHeader
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    let walletHeaderView = WalletBaseInfoView()

    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()

    var delegate: Delegate?
    var totalDelegate: TotalDelegate?
    var listData: [DelegateDetail] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.leftNavigationTitle = "delegate_detail_title"

        view.backgroundColor = normal_background_color

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"3.img-No trust") as? TableViewNoDataPlaceHolder
            holder?.descriptionLabel.text = Localized("delegate_node_details_nodata")
            view.customView(holder)
            view.isScrollAllowed(true)
            if let contentInset = self?.tableView.contentInset {
                view.verticalOffset(-contentInset.top/2.0)
            }
        }

        tableView.tableHeaderView = walletHeaderView
        walletHeaderView.setNeedsLayout()
        walletHeaderView.layoutIfNeeded()
        walletHeaderView.frame.size = walletHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = walletHeaderView

        let doubtButtonItem = UIBarButtonItem(image: UIImage(named: "3.icon_doubt"), style: .done, target: self, action: #selector(doubtTapAction))
        doubtButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = doubtButtonItem

        setupWalletData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.DelegateDetailViewController, presentedVC: self)
        tableView.mj_header.beginRefreshing()
    }
}

extension DelegateDetailViewController {

    private func gotoDelgateController(_ dDetail: DelegateDetail) {
//        guard
//            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == delegate?.walletAddress.lowercased() }),
//            let lockValue = BigUInt(balance.lock ?? "0"),
//            let freeValue = BigUInt(balance.free ?? "0"),
//            lockValue + freeValue > BigUInt.zero else {
//                showMessage(text: Localized("error_wallet_no_balance"))
//                return
//        }

        let controller = DelegateViewController()
        controller.currentNode = dDetail.delegateToNode()
        controller.currentAddress = delegate?.walletAddress
        navigationController?.pushViewController(controller, animated: true)
    }

    private func gotoWithdrawController(_ dDetail: DelegateDetail) {
        let controller = WithDrawViewController()
        controller.currentNode = dDetail.delegateToNode()
        controller.currentAddress = delegate?.walletAddress
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openWebSiteController(_ linkUrl: String?) {
        guard let url = linkUrl else { return }
        let controller = WebCommonViewController()
        controller.requestUrl = url
        navigationController?.pushViewController(controller, animated: true)
    }

    private func setupWalletData() {
        walletHeaderView.nodeAvatarIV.image = delegate?.walletAvatar ?? UIImage(named: "walletAvatar_1")
        walletHeaderView.nodeNameLabel.text = delegate?.walletName ?? "--"
        walletHeaderView.nodeAddressLabel.text = delegate?.walletAddress.addressForDisplay() ?? "--"
    }

    @objc private func fetchData() {
        guard let del = delegate else {
            tableView.mj_header.endRefreshing()
            return
        }

        StakingService.sharedInstance.getDelegateDetail(address: del.walletAddress) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()

            switch result {
            case .success:
                self?.listData.removeAll()

                if let tDelegate = data as? TotalDelegate {
                    self?.totalDelegate = tDelegate

                    self?.walletHeaderView.rewardRatioLabel.text = tDelegate.availableDelegationBalanceValue
                    self?.walletHeaderView.totalRewardLabel.text = tDelegate.delegatedValue

                    if let newData = tDelegate.item, newData.count > 0 {
                        self?.listData.append(contentsOf: newData)
                    }
                }
                self?.tableView.reloadData()
            case .fail:
                break
            }
        }
    }
}

extension DelegateDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeAboutDelegateTableViewCell") as! NodeAboutDelegateTableViewCell
        let delegateDetail = self.listData[indexPath.row]
        cell.delegateDetail = delegateDetail
        cell.delegateButton.isEnabled = delegateDetail.isExistWallet(address: delegate!.walletAddress)
        cell.delegateButton.isSelected = delegateDetail.isInit || (delegateDetail.nodeStatus == .Exiting || delegateDetail.nodeStatus == .Exited)
        cell.delegateButton.backgroundColor = delegateDetail.isExistWallet(address: delegate!.walletAddress) && !delegateDetail.isInit && (delegateDetail.nodeStatus == .Active || delegateDetail.nodeStatus == .Candidate) ? UIColor.white : UIColor(rgb: 0xDCDFE8, alpha: 0.4)
        cell.withDrawButton.isEnabled = delegateDetail.isExistWallet(address: delegate!.walletAddress)
        cell.withDrawButton.backgroundColor = delegateDetail.isExistWallet(address: delegate!.walletAddress) ? UIColor.white : UIColor(rgb: 0xDCDFE8, alpha: 0.4)

        cell.didLinkHanlder = { [weak self] _ in
            self?.openWebSiteController(delegateDetail.website)
        }
        cell.didDelegateHandler = { [weak self] _ in
            if delegateDetail.nodeStatus == .Exited || delegateDetail.nodeStatus == .Exiting {
                return
            }
            if delegateDetail.isInit {
                self?.showMessage(text: Localized("staking_validator_isInit_doubt"))
                return
            }
            self?.gotoDelgateController(delegateDetail)
        }
        cell.didWithdrawHandler = { [weak self] _ in
            self?.gotoWithdrawController(delegateDetail)
        }
        return cell
    }
}

extension DelegateDetailViewController {
    @objc private func doubtTapAction() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10

        let releaseTitleAttr = NSAttributedString(string: Localized("staking_alert_released_delegate") + "\n", attributes: [NSAttributedString.Key.foregroundColor: text_blue_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let releaseDetailAttr = NSAttributedString(string: Localized("staking_alert_released_detail") + "\n", attributes: [NSAttributedString.Key.foregroundColor: common_darkGray_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.paragraphStyle: paragraphStyle])

        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithText(attributedStrings: [releaseTitleAttr, releaseDetailAttr])
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
}
