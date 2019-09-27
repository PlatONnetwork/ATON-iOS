//
//  TransferInfoViewController.swift
//  platonWallet
//
//  Created by matrixelement on 26/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class TransactionDetailViewController: BaseViewController {
    
    public var transaction : Transaction?
    
    var listData: [(title: String, value: String)] = []
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "TransactionDetailTableViewCell")
        tbView.separatorStyle = .none
        tbView.tableFooterView = UIView()
        return tbView
    }()
    
    lazy var transferDetailView = { () -> TransactionDetailHeaderView in
        let view = TransactionDetailHeaderView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "TransactionDetailVC_nav_title"
        initData()
        initSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name:Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didReceiveTransactionUpdate(_ notification: Notification){
        guard let hash = notification.object as? String  else {
            return
        }
        //yujinghan waiting fix
        if hash.ishexStringEqual(other: transaction?.txhash){
            let tx = TransferPersistence.getByTxhash(transaction?.txhash)
            guard let transaction = tx else { return }
            DispatchQueue.main.async { [weak self] in
                self?.transferDetailView.updateContent(tx: transaction)
            }
        }
    }
    
    func initData() {
        guard let tx = transaction, let txType = tx.txType else { return }
        
        if tx.txType == .unknown || tx.txType == .transfer {
            listData.append((title: Localized("TransactionDetailVC_type"), value: tx.transactionStauts.localizeTitle))
        } else {
            listData.append((title: Localized("TransactionDetailVC_type"), value: txType.localizeTitle))
        }
        
        listData.append((title: Localized("TransactionDetailVC_time"), value: tx.timeString))
        
        if txType == .transfer ||
           txType == .MPCtransaction ||
           txType == .contractCreate ||
           txType == .contractExecute ||
           txType == .otherSend ||
           txType == .otherReceive ||
           txType == .createRestrictingPlan {
            
            if txType == .createRestrictingPlan {
                listData.append((title: Localized("TransactionDetailVC_restricted_acount"), value: tx.lockAddress ?? "--"))
                listData.append((title: Localized("TransactionDetailVC_restricted_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0"))
            } else {
                listData.append((title: Localized("TransactionDetailVC_value"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0"))
            }
        } else if txType == .delegateCreate ||
                  txType == .delegateWithdraw {
            listData.append((title: Localized("TransactionDetailVC_delegated_to"), value: tx.toNameString ?? "--"))
            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--"))
            if txType == .delegateCreate {
                listData.append((title: Localized("TransactionDetailVC_delegated_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--"))
            } else {
                listData.append((title: Localized("TransactionDetailVC_withdrawal_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--"))
            }
        } else if txType == .stakingCreate ||
                  txType == .stakingAdd ||
                  txType == .stakingEdit ||
                  txType == .stakingWithdraw ||
                  txType == .reportDuplicateSign ||
                  txType == .declareVersion {
            
            if txType == .reportDuplicateSign {
                listData.append((title: Localized("TransactionDetailVC_reported"), value: tx.nodeName ?? "--"))
            } else {
                listData.append((title: Localized("TransactionDetailVC_voteFor"), value: tx.nodeName ?? "--"))
            }
            
            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--"))
            
            if txType == .stakingCreate ||
               txType == .declareVersion {
                listData.append((title: Localized("TransactionDetailVC_version"), value: tx.version ?? "--"))
            }
            
            if txType != .declareVersion {
                if txType == .reportDuplicateSign {
                    listData.append((title: Localized("TransactionDetailVC_report_type"), value: tx.reportType ?? "--"))
                } else {
                    if txType == .stakingWithdraw {
                        listData.append((title: Localized("TransactionDetailVC_return_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--"))
                    } else if txType == .stakingAdd {
                        listData.append((title: Localized("TransactionDetailVC_stake_add_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--"))
                    } else {
                        listData.append((title: Localized("TransactionDetailVC_stake_amount"), value: tx.valueDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "--"))
                    }
                }
            }
        } else if txType == .submitText ||
                  txType == .submitParam ||
                  txType == .submitVersion ||
                  txType == .voteForProposal {
            listData.append((title: Localized("TransactionDetailVC_voteFor"), value: tx.nodeName ?? "--"))
            listData.append((title: Localized("TransactionDetailVC_nodeId"), value: tx.nodeId ?? "--"))
            listData.append((title: Localized("TransactionDetailVC_proposal_id"), value: tx.txhash ?? "--"))
            listData.append((title: Localized("TransactionDetailVC_proposal_pip"), value: tx.pipString))
            
            if txType == .voteForProposal {
                listData.append((title: Localized("TransactionDetailVC_proposal_type"), value: tx.voteProposalType?.localizedDesciption ?? "--"))
                listData.append((title: Localized("TransactionDetailVC_proposal_vote"), value: tx.vote?.localizedDesciption ?? "--"))
            } else {
                listData.append((title: Localized("TransactionDetailVC_proposal_type"), value: tx.proposalType?.localizedDesciption ?? "--"))
            }
        }
        listData.append((title: Localized("TransactionDetailVC_energon_price"), value: tx.actualTxCostDescription?.displayForMicrometerLevel(maxRound: 8).ATPSuffix() ?? "0"))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailTableViewCell") as! TransactionDetailTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = listData[indexPath.row].title
        cell.valueLabel.text = listData[indexPath.row].value
        return cell
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
