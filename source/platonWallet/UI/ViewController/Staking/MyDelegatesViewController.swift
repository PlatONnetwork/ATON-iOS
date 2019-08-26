//
//  MyDelegatesViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import EmptyDataSet_Swift
import MJRefresh
import BigInt

class MyDelegatesViewController: BaseViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: Localized("staking_main_mydelegate_text"))
    
    lazy var tableView = { () -> ATableView in
        let tbView = ATableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(MyDelegateViewCell.self, forCellReuseIdentifier: "MyDelegateViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        return tbView
    }()
    
    
    let headerView = MyDelegateHeaderView()
    lazy var footerView = { () -> MyDelegateFooterView in
        let fView = MyDelegateFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        fView.faqButton.addTarget(self, action: #selector(faqTapAction), for: .touchUpInside)
        fView.turButton.addTarget(self, action: #selector(tutorialTapAction), for: .touchUpInside)
        return fView
    }()
    
    lazy var refreshHeader = { () -> MJRefreshHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var listData: [Delegate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(74)
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height)
        }
        headerView.recordButtonHandler = { [weak self] in
            self?.gotoDelegateRecordVC()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        let attributed = NSMutableAttributedString(string: Localized("empty_string_my_delegates_left"))
        let actionAttributed = NSAttributedString(string: Localized("empty_string_my_delegates_right"), attributes: [NSAttributedString.Key.foregroundColor: common_blue_color])
        attributed.append(actionAttributed)
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableview(forEmptyDataSet: (self?.tableView)!, attributed, "3.img-No trust") as? TableViewNoDataPlaceHolder
            holder?.textTapHandler = { [weak self] in
                self?.doShowValidatorListController()
            }
            view.customView(holder)
        }
        
        tableView.tableFooterView = footerView

        
        tableView.mj_header = refreshHeader
        tableView.mj_header.beginRefreshing()
    }
    
    @objc func faqTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_faq_title")
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func tutorialTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_tutorial_title")
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func updateDelagateHeader() {
        let total = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt.zero
//            return result + BigUInt(delegate.availableDelegationBalance ?? "0")!
        }
        headerView.totalBalanceLabel.text = total.description.vonToLATString.ATPSuffix()
    }
    
    private func gotoDelegateRecordVC() {
        let viewController = DelegateRecordMainViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func gotoDelegateDetailVC(_ delegate: Delegate) {
        let controller = DelegateDetailViewController()
        controller.delegate = delegate
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func doShowValidatorListController() {
        guard let tabController = self.parent as? StakingMainViewController else { return }
        tabController.moveToValidatorListController()
    }
}

extension MyDelegatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyDelegateViewCell") as! MyDelegateViewCell
        let delegate = listData[indexPath.row]
        cell.delegate = delegate
        cell.cellDidHandle = { [weak self] tapCell in
            self?.gotoDelegateDetailVC(delegate)
        }
        return cell
    }
}

extension MyDelegatesViewController {
    @objc func fetchData() {
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.key!.address }
        guard addresses.count > 0 else { return }
        
        StakingService.sharedInstance.getMyDelegate(adddresses: addresses) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()
            
            switch result {
            case .success:
                self?.listData.removeAll()
                if let newData = data as? [Delegate] {
                    self?.listData.append(contentsOf: newData)
                    self?.tableView.reloadData()
                    self?.updateDelagateHeader()
                }
                self?.tableView.reloadData()
            case .fail(_, _):
                break
            }
        }
    }
}

class ATableView: UITableView {
    override func reloadData() {
        super.reloadData()
        adjustTableFooterView()
    }
    
    func adjustTableFooterView() {
        if let footerView = tableFooterView {
            
            if frame.height > 0.0 {
                layoutIfNeeded()
                
                if contentSize.height < frame.height {
                    var tframe = footerView.frame
                    let height = max(80, frame.height - (contentSize.height - tframe.height))
                    if height != tframe.size.height {
                        tframe.size.height = height
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                } else if contentSize.height > frame.height {
                    var tframe = footerView.frame
                    if tframe.size.height != 80 {
                        tframe.size.height = 80
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                }
            }
        }
    }
}
