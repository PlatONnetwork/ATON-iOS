//
//  SingleButtonTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class SingleButtonTableViewCell: UITableViewCell {
    
    public let button = PButton()
//    public var canDelegation: CanDelegation? {
//        didSet {
//            if canDelegation == nil {
//                button.style = .disable
//            } else {
//                button.style = canDelegation!.canDelegation ? .blue : .disable
//            }
//        }
//    }
    
    public var unavaliableTapAction: Bool = false {
        didSet {
            if unavaliableTapAction {
                button.style = .disable
            } else {
                button.style = .blue
            }
        }
    }
    
    var cellDidTapHandle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color
        
        
        button.frame = CGRect(x: 16, y: 16, width: UIScreen.main.bounds.width - 32, height: 44)
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        button.style = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction() {
        cellDidTapHandle?()
    }

}
