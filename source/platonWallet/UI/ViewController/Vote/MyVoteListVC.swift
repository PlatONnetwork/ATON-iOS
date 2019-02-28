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
    
    var headerView : NodeVoteHeader?
    
    var dataSource: [NodeVoteSummary] = []
    
    var candidateDetailDic:[String:CandidateBasicInfo] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveVoteTransactionUpdate(_:)), name:NSNotification.Name(DidUpdateVoteTransactionByHashNotification) , object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
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
        
        self.navigationItem.localizedText = "MyVoteListVC_nav_title"
        
        view.backgroundColor = UIViewController_backround
        
        headerView = UIView.viewFromXib(theClass: NodeVoteHeader.self) as? NodeVoteHeader
        view.addSubview(headerView!)
        headerView!.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(70)
        }
        
        
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(headerView!.snp.bottom)
        }

        tableView.registerCell(cellTypes: [NodeVoteTableViewCell.self])
        
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("MyVoteListVC_Empty_tips")))
        }
    }
    
    
    func getData(showLoading: Bool = true) {
        
        if showLoading {
            self.showLoading()
        }
        
        VoteManager.sharedInstance.getMyVoteList { [weak self] (result, data) in
            
            guard let self = self else { return }
            
            if showLoading {
                self.hideLoading()
            }
            
            switch result{
                
            case .success:
                
                guard data != nil else {
                    return
                }
                
                guard let summary = data as? [NodeVoteSummary], summary.count > 0 else {
                    return
                }
                
                var empty = true
                for s in summary {
                    if s.tickets.count > 0 {
                        empty = false
                        break
                    }
                }
                guard !empty else {
                    return
                }
                
                self.dataSource = summary
                
                let nodeIds = summary.map({ (node) -> String in
                    return node.CandidateId ?? ""
                })
                self.getCandidateDetail(ids: nodeIds)
                
                self.tableView.reloadData()
                self.tableView.removeEmptyView()
                self.updateTableHeaderVote()
     
            case .fail(let ret, let msg):
                self.showMessage(text: "getMyVoteList fail:\(ret ?? 0),\(msg ?? "")", delay: 3)
            }
        }
        
    }
    
    
    
    func updateTableHeaderVote(){
        headerView?.updateView(dataSource)
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
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let voteDetail = SingleVoteDetailListVC()
        let summary = dataSource[indexPath.row]
        voteDetail.candidate = candidateDetailDic[summary.CandidateId!]
        voteDetail.tickets = summary.tickets
        navigationController?.pushViewController(voteDetail, animated: true)
    }
    
    //MARK: - UIButton Action
    
    @objc func onVote(_ sender: UIButton){
        
        showLoading()
        
        VoteManager.sharedInstance.CandidateDetails(candidateId: dataSource[sender.tag].CandidateId!) { [weak self] (res, data) in
            
            guard let self = self else { return }
            
            self.hideLoading()
            
            switch res{
            case .success:
                guard let candidate = data as? Candidate, candidate.candidateId == self.dataSource[sender.tag].CandidateId else {
                    self.showMessage(text: "data parse error", delay: 3)
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
