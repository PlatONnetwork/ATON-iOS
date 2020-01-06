//
//  RewardRecordViewController.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import MJRefresh
import Localize_Swift

class RewardRecordViewController: BaseViewController {

    var listData: [RewardModel] = [] {
        didSet {
            tableView.mj_footer.isHidden = listData.count == 0
        }
    }

    let listSize: Int = 20

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(RewardRecordCell.self, forCellReuseIdentifier: "RewardRecordCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchDataLastest))!
        return header
    }()

    lazy var refreshFooter: MJRefreshFooter = {
        let footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(fetchDataMore))!
        return footer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = normal_background_color
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"empty_no_data_img") as? TableViewNoDataPlaceHolder
            holder?.descriptionLabel.text = Localized("empty_string_delegation_record")
            view.customView(holder)
            view.isScrollAllowed(true)
        }

        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.mj_header.beginRefreshing()
    }

}

extension RewardRecordViewController {
    private func fetchData(sequence: String, direction: RefreshDirection) {

        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.address }
        guard addresses.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            return
        }

        tableView.mj_header.endRefreshing()
        tableView.mj_footer.endRefreshing()

        let subItem1 = RewardRecordModel(nodeId: "0x4198419840", nodeName: "opppp", reward: "890000000000000000")
        let subItem2 = RewardRecordModel(nodeId: "0x141084391849", nodeName: "faklfjka", reward: "1888700000000000")
        let subItem3 = RewardRecordModel(nodeId: "0x19192391313", nodeName: "fadfka", reward: "890000000000000000")

        let item1 = RewardModel(address: "0x349184148948", totalReward: "88881431340000000000", records: [subItem1, subItem2, subItem3], isOpen: false)
        let item2 = RewardModel(address: "0x349184148948", totalReward: "88881431340000000000", records: [subItem1], isOpen: false)

        listData.append(item1)
        listData.append(item2)
        tableView.reloadData()

//        TransactionService.service.getDelegateRecord(
//            addresses: addresses,
//            beginSequence: sequence,
//            listSize: listSize,
//            direction: direction.rawValue,
//            type: recordType.rawValue) { [weak self] (result, data) in
//                self?.tableView.mj_header.endRefreshing()
//                self?.tableView.mj_footer.endRefreshing()
//
//                switch result {
//                case .success:
//                    if direction == .new {
//                        self?.listData.removeAll()
//                    }
//
//                    if let newData = data as? [Transaction], newData.count > 0 {
//
//                        _ = newData.map({ (tx) -> Transaction in
//                            switch tx.txType! {
//                            case .delegateWithdraw,
//                                 .stakingWithdraw:
//                                tx.direction = .Receive
//                                return tx
//                            default:
//                                tx.direction = .Sent
//                                return tx
//                            }
//                        })
//
//                        self?.listData.append(contentsOf: newData)
//                        self?.tableView.mj_footer.resetNoMoreData()
//                    } else {
//                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
//                    }
//
//                    self?.tableView.reloadData()
//
//                case .fail:
//                    self?.tableView.mj_footer.isHidden = true
//                    break
//                }
//        }
    }

    @objc func fetchDataLastest() {
        fetchData(sequence: "0", direction: .new)
    }

    @objc func fetchDataMore() {
//        guard let sequence = listData.last?.sequence else {
//            tableView.mj_footer.endRefreshingWithNoMoreData()
//            return
//        }
//        fetchData(sequence: String(sequence), direction: .old)
    }
}

extension RewardRecordViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardRecordCell") as! RewardRecordCell
        cell.reward = listData[indexPath.row]
        cell.recordDetailDidHadler = { [weak self] _ in
            if var reward = self?.listData[indexPath.row] {
                reward.isOpen = !reward.isOpen
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }

//        cell.transaction = transaction
//        cell.cellDidHandler = { [weak self] _ in
//            let controller = TransactionDetailViewController()
//            controller.transaction = transaction
//            self?.navigationController?.pushViewController(controller, animated: true)
//        }
        return cell
    }
}
