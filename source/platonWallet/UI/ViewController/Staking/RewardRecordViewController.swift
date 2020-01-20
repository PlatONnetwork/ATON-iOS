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
        super.leftNavigationTitle = "mydelegates_claim_record"
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
    private func fetchData(sequence: Int, direction: RefreshDirection) {

        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.address }
        guard addresses.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            return
        }

        StakingService.sharedInstance.getRewardDelegate(adddresses: addresses, beginSequence: sequence, listSize: listSize, direction: direction.rawValue) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()

            switch result {
            case .success:
                if direction == .new {
                    self?.listData.removeAll()
                }

                if let rewards = data as? [RewardModel], rewards.count > 0 {
                    self?.listData.append(contentsOf: rewards)

                    self?.tableView.mj_footer.resetNoMoreData()
                } else {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self?.tableView.reloadData()
            case .fail(_, let errMsg):
                self?.tableView.mj_footer.isHidden = true
                self?.showErrorMessage(text: errMsg ?? "get data error")
            }
        }
    }

    @objc func fetchDataLastest() {
        fetchData(sequence: -1, direction: .new)
    }

    @objc func fetchDataMore() {
        guard let sequence = listData.last?.sequence else {
            tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        print("sequence: \(sequence)")
        fetchData(sequence: sequence, direction: .old)
    }
}

extension RewardRecordViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardRecordCell") as! RewardRecordCell
        cell.reward = listData[indexPath.row]
        cell.cellDidHandler = { [weak self] _ in
            if let reward = self?.listData[indexPath.row] {
                reward.isOpen = !reward.isOpen
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        return cell
    }
}
