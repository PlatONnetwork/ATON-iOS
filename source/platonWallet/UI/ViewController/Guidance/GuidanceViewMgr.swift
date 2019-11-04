//
//  GuidanceViewMgr.swift
//  platonWallet
//
//  Created by Ned on 2019/9/28.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

enum GuidancePage {
    case MainImportWalletViewController, AssetViewControllerV060, DelegateAction, RedeemAction, ValidatorNodesViewController, MyDelegatesViewController, DelegateDetailViewController

    func getStoredKey() -> String {
        switch self {
        case .MainImportWalletViewController:
            return "GuidancePage_ImportObserverWallet"
        case .AssetViewControllerV060:
            return "GuidancePage_AssetPage"
        case .DelegateAction:
            return "GuidancePage_DelegateAction"
        case .RedeemAction:
            return "GuidancePage_RedeemAction"
        case .ValidatorNodesViewController:
            return "GuidancePage_CandidatePageFilterFunc"
        case .MyDelegatesViewController:
            return "GuidancePage_CandidatePageMyDel"
        case .DelegateDetailViewController:
            return "GuidancePage_CandidateDetailPage"
        }
    }

    func getStoredPlusVersionKey() -> String {
        return getStoredKey() + AppConfig.AppInfo.appVersion
    }

    func getImage() -> UIImage {
        let cnSuffix = "_cn"
        let enSuffix = "_en"
        var imageName = self.getStoredKey()
        if Localize.currentLanguage() == KLanguage.zh_Hans.desription {
            imageName += cnSuffix
        } else {
            imageName += enSuffix
        }

        let image = UIImage(named: imageName)
        return image ?? UIImage()
    }

    func getConstraint() -> ((_ make: ConstraintMaker) -> Void) {

        let image = self.getImage()

        return { (make: ConstraintMaker) -> Void in
            make.center.equalToSuperview()

        }

        switch self {
        case .MainImportWalletViewController:
        return { (make: ConstraintMaker) -> Void in
            let size = image.size
            let leading: CGFloat = 0
            let imgViewWidth = (kUIScreenWidth - leading * 2)
            let imgViewHeight = (imgViewWidth * size.height)/size.width
            var scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
            scaleFactor *= 0.65
            let imgViewSize = CGSize(width: imgViewWidth * scaleFactor, height: imgViewHeight * scaleFactor)
            make.top.equalToSuperview().offset((58 + UIDevice.notchoffset))
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(imgViewSize)
            }
        case .AssetViewControllerV060:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
                let imgViewSize = CGSize(width: kUIScreenWidth, height: imgViewHeight * scaleFactor)
                let top: CGFloat = 12
                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        case .DelegateAction:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
                let imgViewSize = CGSize(width: kUIScreenWidth, height: imgViewHeight * scaleFactor)
                let top: CGFloat = 30
                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        case .RedeemAction:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
                let imgViewSize = CGSize(width: kUIScreenWidth, height: imgViewHeight * scaleFactor)
                let top: CGFloat = 105
                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        case .ValidatorNodesViewController:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
                let imgViewSize = CGSize(width: kUIScreenWidth, height: imgViewHeight * scaleFactor)
                let top: CGFloat = 72
                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        case .MyDelegatesViewController:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let scaleFactor: CGFloat = (kUIScreenWidth >= 375.0 ) ? 375.0/kUIScreenWidth : 1.0
                let imgViewSize = CGSize(width: kUIScreenWidth, height: imgViewHeight * scaleFactor)
                let top: CGFloat = 25

                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        case .DelegateDetailViewController:
            return { (make: ConstraintMaker) -> Void in
                let size = image.size
                let leading: CGFloat = 0
                let imgViewWidth = (kUIScreenWidth - leading * 2)
                let imgViewHeight = (imgViewWidth * size.height)/size.width
                let imgViewSize = CGSize(width: imgViewWidth, height: imgViewHeight)
                //let top : CGFloat= 75
                let top: CGFloat = 10
                make.top.equalToSuperview().offset((top + UIDevice.notchoffset))
                make.centerX.equalToSuperview()
                make.size.equalTo(imgViewSize)
            }
        }

        return { (make: ConstraintMaker) -> Void in }
    }
}

class GuidanceVC: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIScreen.main.nativeBounds.height < 667 {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
            self.view.addGestureRecognizer(gesture)
        }
    }

    var pageType = GuidancePage.AssetViewControllerV060

    let dismissButton = UIButton()

    override func viewDidLoad() {
        let cnSuffix = "_cn"
        let enSuffix = "_en"
        var imageName = pageType.getStoredKey()
        if Localize.currentLanguage() == KLanguage.zh_Hans.desription {
            imageName += cnSuffix
        } else {
            imageName += enSuffix
        }

        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        //https://blog.csdn.net/annkie/article/details/49247755
        //imageView.contentMode = .scaleToFill
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
        self.view.backgroundColor = UIColor(rgb: 0x404040)

        imageView.addSubview(dismissButton)
        dismissButton.backgroundColor = .clear
        dismissButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        dismissButton.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView.snp.edges)
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.size.equalTo(CGSize(width: 100, height: 40))
        }

        imageView.snp.makeConstraints(pageType.getConstraint())
    }

    @objc func onTap() {
        self.dismiss(animated: false, completion: nil)
    }
}

public class GuidanceViewMgr: NSObject {

    static let sharedInstance = GuidanceViewMgr()

    func checkGuidance(page: GuidancePage, presentedVC: UIViewController) {
        let skey = page.getStoredPlusVersionKey()
        guard (UserDefaults.standard.object(forKey: skey) as? Bool) == nil  else {
            return
        }
        let vc = GuidanceVC()
        vc.pageType = page
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        presentedVC.present(vc, animated: false, completion: nil)
        UserDefaults.standard.set(true, forKey: skey)
    }

}
