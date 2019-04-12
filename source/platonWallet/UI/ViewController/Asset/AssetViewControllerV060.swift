//
//  AssetViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import RTRootNavigationController

let AssetHeaderViewH = 168 - 44 + 20
let AssetSectionViewH : CGFloat = 124
 
class AssetViewControllerV060: BaseViewController ,PopupMenuTableDelegate{
    
    let transactionVC = AssetTransactionViewControllerV060()
    let sendVC =  AssetSendViewControllerV060()
    let recvVC = AssetReceiveViewControllerV060()
    
    lazy var scrollView = { () -> UIScrollView in 
        let view = UIScrollView(frame: .zero)
        view.delegate = self
        view.backgroundColor = .white
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        return view
    }() 
    
    lazy var headerView = { () -> AssetHeaderViewV060 in
        let headerView = UIView.viewFromXib(theClass: AssetHeaderViewV060.self) as! AssetHeaderViewV060
        headerView.menuButton.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        headerView.scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        return headerView
    }()
    
    lazy var sectionView = { () -> AssetSectionViewV060 in 
        let view = UIView.viewFromXib(theClass: AssetSectionViewV060.self) as! AssetSectionViewV060
        view.backUpbtn.addTarget(self, action: #selector(onBackup), for: .touchUpInside)
        return view
    }()
    
    lazy var pageVC: AssetPageViewController = {
        
        let vc = AssetPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        return vc
        
    }()
    
    lazy var viewControllers: [BaseViewController] = {
        
        return [transactionVC,sendVC,recvVC]
        
    }()
    
    var tmpChildVCIndex: Int = 0
    var pageViewCurrentIndex: Int = 0
    
    var scrollViewScrollEnableInChildVCs = [true,true,true]
    
    var scrollEnable: Bool {
        get {
            return scrollViewScrollEnableInChildVCs[tmpChildVCIndex]
        }set {
            scrollViewScrollEnableInChildVCs[tmpChildVCIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        headerView.shouldUpdateWalletList()
        sendVC.refreshData()
        transactionVC.refreshData()
        
    }
    
    func initUI() {
        
        self.statusBarNeedTruncate = true
        view.backgroundColor = .white
        view.addSubview(UIView(frame: .zero))
        view.addSubview(scrollView)
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true

        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .always
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let usingsafeAutoLaoutGuide = true
        
        scrollView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            if usingsafeAutoLaoutGuide{
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.top.equalToSuperview()
                }
            }else{
                make.edges.equalToSuperview()
            }
            
        }
        
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(AssetHeaderViewH)
            make.width.equalTo(view)
        }
        
        scrollView.addSubview(sectionView)
        sectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(AssetSectionViewH)
            make.width.equalTo(view)
        }
        
        pageVC.setViewControllers([viewControllers[tmpChildVCIndex]], direction: .forward, animated: false, completion: nil)
        addChild(pageVC)
        scrollView.addSubview(pageVC.view)
        self.updatePageViewConstraint(headerHide: false)
        
        pageVC.didScrolling = {[weak self] offset in
            //self?.sectionView.changingOffset(offset: offset, currentIndex: (self?.pageViewCurrentIndex)!,draging: (self?.pageVC.pagesScrollview?.isDragging)!)
            
        }
        transactionVC.delegate = self
        sectionView.onSelectItem = {[weak self] index in
            
            let target = self?.viewControllers[index]
            
            if (self?.pageViewCurrentIndex)! < index{
                //self?.pageVC.goToNextPage()
                self?.pageVC.setViewControllers([target!], direction: .forward, animated: true, completion: nil)
            }else if (self?.pageViewCurrentIndex)! > index{
                //self?.pageVC.goToPreviousPage()
                self?.pageVC.setViewControllers([target!], direction: .reverse, animated: true, completion: nil)
            }
            self?.pageViewCurrentIndex = index
        }
        
