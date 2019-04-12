//
//  NodeSettingViewModel.swift
//  platonWallet
//
//  Created by juzix on 2019/2/21.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

fileprivate let nodeURLReg = "^(http(s?)://)?([A-Z0-9a-z._%+-/:]{1,50})$"

class NodeStoreService {
    
    static let didEditStateChangeNotification = "didEditStateChangeNotification"
    static let didNodeListChangeNotification = "didNodeListChangeNotification"
    static let didSwitchNodeNotification = "didSwitchNodeNotification"
    static let selectedNodeUrlHadChangedNotification = "selectedNodeUrlHadChangedNotification"
    
    static let share = NodeStoreService()
    
    enum NodeError: Error {
        case urlIllegal
    }
    
    enum NodeEditType { 
        case add
        case delete(index: Int)
    }
    
    var nodeList: [NodeInfo] {
        get { 
            return SettingService.shareInstance.getNodes()
        }
        
    }
    
    var editingNodeList: [NodeInfo]!
    
    var selectedNodeBeforeEdit: NodeInfo!
    
    var isEdit: Bool = false {
        didSet{
            
            if isEdit {
                editingNodeList = [NodeInfo]()
                for item in nodeList {
                    editingNodeList.append(item.copy() as! NodeInfo)
                }
            }else {
                editingNodeList.removeAll()
            }
             
            NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.didEditStateChangeNotification), object: self, userInfo: ["isEdit":isEdit])
        }
    }
    
    private init() {
        
        selectedNodeBeforeEdit = (nodeList.first(where: { (item) -> Bool in
            item.isSelected == true
        })!.copy() as! NodeInfo)
        
    }
    
    func nodeCount() -> Int {
        return isEdit ? editingNodeList.count:nodeList.count
    }
    
    func item(index: Int) -> NodeInfo {
        return isEdit ? editingNodeList[index]:nodeList[index]
    }
    
    func save() throws {
        
        guard checkNodeUrl() else {
            throw NodeError.urlIllegal
        }
        
        SettingService.shareInstance.deleteNodeList(nodeList)
        
        editingNodeList = editingNodeList.filter { (item) -> Bool in
            if item.nodeURLStr.length == 0 {
                return false
            }else {
                if !item.nodeURLStr.hasPrefix("http") {
                    item.nodeURLStr = "http://\(item.nodeURLStr)"
                }
                return true
            }
        }
        
        editingNodeList = editingNodeList.removeDuplicate { $0.nodeURLStr }
        
        var nonNodeSelected = true
        for item in editingNodeList {
            
            if isNewNode(item) {
                SettingService.shareInstance.addOrUpdateNode(NodeInfo(nodeURLStr: item.nodeURLStr))
            }else {
                
                if item.isSelected {
                    nonNodeSelected = false
                }
                
                if item.id == selectedNodeBeforeEdit.id && item.nodeURLStr != selectedNodeBeforeEdit.nodeURLStr {
                    
                    item.isSelected = false
                    NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.selectedNodeUrlHadChangedNotification), object: self, userInfo: ["node":item ,"oldUrl":selectedNodeBeforeEdit.nodeURLStr])
                }
                SettingService.shareInstance.addOrUpdateNode(item)
            }
        }
        if nonNodeSelected {
            NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.selectedNodeUrlHadChangedNotification), object: self, userInfo: ["node":editingNodeList[0]])
        }
        
        
        
    }
    
    func add() {
        editingNodeList.append(NodeInfo())
        NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.didNodeListChangeNotification), object: self, userInfo: ["editType":NodeEditType.add])
    }
    
    func delete(index: Int) {
        editingNodeList.remove(at: index)
        NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.didNodeListChangeNotification), object: self, userInfo: ["editType":NodeEditType.delete(index: index)])
    }
    
    func switchNode(node: NodeInfo) {
        
        SettingService.shareInstance.addOrUpdateNode(node)
        SettingService.shareInstance.updateSelectedNode(node)
        
        self.nodeWillSuccessSwitch()
         
        NotificationCenter.default.post(name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: self, userInfo: ["node":node])
        
        selectedNodeBeforeEdit = nodeList.first(where: { (item) -> Bool in
            item.isSelected == true
        })!.copy() as? NodeInfo
        
    }
    
    func nodeWillSuccessSwitch(){
        WalletService.sharedInstance.refreshDB()
        SWalletService.sharedInstance.refreshDB()
    }
    
    private func checkNodeUrl() -> Bool {
        
        var canSave = true
        
        for node in editingNodeList {
            
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
    
    private func isNewNode(_ node: NodeInfo) -> Bool {
        return node.id == 0
    }
}
