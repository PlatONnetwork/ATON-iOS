//
//  NodeSearchBarView.swift
//  platonWallet
//
//  Created by Admin on 5/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeSearchBarView: UIView {

    let searchBar = UISearchBar()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = .clear

        searchBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 40)
        searchBar.backgroundImage = UIImage()
        searchBar.setImage(UIImage(), for: .search, state: .focused)
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.showsCancelButton = true
        let cancelButton = searchBar.value(forKey: "cancelButton") as! UIButton
        cancelButton.setTitle(Localized("mydelegates_search_cancel"), for: .normal)
        cancelButton.setTitleColor(common_blue_color, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            if #available(iOS 11.0, *) {
                textField.layer.cornerRadius = 18.0
            } else {
                textField.layer.cornerRadius = 14.0
            }
            textField.backgroundColor = normal_background_color
            textField.layer.borderColor = common_blue_color.cgColor
            textField.layer.borderWidth = 1
            textField.font = .systemFont(ofSize: 14)
            textField.LocalizePlaceholder = "mydelegates_search_placeholder"
        }

        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
    }



}
