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

    var currentSort: NodeSort = .rank

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    lazy var rankButton = { () -> UIButton in
        let button = UIButton()
        button.setImage(UIImage(named: "3.icon_ sorting"), for: .normal)
        button.addTarget(self, action: #selector(rankingTapAction), for: .touchUpInside)
        return button
    }()

    lazy var searchButton = { () -> UIButton in
        let button = UIButton()
        button.setImage(UIImage(named: "3.icon_ Search"), for: .normal)
        button.setImage(UIImage(named: "3.icon_ Search2"), for: .selected)
        button.addTarget(self, action: #selector(searhTapAction), for: .touchUpInside)
        return button
    }()

    var isSelectedSearchButton: Bool = false  {
        didSet {
            searchButton.isSelected = isSelectedSearchButton
        }
    }

    @objc func rankingTapAction() {
        view.endEditing(true)
        rankButton.isSelected = !rankButton.isSelected

        showNodeSortView()
    }

    @objc func searhTapAction() {
        searchButton.isSelected = !searchButton.isSelected

        guard let controllers = viewControllers as? [ValidatorNodeListViewController] else { return }
        let controller = controllers[currentIndex]
        controller.searchDidTapHandler()
    }

    func startToRefreshData() {
        guard
            let controllers = viewControllers as? [ValidatorNodeListViewController] else { return }
        _ = controllers.map { $0.selectedSortToReload() }
    }

    func showNodeSortView() {
        let listData = [
            NodeSort.rank,
            NodeSort.delegated,
            NodeSort.delegator,
            NodeSort.yield
        ]

        let type = PopSelectedViewType.sort(datasource: listData, selected: currentSort)
        let contentView = ThresholdValueSelectView(title: Localized("node_sort_title"), type: type)
        contentView.show(viewController: self)
        contentView.valueChangedHandler = { [weak self] value in
            switch value {
            case .sort(_, let selected):
                guard self?.currentSort != selected else {
                    return
                }
                self?.currentSort = selected
                self?.startToRefreshData()
            default:
                break
            }
        }
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
        rankButton.frame = CGRect(x: buttonBarView.frame.width - 18 - 14, y: (buttonBarView.frame.height - 22)/2.0, width: 18, height: 22)
        buttonBarView.addSubview(searchButton)
        searchButton.frame = CGRect(x: rankButton.frame.minX-18-10, y: (buttonBarView.frame.height - 22)/2.0, width: 18, height: 22)
        containerView.backgroundColor = .red
        containerView.frame = CGRect(x: containerView.frame.minX, y: buttonBarView.frame.maxY, width: containerView.frame.width, height: containerView.frame.height - UIApplication.shared.statusBarFrame.height)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GuidanceViewMgr.sharedInstance.checkGuidance(page: .ValidatorNodesViewController, presentedVC: UIApplication.shared.keyWindow?.rootViewController ?? self)
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
