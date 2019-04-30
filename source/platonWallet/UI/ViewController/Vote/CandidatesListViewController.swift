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

let headerViewHeight: CGFloat = 149.0 + UIDevice.notchHeight
let filterBarShrinkHeight : CGFloat = 42.0
let filterBarExpandHeight : CGFloat = 108
let kAnimateScrollHeight: CGFloat = 63.0


class CandidatesListViewController: BaseViewController {
    
    var headerView: CandidatesListHeaderView!
    var filterBarView: CandidatesListFilterBarView!
    var tableView: MultiGestureTableView!
    var sortType: CandidatesListSortType = .default
    var timer: Timer?
    
    //
    var nominateNodeList: [Candidate] = []
    //
    var waitingCandidateslist: [Candidate] = []
    
    var originCandidatesList: [Candidate] = []
    
    var sortedCandidatesList: [Candidate] = []
    
    var filteredCandidateList: [Candidate] = []
    
    var isScrolling : Bool = false
    
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
            print("sortedCandidatesList: ----")
            print(sortedCandidatesList)
            refreshTableView()
        }
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusBarNeedTruncate = true
        initSubView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(onNodeSwitched), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPolling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPolling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*
        let header = headerView
        var height = header!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var newFrame = header!.frame
        if height == 0.0{
            height = 129
        }
        newFrame.size.height = height;
        header!.frame = newFrame
        tableView.tableHeaderView = header
        */
        
