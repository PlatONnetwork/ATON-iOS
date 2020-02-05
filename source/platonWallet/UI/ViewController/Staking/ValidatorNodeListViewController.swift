//
//  ValidatorNodeListViewController.swift
//  platonWallet
//
//  Created by Admin on 28/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import MJRefresh
import Localize_Swift

public enum NodeControllerType {
    case all
    case active
    case candidate
}

class ValidatorNodeListViewController: BaseViewController, IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    var itemInfo: IndicatorInfo = "All"
    var controllerType: NodeControllerType = .all
    var currentSort: NodeSort {
        guard let controller = parent as? ValidatorNodesViewController else { return .rank }
        return controller.currentSort
    }

    var isSearching: Bool = false
    var isShowSearch: Bool = false {
        didSet {
            if isShowSearch {
                tableView.mj_header = nil
                tableView.mj_footer = nil
                tableView.tableHeaderView = searchView
                searchView.searchBar.becomeFirstResponder()
            } else {
                tableView.mj_footer = refreshFooter
                tableView.mj_header = refreshHeader
                tableView.tableHeaderView = nil
            }
            guard let controller = parent as? ValidatorNodesViewController else { return }
            controller.isSelectedSearchButton = isShowSearch
        }
    }

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeTableViewCell.self, forCellReuseIdentifier: "NodeTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        tbView.mj_header = refreshHeader
        tbView.mj_footer = refreshFooter
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    let searchView = NodeSearchBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 66))

    lazy var refreshHeader = { () -> MJRefreshHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchDataLastest))!
        return header
    }()

    lazy var refreshFooter = { () -> MJRefreshFooter in
        let footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(fetchDataMore))!
        return footer
    }()

    var listData: [Node] = [] {
        didSet {
            if tableView.mj_footer != nil {
                tableView.mj_footer.isHidden = listData.count == 0
            }
        }
    }

    var searchResults: [Node] = []

    init(itemInfo: String) {
        self.itemInfo = IndicatorInfo(title: itemInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"empty_no_data_img") as? TableViewNoDataPlaceHolder
            holder?.descriptionLabel.text = Localized("empty_string_validator")
            view.customView(holder)
            view.isScrollAllowed(true)
        }
//        tableView.mj_header.beginRefreshing()

        searchView.searchBar.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: Notification.Name.ATON.DidTabBarDoubleClick, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isViewLoaded && !isShowSearch {
            fetchData(isFetch: controllerType == .all, nil)
        }

        guard let controller = parent as? ValidatorNodesViewController else { return }
        controller.isSelectedSearchButton = isShowSearch
    }

    @objc func scrollToTop() {
        if isViewLoaded {
            if tableView.mj_header != nil {
                tableView.mj_header.beginRefreshing()
            }
//            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ValidatorNodeListViewController {

    private func fetchData(isFetch: Bool, _ nodeId: String?) {
        StakingService.sharedInstance.getNodeList(controllerType: controllerType, sort: currentSort, isFetch: isFetch) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()

            switch result {
            case .success:
                if nodeId == nil {
                    self?.listData.removeAll()
                }

                if let newData = data as? [Node], newData.count > 0 {
                    self?.tableView.mj_footer.resetNoMoreData()
                    self?.listData.append(contentsOf: newData)
                } else {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self?.tableView.reloadData()
            case .fail:
                self?.tableView.mj_footer.isHidden = true
            }
        }
    }

    func searchDidTapHandler() {
        isShowSearch = !isShowSearch
        if !isShowSearch {
            isSearching = false
            tableView.reloadData()
        }
    }

    func hideSearchBarView() {
        isShowSearch = false
        tableView.tableHeaderView = nil
    }

    @objc func fetchDataLastest() {
        if isShowSearch {
            guard let text = searchView.searchBar.text else {
                return
            }
            searchResults = StakingService.sharedInstance.searchNodes(text: text, type: controllerType, sort: currentSort)
            tableView.reloadData()
            return
        }
        fetchData(isFetch: true, nil)
    }

    @objc func fetchDataMore() {
//        guard let nodeId = listData.last?.nodeId else {
        if tableView.mj_footer != nil {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        }

//            return
//        }
//        fetchData(nodeId)
    }
}

extension ValidatorNodeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResults.count
        }
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeTableViewCell") as! NodeTableViewCell
        if isSearching {
            cell.node = searchResults[indexPath.row]
        } else {
            cell.node = listData[indexPath.row]
        }
        cell.cellDidSelectedHandle = { [weak self] in
            guard let self = self else { return }
            self.doShowNodeDetailController(indexPath: indexPath)
        }
        return cell
    }

    func doShowNodeDetailController(indexPath: IndexPath) {
        let controller = NodeDetailViewController()
        if isSearching {
            controller.nodeId = searchResults[indexPath.row].nodeId
        } else {
            controller.nodeId = listData[indexPath.row].nodeId
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ValidatorNodeListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.resignFirstResponder()
        isSearching = true
        searchResults = StakingService.sharedInstance.searchNodes(text: text, type: controllerType, sort: currentSort)
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchResults = []
        hideSearchBarView()
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            isSearching = false
            tableView.reloadData()
        }
    }
}
