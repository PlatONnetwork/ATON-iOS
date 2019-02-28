//
//  CandidatesListViewController.swift
//  platonWallet
//
//  Created by juzix on 2018/12/25.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import platonWeb3

enum CandidatesListSortType: Int {
    case `default` = 0,reward,location
}


class CandidatesListViewController: BaseViewController {
    
    var headerView: CandidatesListHeaderView!
    var selectionView: CandidatesListSectionHeaderView!
    var tableView: UITableView!
    var sortType: CandidatesListSortType = .default
    var timer: Timer?
    
    var candidatesPool: [Candidate] = []
    var alternativePool: [Candidate] = []
    
    var originCandidatesList: [Candidate] = []
    var sortedCandidatesList: [Candidate] = []
    var filteredCandidateList: [Candidate] = []
    
    var isFirstQuery = true
    
    var dataSource: [Candidate] = [] {
        didSet {
            isFirstQuery = false
        }
    }
    
    var isQuerying = false
   
    var searchText = "" {
        didSet {
            guard sortedCandidatesList.count > 0 else {
                return
            }
            refreshTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localized("CandidateListVC_title")
        initSubView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPolling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPolling()
    }
    
    func initSubView() {
        
        headerView = CandidatesListHeaderView(frame: .zero)
        view.addSubview(headerView)
        headerView.snp.makeConstraints({ (maker) in
            maker.top.equalToSuperview().offset(8)
            maker.left.equalToSuperview().offset(12)
            maker.right.equalToSuperview().offset(-12)
            maker.height.equalTo(50)
        })
        
        selectionView = CandidatesListSectionHeaderView(frame: .zero)
        selectionView.delegate = self
        for btn in selectionView.btns {
            btn.addTarget(self, action: #selector(sortTypeChange(_ :)), for: .touchUpInside)
        }
        selectionView.updateSelectedBtn(selectionView.btns[0])
        view.addSubview(selectionView)
        selectionView.snp.makeConstraints { (maker) in
            maker.top.equalTo(headerView.snp.bottom).offset(10)
            maker.left.equalToSuperview().offset(12)
            maker.right.equalToSuperview().offset(-12)
            maker.height.equalTo(44)
        }
        selectionView.searchTF.delegate = self
        
        tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CandidatesTableViewCell", bundle: nil), forCellReuseIdentifier: "CandidatesTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIViewController_backround
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(selectionView.snp.bottom)
            maker.left.equalToSuperview().offset(12)
            maker.right.equalToSuperview().offset(-12)
            maker.bottom.equalToSuperview()
        }
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("CandidateListVC_empty_desc")))
        }
        
        let rightMenuButton = UIButton(type: .custom)
