//
//  CommunityViewController.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CommunityViewController: BaseViewController {
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(CommunityNameTableViewCell.self, forCellReuseIdentifier: "CommunityNameTableViewCell")
        tbView.register(CommunityContentTableViewCell.self, forCellReuseIdentifier: "CommunityContentTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        return tbView
    }()
    
    var listData: [CommunityCellStyle] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = normal_background_color
        
        let item1 = CommunityCellStyle(avatar: "4.icon-WeChat", name: Localized("community_contact_wechat"), contacts:
            [
            CommunityContactStyle(contact: Localized("community_contact_wechat_group") + "CatherinePlatON", action: .scan),
            CommunityContactStyle(contact: Localized("community_contact_wechat_open") + "CatherinePlatON", action: .scan)]
        )
        let item2 = CommunityCellStyle(avatar: "4.icon-Telegram", name: Localized("community_contact_telegram"), contacts: [
            CommunityContactStyle(contact: "https://t.me/PlatONHK", action: .link)]
        )
        let item3 = CommunityCellStyle(avatar: "4.icon-GitHub", name: Localized("community_contact_gitHub"), contacts: [
            CommunityContactStyle(contact: "https://github.com/PlatONnetwork", action: .link)]
        )
        let item4 = CommunityCellStyle(avatar: "4.icon-Twitter", name: Localized("community_contact_twitter"), contacts: [
            CommunityContactStyle(contact: "https://twitter.com/PlatON_Network", action: .link)]
        )
        let item5 = CommunityCellStyle(avatar: "4.icon-Facebook", name: Localized("community_contact_facebook"), contacts: [
            CommunityContactStyle(contact: "https://facebook.com/PlatONNet work/", action: .link)]
        )
        
        listData.append(contentsOf: [item1, item2, item3, item4, item5])
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData[section].contacts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let style = listData[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityNameTableViewCell") as! CommunityNameTableViewCell
            cell.avatarIV.image = UIImage(named: style.avatar)
            cell.nameLabel.text = style.name
            return cell
        } else {
            let contact = style.contacts[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityContentTableViewCell") as! CommunityContentTableViewCell
            cell.contact = contact
            
            if indexPath.row == style.contacts.count {
                cell.lineLeadingConstraint?.deactivate()
            } else {
                cell.lineLeadingConstraint?.activate()
            }
            
            cell.cellDidCopyHandle = { content in
                if content?.count ?? 0 > 0 {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = content!
                    UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("ExportVC_copy_success"))
                }
            }
            cell.cellDidRightHandle = { [weak self] in
                switch contact.action {
                case .link:
                    UIApplication.shared.openURL(URL(string: contact.contact)!)
                case .scan:
                    self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row - 1, section: indexPath.section)], with: .fade)
                }
            }
            return cell
        }
    }
}
