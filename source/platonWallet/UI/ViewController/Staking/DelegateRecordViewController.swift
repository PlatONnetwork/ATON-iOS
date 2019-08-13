//
//  DelegateRecordViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class DelegateRecordViewController: BaseViewController, IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var itemInfo: IndicatorInfo = "All"
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(DelegateRecordTableViewCell.self, forCellReuseIdentifier: "DelegateRecordTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        return tbView
    }()
    
    init(itemInfo: String) {
        self.itemInfo = IndicatorInfo(title: itemInfo)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = normal_background_color
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

extension DelegateRecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DelegateRecordTableViewCell") as! DelegateRecordTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}
