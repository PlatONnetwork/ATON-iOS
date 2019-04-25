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

class MyVoteListVC: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    let tableView = UITableView()
    
    var headerView : NodeVoteHeader? = UIView.viewFromXib(theClass: NodeVoteHeader.self) as? NodeVoteHeader
    
    var dataSource: [NodeVoteSummary] = []
    
    var candidateDetailDic:[String:CandidateBasicInfo] = [:]
    
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
    
    func getCandidateDetail(ids: [String]) {
        for id in ids {
            self.candidateDetailDic[id] = VotePersistence.getCandidateInfoWithId(id)
        }
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
    }
    
    
    func getData(showLoading: Bool = true) {
        
        if showLoading {
            self.showLoadingHUD()
        }
        
        let addressStrs = AssetVCSharedData.sharedData.walletList.filterClassicWallet.map { cwallet in
            return cwallet.key!.address
        }
        if addressStrs.count > 0{
            VoteManager.sharedInstance.getBatchVoteSummary(addressList: addressStrs) {[weak self] (result, resp) in
                switch result{
                    
                case .success:
                    if let sum = resp as? MyVoteStatic{
                        self?.headerView?.updateView(sum)
                    }
                case .fail(_, _):
                    do{}
                }
            }
        }
        
        VoteManager.sharedInstance.getMyVoteList(localDataCompletion: {[weak self] (result, data) in
            guard let self = self else { return }
            //default is success
            /*
            if let summaries = data as? [NodeVoteSummary]{
                if showLoading && summaries.count > 0{
                    self.hideLoadingHUD()
                }
                self.reloadWhenSuccessed(summaries: summaries)
            }
             */
            
        }) {[weak self] (result, data) in
            guard let self = self else { return }
            
            if showLoading {
                self.hideLoadingHUD()
            }
            
            switch result{
                
            case .success: 
                guard data != nil, let summary = data as? [NodeVoteSummary], summary.count > 0 else {
                    return
                }
                self.reloadWhenSuccessed(summaries: summary)
                
            case .fail(_, let msg):
                self.showMessage(text: "\(msg ?? "")", delay: 3)
            }
        }
        
    }
    
    func reloadWhenSuccessed(summaries: [NodeVoteSummary]){
        self.dataSource = summaries
        let nodeIds = summaries.map({ (node) -> String in
            return node.CandidateId ?? ""
        }) 
        self.getCandidateDetail(ids: nodeIds)
        self.tableView.reloadData()
        self.tableView.removeEmptyView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : NodeVoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: NodeVoteTableViewCell.self)) as! NodeVoteTableViewCell
        let summary = dataSource[indexPath.row]
        cell.updateCell(nodeVote: summary, candidate: candidateDetailDic[summary.CandidateId ?? ""]!)
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
        let summary = dataSource[indexPath.row]
        voteDetail.candidate = candidateDetailDic[summary.CandidateId!]
        voteDetail.voteSum = summary
        navigationController?.pushViewController(voteDetail, animated: true)
    } 
    
    //MARK: - UIButton Action
    
    @objc func onVote(_ sender: UIButton){
        
        showLoadingHUD()

        VoteManager.sharedInstance.GetCandidateDetails(candidateId: dataSource[sender.tag].CandidateId!) { [weak self] (res, data) in
            self?.hideLoadingHUD()
            guard let self = self else { return }
            switch res{
            case .success:
                guard let candidate = data as? Candidate, candidate.candidateId == self.dataSource[sender.tag].CandidateId else {
                    self.showMessage(text: Localized("data_parser_error"), delay: 3)
                    return
                }
                let voteVC = VotingViewController0()
                voteVC.candidate = candidate
                self.navigationController?.pushViewController(voteVC, animated: true)
            default:
                self.showMessage(text: "failed", delay: 3)
                break
            }
            
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