        assetHeaderStyle = (false,false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name(updateWalletList_Notification), object: nil)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    } 
    
    //MARK: - Constraint
    
    func updatePageViewConstraint(headerHide: Bool){
        
        let tabbarHeight = (navigationController?.tabBarController?.tabBar.frame.size.height ?? 0)
        if headerHide{
            pageVC.view.snp.remakeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.width.equalTo(view)
                make.top.equalTo(sectionView.snp.bottom).offset(0)
                make.height.equalTo(kUIScreenHeight - 70 - tabbarHeight - CGFloat(AssetSectionViewH))
            }
        }else{
            pageVC.view.snp.remakeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.width.equalTo(view)
                make.top.equalTo(sectionView.snp.bottom).offset(0)
                make.height.equalTo(kUIScreenHeight - 0 - tabbarHeight - CGFloat(AssetSectionViewH))
            }
        }
    }
    
    func checkAndSetNoWalletViewStyle(){
        
        if AssetVCSharedData.sharedData.walletList.count == 0{
            sectionView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            sectionView.setSectionSelectedIndex(index: 0)
            sectionView.isHidden = true
            self.scrollView.isScrollEnabled = false
            pageVC.pagesScrollview?.isScrollEnabled = false
        }else{
            sectionView.snp.updateConstraints { (make) in
                make.height.equalTo(AssetSectionViewH)
            }
            sectionView.isHidden = false
            self.scrollView.isScrollEnabled = true
            pageVC.pagesScrollview?.isScrollEnabled = true
        }
    }
     
    func initData(){
        transactionVC.delegate = self
        AssetVCSharedData.sharedData.reloadWallets()
    }
    
    //hide animate
    var assetHeaderStyle: (hide: Bool,animated: Bool)?{
        didSet{
            print("headerStyle:\(String(describing: assetHeaderStyle))")
            let hide = assetHeaderStyle?.0 ?? false
            let animated = assetHeaderStyle?.1 ?? false
            
            
            
            if hide{
                
                scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH), animated: animated)
                sectionView.backgroundColor = .white
                DispatchQueue.main.async {
                    self.scrollView.isScrollEnabled = true
                }
                view.backgroundColor = .white
                sectionView.backgroundColor = .white
                sectionView.grayoutBackground.backgroundColor = .white
                sectionView.bottomSepline.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)

            }else{
                
                sectionView.backgroundColor = UIColor(red: 247, green: 250, blue: 255, alpha: 1)
                
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
                DispatchQueue.main.async {
                    self.scrollView.isScrollEnabled = true
                }
                view.backgroundColor = .white
                sectionView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
                sectionView.grayoutBackground.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
                sectionView.bottomSepline.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9333333333, blue: 0.9568627451, alpha: 1)
            }
            
            transactionVC.setHeaderStyle(hide: hide)
            self.updatePageViewConstraint(headerHide: hide)
            
        }
    }

}

extension AssetViewControllerV060: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }
        
        if curIndex == 0 {
            return nil
        }
        curIndex -= 1
        tmpChildVCIndex = curIndex
        
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
        tmpChildVCIndex = curIndex
        return viewControllers[curIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (!completed)
        {
            return
        }
        for (index,obj) in viewControllers.enumerated(){
            if pageViewController.viewControllers!.first! == obj{
                self.pageViewCurrentIndex = index
            }
        }

        sectionView.didFinishAnimating(index: self.pageViewCurrentIndex)
    }
}


//MARK: - UIScrollViewDelegate

