//
//  TransactionDetailHeaderView.swift
//  platonWallet
//
//  Created by Admin on 6/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import SnapKit
import Localize_Swift

class TransactionDetailHeaderView: UIView {
    
    public let statusIconImageVIew = UIImageView()
    public let pendingLoadingImage = UIImageView()
    
    public let statusLabel = UILabel()
    public let fromLabel = UILabel()
    public let toLabel = UILabel()
    
    public let copyFromAddrBtn = CopyButton()
    public let copyToAddrBtn = CopyButton()
    
    public let detailContainer = UIView()
    public let walletNameLabel = UILabel()
    public let fromAvatarIV = UIImageView()
    public let fromNameLabel = UILabel()
    public let toAvatarIV = UIImageView()
    public let toNameLabel = UILabel()
    public let topValueLabel = UILabel()
    public let toIconIV = UIImageView()
    
    var baseInfoTopConstraint: Constraint?
    var toLabelLeadingConstraint: Constraint?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(statusIconImageVIew)
        statusIconImageVIew.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(45)
        }
        
        addSubview(pendingLoadingImage)
        pendingLoadingImage.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerX.equalTo(statusIconImageVIew.snp.centerX).offset(-5)
            make.centerY.equalTo(statusIconImageVIew.snp.centerY).offset(3)
        }
        
        statusLabel.textColor = .black
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 20)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(statusIconImageVIew.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(29)
        }

        let baseInfoView = UIView()
        addSubview(baseInfoView)
        baseInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(statusLabel.snp.bottom)
        }

        topValueLabel.font = .systemFont(ofSize: 24, weight: .medium)
        baseInfoView.addSubview(topValueLabel)
        topValueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(15)
        }

        let arrowIV = UIImageView()
        arrowIV.image = UIImage(named: "2.icon_right")
        baseInfoView.addSubview(arrowIV)
        arrowIV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
            baseInfoTopConstraint = make.top.equalTo(topValueLabel.snp.bottom).offset(22).constraint
            make.top.equalToSuperview().offset(22).priorityMedium()
            make.bottom.equalToSuperview().offset(-22)
        }

        fromNameLabel.textColor = .black
        fromNameLabel.font = .systemFont(ofSize: 15)
        fromNameLabel.textAlignment = .right
        baseInfoView.addSubview(fromNameLabel)
        fromNameLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIV.snp.leading).offset(-10)
            make.centerY.equalTo(arrowIV.snp.centerY)
        }

        baseInfoView.addSubview(fromAvatarIV)
        fromAvatarIV.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalTo(arrowIV.snp.centerY)
            make.trailing.equalTo(fromNameLabel.snp.leading).offset(-4)
        }

        baseInfoView.addSubview(toAvatarIV)
        toAvatarIV.snp.makeConstraints { make in
            make.leading.equalTo(arrowIV.snp.trailing).offset(6)
            make.width.height.equalTo(30)
            make.centerY.equalTo(arrowIV.snp.centerY)
        }

        toNameLabel.textColor = .black
        toNameLabel.font = .systemFont(ofSize: 15)
        baseInfoView.addSubview(toNameLabel)
        toNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(toAvatarIV.snp.trailing).offset(5)
            make.centerY.equalTo(arrowIV.snp.centerY)
        }


        let baseInfoLineV = UIView()
        baseInfoLineV.backgroundColor = common_line_color
        baseInfoView.addSubview(baseInfoLineV)
        baseInfoLineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.bottom.trailing.equalToSuperview()
        }

        let fromTipLabel = UILabel()
        fromTipLabel.text = "From:"
        fromTipLabel.textColor = .black
        fromTipLabel.font = .systemFont(ofSize: 14)
        addSubview(fromTipLabel)
        fromTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(baseInfoView.snp.bottom).offset(16)
        }

        let fromContainerView = UIView()
        fromContainerView.backgroundColor = normal_background_color
        addSubview(fromContainerView)
        fromContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(fromTipLabel.snp.bottom).offset(8)
        }

        fromLabel.textColor = common_lightLightGray_color
        fromLabel.font = .systemFont(ofSize: 12)
        fromContainerView.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(-31)
        }

        copyFromAddrBtn.setImage(UIImage(named: "copyIcon"), for: .normal)
        fromContainerView.addSubview(copyFromAddrBtn)
        copyFromAddrBtn.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let toTipLabel = UILabel()
        toTipLabel.text = "To:"
        toTipLabel.textColor = .black
        toTipLabel.font = .systemFont(ofSize: 14)
        addSubview(toTipLabel)
        toTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(fromContainerView.snp.bottom).offset(16)
        }

        let toContainerView = UIView()
        toContainerView.backgroundColor = normal_background_color
        addSubview(toContainerView)
        toContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(toTipLabel.snp.bottom).offset(8)
