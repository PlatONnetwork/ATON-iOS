//
//  NodeSettingViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

private let nodeURLReg = "^(http(s?)://)?([A-Z0-9a-z._%+-/:]{1,50})$"

class NodeSettingViewControllerV2: BaseViewController {

    // MARK: Lazy Init
    lazy var tableView: UITableView = {

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(NodeSettingCell.self, forCellReuseIdentifier: "NodeSettingCell")
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 70
        return tableView
    }()

    var backItem: UIBarButtonItem?

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedNodeChange(_:)), name: Notification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backItem = navigationItem.leftBarButtonItem
    }

    @objc func selectedNodeChange(_ notify:Notification) {
        tableView.reloadData()
    }

    ///keyboard notification
    @objc func keyboardWillChangeFrame(_ notify:Notification) {

        let endFrame = notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        if endFrame.origin.y - UIScreen.main.bounds.height < 0 {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets.zero
        }
    }

    func setupUI() {
        super.leftNavigationTitle = "SettingsVC_nodeSet_title"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
}

extension NodeSettingViewControllerV2: UITableViewDelegate, UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NodeStoreService.share.nodeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeSettingCell", for: indexPath) as! NodeSettingCell
        let nodeChain = NodeStoreService.share.nodeList[indexPath.row]
        let isSelected = nodeChain.chainId == SettingService.shareInstance.currentNodeChainId
        cell.setup(nodeName: Localized(nodeChain.desc), nodeUrl: nodeChain.nodeURLStr, isSelected: isSelected, chainId: nodeChain.chainId)
        return cell
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 68
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let didSelectNode = NodeStoreService.share.nodeList[indexPath.row]

        // 当前点击的节点已经为选中状态，则不往下
        guard !didSelectNode.isSelected else {
            return
        }

        NodeStoreService.share.switchNode(node: didSelectNode)
        self.showMessage(text: Localized("SettingsVC_nodeSet_switchSuccess_tips"))
        
        /*
//        showLoadingHUD()
        Web3Helper.switchRpcURL(didSelectNode.nodeURLStr, succeedCb: { [weak self] in

            guard let self = self else {
                return
            }
//            self.hideLoadingHUD()
//            NodeStoreService.share.switchNode(node: didSelectNode)
//            self.showMessage(text: Localized("SettingsVC_nodeSet_switchSuccess_tips"))
        }) { [weak self] in

//            self?.hideLoadingHUD()
            self?.showMessage(text: Localized("SettingsVC_nodeSet_switchFail_tips"))
        }
 */

    }
}
