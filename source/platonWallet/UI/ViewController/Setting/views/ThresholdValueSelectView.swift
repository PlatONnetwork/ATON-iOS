//
//  ThresholdValueSelectView.swift
//  platonWallet
//
//  Created by Admin on 4/12/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import platonWeb3
import SnapKit

class ThresholdValueSelectView: UIView {

    static let thresholdCellHeight: Float = 46.0
    var datasource: [BigUInt]!
    var selectedValue: BigUInt!
    var valueChangedHandler: ((BigUInt) -> Void)?
    private var tableviewBottomConstraint: Constraint?

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(ThresholdSelectCell.self, forCellReuseIdentifier: "thresholdCellIdentifier")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.rowHeight = CGFloat(ThresholdValueSelectView.thresholdCellHeight)
        tbView.layer.cornerRadius = 8.0
        tbView.layer.masksToBounds = true
        return tbView
    }()

    convenience init(listData: [BigUInt], selected: BigUInt) {
        self.init(frame: .zero)
        self.datasource = listData
        self.selectedValue = selected
        setupSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        backgroundColor = UIColor(rgb: 0x000000, alpha: 0.65)

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            tableviewBottomConstraint = make.bottom.equalToSuperview().offset(Float(datasource.count) * ThresholdValueSelectView.thresholdCellHeight).constraint
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(Float(datasource.count) * ThresholdValueSelectView.thresholdCellHeight)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard
            let touch = touches.first,
            !tableView.frame.contains(touch.location(in: self))
        else { return }
        dismiss()
    }

    func show(viewController: UIViewController) {
        viewController.navigationController?.view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        layoutIfNeeded()
        tableviewBottomConstraint?.update(offset: -16)
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }

    func dismiss() {
        tableviewBottomConstraint?.update(offset: Float(datasource.count) * ThresholdValueSelectView.thresholdCellHeight)
        UIView.animate(withDuration: 0.15, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension ThresholdValueSelectView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
        let item = datasource[indexPath.row]
        cell.titleLabel.text = (item/PlatonConfig.VON.LAT).description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()
        cell.selectedIV.isHidden = (item != selectedValue)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datasource[indexPath.row]
        guard item != selectedValue else {
            tableView.reloadData()
            return
        }
        selectedValue = item
        tableView.reloadData()
        valueChangedHandler?(selectedValue)
        dismiss()
    }
}

class ThresholdSelectCell: UITableViewCell {
    let titleLabel = UILabel()
    let selectedIV = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 15)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-13)
            make.trailing.equalToSuperview().offset(-52)
        }

        selectedIV.image = UIImage(named: "iconApprove")
        contentView.addSubview(selectedIV)
        selectedIV.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        let lineV = UIView()
        lineV.backgroundColor = UIColor(rgb: 0xe4e7f3)
        contentView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
