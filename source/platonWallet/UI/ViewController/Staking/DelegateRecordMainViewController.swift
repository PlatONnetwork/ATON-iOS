//
//  DelegateRecordMainViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class DelegateRecordMainViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = common_blue_color
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { (oldCell: PTSButtonCell?, newCell: PTSButtonCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = common_blue_color
        }

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = DelegateRecordViewController(itemInfo: Localized("staking_delegate_record_all"))
        child_1.recordType = .all
        let child_2 = DelegateRecordViewController(itemInfo: Localized("staking_delegate_record_delegate"))
        child_2.recordType = .delegate
        let child_3 = DelegateRecordViewController(itemInfo: Localized("staking_delegate_record_undelegate"))
        child_3.recordType = .redeem

        return [child_1, child_2, child_3]
    }

    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        return self.getBasicLeftBarButtonItemWithBasicStyle(localizedText: "delegate_record_title")
    }

    func getBasicLeftBarButtonItemWithBasicStyle(localizedText: String?) -> UIBarButtonItem {

        let label = UILabel(frame: CGRect(x: 25, y: 0, width: 200, height: 44))
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.localizedText = localizedText
        label.tag = titleLabelTag

        let backButton = EnlargeTouchButton(type: .custom)
        backButton.setBackgroundImage(UIImage(named: "navback"), for: .normal)
        //backButton.contentMode = .scaleAspectFit
        //backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(onNavigationBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 14, width: 16, height: 16)

        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 120 + 32 + 10, height: 44))
        parentView.addSubview(label)
        parentView.addSubview(backButton)
        parentView.backgroundColor = .clear

        let leftBarButtonItem = UIBarButtonItem(customView: parentView)
        return leftBarButtonItem
    }

    @objc func onNavigationBack() {
        navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
