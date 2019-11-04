//
//  CreateImportCollectionViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class CreateImportCollectionViewCell: UICollectionViewCell {

    let bgView = UIView()
    let functionIcon = UIImageView()
    let functionLabel = UILabel()

    var index: Int? {
        didSet {
            if index == 0 {
                functionIcon.image = UIImage(named: "cellItemCreate")
                functionLabel.localizedText = "AddWalletMenuVC_createIndividualWallet_title"
            } else {
                functionIcon.image = UIImage(named: "cellItemImport")
                functionLabel.localizedText = "AddWalletMenuVC_importIndividualWallet_title"
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(functionIcon)
        functionIcon.snp.makeConstraints { make in
            make.height.width.equalTo(26)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }

        functionLabel.font = UIFont.systemFont(ofSize: 8)
        functionLabel.textAlignment = .center
        functionLabel.textColor = UIColor(rgb: 0xB6BBD0)
        contentView.addSubview(functionLabel)
        functionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
            make.top.equalTo(functionIcon.snp.bottom)
        }

        bgView.addDashedBorder()
    }
}

extension UIView {
    func addDashedBorder() {
        let color = UIColor(rgb: 0xE4E7F3).cgColor
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color
        yourViewBorder.lineDashPattern = [6, 3]
        yourViewBorder.lineWidth = 1.0
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.lineJoin = CAShapeLayerLineJoin.round
        yourViewBorder.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 108, height: 52)).cgPath
        layer.addSublayer(yourViewBorder)
    }
}