//            make.bottom.equalToSuperview().offset(-16)
        }

        toIconIV.image = UIImage(named: "2.icon_Shared2")
        toContainerView.addSubview(toIconIV)
        toIconIV.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }


        toLabel.textColor = common_lightLightGray_color
        toLabel.font = .systemFont(ofSize: 12)
        toContainerView.addSubview(toLabel)
        toLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
//            toLabelLeadingConstraint = make.leading.equalTo(toIconIV.snp.trailing).offset(3).constraint
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(-31)
        }

        copyToAddrBtn.setImage(UIImage(named: "copyIcon"), for: .normal)
        toContainerView.addSubview(copyToAddrBtn)
        copyToAddrBtn.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let bottomLineV = UIView()
        bottomLineV.backgroundColor = common_line_color
        addSubview(bottomLineV)
        bottomLineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(toContainerView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        copyFromAddrBtn.attachTextView = fromLabel
        copyToAddrBtn.attachTextView = toLabel
        pendingLoadingImage.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateContent(tx: Transaction) {
        
        updateStatus(tx: tx)
        
        fromLabel.text = tx.from
        toLabel.text = tx.to
        
        if let w = WalletService.sharedInstance.getWalletByAddress(address: tx.from ?? ""){
            self.walletNameLabel.text = w.name
        } else {
            let walletNames = AddressBookService.service.getAll().filter { $0.walletAddress == tx.from }.map { $0.walletName }
            guard walletNames.count > 0 else { return }
            self.walletNameLabel.text = walletNames.first!
        }
        
        toNameLabel.text = tx.toNameString
        fromNameLabel.text = tx.fromNameString
        toAvatarIV.image = tx.toAvatarImage
        fromAvatarIV.image = tx.fromAvatarImage
        
        if let valueString = tx.valueString.0, let color = tx.valueString.1 {
            topValueLabel.text = valueString
            topValueLabel.textColor = color
        } else {
            topValueLabel.text = nil
            baseInfoTopConstraint?.deactivate()
        }
        
        toIconIV.image = tx.toIconImage
        if tx.toIconImage == nil {
            toLabelLeadingConstraint?.deactivate()
        }
    }
    
    func updateStatus(tx : Transaction){
        
        //        if tx.txType == .transfer  {
        //            transactionTypeLabel.text = tx.direction.localizedDesciption
        //        } else {
        //            transactionTypeLabel.text = tx.txType?.localizeTitle
        //        }
        
        statusLabel.text = tx.transactionStauts.localizeDescAndColor.0
        statusLabel.textColor = .black
        switch tx.transactionStauts {
        case .sending, .receiving, .voting:
            statusIconImageVIew.image = UIImage(named: "statusPending")
            self.pendingLoadingImage.isHidden = false
            self.pendingLoadingImage.rotate()
        case .sendSucceed, .receiveSucceed, .voteSucceed:
            self.pendingLoadingImage.isHidden = true
            statusIconImageVIew.image = UIImage(named: "statusSuccess")
        case .sendFailed, .receiveFailed, .voteFailed:
            self.pendingLoadingImage.isHidden = true
            statusIconImageVIew.image = UIImage(named: "statusFail")
        }
        
        
    }
}
