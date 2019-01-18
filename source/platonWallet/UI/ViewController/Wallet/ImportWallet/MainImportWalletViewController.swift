//
//  MainImportWalletViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

enum ImportWalletVCType: Int {
    case keystore = 0,mnemonic,privateKey
}

class MainImportWalletViewController: BaseViewController,UIScrollViewDelegate,ImportWalletHeaderViewDelegate {
    
    lazy var pageVC: UIPageViewController = {
        
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        return vc
        
    }()
    
    lazy var headerView: ImportWalletHeaderView = {

        let view = ImportWalletHeaderView(tabLists: [Localized("importWalletVC_tab_keystore"),Localized("importWalletVC_tab_mnemonic"),Localized("importWalletVC_tab_privateKey")], currentIndex: currentIndex)
        view.delegate = self
        return view
        
    }()
    
    lazy var viewControllers: [BaseImportWalletViewController] = {
        
        return [ImportKeystoreViewController(), ImportMnemonicOrPrivateKeyViewController(type: .mnemonic), ImportMnemonicOrPrivateKeyViewController(type: 
            .privateKey)]
        
    }()
    
    var currentIndex = 0 {
        didSet {
            if oldValue == currentIndex {
                return
            }
            headerView.curIndex = currentIndex
        }
    }
    
    var defaultText: String = ""
    
    convenience init(type: ImportWalletVCType, text: String = "") {
        self.init()
        currentIndex = type.rawValue
        defaultText = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
        
        navigationItem.localizedText = "importWalletVC_title"
        
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanWhite"), for: .normal)
        scanButton.addTarget(self, action: #selector(onNavRightBtnClick), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(42)
        }
        
        let firstVC = viewControllers[currentIndex]
        firstVC.defaultText = defaultText
        pageVC.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(headerView.snp.bottom)
        }
        
    }
    
    @objc func onNavRightBtnClick() {
        
        let scanVC = QRScannerViewController { [weak self] (res) in
           
            self?.navigationController?.popViewController(animated: true)

            self?.handleScanResp(res) 
            
        }
        
        navigationController?.pushViewController(scanVC, animated: true)
        
    }
    
    func handleScanResp(_ resp: String) {
        
        var index = currentIndex
        
        if resp.isValidKeystore() {
            
            index = ImportWalletVCType.keystore.rawValue
            gotoVCForTabIndex(index, text: resp)

        }else if resp.isValidPrivateKey() {
            
            index = ImportWalletVCType.privateKey.rawValue
            gotoVCForTabIndex(index, text: resp)
            
        }else {
            showMessage(text: Localized("QRScan_failed_tips"))
        }
    }
        
    ///ImportWalletHeaderViewDelegate
    func didClickTabIndex(_ index: Int) {
        gotoVCForTabIndex(index)
    }
    
    func gotoVCForTabIndex(_ index: Int, text: String = "") {
        
        func fillTextView(text: String) {
            
            guard text.length > 0 else {
                return
            }
            
            if index == ImportWalletVCType.keystore.rawValue {
                (self.viewControllers[index] as! ImportKeystoreViewController).keystoreTextView.text = text
            }else {
                (self.viewControllers[index] as! ImportMnemonicOrPrivateKeyViewController).textView.text = text
            }
        }
        
        if index == currentIndex {
            
            fillTextView(text: text)
            
            return
        }
        
        var direction = UIPageViewController.NavigationDirection.forward
        
        if index < currentIndex {
            direction = UIPageViewController.NavigationDirection.reverse
        }
        
        pageVC.setViewControllers([viewControllers[index]], direction: direction, animated: true, completion: {(finished) in
            
            fillTextView(text: text)
            
        })
        
        currentIndex = index
    }
    
}

extension MainImportWalletViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    
    
    /// UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }
        
        if curIndex == 0 {
            return nil
        }
        curIndex -= 1
        
        return viewControllers[curIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }
        
        if curIndex == viewControllers.count - 1 {
            return nil
        }
        curIndex += 1
        
        return viewControllers[curIndex]
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == pageViewController.viewControllers![0]
        }
        
        currentIndex = curIndex
        
    }

    
}
