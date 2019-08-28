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
import RTRootNavigationController


private var hasRTRootNavigationControllerSwizzled = false

/*
extension RTRootNavigationController : UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    
    @objc open func pushViewController_hook(_ viewController: UIViewController, animated: Bool)
    {
//        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)){
//            self.interactivePopGestureRecognizer?.isEnabled = false
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.interactivePopGestureRecognizer?.isEnabled = true
//            }
//
//        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    @objc open func viewDidLoad_hook() {
        super.viewDidLoad()
        //this will enable interactivePopGestureRecognizer temporarily???
        //https://stackoverflow.com/questions/20992039/uinavigationcontroller-interactivepopgesturerecognizer-working-abnormal-in-ios7
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)){
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    final public class func doBadSwizzleStuff() {
        
        guard !hasRTRootNavigationControllerSwizzled else { return }
        
        hasRTRootNavigationControllerSwizzled = true
        
        let originalSelector = #selector(pushViewController(_:animated:))
        let swizzledSelector = #selector(self.pushViewController_hook(_:animated:))
        doSwizzling(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
        
        let originalSelector1 = #selector(viewDidLoad)
        let swizzledSelector1 = #selector(self.viewDidLoad_hook)
        doSwizzling(originalSelector: originalSelector1, swizzledSelector: swizzledSelector1)
    
    }
    
    final public class func doSwizzling(originalSelector:Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        guard originalMethod != nil,swizzledMethod != nil else {
            return
        }
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
    
}
*/

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
}

let titleLabelTag = 134

class BaseViewController: UIViewController {
    
    var passwordInputAlert: AlertStylePopViewController?
    
    private var shadowImageView: UIImageView?
    
    var innerLeftBarButtonItem: UIBarButtonItem?
    
    var leftNavigationTitle: String?
    
    var statusBarNeedTruncate : Bool = false
    
    var titleLabel : UILabel?{
        guard let bar = self.innerLeftBarButtonItem,bar.customView != nil,(bar.customView?.subviews.count)! > 0 else {
            return nil
        }

        for item in (bar.customView?.subviews)!{
            if item.tag == titleLabelTag{
                return (item as? UILabel)
            }
            if let label = item as? UILabel{
                return label
            } 
        }
        return nil
    }

    
    lazy var tableNodataHolderView : TableViewNoDataPlaceHolder = {
        return (UIView.viewFromXib(theClass: TableViewNoDataPlaceHolder.self) as! TableViewNoDataPlaceHolder)
    }()
    
    var useDefaultLeftBarButtonItem : Bool = true
    