extension AssetViewControllerV060 : UIScrollViewDelegate,ChildScrollViewDidScrollDelegate {
    

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if scrollView == self.scrollView{
            
            if (actualPosition.y >= 0.0){
                print("self.scrollView Dragging down")
                
            }else{
                print("self.scrollView Dragging up")
                //scrollView.isScrollEnabled = true
                if (self.assetHeaderStyle?.0)!{
                    //self.scrollView.isScrollEnabled = false
                    //self.transactionVC.tableView.isScrollEnabled = true
                }
                
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
        if scrollView.isDragging && scrollView.isDecelerating{
            if scrollView.contentOffset.y > CGFloat(AssetHeaderViewH) * 0.5{
                self.assetHeaderStyle = (true,true)
            }else{
                self.assetHeaderStyle = (false,true)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
            if (self.assetHeaderStyle?.hide)!{
                self.assetHeaderStyle = (false,true)
            }
            
        }else{
            if !(self.assetHeaderStyle?.hide)!{
                self.assetHeaderStyle = (true,true)
            }
        }
        return
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollview Didcroll:\(scrollView.contentOffset.y)")
        
        let rec = sectionView.convert(sectionView.bounds, to: view)
        print("sectionView y:\(rec.origin.y)")
        
//        if rec.origin.y > 0 && rec.origin.y < (UIDevice.notchHeight + 20) && !self.assetHeaderStyle!.0{
//            self.updatePageViewConstraint(headerHide: true)
//        }
        
        if (!scrollEnable || scrollView.contentOffset.y >= CGFloat(AssetHeaderViewH)) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH - 20), animated: false)
            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: 0, y: AssetHeaderViewH), animated: false)
            }
            if !(self.assetHeaderStyle?.hide)!{
                self.assetHeaderStyle = (true,false)
            }
        }
    } 
    
    func childScrollViewDidScroll(childScrollView: UIScrollView) {
        let yoffset = childScrollView.contentOffset.y
        //print("childScrollViewDidScroll:\(yoffset)")
        if yoffset <= 0 {
            scrollEnable = true
            childScrollView.setContentOffset(.zero, animated: false)
        }else {
            let rec = sectionView.convert(sectionView.bounds, to: view)
            if scrollEnable && rec.origin.y > 0 && !(self.assetHeaderStyle?.hide)!{
                childScrollView.setContentOffset(.zero, animated: false)
            }else {
                scrollEnable = false
            }
        }

    }
    
    // MARK: - User Interaction
    
    @objc func onMenu(){
        var menuArray: [MenuItem] = []
        let menu1 = MenuItem(icon: UIImage(named: "img-more-classic-create"), title: Localized("AddWalletMenuVC_createIndividualWallet_title"))
        let menu2 = MenuItem(icon: UIImage(named: "img-more-Joint-create"), title: Localized("AddWalletMenuVC_createSharedWallet_title"))
        let menu3 = MenuItem(icon: UIImage(named: "img-more-classic-import"), title: Localized("AddWalletMenuVC_importIndividualWallet_title"))
        let menu4 = MenuItem(icon: UIImage(named: "img-more-Joint-add"), title: Localized("AddWalletMenuVC_addSharedWallet_title"))
        menuArray = [menu1, menu2, menu3, menu4]
        let menu = PopupMenuTable(menuArray: menuArray, arrowPoint: CGPoint(x: UIScreen.main.bounds.width - 30, y: 64 + UIDevice.notchHeight))
        menu.popUp()
        menu.delegate = self
    }
    
    @objc func onScan(){ 
        let scanner = QRScannerViewController { [weak self](res) in
            self?.navigationController?.popViewController(animated: true)
            self?.handleScanResp(res)
        }
        scanner.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(scanner, animated: true)
    }
    
    @objc func onBackup(){
        guard let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet, wallet.canBackupMnemonic else {
            return
        }
        self.showWalletBackup(wallet: wallet)
    }
    
    //MARK: - Login
    
    func handleScanResp(_ res: String) {
        var targetVC: UIViewController?
        if res.isValidAddress() {
            self.sectionView.setSectionSelectedIndex(index: 1)
            sendVC.walletAddressView.textField.text = res
        }else if res.isValidPrivateKey() {
            targetVC = MainImportWalletViewController(type: .privateKey, text: res)
        }else if res.isValidKeystore() {
            targetVC = MainImportWalletViewController(type: .keystore, text: res)
        }else {
            showMessage(text: Localized("QRScan_failed_tips"))
        }
        if targetVC != nil {
            targetVC!.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC!, animated: true)
        }
    }
    
    // MARK: - PopupMenuTableDelegate
    
    func popupMenu(_ popupMenu: PopupMenuTable, didSelectAt index: Int) {
        switch index {
        case 0:
            createIndividualWallet()
        case 1:
            createSharedWallet()
        case 2:
            importIndividualWallet()
        case 3:
            addSharedWallet()
        default:
            do{}
        }
    }
    
    func createIndividualWallet() {
        let createWalletVC = CreateIndividualWalletViewController()
        createWalletVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createWalletVC, animated: true)
    }
    
    func createSharedWallet() {
        let vc = CreateSharedWalletStep1ViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func importIndividualWallet() {
        let importWallet = MainImportWalletViewController()
        importWallet.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(importWallet, animated: true)
    }
    
    func addSharedWallet() {
        let addSharedWallet = AddSharedWalletVC()
        addSharedWallet.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSharedWallet, animated: true)
    }
}

 
extension AssetViewControllerV060{
    static func pushViewController(viewController: UIViewController){
        guard let tabvc = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
        let nav = tabvc.viewControllers?.first as? BaseNavigationController else{
            return
        }
        viewController.hidesBottomBarWhenPushed = true
        nav.pushViewController(viewController, animated: true)
        //MainTabBarViewController.setTabbarHide(hide: true)
    }
    
