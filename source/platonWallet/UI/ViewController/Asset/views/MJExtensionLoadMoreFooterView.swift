//
//  MJExtensionLoadMoreFooterView.swift
//  platonWallet
//
//  Created by Admin on 22/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import MJRefresh
import Localize_Swift

class MJExtensionLoadMoreFooterView: MJRefreshAutoFooter {
    
    var loadMoreTapHandle: (() -> Void)?
    
    override func prepare() {
        super.prepare()
        
        self.mj_h = 69;
        
        let moreButton = UIButton()
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        moreButton.setTitleColor(UIColor(hex: "105cfe"), for: .normal)
        moreButton.setTitle(Localized("transaction_loadmore_text"), for: .normal)
        moreButton.addTarget(self, action: #selector(loadMoreTapAction), for: .touchUpInside)
        self.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func loadMoreTapAction() {
        loadMoreTapHandle?()
    }
}


