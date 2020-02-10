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

enum PopSelectedViewType {
    case none
    case sort(datasource: [NodeSort], selected: NodeSort)
    case threshold(datasource: [BigUInt], selected: BigUInt)
    case delegate(datasource: [(String, String, Bool)], selected: (String, String, Bool))

    var count: Int {
        switch self {
        case .sort(let datasource, _):
            return datasource.count
        case .threshold(let datasource, _):
            return datasource.count
        case .delegate(let datasource, _):
            return datasource.count
        default:
            return 0
        }
    }
}

class ThresholdValueSelectView: UIView, UITableViewDelegate, UITableViewDataSource {

    var type: PopSelectedViewType = PopSelectedViewType.none
    var cellHeight: CGFloat {
        switch type {
        case .delegate(_, _):
            return 62.0
        default:
            return 46.0
        }
    }
    var valueChangedHandler: ((PopSelectedViewType) -> Void)?
    private var tableviewBottomConstraint: Constraint?

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(ThresholdSelectCell.self, forCellReuseIdentifier: "thresholdCellIdentifier")
        tbView.register(BalanceSelectCell.self, forCellReuseIdentifier: "balanceSelectCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = cellHeight
        }
        tbView.layer.cornerRadius = 8.0
        tbView.layer.masksToBounds = true
        return tbView
    }()

    convenience init(title: String? = nil, type: PopSelectedViewType) {
        self.init(frame: .zero)
        self.type = type

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
            tableviewBottomConstraint = make.bottom.equalToSuperview().offset(CGFloat(type.count) * cellHeight).constraint
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            if title == nil {
                make.height.equalTo(CGFloat(type.count) * cellHeight)
            } else {
                make.height.equalTo(CGFloat(type.count + 1) * cellHeight)
            }
        }

        if let string = title {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: cellHeight))
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
        tableviewBottomConstraint?.update(offset: CGFloat(type.count) * cellHeight)
        UIView.animate(withDuration: 0.15, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch type {
        case .delegate(let datasource, let selectedValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: "balanceSelectCell") as! BalanceSelectCell
            cell.titleLabel.text = datasource[indexPath.row].0
            cell.valueLabel.text = datasource[indexPath.row].1.vonToLATString?.balanceFixToDisplay(maxRound: 8).ATPSuffix()
            cell.selectedIV.isHidden = datasource[indexPath.row] != selectedValue
            return cell
        case .sort(let datasource, let selectedValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
            cell.titleLabel.text = datasource[indexPath.row].text
            cell.selectedIV.isHidden = datasource[indexPath.row] != selectedValue
            return cell
        case .threshold(let datasource, let selectedValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
            let itemBigUint = datasource[indexPath.row]
            cell.titleLabel.text = (itemBigUint/PlatonConfig.VON.LAT).description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()
            cell.selectedIV.isHidden = itemBigUint != selectedValue
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .delegate(let datasource, var selectedValue):
            let item = datasource[indexPath.row]
            if item == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = item
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.delegate(datasource: [], selected: selectedValue))
            dismiss()
        case .sort(let datasource, var selectedValue):
            let item = datasource[indexPath.row]
            if item == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = item
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.sort(datasource: [], selected: selectedValue))
            dismiss()
        case .threshold(let datasource, var selectedValue):
            let item = datasource[indexPath.row]
            if item == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = item
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.threshold(datasource: [], selected: selectedValue))
            dismiss()
        default:
            break
        }


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

class BalanceSelectCell: UITableViewCell {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let selectedIV = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-52)
        }

        valueLabel.textColor = .black
        valueLabel.font = .systemFont(ofSize: 12)
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-10)
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

class ThresholdSelectCell: UITableViewCell {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
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
