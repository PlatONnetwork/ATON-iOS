//
//  CreateImportCollectionViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class CreateImportCollectionViewCell: UICollectionViewCell, CellConfigurable {

    let bgView = UIView()
    let functionIcon = UIImageView()
    let functionLabel = UILabel()

    var viewModel: AssetGenerateViewModel?

    lazy var lineShapeLayer: CAShapeLayer = {
        let color = UIColor(rgb: 0xE4E7F3).cgColor
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color
        yourViewBorder.lineDashPattern = [6, 3]
        yourViewBorder.lineWidth = 1.0
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.lineJoin = CAShapeLayerLineJoin.round
        return yourViewBorder
    }()

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AssetGenerateViewModel else { return }
        self.viewModel = viewModel

        functionIcon.image = viewModel.icon
        functionLabel.localizedText = viewModel.title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        bgView.backgroundColor = .white
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(functionIcon)
        functionIcon.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(14)
        }

        functionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        functionLabel.textColor = common_blue_color
        contentView.addSubview(functionLabel)
        functionLabel.snp.makeConstraints { make in
            make.leading.equalTo(functionIcon.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        bgView.layer.addSublayer(lineShapeLayer)
    }

    override func layoutSubviews() {
        lineShapeLayer.path = UIBezierPath(rect: bgView.bounds).cgPath
        super.layoutSubviews()
    }
}
