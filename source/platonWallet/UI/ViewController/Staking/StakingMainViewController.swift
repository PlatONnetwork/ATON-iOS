//
//  StakingMainViewController.swift
//  platonWallet
//
//  Created by Admin on 23/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class StakingMainViewController: StakingPageTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        navigationController?.navigationBar.isHidden = true
        
//        settings.style.buttonBarBackgroundColor = .white
//        settings.style.buttonBarItemBackgroundColor = .white
//        settings.style.selectedBarBackgroundColor = .white
//        settings.style.buttonBarLeftContentInset = 0.0
//        settings.style.buttonBarItemBackgroundColor = .blue
//
//        buttonBarView.backgroundColor = .white
//        buttonBarView.selectedBar.backgroundColor = UIColor(hex: "1B60F3")
//
//        buttonBarView.frame = CGRect(x: 16, y: UIApplication.shared.statusBarFrame.size.height, width: view.bounds.width*0.7, height: 44)
//
//        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//            guard changeCurrentIndex == true else { return }
//
//            oldCell?.label.textColor = UIColor(hex: "898c9e")
//            newCell?.label.textColor = .black
//
//            if animated {
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//                })
//            } else {
//                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            }
//        }
        if #available(iOS 11.0, *) {
            containerView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func moveToValidatorListController() {
        guard let viewController = viewControllers.last else { return }
        moveTo(viewController: viewController)
    }
    
//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let controller1 = ValidatorNodesViewController()
//        let controller2 = ValidatorNodesViewController()
//
//        return [controller1, controller2]
//
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
