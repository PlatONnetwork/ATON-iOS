//
//  WalletBalanceTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class WalletBalanceTableViewCell: UITableViewCell {

    public let balanceTipLabel = UILabel()
    public let balanceLabel = UILabel()
    public let rightImageView = UIImageView()
    public let bottomlineV = UIView()
    public let containerView = UIButton()
    
    var cellDidHandle: ((_ cell: WalletBalanceTableViewCell) -> Void)?
    
    func setupBalanceData(_ balance: (String, String)) {
        balanceTipLabel.text = balance.0
        balanceLabel.text = (balance.1.vonToLATString ?? "0").balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }
    
    var isTopCell: Bool = false {
        didSet {
            containerView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(isTopCell ? 14 : 0)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = normal_background_color
        
        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        
        balanceTipLabel.textColor = .black
        balanceTipLabel.font = .systemFont(ofSize: 15)
        balanceTipLabel.text = Localized("statking_validator_Balance")
        balanceTipLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        containerView.addSubview(balanceTipLabel)
        balanceTipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
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
