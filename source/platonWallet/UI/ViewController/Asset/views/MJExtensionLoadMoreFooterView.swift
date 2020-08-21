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
    var moreButton = UIButton()
    override func prepare() {
        super.prepare()

        self.mj_h = 69

        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        moreButton.setTitleColor(UIColor(hex: "105cfe"), for: .normal)
        moreButton.setTitle(Localized("transaction_loadmore_text"), for: .normal)
        moreButton.addTarget(self, action: #selector(loadMoreTapAction), for: .touchUpInside)
        self.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupLang(noti:)), name: NSNotification.Name.ATON.GloabalChangeLanguage, object: nil)
    }

    @objc private func loadMoreTapAction() {
        loadMoreTapHandle?()
    }
    
    @objc private func setupLang(noti: NSNotification) {
        if (noti.userInfo != nil) {
//            guard let userInfo = noti.userInfo else { return }
//            guard let langObj = noti.userInfo?["lang"] else { return }
//            let lang = langObj as! String
//            if lang.contains("zh") {
//
//            }
            // 延时一秒刷新标题
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.moreButton.setTitle(Localized("transaction_loadmore_text"), for: .normal)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
