//
//  NodeSettingViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

fileprivate let nodeURLReg = "^(http(s?)://)?([A-Z0-9a-z._%+-/:]{1,50})$"

class NodeSettingViewControllerV2: BaseViewController {
    
    //MARK: Lazy Init
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UINib(nibName: "NodeSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "NodeSettingTableViewCell")
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    lazy var footView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 68))
        let imgV = UIImageView(image: UIImage(named: "icon_node_add"))
        imgV.contentMode = .scaleAspectFit
        view.addSubview(imgV)
        imgV.snp.makeConstraints({ (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
        })
        let lab = UILabel()
        lab.localizedText = "SettingsVC_nodeSet_addBtn_title"
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(lab)
        lab.snp.makeConstraints({ (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(imgV.snp.right).offset(4)
        })
        let btn = UIButton()
        btn.addTarget(self, action: #selector(onAddClick), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints({ (maker) in
            maker.left.top.bottom.equalToSuperview()
            maker.right.equalTo(lab)
        })
        view.addBottomSepline(offset: 16)
        return view
    }()
    
    lazy var rightBarButton = { () -> UIButton in
        let btn = UIButton.getCommonBarButton()
        btn.setTitle(Localized("SettingsVC_nodeSet_editBtn_title"), for: .normal)
        btn.addTarget(self, action: #selector(onRigthItemClick(_ :)), for: .touchUpInside)
        btn.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
        return btn
    }()
    
    lazy var cancelBarButton = { () -> UIButton in 
        let btn = UIButton.getCommonBarButton()
        btn.setTitle(Localized("SettingsVC_nodeSet_cancelBtn_title"), for: .normal)
        btn.addTarget(self, action: #selector(onCancelEditClick), for: .touchUpInside)
        return btn
    }()
    
    var backItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editStateChange(_:)), name: NSNotification.Name(rawValue: NodeStoreService.didEditStateChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nodeListChange(_:)), name: NSNotification.Name(rawValue: NodeStoreService.didNodeListChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedNodeChange(_:)), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reconnectNode(_:)), name: NSNotification.Name(NodeStoreService.selectedNodeUrlHadChangedNotification), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backItem = navigationItem.leftBarButtonItem
    }
    
    @objc func editStateChange(_ notify:Notification) {
        
        let newEditState = notify.userInfo?["isEdit"] as? Bool ?? false
        if newEditState {
            super.leftNavigationTitle = "SettingsVC_nodeSet_edit_title"
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBarButton)
            rightBarButton.setTitle(Localized("SettingsVC_nodeSet_saveBtn_title"), for: .normal)
            tableView.tableFooterView = footView
        }else {
            super.leftNavigationTitle = "SettingsVC_nodeSet_title"
            navigationItem.leftBarButtonItem = backItem
            rightBarButton.setTitle(Localized("SettingsVC_nodeSet_editBtn_title"), for: .normal)
            tableView.tableFooterView = UIView()
        }
        
        tableView.reloadData()
    }
    
    @objc func nodeListChange(_ notify:Notification) {
        let type = notify.userInfo?["editType"] as! NodeStoreService.NodeEditType
        switch type {
        case .add:
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: NodeStoreService.share.nodeCount()-1, section: 0)], with: .automatic)
            tableView.endUpdates()
        case .delete(let index):
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = tableView.cellForRow(at:indexPath) as? NodeSettingTableViewCell else {
                tableView.reloadData()
                return;
            }
            cell.nodeTF.resignFirstResponder()
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    @objc func selectedNodeChange(_ notify:Notification) {
        tableView.reloadData()
    }
    
    @objc func reconnectNode(_ notify: Notification) {
        
        guard let node = notify.userInfo?["node"] as? NodeInfo else {
            return
        }
        
        let oldUrl = notify.userInfo?["oldUrl"] as? String
        
        showLoadingHUD()
        
        Web3Helper.switchRpcURL(node.nodeURLStr) { [weak self] (success) in
            guard let self = self else { return }
            
            self.hideLoadingHUD()
            
            let newNode = node.copy() as! NodeInfo
            
            if !success {
                if oldUrl != nil {
                    
                    newNode.nodeURLStr = oldUrl!
                    self.showMessage(text: Localized("SettingsVC_nodeSet_recovery_tips"))
                }else {
                    
                }
                
            }else {
                
                NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
            }
            NodeStoreService.share.switchNode(node: newNode)
            
        }
        
    }
    
    ///keyboard notification
    @objc func keyboardWillChangeFrame(_ notify:Notification) {
        
        let endFrame = notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        if endFrame.origin.y - UIScreen.main.bounds.height < 0 {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
        }else {
            tableView.contentInset = UIEdgeInsets.zero
        }
    }
    
    func setupUI() {
        super.leftNavigationTitle = "SettingsVC_nodeSet_title"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }
    
    @objc func onRigthItemClick(_ sender: UIBarButtonItem) {
        
        view.becomeFirstResponder()
        if NodeStoreService.share.isEdit { //save
            do{
                try NodeStoreService.share.save()
            }catch NodeStoreService.NodeError.urlIllegal{
                showMessage(text: Localized("SettingsVC_error_node_format"))
                return
            }catch{
                
            }
        }
        NodeStoreService.share.isEdit = !NodeStoreService.share.isEdit
        
    }
    
    @objc func onAddClick() {
        
        NodeStoreService.share.add()
        
    }
    
    @objc func onCancelEditClick() {
        NodeStoreService.share.isEdit = false
        
    }
    
}

