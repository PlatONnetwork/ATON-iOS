//
//  ValidatorNodeListViewController.swift
//  platonWallet
//
//  Created by Admin on 28/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import MJRefresh

class ValidatorNodeListViewController: BaseViewController, IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var itemInfo: IndicatorInfo = "All"
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeTableViewCell.self, forCellReuseIdentifier: "NodeTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        return tbView
    }()
    
    lazy var refreshHeader = { () -> MJRefreshHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()
    
    var listData: [Node] = []
    
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
        
        tableView.mj_header = refreshHeader
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
    @objc func fetchData() {
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.key!.address }
        guard addresses.count > 0 else { return }
        
        StakingService.sharedInstance.getNodeList { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()
            
            switch result {
            case .success:
                self?.listData.removeAll()
                if let newData = data as? [Node] {
                    self?.listData.append(contentsOf: newData)
                }
                self?.tableView.reloadData()
            case .fail(_, _):
                break
            }
        }
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
