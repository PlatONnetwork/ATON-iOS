//
//  BiometricsAuthViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/6.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import LocalAuthentication
import Localize_Swift

class BiometricsAuthViewController: BaseViewController {
    
    enum BiometricsType {
        case face, touch
    }

    @IBOutlet weak var localAuthIconImgV: UIImageView!
    
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var tipsBtn: UIButton!
    
    @IBOutlet weak var switchPswAuthBtn: UIButton!
    var biometricsType: BiometricsType!
    
    var completion:(()->Void)?
    
    convenience init(biometricsType: BiometricsType, completion:@escaping ()->Void) {
        self.init()
        self.biometricsType = biometricsType
        self.completion = completion
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard WalletService.sharedInstance.wallets.count > 0 else {
            completion?()
            return
        }
        
        localAuthIconImgV.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(continueAuth(_ :)))
        localAuthIconImgV.addGestureRecognizer(tapGes)
        
        if biometricsType == .touch {
            localAuthIconImgV.image = UIImage(named: "localAuth_icon_finger")
            tipsBtn.localizedNormalTitle = "BiometricsAuthVC_authTouchIDBtn_title"
        }else {
            localAuthIconImgV.image = UIImage(named: "localAuth_icon_face")
            tipsBtn.localizedNormalTitle = "BiometricsAuthVC_authFaceIDBtn_title"
        }
        
        showLocalAuth()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func continueAuth(_ sender: Any) {
        showLocalAuth()
    }
    
    @IBAction func switchToPswAuth(_ sender: Any) {
        
        let pswAuthVC = PasswordAuthViewController()
        pswAuthVC.completion = completion
        rt_navigationController.pushViewController(pswAuthVC, animated: true, complete: nil) 
    }
    
    func showLocalAuth() {
        
        tips.isHidden = true
        
        let laCtx = LAContext()
        laCtx.localizedFallbackTitle = ""
        var error: NSError?
        guard laCtx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            tips.isHidden = false
            return
        }
        laCtx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Localized("touchid_auth_text")) { [weak self](success, error) in
            
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                }else {
                    print(error!)
                }
            }
        }
        
    }

}
