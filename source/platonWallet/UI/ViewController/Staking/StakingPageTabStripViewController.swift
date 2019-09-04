//
//  StakingPageTabStripViewController.swift
//  platonWallet
//
//  Created by Admin on 23/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit


class StakingPageTabStripViewController: BaseButtonBarPagerTabStripViewController<StakingLabelViewCell> {
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor(hex: "1B60F3")
        settings.style.selectedBarHeight = 4.0
        settings.style.selectedBarWidth = 20.0
        settings.style.selectedBarZPostion = -1
        
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarLeftContentInset = 16
        settings.style.buttonBarRightContentInset = 16
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 18)
        
        buttonBarItemSpec = ButtonBarItemSpec.cellClass(width: { [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont ?? label.font
            label.localizedText = childItemInfo.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + CGFloat(self?.settings.style.buttonBarItemLeftRightMargin ?? 8 * 2)
        })
        

        
        changeCurrentIndexProgressive = { [weak self] (oldCell: StakingLabelViewCell?, newCell: StakingLabelViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(hex: "898c9e")
            newCell?.label.textColor = .black
            
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }
        }
        super.viewDidLoad()
        buttonBarView.removeFromSuperview()
        
        buttonBarView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        navigationController?.navigationBar.addSubview(buttonBarView)
        
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let delegateController = MyDelegatesViewController()
        let validatorController = ValidatorNodesViewController()
        return [delegateController, validatorController]
    }
    
    override func configure(cell: StakingLabelViewCell, for indicatorInfo: IndicatorInfo) {
//        cell.label.text = indicatorInfo.title
        cell.label.localizedText = indicatorInfo.title
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
