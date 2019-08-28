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
    var isRankingSorted: Bool = true
    
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
    
    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchDataLastest))!
        return header
    }()
    
    lazy var refreshFooter: MJRefreshFooter = {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(fetchDataMore))!
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
        }
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.mj_header.beginRefreshing()
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
    private func fetchData(_ nodeId: String?) {
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.key!.address }
        guard addresses.count > 0 else { return }
        
        if nodeId == nil {
            listData.removeAll()
        }
        
        StakingService.sharedInstance.getNodeList(controllerType: controllerType, isRankingSorted: isRankingSorted) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            
            switch result {
            case .success:
                
                if let newData = data as? [Node], newData.count > 0 {
                    self?.tableView.mj_footer.resetNoMoreData()
                    self?.listData.append(contentsOf: newData)
                } else {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self?.tableView.reloadData()
            case .fail(_, _):
                self?.tableView.mj_footer.isHidden = true
                break
            }
        }
    }
    
    public func pullDownForRefreshData(isRankSelected: Bool) {
        isRankingSorted = isRankSelected
        if tableView.mj_header != nil {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    @objc func fetchDataLastest() {
        fetchData(nil)
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
            let controller = NodeDetailViewController()
            controller.nodeId = self.listData[indexPath.row].nodeId
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        return cell
    }
}
