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
        tableView.separatorColor = UIColor(rgb: 0x32394E)
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    lazy var footView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        let imgV = UIImageView(image: UIImage(named: "icon_node_add"))
        imgV.contentMode = .scaleAspectFit
        view.addSubview(imgV)
        imgV.snp.makeConstraints({ (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
        })
        let lab = UILabel()
        lab.localizedText = "SettingsVC_nodeSet_addBtn_title"
        lab.textColor = UIColor.white
        lab.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(lab)
        lab.snp.makeConstraints({ (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(imgV.snp.right).offset(12)
        })
        let btn = UIButton()
        btn.addTarget(self, action: #selector(onAddClick), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints({ (maker) in
            maker.left.top.bottom.equalToSuperview()
            maker.right.equalTo(lab)
        })
        return view
    }()
    
    lazy var rightBarButton = { () -> UIButton in
        let btn = UIButton.getCommonBarButton()
        btn.setTitle(Localized("SettingsVC_nodeSet_editBtn_title"), for: .normal)
        btn.addTarget(self, action: #selector(onRigthItemClick(_ :)), for: .touchUpInside)
        return btn
    }()
    
    lazy var cancelBarButton = { () -> UIButton in 
        let btn = UIButton.getCommonBarButton()
        btn.setTitle(Localized("SettingsVC_nodeSet_cancelBtn_title"), for: .normal)
        btn.addTarget(self, action: #selector(onCancelEditClick), for: .touchUpInside)
        return btn
    }()
    
    var backItem: UIBarButtonItem?
    
    var isEdit: Bool = false {
        
        didSet {
            
            if isEdit == true {
                
                navigationItem.localizedText = "SettingsVC_nodeSet_edit_title"
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBarButton)
                
                rightBarButton.setTitle(Localized("SettingsVC_nodeSet_saveBtn_title"), for: .normal)
                
                tableView.tableFooterView = footView
                
            }else {
                
                navigationItem.localizedText = "SettingsVC_nodeSet_title"
                
                navigationItem.leftBarButtonItem = backItem
                rightBarButton.setTitle(Localized("SettingsVC_nodeSet_editBtn_title"), for: .normal)
                
                tableView.tableFooterView = UIView()
                
            }
            
            tableView.reloadData()
        }
    }
    
    var nodes: [NodeInfo] {
        return SettingService.shareInstance.getNodes()
    }
    
    var editingNodes: [NodeInfo] = []
    
    var currentSelectedNode: (id:Int,url:String)!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backItem = navigationItem.leftBarButtonItem
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
        
        navigationItem.localizedText = "SettingsVC_nodeSet_title"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

    }
    
    @objc func onRigthItemClick(_ sender: UIBarButtonItem) {
        
        if isEdit {
            //save
            saveNodeChanging()
        }else {
            startEdit()
        }
        
        isEdit = !isEdit
    }
    
    @objc func onAddClick() {
        
        let node = NodeInfo()
        editingNodes.append(node)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: editingNodes.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
        
    }
    
    @objc func onCancelEditClick() {
        
        isEdit = false
        
    }

    private func startEdit() {
        
        editingNodes = [NodeInfo]()
        for item in nodes {
            editingNodes.append(item.copy() as! NodeInfo)
        }
    }
    
    private func saveNodeChanging() {
        
        guard canSaveEditedNode() else {
            showMessage(text: Localized("SettingsVC_error_node_format"))
            return
        }
        SettingService.shareInstance.deleteNodeList(nodes)
        
        editingNodes = editingNodes.filter { (item) -> Bool in
            if item.nodeURLStr.length == 0 {
                return false
            }else {
                if !item.nodeURLStr.hasPrefix("http") {
                    item.nodeURLStr = "http://\(item.nodeURLStr)"
                }
                return true
            }
        }
        
        editingNodes = editingNodes.removeDuplicate { $0.nodeURLStr }
        
        var nonNodeSelected = true
        for item in editingNodes {
            
            if isNewNode(item) {
                SettingService.shareInstance.addOrUpdateNode(NodeInfo(nodeURLStr: item.nodeURLStr))
            }else {
                
                if item.isSelected {
                    nonNodeSelected = false
                }
                
                if item.id == currentSelectedNode.id && item.nodeURLStr != currentSelectedNode.url {
                    
                    item.isSelected = false
                    self.reconnectNode(item)
                }
                SettingService.shareInstance.addOrUpdateNode(item)
            }
        }
        if nonNodeSelected {
            switchToDefaultNodeWhileNonNodeBeSelected(editingNodes[0])
        }
        
    }
    
    private func switchToDefaultNodeWhileNonNodeBeSelected(_ defaultNode: NodeInfo) {
        
        showLoading()
        Web3Helper.switchRpcURL(defaultNode.nodeURLStr) { [weak self](success) in
            guard let self = self else { return }
            
            self.hideLoading()
            
            if success {
                NotificationCenter.default.post(name: NSNotification.Name(didswitchNode_Notification), object: nil)
                self.showMessage(text: Localized("SettingsVC_nodeSet_switchDefault_tips"))
            }
            SettingService.shareInstance.updateSelectedNode(defaultNode)
            self.tableView.reloadData()
            
        }
        
    }
    
    private func reconnectNode(_ node: NodeInfo) {
        
        showLoading()
        
        Web3Helper.switchRpcURL(node.nodeURLStr) { [weak self] (success) in
            guard let self = self else { return }
            
            self.hideLoading()
            
            let newNode = node.copy() as! NodeInfo
            newNode.isSelected = true
            
            if !success {
                newNode.nodeURLStr = self.currentSelectedNode.url
                self.showMessage(text: Localized("SettingsVC_nodeSet_recovery_tips"))
            }else {

                NotificationCenter.default.post(name: NSNotification.Name(didswitchNode_Notification), object: nil)
            }
            
            SettingService.shareInstance.addOrUpdateNode(newNode)
             
            self.tableView.reloadData()
        }
        
    }
    
    private func isNewNode(_ node: NodeInfo) -> Bool {
        return node.id == 0
    }
    
    private func canSaveEditedNode() -> Bool {
        
        var canSave = true
        
        for node in editingNodes {
            
            if node.isDefault {
                continue
            }
            
            if node.nodeURLStr.length == 0 {
                continue
            }
            
            if !NSPredicate(format: "SELF MATCHES %@", nodeURLReg).evaluate(with: node.nodeURLStr) {
                canSave = false 
                break
            }
            
        }
        return canSave
    }
    
}

