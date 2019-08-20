//
//  WalletBalanceTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WalletBalanceTableViewCell: UITableViewCell {

    public let balanceTipLabel = UILabel()
    public let balanceLabel = UILabel()
    public let rightImageView = UIImageView()
    public let bottomlineV = UIView()
    
    var cellDidHandle: ((_ cell: WalletBalanceTableViewCell) -> Void)?
    
    func setupBalanceData(_ balance: (String, String)) {
        balanceTipLabel.text = balance.0
        balanceLabel.text = balance.1.vonToLATString.balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let containerView = UIButton()
        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }
        
        
        balanceTipLabel.textColor = .black
        balanceTipLabel.font = .systemFont(ofSize: 15)
        balanceTipLabel.text = Localized("statking_validator_Balance")
        containerView.addSubview(balanceTipLabel)
        balanceTipLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(15)
        }
        
        
        balanceLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        balanceLabel.textColor = .black
        balanceLabel.textAlignment = .right
        balanceLabel.text = "0"
        containerView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(balanceTipLabel)
            make.leading.equalTo(balanceTipLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-44)
            make.height.equalTo(18)
        }
        
        containerView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        bottomlineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        containerView.addSubview(bottomlineV)
        bottomlineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func containerTapAction() {
        cellDidHandle?(self)
    }

}
