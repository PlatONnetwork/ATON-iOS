//
//  StakingLabelViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import SnapKit

class StakingLabelViewCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
