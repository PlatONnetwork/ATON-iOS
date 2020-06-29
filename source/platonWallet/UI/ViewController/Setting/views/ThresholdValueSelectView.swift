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
    case delegate(datasource: [(String, String, Bool)], selected: Int)

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
        case .delegate:
            return 62.0
        default:
            return 50.0
        }
    }
    var valueChangedHandler: ((PopSelectedViewType) -> Void)?
    var onCompletion: (() -> Void)?
    private var tableviewBottomConstraint: Constraint?

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(ThresholdSelectCell.self, forCellReuseIdentifier: "thresholdCellIdentifier")
        tbView.register(BalanceSelectCell.self, forCellReuseIdentifier: "balanceSelectCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.rowHeight = cellHeight
//        if #available(iOS 11, *) {
//            tbView.estimatedRowHeight = UITableView.automaticDimension
//        } else {
//            tbView.estimatedRowHeight = cellHeight
//        }
        return tbView
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "1.icon_shut down"), for: .normal)
        return button
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

    lazy var headerView = UIView()
    func setupSubviews(title: String?) {
        headerView.backgroundColor = .white
        headerView.isUserInteractionEnabled = true

        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = title
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
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

        headerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(label)
            make.height.width.equalTo(32)
        }

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
    }


    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard
            let touch = touches.first,
            !headerView.frame.contains(touch.location(in: headerView))
        else { return }
        dismiss()
    }*/

    func show(viewController: UIViewController) {
        viewController.tabBarController?.view.addSubview(self)

        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        layoutIfNeeded()
        tableviewBottomConstraint?.update(offset: 0)
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
            cell.selectedIV.isHidden = indexPath.row != selectedValue
            return cell
        case .sort(let datasource, let selectedValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
            cell.titleLabel.text = datasource[indexPath.row].text
            cell.selectedIV.isHidden = datasource[indexPath.row] != selectedValue
            return cell
        case .threshold(let datasource, let selectedValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: "thresholdCellIdentifier") as! ThresholdSelectCell
            let itemBigUint = datasource[indexPath.row]
            cell.titleLabel.text = (itemBigUint/PlatonConfig.VON.LAT).description.ATPSuffix()
            cell.selectedIV.isHidden = itemBigUint != selectedValue
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .delegate(let datasource, var selectedValue):
            if indexPath.row == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = indexPath.row
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.delegate(datasource: [], selected: selectedValue))
        case .sort(let datasource, var selectedValue):
            let item = datasource[indexPath.row]
            if item == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = item
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.sort(datasource: [], selected: selectedValue))
        case .threshold(let datasource, var selectedValue):
            let item = datasource[indexPath.row]
            if item == selectedValue {
                tableView.reloadData()
                return
            }
            selectedValue = item
            tableView.reloadData()
            valueChangedHandler?(PopSelectedViewType.threshold(datasource: [], selected: selectedValue))
        default:
            break
        }
        onCompletion?()

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
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
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
