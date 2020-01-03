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

class ThresholdValueSelectView<T>: UIView, UITableViewDelegate, UITableViewDataSource {

    let thresholdCellHeight: Float = 46.0
    var datasource: [T]!
    var selectedValue: T!
    var valueChangedHandler: ((T) -> Void)?
    private var tableviewBottomConstraint: Constraint?

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(ThresholdSelectCell.self, forCellReuseIdentifier: "thresholdCellIdentifier")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.rowHeight = CGFloat(thresholdCellHeight)
        tbView.layer.cornerRadius = 8.0
        tbView.layer.masksToBounds = true
        return tbView
    }()

    convenience init(listData: [T], selected: T, title: String? = nil) {
        self.init(frame: .zero)
        self.datasource = listData
        self.selectedValue = selected

        setupSubviews(title: title)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews(title: String?) {
        backgroundColor = UIColor(rgb: 0x000000, alpha: 0.65)

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            tableviewBottomConstraint = make.bottom.equalToSuperview().offset(Float(datasource.count) * thresholdCellHeight).constraint
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            if title == nil {
                make.height.equalTo(Float(datasource.count) * thresholdCellHeight)
            } else {
                make.height.equalTo(Float(datasource.count + 1) * thresholdCellHeight)
            }
        }

        if let string = title {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat(thresholdCellHeight)))
            tableView.tableHeaderView = headerView
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .black
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.text = string
            headerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(13)
                make.bottom.equalToSuperview().offset(-13)
            }

            let lineV = UIView()
            lineV.backgroundColor = UIColor(rgb: 0xe4e7f3)
            headerView.addSubview(lineV)
            lineV.snp.makeConstraints { make in
                make.height.equalTo(1/UIScreen.main.scale)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview()
            }
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
        viewController.tabBarController?.view.addSubview(self)

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
        tableviewBottomConstraint?.update(offset: Float(datasource.count) * thresholdCellHeight)
        UIView.animate(withDuration: 0.15, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
        let item = datasource[indexPath.row]

        if let itemBigUint = item as? BigUInt {
            cell.titleLabel.text = (itemBigUint/PlatonConfig.VON.LAT).description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()
            cell.selectedIV.isHidden = itemBigUint != (selectedValue as! BigUInt)
        } else if let itemSort = item as? NodeSort {
            cell.titleLabel.text = itemSort.text
            cell.selectedIV.isHidden = itemSort != (selectedValue as! NodeSort)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datasource[indexPath.row]

        if let itemBigUint = item as? BigUInt, itemBigUint == (selectedValue as! BigUInt) {
            tableView.reloadData()
            return
        } else if let itemSort = item as? NodeSort, itemSort == (selectedValue as! NodeSort) {
            tableView.reloadData()
            return
        }

        selectedValue = item
        tableView.reloadData()
        valueChangedHandler?(selectedValue)
        dismiss()
    }
}

//extension ThresholdValueSelectView<T>: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return datasource.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
//        let item = datasource[indexPath.row]
//        cell.titleLabel.text = (item/PlatonConfig.VON.LAT).description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()
//        cell.selectedIV.isHidden = (item != selectedValue)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = datasource[indexPath.row]
//        guard item != selectedValue else {
//            tableView.reloadData()
//            return
//        }
//        selectedValue = item
//        tableView.reloadData()
//        valueChangedHandler?(selectedValue)
//        dismiss()
//    }
//}

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
