//
//  SelectWalletTableHeader.swift
//  platonWallet
//
//  Created by juzix on 2020/7/20.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class SelectWalletTableHeader: UITableViewHeaderFooterView {

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    fileprivate let titleLabel = UILabel()
    

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(hex: "F9FBFF")
        contentView.backgroundColor = UIColor(hex: "F9FBFF")

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