    var endEditingWhileTapBackgroundView: Bool = false {
        didSet {
            if endEditingWhileTapBackgroundView {
                let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapView))
                view.addGestureRecognizer(tapGes)
            }
        }
    }
    
    var backToViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultUIStyle()
    }
    
    func autoAdjustInset(){
         if #available(iOS 11.0, *) {
            if let scrollView =  self.view.subviews.first as? UIScrollView{
                scrollView.contentInsetAdjustmentBehavior = .never
            } 
         
         } else {
            automaticallyAdjustsScrollViewInsets = false
         }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.`default`
    }
    
    @objc private func tapView() {
        if endEditingWhileTapBackgroundView {
            view.endEditing(true)
        }
    }
     
    func setDefaultUIStyle() {
        
        view.backgroundColor = UIViewController_backround
        
         navigationController?.navigationBar.shadowImage = UIImage()
        
        let backgroundImage = UIImage.gradientImage(colors: [UIColor(rgb: 0xdfeafc), UIColor(rgb: 0xf0f4fb)], size: CGSize(width: 1, height: 1), startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
        
        if type(of: self) == AssetSendViewControllerV060.self ||
            type(of: self) == ImportMnemonicOrPrivateKeyViewController.self ||
            type(of: self) == PersonalViewController.self ||
            type(of: self) == QRScannerViewController.self ||
            type(of: self) == MainImportWalletViewController.self {
            
            let backgrouImage = UIImage(color: nav_bar_backgroud)
            navigationController?.navigationBar.setBackgroundImage(backgrouImage, for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            
        }else{
            //设置导航栏背景图片为白色，会导致状态栏透明？？？，出现左滑返回时，状态栏出现阴影
            navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16.0),NSAttributedString.Key.foregroundColor:UIColor.white]
        }
    }
    
    func setLeftBarButtonItemWithTitle(backTitle: String?) {
    }
    
    func getBasicLeftBarButtonItemWithBasicStyle(localizedText: String?) -> UIBarButtonItem{
        
        let label = UILabel(frame: CGRect(x: 25, y: 0, width: 200, height: 44))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16) 
        label.localizedText = localizedText
        label.tag = titleLabelTag
        
        let backButton = EnlargeTouchButton(type: .custom)
        backButton.setBackgroundImage(UIImage(named: "navback"), for: .normal)
        //backButton.contentMode = .scaleAspectFit
        //backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(onCustomBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 14, width: 16, height: 16)
        
        /*
        let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
        tlabel.text = ""
        tlabel.tag = titleLabelTag
         */
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 120 + 32 + 10, height: 44))
        parentView.addSubview(label)
        parentView.addSubview(backButton)
        parentView.backgroundColor = .clear
        
        /*
        let stackView = UIStackView(arrangedSubviews: [tlabel,backButton,label])
        stackView.axis = .horizontal
        stackView.spacing = CGFloat(5)
        stackView.frame = CGRect(x: 0, y: 0, width: 120 + 32 + 10, height: 44)
         */
        
        let leftBarButtonItem = UIBarButtonItem(customView: parentView)
        self.innerLeftBarButtonItem = leftBarButtonItem
        return leftBarButtonItem
    }
        
    
    
    @objc func onCustomBack() {
        guard let controller = backToViewController else {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.popToViewController(controller, animated: true)
    }
    
    func showNavigationBarShadowImage(image:UIImage = UIImage(color: UIColor(rgb: 0x32394E)) ?? UIImage()) {
        navigationController?.navigationBar.shadowImage = image
    }
    
    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        if self.useDefaultLeftBarButtonItem && leftNavigationTitle != nil && (leftNavigationTitle?.length)! > 0{
            return self.getBasicLeftBarButtonItemWithBasicStyle(localizedText: self.leftNavigationTitle)
        }
        return UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(back))
    }
    
    
    
    @objc func back() {
        guard let controller = backToViewController else {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.popToViewController(controller, animated: true)
    }
     
    func emptyViewForTableView(forEmptyDataSet scrollView: UIScrollView, _ description: String?, _ imageName: String?) -> UIView? {
        let holder = self.tableNodataHolderView
        if description != nil && description!.length > 0{
            holder.descriptionLabel.text = description
        }
        if let imageName = imageName, imageName.count > 0{
            holder.imageView.image = UIImage(named: imageName)
        }
        
        return holder
    }
    
    func emptyViewForTableview(forEmptyDataSet scrollView: UIScrollView, _ attributedText: NSAttributedString, _ imageName: String) -> UIView? {
        let holderView = self.tableNodataHolderView
        holderView.descriptionLabel.attributedText = attributedText
        holderView.imageView.image = UIImage(named: imageName)
        return holderView
    }
    
    deinit {
        print(String(describing: self) + "no circular refrence ")
    }
    
    

}

//MARK: - EmptyDataSetSource

extension BaseViewController{
    func setplaceHolderBG(hide: Bool,tableView: UITableView){
        if hide{
            self.tableNodataHolderView.containerView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
            self.tableNodataHolderView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
            tableView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
        }else{
            self.tableNodataHolderView.containerView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
            self.tableNodataHolderView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
            tableView.backgroundColor = #colorLiteral(red: 0.9751496911, green: 0.984305203, blue: 1, alpha: 1)
        }
    }
    
}