//        rightMenuButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightMenuButton.setTitle(Localized("CandidateListVC_rightBtn_title"), for: .normal)
        rightMenuButton.setTitleColor(UIColor(rgb: 0xCDCDCD), for: .normal)
        rightMenuButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rightMenuButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightMenuButton)
        rightMenuButton.sizeToFit()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func onNavRight(){
        let myvote = MyVoteListVC()
        navigationController?.pushViewController(myvote, animated: true)
    }
    
    func startPolling() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(queryDataAndUpdate), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc func queryDataAndUpdate() {
        
        updateTicketPriceAndPoolNum()
        
        if !isQuerying {
            queryCandidatesList()
        }

    }
    
    private func updateTicketPriceAndPoolNum() {
        headerView.updateTicketPrice(VoteManager.sharedInstance.ticketPrice?.convertToEnergon(round: 4), isUpward: true)
        headerView.updatePoll(VoteManager.sharedInstance.ticketPoolUsageNum, voteRate: VoteManager.sharedInstance.ticketPoolUsageRate)
        
    }
    
    private func queryCandidatesList() {
        
        isQuerying = true 
        
        if isFirstQuery {
            showLoading()
        }
        
        VoteManager.sharedInstance.CandidateList { [weak self] (res, data) in
            
            guard let self = self else { return }
            
            switch res {
            case .success:
                guard var list = data as? [Candidate] else {
                    return
                }
                list.sort(by: { (e1, e2) -> Bool in
                    return e1.deposit! > e2.deposit!
                })
                
                list = list.count > 200 ? Array(list[0..<200]) : list
                
                for i in 0..<list.count {
                    list[i].rankByDeposit = UInt16(i + 1)
                }
                
                self.setCandidateAreaInfo(list: list)
                self.queryCandidateTicketCount(list: list, completion: { (newList) in
                
                    if (self.isFirstQuery) {
                        self.hideLoading()
                    }
                    
                    divideInfoPool()
                    
                    self.isQuerying = false 
                    
                    self.startSort()
                })
                
                func divideInfoPool() {
                    let first100 = list.count > 100 ? Array(list[0..<100]) : list
                    self.candidatesPool = first100.filter { (item) -> Bool in
                        item.tickets ?? 0 >= kCandidateMinNumOfTickets
                    }
                    for item in self.candidatesPool {
                        item.rankStatus = .candidateFirst100
                    }
                    self.alternativePool = list.filter { (item) -> Bool in
                        item.tickets ?? 0 < kCandidateMinNumOfTickets
                    }
                    self.alternativePool = self.alternativePool.count > 100 ? Array(self.alternativePool[0..<100]):self.alternativePool
                    for item in self.alternativePool {
                        item.rankStatus = .alternativeFirst100
                    }
                }
            case .fail(_, _):
                self.isQuerying = false
                if (self.isFirstQuery) {
                    self.hideLoading()
                }
            
            }
        }
    }
    
    func setCandidateAreaInfo(list: [Candidate]) {
        
        let ips = list.map { (e) -> String in
            return e.host ?? ""
        }
        
        let ipGeoInfoDic = IPQuery.sharedInstance.getIPGeoInfoFromDB(ipList: ips)
        for candidate in list {
            candidate.area = ipGeoInfoDic[candidate.host ?? ""]
        }
        
    }
    
    func queryCandidateTicketCount(list: [Candidate], completion:@escaping (([Candidate])->Void)) {
            
        let ids = list.map({ (item) -> String in
            return item.candidateId!
        })
        
        VoteManager.sharedInstance.GetBatchCandidateTicketCount(candidateIds: ids) { (res, data) in
            switch res{
            case .success:
                if let ticketNums = data as? [String:Int] {
                    for i in 0..<list.count {
                        if let candidateId = list[i].candidateId, let num = ticketNums[candidateId] {
                            list[i].tickets = UInt16(num)
                        }
                    }
                }
            default:
                break
            }
            completion(list)
        }

//        VoteManager.sharedInstance.GetBatchCandidateTicketIds(candidateIds: ids) { (res, data) in
//            print("TicketIds Query Done")
//            switch res{
//            case .success:
//                if let ticketNums = data as? [String:[String]] {
//                    for i in 0..<list.count {
//                        if let candidateId = list[i].candidateId, let arr = ticketNums[candidateId], arr.count > 0 {
//                            list[i].tickets = UInt16(arr.count)
//                        }
//                    }
//                }
//            default:
//                break
//            }
//            completion(list)
//        }

    }
    
    @objc func sortTypeChange(_ sender: UIButton) {
        
        for i in 0..<selectionView.btns.count {
            if sender == selectionView.btns[i] {
                sortType = CandidatesListSortType(rawValue: i) ?? .default
                break
            }
        }
        selectionView.updateSelectedBtn(sender)
        
        startSort()
    }
    
    private func startSort() {
        
        sortedCandidatesList = sortByType(type: sortType)
        
        refreshTableView()
    }
    
    private func refreshTableView() {
        if searchText.length > 0 {
            filterBySearchText()
            dataSource = filteredCandidateList
        }else {
            dataSource = sortedCandidatesList
        }
        
        tableView.reloadData()
    }
    
    private func sortByType(type: CandidatesListSortType) -> [Candidate] {
        
        switch type {
        case .default:
            
            return candidatesPool + alternativePool
            
        case .reward:
            
            var list = candidatesPool + alternativePool
            list.sort { (e1, e2) -> Bool in
                
                if e1.fee ?? 0 != e2.fee ?? 0 {
                    return e1.fee ?? 0 > e2.fee ?? 0 
                }else if e1.deposit! != e2.deposit! {
                    return e1.deposit! > e2.deposit!
                }else if e1.tickets ?? 0 != e2.tickets ?? 0 {
                    return e1.tickets ?? 0 > e2.tickets ?? 0
                }else {
                    return e1.blockNumber! < e2.blockNumber!
                }
            }
            return list
            
        case .location:
            
            let list = candidatesPool + alternativePool
            
            let collation = UILocalizedIndexedCollation.current()
            let sectionCount = collation.sectionTitles.count
            var arrs = [[Candidate]]()
            for _ in 0..<sectionCount { 
                arrs.append([Candidate]())
            }
            
            for item in list {
                let index = collation.section(for: item, collationStringSelector: #selector(getter: Candidate.countryName))
                arrs[index].append(item)
            }
            var sortArr = [Candidate]()
            for i in 0..<sectionCount {
                sortArr += arrs[i]
            }
            return sortArr
            
        }
        
    }
    
    private func filterBySearchText() {
        filteredCandidateList = sortedCandidatesList.filter { (candidate) -> Bool in

            if (candidate.extra?.nodeName.uppercased() ?? "").range(of: self.searchText.uppercased()) != nil {
                return true
            }
            return false
        }
    }
    
}




extension CandidatesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CandidatesTableViewCell", for: indexPath) as! CandidatesTableViewCell
        let candidate = dataSource[indexPath.row]
        cell.feedData(candidate) { [weak self] () in
            
            guard let self = self else { return }
            
            let res = VoteManager.sharedInstance.checkMyWalletBalanceIsEnoughToVote()
            guard res.canVote else {
                self.showMessage(text: res.errMsg, delay: 3)
                return
            }
            
            let votingVC = VotingViewController0()
            votingVC.candidate = candidate
            self.navigationController?.pushViewController(votingVC, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = CandidateDetailViewController()
        vc.candidate = dataSource[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

extension CandidatesListViewController: UITextFieldDelegate, HeaderViewProtocol {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.searchText = textField.text ?? ""
        }
        
        return true
    }
    
    //MARK: HeaderViewProtocol
    func hideSearchTextField(_ textField: UITextField) {
        self.searchText = ""
    }
    
}
