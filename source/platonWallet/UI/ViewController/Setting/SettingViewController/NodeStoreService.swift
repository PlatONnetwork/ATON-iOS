//
//  NodeSettingViewModel.swift
//  platonWallet
//
//  Created by juzix on 2019/2/21.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

private let nodeURLReg = "^(http(s?)://)?([A-Z0-9a-z._%+-/:]{1,50})/rpc$"

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

    var nodeList: [NodeInfo] = NodeInfoPersistence.sharedInstance.getAll()

    var editingNodeList: [NodeInfo] = []

    var isEdit: Bool = false {
        didSet {

            if isEdit {
                editingNodeList = [NodeInfo]()
                for item in nodeList {
                    editingNodeList.append(item.copy() as! NodeInfo)
                }
            } else {
                editingNodeList.removeAll()
            }

            NotificationCenter.default.post(name: Notification.Name(NodeStoreService.didEditStateChangeNotification), object: self, userInfo: ["isEdit":isEdit])
        }
    }

    private init() {

        //default setting

    }

    func nodeCount() -> Int {
        return isEdit ? editingNodeList.notDeleteArray.count : nodeList.count
    }

    func item(index: Int) -> NodeInfo {
        return isEdit ? editingNodeList.notDeleteArray[index] : nodeList[index]
    }

    func save() throws {

        guard checkNodeUrl() else {
            throw NodeError.urlIllegal
        }

        editingNodeList = editingNodeList.filter { (item) -> Bool in
            if item.nodeURLStr.length == 0 {
                return false
            } else {
                if !item.nodeURLStr.hasPrefix("http") {
                    item.nodeURLStr = "http://\(item.nodeURLStr)"
                }
                return true
            }
        }

        editingNodeList = editingNodeList.removeDuplicate { $0.nodeURLStr }

        var nonNodeSelected = true
        for item in editingNodeList {

            if item.status == .delete {
                NodeInfoPersistence.sharedInstance.delete(node: item)
                continue
            }

            if item.status == .create {
                NodeInfoPersistence.sharedInstance.add(nodeURLStr: item.nodeURLStr, desc: "", chainId: item.chainId, isSelected: false, isDefault: false)
                continue
            }

            if item.status == .edit {
                guard let oriNode = nodeList.first(where: { $0.id == item.id && $0.nodeURLStr != item.nodeURLStr }) else { continue }
                NodeInfoPersistence.sharedInstance.add(node: item)

                if item.isSelected {
                    NotificationCenter.default.post(name: Notification.Name(NodeStoreService.selectedNodeUrlHadChangedNotification), object: self, userInfo: ["node":item ,"oldUrl":oriNode.nodeURLStr])
                }
            }

            if item.isSelected {
                nonNodeSelected = false
            }
        }

        nodeList = editingNodeList.filter { $0.status != .delete}.map({ (nodeInfo) -> NodeInfo in
            nodeInfo.status = .none
            return nodeInfo
        })

        if nonNodeSelected {
            NotificationCenter.default.post(name: Notification.Name(NodeStoreService.selectedNodeUrlHadChangedNotification), object: self, userInfo: ["node":editingNodeList[0]])
        }
    }

    func add() {
        let newNode = NodeInfo()
        newNode.status = .create
        editingNodeList.append(newNode)
        NotificationCenter.default.post(name: Notification.Name(NodeStoreService.didNodeListChangeNotification), object: self, userInfo: ["editType":NodeEditType.add])
    }

    func delete(index: Int) {
        editingNodeList[index].status = .delete
        NotificationCenter.default.post(name: Notification.Name(NodeStoreService.didNodeListChangeNotification), object: self, userInfo: ["editType":NodeEditType.delete(index: index)])
    }

    func edit(index: Int, newText: String) {
        if editingNodeList[index].status != .create {
            editingNodeList[index].status = .edit
        }
        editingNodeList[index].nodeURLStr = newText
    }

    func switchNode(node: NodeInfo) {

        let newArr = nodeList.detached.map({ (nodeInfo) -> NodeInfo in
            nodeInfo.isSelected = nodeInfo.id == node.id
            return nodeInfo
        })
        nodeList = newArr

        nodeList.forEach { (node) in
            NodeInfoPersistence.sharedInstance.add(node: node)
        }

        SettingService.shareInstance.currentNodeChainId = node.chainId
//        SettingService.shareInstance.currentNodeURL = node.nodeURLStr

        nodeWillSuccessSwitch()

        NotificationCenter.default.post(name: Notification.Name(NodeStoreService.didSwitchNodeNotification), object: self, userInfo: ["node":node])
    }

    func nodeWillSuccessSwitch() {
        WalletService.sharedInstance.refreshDB()

        if AssetVCSharedData.sharedData.walletList.count == 0 {
            (UIApplication.shared.delegate as? AppDelegate)?.gotoWalletCreateVC()
        }
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
}
