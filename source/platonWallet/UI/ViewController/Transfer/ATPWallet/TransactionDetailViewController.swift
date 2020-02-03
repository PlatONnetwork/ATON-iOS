//
//  TransferInfoViewController.swift
//  platonWallet
//
//  Created by matrixelement on 26/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class TransactionDetailViewController: BaseViewController {

    var transaction: Transaction?
    var txSendAddress: String?

    var listData: [(title: String, value: String, copy: Bool)] = []

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "TransactionDetailTableViewCell")
        tbView.register(TransactionDetailHashTableViewCell.self, forCellReuseIdentifier: "TransactionDetailHashTableViewCell")
        tbView.separatorStyle = .none
        tbView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 40
        }
        return tbView
    }()

    lazy var transferDetailView = { () -> TransactionDetailHeaderView in
        let view = TransactionDetailHeaderView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "TransactionDetailVC_nav_title"
        initObserver()
        initData()
        initSubViews()
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        guard let txStatus = notification.object as? TransactionsStatusByHash else { return }
        guard let currentTx = transaction else { return }
        guard let txhash = txStatus.hash, txhash.ishexStringEqual(other: currentTx.txhash), let status = txStatus.localStatus else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            if let senderAddress = self?.txSendAddress {
                switch currentTx.txType! {
                case .transfer:
                    currentTx.direction = (senderAddress.lowercased() == currentTx.from?.lowercased() ? .Sent : senderAddress.lowercased() == currentTx.to?.lowercased() ? .Receive : .unknown)
                case .delegateWithdraw,
                     .stakingWithdraw,
                     .claimReward:
                    currentTx.direction = .Receive
                default:
                    currentTx.direction = .Sent
                }
            }

            currentTx.txReceiptStatus = status.rawValue
            self?.transferDetailView.updateContent(tx: currentTx)
            self?.tableView.tableHeaderView = self?.transferDetailView
            self?.transferDetailView.setNeedsLayout()
            self?.transferDetailView.layoutIfNeeded()
            self?.transferDetailView.frame.size = self?.transferDetailView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? CGSize(width: UIScreen.main.bounds.width, height: 250)
            self?.tableView.tableHeaderView = self?.transferDetailView
        }
    }

    func initObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name: Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)
    }

    func initData() {
        guard let tx = transaction, let txType = tx.txType else { return }

        if tx.txType == .unknown || tx.txType == .transfer {
            if tx.direction == .unknown {
                listData.append((title: Localized("TransactionDetailVC_type"), value: txType.localizeTitle, copy: false))
            } else {
                listData.append((title: Localized("TransactionDetailVC_type"), value: tx.direction.localizedDesciption ?? txType.localizeTitle, copy: false))
            }
        } else {
            listData.append((title: Localized("TransactionDetailVC_type"), value: txType.localizeTitle, copy: false))
        }

        listData.append((title: Localized("TransactionDetailVC_time"), value: tx.timeString, copy: false))

        if txType == .transfer ||
           txType == .MPCtransaction ||
           txType == .contractCreate ||
           txType == .contractExecute ||
           txType == .otherSend ||
           txType == .otherReceive ||
           txType == .createRestrictingPlan {

            if txType == .createRestrictingPlan {
                listData.append((title: Localized("TransactionDetailVC_restricted_acount"), value: tx.lockAddress ?? "--", copy: false))
                listData.append((title: Localized("TransactionDetailVC_restricted_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0", copy: false))
            } else {
                listData.append((title: Localized("TransactionDetailVC_value"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0", copy: false))
            }
        } else if txType == .delegateCreate ||
                  txType == .delegateWithdraw {
            listData.append((title:  txType == .delegateCreate ? Localized("TransactionDetailVC_delegated_to") : Localized("TransactionDetailVC_withdraw_to"), value: tx.toNameString ?? "--", copy: false))
            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--", copy: false))
            listData.append((title: txType == .delegateCreate ? Localized("TransactionDetailVC_delegated_amount") : Localized("TransactionDetailVC_withdrawal_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--", copy: false))
            if let totalRewardBInt = BigUInt(tx.totalReward ?? "0"), totalRewardBInt > BigUInt.zero {
                listData.append((title: Localized("TransactionDetailVC_reward_amount"), value: tx.totalReward?.vonToLATString?.ATPSuffix() ?? "--", copy: false))
            }
        } else if txType == .stakingCreate ||
                  txType == .stakingAdd ||
                  txType == .stakingEdit ||
                  txType == .stakingWithdraw ||
                  txType == .reportDuplicateSign ||
                  txType == .declareVersion {

            if txType == .reportDuplicateSign {
                listData.append((title: Localized("TransactionDetailVC_reported"), value: tx.nodeName ?? "--", copy: false))
            } else {
                listData.append((title: Localized("TransactionDetailVC_voteFor"), value: tx.nodeName ?? "--", copy: false))
            }

            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--", copy: false))

            if txType == .stakingCreate ||
               txType == .declareVersion {
                listData.append((title: Localized("TransactionDetailVC_version"), value: tx.versionDisplayString, copy: false))
            }

            if txType != .declareVersion {
                if txType == .reportDuplicateSign {
                    listData.append((title: Localized("TransactionDetailVC_report_type"), value: tx.reportType?.localizedDesciption ?? "--", copy: false))
                } else {
                    if txType == .stakingWithdraw {
                        listData.append((title: Localized("TransactionDetailVC_return_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--", copy: false))
                    } else if txType == .stakingAdd {
                        listData.append((title: Localized("TransactionDetailVC_stake_add_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--", copy: false))
                    } else {
                        listData.append((title: Localized("TransactionDetailVC_stake_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--", copy: false))
                    }
                }
            }
        } else if txType == .submitText ||
                  txType == .submitParam ||
                  txType == .submitVersion ||
                  txType == .submitCancel ||
                  txType == .voteForProposal {
            listData.append((title: Localized("TransactionDetailVC_voteFor"), value: tx.nodeName ?? "--", copy: false))
            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--", copy: false))
            listData.append((title: Localized("TransactionDetailVC_proposal_id"), value: tx.proposalId ?? "--", copy: false))
            listData.append((title: Localized("TransactionDetailVC_proposal_pip"), value: tx.pipString, copy: false))

            if txType == .voteForProposal {
                listData.append((title: Localized("TransactionDetailVC_proposal_type"), value: tx.proposalType?.localizedDesciption ?? "--", copy: false))
                listData.append((title: Localized("TransactionDetailVC_proposal_vote"), value: tx.vote?.localizedDesciption ?? "--", copy: false))
            } else {
                listData.append((title: Localized("TransactionDetailVC_proposal_type"), value: tx.proposalType?.localizedDesciption ?? "--", copy: false))
            }
        } else if txType == .claimReward {
            listData.append((title: Localized("TransactionDetailVC_claim_wallet"), value: tx.fromNameString ?? "--", copy: false))
            listData.append((title: Localized("TransactionDetailVC_reward_amount"), value: (tx.totalReward?.vonToLATString ?? "0.00").ATPSuffix(), copy: false))
        }
        listData.append((title: Localized("TransactionDetailVC_energon_price"), value: tx.actualTxCostDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0", copy: false))
        listData.append((title: Localized("TransactionDetailVC_transaction_hash"), value: tx.txhash ?? "--", copy: true))
    }

    func initSubViews() {

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        transferDetailView.updateContent(tx: transaction!)
        tableView.tableHeaderView = transferDetailView
        transferDetailView.setNeedsLayout()
        transferDetailView.layoutIfNeeded()
        transferDetailView.frame.size = transferDetailView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = transferDetailView
    }
}

extension TransactionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if listData[indexPath.row].copy {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailHashTableViewCell") as! TransactionDetailHashTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = listData[indexPath.row].title
            cell.valueLabel.text = listData[indexPath.row].value
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailTableViewCell") as! TransactionDetailTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = listData[indexPath.row].title
            cell.valueLabel.text = listData[indexPath.row].value
            return cell
        }
    }

}

extension Transaction {
    var timeString: String {
        if confirmTimes != 0 {
            return Date.toStanderTimeDescrition(millionSecondsTimeStamp: confirmTimes) ?? "0"
        } else {
            return Date.toStanderTimeDescrition(millionSecondsTimeStamp: createTime) ?? "0"
        }
    }
}
