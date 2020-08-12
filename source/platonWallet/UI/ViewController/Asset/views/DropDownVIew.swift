//
//  DropDownVIew.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import SnapKit

// MARK: - MenuItem

public struct MenuItem {
    var icon: UIImage?
    var title: String?

    public init(icon: UIImage?, title: String?) {
        self.icon = icon
        self.title = title
    }
}

// MARK: - PopupMenuTableDelegate

@objc public protocol PopupMenuTableDelegate {

    func popupMenu(_ popupMenu: PopupMenuTable, didSelectAt index: Int)
}

// MARK: - PopupMenuTable

public enum PopupMenuTableArrowPosition {
    case left
    case right
}

public let menuWidth : CGFloat = 145

public class PopupMenuTable: UIView {

    var menuCellSize: CGSize = CGSize(width: menuWidth, height: 48)
    var menuTextFont: UIFont = .systemFont(ofSize: 14)
    var menuTextColor: UIColor = .black
    var menuBackgroundColor: UIColor = .white
    var menuLineColor: UIColor = UIColor(rgb: 0xEBEEF4)

    var tableViewStartPoint: CGPoint = .zero
    var arrowWidth: CGFloat = 10
    var arrowHeight: CGFloat = 10
    var arrowOffset: CGFloat = 10
    var arrowPoint: CGPoint = .zero
    var arrowPosition: PopupMenuTableArrowPosition = .right

    var contentBgColor: UIColor = UIColor.black.withAlphaComponent(0.6)

    public weak var delegate: PopupMenuTableDelegate?

    fileprivate let CellID = "MenuCell"

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.bounces = false
        tableView.layer.cornerRadius = 5
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(MenuCell.self, forCellReuseIdentifier: CellID)
        return tableView
    }()

    var menuArray: [MenuItem] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    // MARK: - Initialization

    public init(menuArray: [MenuItem], arrowPoint: CGPoint,
                cellSize: CGSize = CGSize(width: menuWidth, height: 44),
                arrowPosition: PopupMenuTableArrowPosition = .right,
                frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) {

        super.init(frame: frame)

        self.arrowPoint = arrowPoint
        self.menuCellSize = cellSize
        self.arrowPosition = arrowPosition
        self.backgroundColor = contentBgColor

        switch arrowPosition {
        case .left:
            let x = arrowPoint.x - arrowWidth/2 - arrowOffset
            let y = arrowPoint.y + arrowHeight
            tableViewStartPoint = CGPoint(x: x, y: y)
            tableView.frame = CGRect(x: x,
                                     y: y,
                                     width: cellSize.width,
                                     height: cellSize.height*CGFloat(menuArray.count))
        case .right:
            let x = arrowPoint.x + arrowWidth/2 + arrowOffset
            let y = arrowPoint.y + arrowHeight
            tableViewStartPoint = CGPoint(x: x, y: y)
            tableView.frame = CGRect(x: x,
                                     y: y,
                                     width: -cellSize.width,
                                     height: cellSize.height*CGFloat(menuArray.count))
        }

        self.addSubview(tableView)

        self.menuArray = menuArray

        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        if self.arrowPosition == .left {
            let startX = self.arrowPoint.x - arrowWidth/2
            let startY = self.arrowPoint.y + arrowHeight
            context?.move(to: CGPoint(x: startX, y: startY))
            context?.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.y))
            context?.addLine(to: CGPoint(x: startX + arrowWidth, y: startY))
        } else {
            let startX = self.arrowPoint.x + arrowWidth/2
            let startY = self.arrowPoint.y + arrowHeight
            context?.move(to: CGPoint(x: startX, y: startY))
            context?.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.y))
            context?.addLine(to: CGPoint(x: startX - arrowWidth, y: startY))
        }
        context?.closePath()
        self.tableView.backgroundColor?.setFill()
        self.tableView.backgroundColor?.setStroke()
        context?.drawPath(using: .fillStroke)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
}

// MARK: - Public Function

extension PopupMenuTable {

    public func popUp() {
        let frame = self.tableView.frame
        self.tableView.frame = CGRect(x: tableViewStartPoint.x, y: tableViewStartPoint.y, width: 0, height: 0)
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame = frame
        }
    }

    public func dismiss() {
        self.removeFromSuperview()
        return
//        UIView.animate(withDuration: 0.2, animations: {
//            self.tableView.frame = CGRect(x: self.tableViewStartPoint.x, y: self.tableViewStartPoint.y, width: 0, height: 0)
//        }) { (finished) in
//            self.removeFromSuperview()
//        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PopupMenuTable: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.menuCellSize.height
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! MenuCell
        let menu = self.menuArray[indexPath.row]
        cell.configureCell(menu: menu)
        cell.titleLabel.font = menuTextFont
        cell.titleLabel.textColor = menuTextColor
        cell.line.isHidden = (indexPath.row < menuArray.count - 1) ? false : true
        cell.line.backgroundColor = menuLineColor
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss()
        self.delegate?.popupMenu(self, didSelectAt: indexPath.row)
    }
}

class MenuCell: UITableViewCell {

    lazy var iconView: UIImageView = UIImageView()
    lazy var titleLabel: UILabel = UILabel()
    lazy var line: UIView = UIView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Function

extension MenuCell {

    private func setUpCell() {
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.line)

        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.equalTo(20)
            make.height.equalTo(18)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(3)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(38)
            make.right.equalToSuperview().inset(0)
            make.height.equalTo(1)
        }
    }
}

extension MenuCell {

    func configureCell(menu: MenuItem) {
        titleLabel.text = menu.title

        if let icon = menu.icon {
            iconView.image = icon

        } else {
            iconView.isHidden = true
            titleLabel.snp.remakeConstraints({ (make) in
                make.left.right.equalToSuperview().inset(8)
                make.top.bottom.equalToSuperview().inset(5)
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.adjustsFontSizeToFitWidth = true
    }
}
