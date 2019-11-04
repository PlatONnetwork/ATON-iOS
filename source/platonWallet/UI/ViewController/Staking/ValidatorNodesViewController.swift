//
//  ValidatorNodesViewController.swift
//  platonWallet
//
//  Created by Admin on 23/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class ValidatorNodesViewController: ButtonBarPagerTabStripViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = IndicatorInfo(title: "staking_main_validator_text")

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    lazy var rankButton = { () -> UIButton in
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(common_blue_color, for: .normal)
        button.localizedNormalTitle = "staking_validator_node_rank"
        button.localizedSelectedTitle = "staking_validator_node_yield"
        button.setImage(UIImage(named: "3.icon_ sorting"), for: .normal)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.layer.cornerRadius = 11.0
        button.layer.borderColor = common_blue_color.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.addTarget(self, action: #selector(rankingTapAction), for: .touchUpInside)
        return button
    }()

    @objc func rankingTapAction() {
        rankButton.isSelected = !rankButton.isSelected

        guard let controllers = viewControllers as? [ValidatorNodeListViewController] else { return }
        _ = controllers.map { $0.pullDownForRefreshData(isRankSelected: !rankButton.isSelected) }
    }

    override func viewDidLoad() {
        settings.style.selectedBarVerticalAlignment = .middle
        settings.style.selectedBarLayerCorner = 18.0
        settings.style.selectedBarHeight = 36.0
        settings.style.selectedBarBackgroundColor = common_blue_color
        settings.style.selectedBarZPostion = -1

        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15)

        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = view.bounds.width/4.0

        changeCurrentIndexProgressive = { (oldCell: PTSButtonCell?, newCell: PTSButtonCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = .white
        }

        super.viewDidLoad()
        containerView.isScrollEnabled = false
        buttonBarView.frame = CGRect(x: buttonBarView.frame.minX, y: buttonBarView.frame.minY + UIApplication.shared.statusBarFrame.height, width: buttonBarView.frame.width, height: buttonBarView.frame.height + 28)
        buttonBarView.addSubview(rankButton)
        rankButton.frame = CGRect(x: buttonBarView.frame.width - 67 - 10, y: (buttonBarView.frame.height - 22)/2.0, width: 67, height: 22)
        containerView.frame = CGRect(x: containerView.frame.minX, y: buttonBarView.frame.maxY, width: containerView.frame.width, height: containerView.frame.height - UIApplication.shared.statusBarFrame.height)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: .ValidatorNodesViewController, presentedVC: self)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = ValidatorNodeListViewController(itemInfo: "staking_validator_node_all")
        child_1.controllerType = .all
        let child_2 = ValidatorNodeListViewController(itemInfo: "staking_validator_node_active")
        child_2.controllerType = .active
        let child_3 = ValidatorNodeListViewController(itemInfo: "staking_validator_node_candidate")
        child_3.controllerType = .candidate

        return [child_1, child_2, child_3]
    }

}