//        if #available(iOS 11.0, *) {
//            print("adjustedContentInset:\(scrollContainer.adjustedContentInset)")
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    
    func initSubView() {
        
        
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.addSubview(tmpView)
        
        tableView = MultiGestureTableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CandidatesTableViewCell", bundle: nil), forCellReuseIdentifier: "CandidatesTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIViewController_backround
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"empty_no_data_img") as? TableViewNoDataPlaceHolder
            view.customView(holder)
            view.isScrollAllowed(true)
            if let contentInset = self?.tableView.contentInset {
                view.verticalOffset(-contentInset.top/2.0)
            }
        }
        
        tableView.contentInset = UIEdgeInsets(top: headerViewHeight + filterBarShrinkHeight - kStatusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        
        headerView = CandidatesListHeaderView(frame: .zero)
        headerView.myVoteButton.addTarget(self, action: #selector(onMyVote), for: .touchUpInside)
        view.addSubview(headerView)
        headerView.snp.makeConstraints({ (maker) in
            maker.top.equalToSuperview().offset(-kStatusBarHeight)
            maker.leading.equalToSuperview().offset(0)
            maker.trailing.equalToSuperview().offset(0)
            maker.height.equalTo(headerViewHeight)
        })
        
        
        filterBarView = CandidatesListFilterBarView(frame: .zero)
        filterBarView.delegate = self
        for btn in filterBarView.filterButtons {
            btn.addTarget(self, action: #selector(sortTypeChange(_ :)), for: .touchUpInside)
        }
        filterBarView.searchTF.delegate = self
        filterBarView.searchTF.returnKeyType = .search
        filterBarView.updateSelectedBtn(filterBarView.filterButtons[0])
        
        view.addSubview(filterBarView)
        filterBarView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(filterBarShrinkHeight)
        }
        
        
        
        
    }
    
    @objc func onMyVote(){
        let myvote = MyVoteListVC()
        myvote.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(myvote, animated: true)
    }
    
    @objc func onNavRight(){
        let myvote = MyVoteListVC()
        myvote.hidesBottomBarWhenPushed = true
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
            showLoadingHUD()
        }
        
        VoteManager.sharedInstance.GetVotePageCandidateList { [weak self] (res, tumpleDdata) in
             
            guard let self = self else { return }
             
            switch res {
            case .success:
                guard let data = tumpleDdata as? ([Candidate],[String]) else{
                    return
                }
                guard var list = data.0 as? [Candidate] else {
                    return
                }
                
                list.candidateSort()
                
                //list = list.count > 200 ? Array(list[0..<200]) : list
                
                for i in 0..<list.count {
                    list[i].rankByDeposit = UInt16(i + 1)
                }
                
                self.setCandidateAreaInfo(list: list)
                self.queryCandidateTicketCount(list: list, completion: { (newList) in
                
                    if (self.isFirstQuery) {
                        self.hideLoadingHUD()
                    }
                    
                    dividenominatedandwaitingCandidateslistPool(validatorIds: data.1)
                    
                    self.isQuerying = false 
                    
                    self.startSort()
                })
                
                func dividenominatedandwaitingCandidateslistPool(validatorIds: [String]) {
                    let first100 = list.count > 100 ? Array(list[0..<100]) : list
                    self.nominateNodeList = first100.filter { (item) -> Bool in
                        item.tickets ?? 0 >= kCandidateMinNumOfTickets
                    } 
                    for item in self.nominateNodeList {
                        item.rankStatus = .candidateFirst100
                    }
                    self.waitingCandidateslist = list.filter { (item) -> Bool in
                        item.tickets ?? 0 < kCandidateMinNumOfTickets
                    }
                    self.waitingCandidateslist = self.waitingCandidateslist.count > 100 ? Array(self.waitingCandidateslist[0..<100]) : self.waitingCandidateslist
                    for item in self.waitingCandidateslist {
                        item.rankStatus = .alternativeFirst100
                    }
                    
                    for item in self.nominateNodeList{
                        if validatorIds.contains(item.candidateId ?? ""){
                            item.rankStatus = .validator
                        }
                    }
                    for item in self.waitingCandidateslist{
                        if validatorIds.contains(item.candidateId ?? ""){
                            item.rankStatus = .validator
                        }
                    }
                    
                    
                }
            case .fail(_, _):
                self.isQuerying = false
                if (self.isFirstQuery) {
                    self.hideLoadingHUD()
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
        
        VoteManager.sharedInstance.GetCandidateTicketCount(candidateIds: ids) { (res, data) in
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

    }
    
    @objc func sortTypeChange(_ sender: UIButton) {
        
        for i in 0..<filterBarView.filterButtons.count {
            if sender == filterBarView.filterButtons[i] {
                filterBarView.updateFilterIndicator(index: i)
                sortType = CandidatesListSortType(rawValue: i) ?? .default
                break
            }
        }
        filterBarView.updateSelectedBtn(sender)

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
            
            var dataSource = nominateNodeList + waitingCandidateslist
            dataSource.candidateSort()
            return dataSource
            
        case .reward:
            
            var list = nominateNodeList + waitingCandidateslist
            list.sort { (e1, e2) -> Bool in
                
                if e1.fee ?? 0 != e2.fee ?? 0 {
                    return e1.fee ?? 0 < e2.fee ?? 0 
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
            
            let list = nominateNodeList + waitingCandidateslist
            
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
            if (candidate.extra?.nodeName!.uppercased() ?? "").range(of: self.searchText.uppercased()) != nil {
                return true
            }
            return false
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        scrollContainer.contentSize = CGSize(width: scrollContainer.frame.width, height: tableView.contentSize.height + headerView.frame.height + filterBarView.frame.height + kStatusBarHeight + 1)
//        super.viewWillLayoutSubviews()
//
//    }
    
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
            votingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(votingVC, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = CandidateDetailViewController()
        vc.candidate = dataSource[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
}



extension CandidatesListViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isScrolling = false
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
        if filterBarView.searchTF.isEditing {
            filterBarView.searchTF.resignFirstResponder()
        }
//        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
//        if scrollView == scrollContainer{
//            if (actualPosition.y > 0){
//                if self.headerStyle == HeaderStyle.VoteSummaryHide{
//                    self.scrollContainer.isScrollEnabled = true
//                }
//                self.scrollContainer.isScrollEnabled = true
//            }else{}
//        }else if scrollView == self.tableView{
//            if (actualPosition.y >= 0.0){
//
//                if self.headerStyle == HeaderStyle.VoteSummaryHide{
//                    DispatchQueue.main.async {
//                        self.scrollContainer.isScrollEnabled = true
//                    }
//                }
//            }else{
//
//            }
//        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //filterBarView.changeLayoutWhileScrolling(offset: 138 - scrollView.contentOffset.y)
    }
  
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //filterBarView.changeLayoutWhileScrolling(offset: 138 - scrollView.contentOffset.y)
//        if scrollView == scrollContainer{
//            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
//                self.headerStyle = .VoteSummaryHeaderShow
//            }else{
//                self.headerStyle = .VoteSummaryHide
//            }
//        }
//        if !decelerate{
//            self.isScrolling = false
//        }
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yOffset = scrollView.contentOffset.y
        if scrollView == tableView{
            let xOffset = scrollView.contentInset.top + yOffset
            if xOffset < kAnimateScrollHeight {
                
                headerView.snp.updateConstraints { make in
                    make.height.equalTo(headerViewHeight - xOffset)
                }
                
                var alpha = (kAnimateScrollHeight - xOffset)/kAnimateScrollHeight*1.0
                print("scroll alpha value: \(alpha)")
                if alpha < 0.0 {
                    alpha = 0.0
                } else if alpha > 1.0 {
                    alpha = 1.0
                }

                if !filterBarView.searchTF.isEditing {
                    headerView.updateHeaderViewStyle(alpha)
                    filterBarView.updateLayoutstyle(alpha)
                }
                
                
                if alpha == 0.0 {
                    self.setplaceHolderBG(hide:false ,tableView: self.tableView)
                    NotificationCenter.default.post(name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1))
                } else if alpha == 1.0 {
                    self.setplaceHolderBG(hide: true,tableView: self.tableView)
                    NotificationCenter.default.post(name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: UIColor.white)
                }
            } else {
                headerView.snp.updateConstraints { make in
                    make.height.equalTo(headerViewHeight - kAnimateScrollHeight)
                }
                
                headerView.updateHeaderViewStyle(0.0)
                filterBarView.updateLayoutstyle(0.0)
                
                self.setplaceHolderBG(hide:false ,tableView: self.tableView)
                NotificationCenter.default.post(name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1))
            }
            
            if scrollView.isDragging{
                self.isScrolling = true
            }
        }
    }
    
    

    
}
extension CandidatesListViewController: UITextFieldDelegate, HeaderViewProtocol {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.searchText = textField.text ?? ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.searchText = textField.text ?? ""
        return true
    }
    
    //MARK: HeaderViewProtocol
    func hideSearchTextField(_ textField: UITextField) {
        self.searchText = ""
    }
    
    //MARK: - Notification
    
    @objc func onNodeSwitched(){
        DispatchQueue.main.async {
            self.dataSource.removeAll()
            self.tableView.reloadData()
        }
    }
    
    
}
