//
//  AddressBookViewController.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SwipeCellKit

typealias SelectionCompletion = (_ addressInfo: AddressInfo?) -> Void

class AddressBookViewController: BaseViewController {

    var selectionCompletion: SelectionCompletion?

    var dataSource: [AddressInfo]? = []

    var tableView: UITableView!

    var isHideAddButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        initData()
    }

    func initData() {
        dataSource?.removeAll()
        dataSource = AddressBookService.service.getAll()
        tableView!.reloadData()
    }

    func initSubViews() {

        // tableview滚动会显示导行栏透明的情况，可修改基类处理，暂定在该页面处理
        navigationController?.navigationBar.isTranslucent = false

        view.backgroundColor = normal_background_color
        tableView = UITableView()
        tableView.backgroundColor = normal_background_color
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        view.addSubview(tableView!)
        tableView!.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        tableView.registerCell(cellTypes: [AddressBookTableViewCell.self])
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("AddresssBookVC_empty_tip"), "empty_no_data_img"))
        }
    }

    func initNavigationItem() {

        super.leftNavigationTitle = "AddressBookVC_nav_title"
        guard isHideAddButton == false else { return }

        //let backgrouImage = UIImage(color: .white)
        //self.navigationController?.navigationBar.setBackgroundImage(backgrouImage, for: .default)

        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "nav_add"), for: .normal)
        addButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc func onNavRight() {
        let newAddrInfo = NewAddressInfoViewController()
        newAddrInfo.addCompletion = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self?.initData()
            })
        }
        navigationController?.pushViewController(newAddrInfo, animated: true)
    }

}

extension AddressBookViewController: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddressBookTableViewCell.self)) as! AddressBookTableViewCell
        cell.delegate = self
        cell.setUpdCell(addressInfo: dataSource![indexPath.row], isForSelectMode: selectionCompletion != nil)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.count)!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectionCompletion != nil) {
            if (AssetVCSharedData.sharedData.selectedWallet as! Wallet).address.lowercased() == dataSource![indexPath.row].walletAddress?.lowercased() {
                return
            }

            let info = dataSource![indexPath.row]
            selectionCompletion!(info)
            navigationController?.popViewController(animated: true)
        } else {
            UIPasteboard.general.string = dataSource![indexPath.row].walletAddress ?? ""
            showMessage(text: Localized("ExportVC_copy_success"))
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if selectionCompletion != nil {
            return nil
        }

        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .default, title: Localized("AddressBookVC_cell_delete_title")) { action, indexPath in

            AddressBookService.service.delete(addressInfo: self.dataSource![indexPath.row])
            self.dataSource?.remove(at: indexPath.row)
            action.fulfill(with: .delete)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = UIColor(rgb: 0xF5302C)
        deleteAction.textColor = UIColor(rgb: 0xFAFAFA)
        deleteAction.font = UIFont.systemFont(ofSize: 14)
        deleteAction.hidesWhenSelected = true

        let editAction = SwipeAction(style: .default, title: Localized("AddressBookVC_cell_edit_title")) { (_, indexPath) in

            let vc = NewAddressInfoViewController()
            vc.addCompletion = { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self?.initData()
                })
            }
            vc.fromScene = .edit
            vc.addressInfo = self.dataSource![indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        editAction.backgroundColor = UIColor(rgb: 0xF0F1F5)
        editAction.textColor = .black
        editAction.font = UIFont.systemFont(ofSize: 14)
        editAction.hidesWhenSelected = true
        return [deleteAction, editAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {

        var options = SwipeOptions()
        options.maximumButtonWidth = 60

        //设置expansionstyle会左拉到底会自动删除
//        options.expansionStyle = expansionStyle
        options.transitionStyle = .border
        return options
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //bug fix for below ios10 tableView cannot response separatorInset
        if #available(iOS 10, *) {

        } else {
            cell.layoutMargins = .zero
        }
    }

}
