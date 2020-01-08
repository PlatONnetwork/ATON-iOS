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
    var currentSort: NodeSort = .rank

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeTableViewCell.self, forCellReuseIdentifier: "NodeTableViewCell")
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

    lazy var searchBar = { () -> UISearchBar in
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        searchbar.backgroundImage = UIImage()
        searchbar.setImage(UIImage(), for: .search, state: .focused)
        searchbar.setImage(UIImage(), for: .search, state: .normal)
        searchbar.delegate = self
        if let textField = searchbar.value(forKey: "searchField") as? UITextField {
            textField.layer.cornerRadius = 18.0
            textField.layer.borderColor = common_blue_color.cgColor
            textField.layer.borderWidth = 1
            textField.font = .systemFont(ofSize: 14)
            textField.LocalizePlaceholder = "mydelegates_search_placeholder"
        }
        return searchbar
    }()

    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchDataLastest))!
        return header
    }()

    lazy var refreshFooter: MJRefreshFooter = {
        let footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(fetchDataMore))!
        return footer
    }()

    var listData: [Node] = [] {
        didSet {
            tableView.mj_footer.isHidden = listData.count == 0
        }
    }

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
        
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.mj_header.beginRefreshing()

        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: Notification.Name.ATON.DidTabBarDoubleClick, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isViewLoaded {
            fetchData(isFetch: controllerType == .all, nil)
        }
    }

    @objc func scrollToTop() {
        if isViewLoaded {
            tableView.mj_header.beginRefreshing()
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

    func nodeSortDidTapHandle() {
        let listData = [
            NodeSort.rank,
            NodeSort.delegated,
            NodeSort.delegator,
            NodeSort.yield
        ]

        let contentView = ThresholdValueSelectView<NodeSort>(listData: listData, selected: currentSort, title: Localized("node_sort_title"))
        contentView.show(viewController: self)
        contentView.valueChangedHandler = { [weak self] (value) in
            guard self?.currentSort != value else {
                return
            }

            self?.currentSort = value
            self?.pullDownForRefreshData()
        }
    }

    public func pullDownForRefreshData() {
        if tableView.mj_header != nil {
            tableView.mj_header.beginRefreshing()
        }
    }

    func searchDidTapHandler(isOn: Bool) {
        if isOn && tableView.tableHeaderView == nil {
            tableView.tableHeaderView = searchBar
        } else if !isOn && tableView.tableHeaderView != nil {
            tableView.tableHeaderView = nil
        }
    }

    @objc func fetchDataLastest() {
        fetchData(isFetch: true, nil)
    }

    @objc func fetchDataMore() {
//        guard let nodeId = listData.last?.nodeId else {
            tableView.mj_footer.endRefreshingWithNoMoreData()
//            return
//        }
//        fetchData(nodeId)
    }
}

extension ValidatorNodeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeTableViewCell") as! NodeTableViewCell
        cell.node = listData[indexPath.row]
        cell.cellDidSelectedHandle = { [weak self] in
            guard let self = self else { return }
            self.doShowNodeDetailController(indexPath: indexPath)
        }
        return cell
    }

    func doShowNodeDetailController(indexPath: IndexPath) {
        let controller = NodeDetailViewController()
        controller.nodeId = listData[indexPath.row].nodeId
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ValidatorNodeListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("start search")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}
