//
//  MyVoteListVC.swift
//  platonWallet
//
//  Created by Ned on 26/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import MJRefresh

class MyVoteListVC: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    let tableView = UITableView()
    
    var headerView : NodeVoteHeader? = UIView.viewFromXib(theClass: NodeVoteHeader.self) as? NodeVoteHeader
    
    var dataSource: [NodeVote] = []
    
    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        header.lastUpdatedTimeLabel.isHidden = true
        return header
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveVoteTransactionUpdate(_:)), name:NSNotification.Name(DidUpdateVoteTransactionByHashNotification) , object: nil)
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func didReceiveVoteTransactionUpdate(_ notify: Notification) {
        getData(showLoading: false)
    }
    
    
    @objc func onNavigationLeft(){
        
    }
    
    func initSubViews() {
        
        super.leftNavigationTitle = "MyVoteListVC_nav_title"
        
        view.backgroundColor = UIViewController_backround
        
        /*
        view.addSubview(headerView!)
        headerView!.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            maker.height.equalTo(88)
        }
        */
        
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalToSuperview()
            }
        }

        tableView.tableHeaderView = headerView
        headerView?.frame = CGRect(x: 0, y: 0, width: kUIScreenWidth, height: 88)
            
        tableView.registerCell(cellTypes: [NodeVoteTableViewCell.self])
        
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("MyVoteListVC_Empty_tips"),"empty_no_data_img"))
        }
        self.autoAdjustInset()
        
        tableView.mj_header = refreshHeader
        tableView.mj_header.beginRefreshing()
    }
    
    
    @objc func fetchData() {
        getData(showLoading: false)
    }
    
    func getData(showLoading: Bool = true) {
        
        
        let addressStrs = AssetVCSharedData.sharedData.walletList.filterClassicWallet.map { cwallet in
            return cwallet.key!.address
        }
        guard addressStrs.count > 0 else {
            return
        }

        VoteManager.sharedInstance.GetBatchMyVoteNodeList(addressList: addressStrs) { [weak self] (result, response) in
            guard let self = self else { return }
            
            self.refreshHeader.endRefreshing()
            switch result{
                
            case .success:
                guard response != nil, let nodeVoteResponse = response as? NoteVoteResponse, nodeVoteResponse.data.count > 0 else {
                    return
                }
                
                self.headerView?.updateView(nodeVoteResponse.voteStatic)
                self.reloadWhenSuccessed(nodeVotes: nodeVoteResponse.data)
                
            case .fail(_, let msg):
                self.showMessage(text: "\(msg ?? "")", delay: 3)
            }
        }
    }
    
    func reloadWhenSuccessed(nodeVotes: [NodeVote]){
        self.dataSource = nodeVotes
        let nodeIds = nodeVotes.map({ (node) -> String in
            return node.nodeId ?? ""
        })
        self.tableView.reloadData()
        self.tableView.removeEmptyView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : NodeVoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: NodeVoteTableViewCell.self)) as! NodeVoteTableViewCell
        let nodeVote = dataSource[indexPath.row]
        cell.updateCell(nodeVote: nodeVote)
        cell.voteBtn.tag = indexPath.row
        cell.voteBtn.addTarget(self, action: #selector(onVote(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let voteDetail = SingleVoteDetailListVC()
        voteDetail.nodeVote = dataSource[indexPath.row]
        navigationController?.pushViewController(voteDetail, animated: true)
    } 
    
    //MARK: - UIButton Action
    
    @objc func onVote(_ sender: UIButton){
        
        let res = VoteManager.sharedInstance.checkMyWalletBalanceIsEnoughToVote()
        guard res.canVote else {
            self.showMessage(text: res.errMsg, delay: 3)
            return
        }
        
        let vote = dataSource[sender.tag]
        let candidate = Candidate()
        candidate.candidateId = vote.nodeId
        candidate.name = vote.name
        
        let voteVC = VotingViewController0()
        voteVC.candidate = candidate
        voteVC.voteCompletion = { [weak self] in
            self?.tableView.mj_header.beginRefreshing()
        }
        self.navigationController?.pushViewController(voteVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
