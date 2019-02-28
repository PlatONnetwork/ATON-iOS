//
//  BaseViewController.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import EmptyDataSet_Swift

class BaseViewController: UIViewController {
    
    var endEditingWhileTapBackgroundView: Bool = false {
        didSet {
            if endEditingWhileTapBackgroundView {
                let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapView))
                view.addGestureRecognizer(tapGes)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultUIStyle()
        
    }
    
    @objc private func tapView() {
        if endEditingWhileTapBackgroundView {
            view.endEditing(true)
        }
    }

    func setDefaultUIStyle() {
        
        view.backgroundColor = UIViewController_backround
        
        let backgrouImage = UIImage(color: nav_bar_backgroud)
        navigationController?.navigationBar.setBackgroundImage(backgrouImage, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16.0),NSAttributedString.Key.foregroundColor:UIColor.white]
        
    }
    
    func showNavigationBarShadowImage(image:UIImage = UIImage(color: UIColor(rgb: 0x32394E)) ?? UIImage()) {
        
        navigationController?.navigationBar.shadowImage = image
        
    }
    
    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        
        return UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(back))
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func emptyViewForTableView(forEmptyDataSet scrollView: UIScrollView, _ description: String?) -> UIView? {
        
        let holder = (UIView.viewFromXib(theClass: TableViewNoDataPlaceHolder.self) as! TableViewNoDataPlaceHolder)
        if description != nil && description!.length > 0{
            holder.descriptionLabel.text = description
        }
        return holder
    }
    
    deinit {
        print(String(describing: self) + "no circular refrence ")
    }

}
