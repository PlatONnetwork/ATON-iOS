//
//  TSLViewController.swift
//  platonWallet
//
//  Created by Ned on 11/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class TSLViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        self.navigationController?.isNavigationBarHidden = true
        
        let button = UIButton(type: .custom)
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        button.addTarget(self, action: #selector(onNext), for: .touchUpInside)
    }
    
    @objc func onNext(){
        self.navigationController?.pushViewController(TSLViewControllerTwo(), animated: false)
    }

}

class TSLViewControllerTwo: BaseViewController {
    override func viewDidLoad() {
        self.view.backgroundColor = .green
    }
}