extension NodeSettingViewControllerV2: UITableViewDelegate, UITableViewDataSource, NodeSettingTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEdit ? editingNodes.count : nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeSettingTableViewCell", for: indexPath) as! NodeSettingTableViewCell
        let nodeInfo = isEdit ? editingNodes[indexPath.row] : nodes[indexPath.row]
        
        if !isEdit && nodeInfo.isSelected {
            currentSelectedNode = (nodeInfo.id, nodeInfo.nodeURLStr)
        }
        
        cell.setup(node: nodeInfo.nodeURLStr, isSelected: isEdit ? false : nodeInfo.isSelected, isEdit: nodeInfo.isDefault ? false : isEdit, desc: nodeInfo.desc)
        cell.delegate = self
        
        if isEdit && indexPath.row == editingNodes.count - 1 {
            cell.nodeTF.becomeFirstResponder()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !isEdit else {
            return
        }
        
        let didSelectNode = self.nodes[indexPath.row]
        
        if didSelectNode.id == currentSelectedNode.id {
            return
        }
        
        showLoading()
        
        Web3Helper.switchRpcURL(didSelectNode.nodeURLStr, succeedCb: { [weak self] in
            
            guard self != nil else {
                return
            }
            
            self!.hideLoading()
            self!.showMessage(text: Localized("SettingsVC_nodeSet_switchSuccess_tips"))
            SettingService.shareInstance.updateSelectedNode(didSelectNode)
            
            self!.tableView.reloadData()
            
        }) { [weak self] in
            
            self?.hideLoading()
            self?.showMessage(text: Localized("SettingsVC_nodeSet_switchFail_tips"))
        }
        
    }
    
    //MARK: NodeSettingTableViewCellDelegate
    func deleteNode(_ cell: NodeSettingTableViewCell) {
        guard let indexPath = tableView .indexPath(for: cell) else {
            return
        }
              
        cell.nodeTF.resignFirstResponder()
        editingNodes.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
    }
    
    func editNode(_ cell:NodeSettingTableViewCell) {
        guard let indexPath = tableView .indexPath(for: cell) else {
            return
        }
        editingNodes[indexPath.row].nodeURLStr = cell.nodeTF.text!
    }
}
