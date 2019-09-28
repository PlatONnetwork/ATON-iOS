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

enum HeaderStyle {
    case VoteSummaryHeaderShow,VoteSummaryHide
}

let headerViewHeight: CGFloat = 149.0 + UIDevice.notchHeight
let filterBarShrinkHeight : CGFloat = 42.0
let filterBarExpandHeight : CGFloat = 108

class CandidatesListViewController: BaseViewController {
    
    var scrollContainer = CandidateScrollContainer()
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
    
    var headerStyle : HeaderStyle = .VoteSummaryHeaderShow {
        
        didSet {
             
            print("headerStyle didset to :\(headerStyle)")
            if headerStyle == .VoteSummaryHeaderShow{
                self.setplaceHolderBG(hide: true,tableView: self.tableView)
                self.scrollContainer.setContentOffset(CGPoint(x: self.scrollContainer.contentOffset.x, y: 0), animated: true)
                filterBarView.setlayoutStyle(expand: false)
                NotificationCenter.default.post(name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: UIColor.white)
            }else if headerStyle == .VoteSummaryHide{
                self.setplaceHolderBG(hide:false ,tableView: self.tableView)
                self.scrollContainer.setContentOffset(CGPoint(x: self.scrollContainer.contentOffset.x, y: headerViewHeight), animated: true)
                self.tableView.isScrollEnabled = true
                filterBarView.setlayoutStyle(expand: true)
                NotificationCenter.default.post(name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1))
            }
             
            
            let tabbarHeight = navigationController?.tabBarController?.tabBar.frame.size.height ?? 0
            if headerStyle == .VoteSummaryHeaderShow {
                tableView.snp.updateConstraints { (make) in
                    make.height.equalTo(kUIScreenHeight - filterBarExpandHeight - tabbarHeight)
                }
            }else{
                tableView.snp.updateConstraints { (make) in
                    make.height.equalTo(kUIScreenHeight - tabbarHeight - headerViewHeight)
                }
            }
            
        }
    }
    
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
        
        NSLog("content height:%f", self.scrollContainer.contentSize.height)
        
        if #available(iOS 11.0, *) {
            print("adjustedContentInset:\(scrollContainer.adjustedContentInset)")
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func initSubView() {
        
        
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.addSubview(tmpView)
        
        scrollContainer.delegate = self
        view.addSubview(scrollContainer)
        
        self.scrollContainer.canCancelContentTouches = true
        self.scrollContainer.delaysContentTouches = true
        
        let usingSafeArealayout = false
        scrollContainer.snp.makeConstraints { (make) in
            if usingSafeArealayout{
                make.leading.trailing.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                } else {
                    make.bottom.equalToSuperview()
                }
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalToSuperview()
                }
            }else{
                make.edges.equalToSuperview()
            }
        }
        
        if #available(iOS 11.0, *) {
            scrollContainer.contentInsetAdjustmentBehavior = .always
        } else {
            automaticallyAdjustsScrollViewInsets = false
        } 
        
        headerView = CandidatesListHeaderView(frame: .zero)
        headerView.myVoteButton.addTarget(self, action: #selector(onMyVote), for: .touchUpInside)
        scrollContainer.addSubview(headerView) 
        headerView.snp.makeConstraints({ (maker) in
            maker.top.equalToSuperview().offset(0)
            maker.leading.equalToSuperview().offset(0)
            maker.trailing.equalToSuperview().offset(0)
            maker.width.equalTo(kUIScreenWidth)
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
        filterBarView.myvoteBtn.addTarget(self, action: #selector(onMyVote), for: .touchUpInside)
        
        scrollContainer.addSubview(filterBarView)
        filterBarView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp_bottomMargin)
            make.height.equalTo(filterBarShrinkHeight)
        }
        
        tableView = MultiGestureTableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CandidatesTableViewCell", bundle: nil), forCellReuseIdentifier: "CandidatesTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIViewController_backround
        tableView.tableFooterView = UIView()
        scrollContainer.addSubview(tableView)
        
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"empty_no_data_img") as? TableViewNoDataPlaceHolder
            view.customView(holder)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(filterBarView.snp_bottomMargin).offset(10)
            make.leading.bottom.trailing.equalToSuperview()
            make.width.equalTo(kUIScreenWidth)
            make.height.equalTo(100)
        }
        self.headerStyle = HeaderStyle.VoteSummaryHeaderShow
        
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
                        self.hideLoadingHUD()
                    }
                    
                    dividenominatedandwaitingCandidateslistPool()
                    
                    self.isQuerying = false 
                    
                    self.startSort()
                })
                
                func dividenominatedandwaitingCandidateslistPool() {
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

        if !isScrolling{
            tableView.reloadData()
        }
        
    }
    
    private func sortByType(type: CandidatesListSortType) -> [Candidate] {
        
        switch type {
        case .default:
            
            return nominateNodeList + waitingCandidateslist
            
        case .reward:
            
            var list = nominateNodeList + waitingCandidateslist
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
        
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if scrollView == scrollContainer{
            
        
            if (actualPosition.y > 0){
                if self.headerStyle == HeaderStyle.VoteSummaryHide{
                    self.scrollContainer.isScrollEnabled = true
                }
            }else{}
        }else if scrollView == self.tableView{
            if (actualPosition.y >= 0.0){
                
                if self.headerStyle == HeaderStyle.VoteSummaryHide{
                    DispatchQueue.main.async {
                        self.scrollContainer.isScrollEnabled = true
                    }
                }
            }else{
                
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //filterBarView.changeLayoutWhileScrolling(offset: 138 - scrollView.contentOffset.y)
    }
  
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //filterBarView.changeLayoutWhileScrolling(offset: 138 - scrollView.contentOffset.y)
        
        if scrollView == scrollContainer{

            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
                self.headerStyle = .VoteSummaryHeaderShow
            }else{
                self.headerStyle = .VoteSummaryHide
            }
        }
        if !decelerate{
            self.isScrolling = false
        }
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yoffset = scrollView.contentOffset.y
        if scrollView == scrollContainer{
            if yoffset > headerViewHeight{
                DispatchQueue.main.async {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: headerViewHeight), animated: false)
                    scrollView.isScrollEnabled = false
                }
            }
            
        }else if scrollView == tableView{
            if scrollView.isDragging{
                self.isScrolling = true
            }
            
            if scrollView.isDragging && self.headerStyle == .VoteSummaryHide{
                self.scrollContainer.setContentOffset(CGPoint(x: self.scrollContainer.contentOffset.x, y: headerViewHeight), animated: false)
            }
            
            if self.headerStyle == .VoteSummaryHide{
                if yoffset > 5.0{
                    self.scrollContainer.isScrollEnabled = false
                }else{
                    self.scrollContainer.isScrollEnabled = true
                }
            }
            
            if self.headerStyle == HeaderStyle.VoteSummaryHeaderShow{
                tableView.setContentOffset(.zero, animated: false)
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
