//
//  SingleVoteDetailListVC.swift
//  platonWallet
//
//  Created by Ned on 27/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SingleVoteDetailListVC : BaseViewController, UITableViewDelegate,UITableViewDataSource {

    let tableView = UITableView()
    
    var tableViewHeader : VoteDetailHeader?
    
    var candidate : CandidateBasicInfo?
    
    var voteSum : NodeVoteSummary?
    
    var dataSource : [SingleVote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initData()
    }
    
    @objc func onNavigationLeft(){
        
    }
    
    func initSubViews() {
        
        super.leftNavigationTitle = "SingleVoteDetailListVC_nav_title"
        
        view.backgroundColor = UIViewController_backround
        
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = (self as UITableViewDataSource)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        tableView.registerCell(cellTypes: [VoteDetailCell.self])
        tableView.tableHeaderView = tableviewHeader()
        
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("MyVoteListVC_Empty_tips"),"empty_no_data_img"))
        }
    }
    
    func tableviewHeader() -> VoteDetailHeader? {
        if tableViewHeader == nil{
            tableViewHeader = UIView.viewFromXib(theClass: VoteDetailHeader.self) as? VoteDetailHeader
        }
        return tableViewHeader
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let header = tableviewHeader()

        //var height = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var newFrame = header?.frame
        newFrame?.size.height = 124
        header?.frame = newFrame!
        tableView.tableHeaderView = header
    }
    
    func initData(){
        
        
        guard let candidate = candidate else {
            return
        }
        tableViewHeader?.updateView(candidate)
        dataSource.removeAll()
        let singlevotes = voteSum?.singleVote as! [SingleVote]
        dataSource.append(contentsOf: singlevotes)
  
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : VoteDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: VoteDetailCell.self)) as! VoteDetailCell

        cell.updateCell(singleVote: dataSource[indexPath.section])

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return 226
        return 252
    }
    
    
    //MARK: - UIButton Action
    
    @objc func onVote(){
        let voteVC = VotingViewController0()
        navigationController?.pushViewController(voteVC, animated: true)
    }

}