extension NodeSettingViewControllerV2: UITableViewDelegate, UITableViewDataSource, NodeSettingTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NodeStoreService.share.nodeCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeSettingTableViewCell", for: indexPath) as! NodeSettingTableViewCell
        let nodeInfo = NodeStoreService.share.item(index: indexPath.row)

        let isEdit = NodeStoreService.share.isEdit
        cell.setup(node: nodeInfo.nodeURLStr, isSelected: isEdit ? false : nodeInfo.isSelected, isEdit: nodeInfo.isDefault ? false : isEdit, desc: nodeInfo.desc)
        cell.delegate = self
        
        if isEdit && indexPath.row == NodeStoreService.share.nodeCount() - 1 {
            cell.nodeTF.becomeFirstResponder()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !NodeStoreService.share.isEdit else {
            return
        }
        
        let didSelectNode = NodeStoreService.share.nodeList[indexPath.row]
        
        if didSelectNode.id == NodeStoreService.share.selectedNodeBeforeEdit.id {
            return
        }
        
        showLoadingHUD()
        
        Web3Helper.switchRpcURL(didSelectNode.nodeURLStr, succeedCb: { [weak self] in
            
            guard let self = self else {
                return
            }
            self.hideLoadingHUD()
            self.showMessage(text: Localized("SettingsVC_nodeSet_switchSuccess_tips"))
            NodeStoreService.share.switchNode(node: didSelectNode)
            
        }) { [weak self] in
            
            self?.hideLoadingHUD()
            self?.showMessage(text: Localized("SettingsVC_nodeSet_switchFail_tips"))
        }
        
    }
    
    //MARK: NodeSettingTableViewCellDelegate
    func deleteNode(_ cell: NodeSettingTableViewCell) {
        guard let indexPath = tableView .indexPath(for: cell) else {
            return
        }
        NodeStoreService.share.delete(index: indexPath.row)
        
    }
    
    func editNode(_ cell:NodeSettingTableViewCell) {
        guard let indexPath = tableView .indexPath(for: cell) else {
            return
        }
        
        if indexPath.row >= NodeStoreService.share.editingNodeList.count {
            return
        }
        
        NodeStoreService.share.editingNodeList[indexPath.row].nodeURLStr = cell.nodeTF.text!
    }
}
