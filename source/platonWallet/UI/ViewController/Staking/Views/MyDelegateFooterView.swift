//
//  MyDelegateFooterView.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class MyDelegateFooterView: UIView {
    
    public let faqButton = UIButton()
    public let turButton = UIButton()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        faqButton.setCornerLineStyle(UIImage(named: "3.icon_problem"), Localized("staking_main_delegate_faq"))
        turButton.setCornerLineStyle(UIImage(named: "3.icon_tutorial"), Localized("staking_main_delegate_tutorial"))
        
        addSubview(faqButton)
        faqButton.snp.makeConstraints { make in
            make.width.equalTo(140).priorityLow()
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(33)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        addSubview(turButton)
        turButton.snp.makeConstraints { make in
            make.width.equalTo(140).priorityLow()
            make.height.equalTo(40)
            make.trailing.equalToSuperview().offset(-33)
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