    static func popViewController(){
        guard let tabvc = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else{
                return
        }
        nav.popViewController(animated: true)
        //MainTabBarViewController.setTabbarHide(hide: false)
    }
    
    static func setScrollViewScrollEnable(enable: Bool){
        guard let tabvc = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else{
                return
        }
        
        guard let navofAssetV60 = nav.viewControllers.first as? RTContainerController else {
            return 
        }
        
        guard let vc = navofAssetV60.contentViewController as? AssetViewControllerV060 else {
            return
        }
        
        vc.scrollView.isScrollEnabled = enable
    }
    
    
    static func getInstance() -> AssetViewControllerV060?{
        guard let tabvc = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
            let nav = tabvc.viewControllers?.first as? BaseNavigationController else{
                return nil
        }
        guard let navofAssetV60 = nav.viewControllers.first as? RTContainerController else {
            return nil 
        }
        
        guard let vc = navofAssetV60.contentViewController as? AssetViewControllerV060 else {
            return nil
        }
        return vc
    }
    
    static func setPageViewController(index: Int){
        guard let vc = self.getInstance() else{
            return
        }
        vc.sectionView.setSectionSelectedIndex(index: index)
    }
    
    static func reloadTransactionList(){
        guard let vc = self.getInstance() else{
            return
        }
        //wait for db writing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
            vc.transactionVC.refreshData()
        }
    }
    
    static func gotoCreateClassicWallet(){
        guard let vc = self.getInstance() else{
            return
        }
        vc.createIndividualWallet()
    }
    
    static func gotoImportClassicWallet(){
        guard let vc = self.getInstance() else{
            return
        }
        vc.importIndividualWallet()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //MainTabBarViewController.setTabbarHide(hide: false)
    }
}

//MARK: - Notification

extension AssetViewControllerV060{
    
    @objc func OnBeginEditing(_ no : Notification){
        guard let textFiled = no.object as? UITextField else {
            return
        }
        if textFiled == sendVC.amountView.textField{
            self.assetHeaderStyle = (true,true)
        }else if textFiled == sendVC.walletAddressView.textField{
            self.assetHeaderStyle = (true,true)
        }
    }
    
    @objc func updateWalletList(){
        headerView.shouldUpdateWalletList()
        sendVC.refreshData()
        transactionVC.refreshData()
        self.checkAndSetNoWalletViewStyle()
    }
    
}
