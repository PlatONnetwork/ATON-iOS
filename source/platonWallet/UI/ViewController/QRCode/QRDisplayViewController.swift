//
//  QRDisplayViewController.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class QRDisplayViewController: BaseViewController {

    let qrCodeView = UIView.viewFromXib(theClass: QRCodeView.self) as! QRCodeView
    
    let sharedQRView = UIView.viewFromXib(theClass: SharedQRView.self) as! SharedQRView
    
    var walletInstance : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        super.leftNavigationTitle = "ReceiveVC_nav_title"
        view.addSubview(qrCodeView)
        qrCodeView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(view)
        }
         
        if let wallet = walletInstance as? Wallet{
            let qrImage = setupQRCodeImage((wallet.key?.address)!, image: nil)
            qrCodeView.qrCodeImageView.image = qrImage
            qrCodeView.addressLabel.text = wallet.key?.address
//            qrCodeView.publicKeyLabel.text = wallet.key?.publicKey
//            qrCodeView.walletNameLabel.text = wallet.name
        }else if let swallet = walletInstance as? SWallet{
            let qrImage = setupQRCodeImage(swallet.contractAddress, image: nil)
            qrCodeView.qrCodeImageView.image = qrImage
            qrCodeView.addressLabel.text = swallet.contractAddress
//            qrCodeView.walletNameLabel.text = swallet.name
        }
        
        qrCodeView.saveImgAndShreadBtn.addTarget(self, action: #selector(onSaveImgAndShared), for: .touchUpInside)
        
        let rightMenuButton = UIButton(type: .custom)
        rightMenuButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightMenuButton.setImage(UIImage(named: "iconShare"), for: .normal)
        rightMenuButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightMenuButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        //displayAlert()
    }
    
    @objc func onNavRight(){
        let popUpVC = PopUpViewController()
        let view = SharedView()
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: SharedView.getSharedViewHeight()))
        popUpVC.setCloseEvent(button: view.closeBtn)
        popUpVC.show(inViewController: self)
    }
    
    func displayAlert(){
        
        /*
        let node = SettingService.shareInstance.getSelectedNodes()
        if node == nil || node?.nodeURLStr == DefaultNodeURL_Alpha{
            return
        }
         */
        
        let alertC = PAlertController(title: Localized("QRView_transfer_tip_title"), message: Localized("QRView_transfer_tip"))
        alertC.titleLabel?.textColor = #colorLiteral(red: 1, green: 0.2784313725, blue: 0.2784313725, alpha: 1)
        alertC.addAction(title: Localized("alert_disclaimer_confirmBtn_title")) {
            
        }
        alertC.show(inViewController: self)
    }
    
    //MARK: QR generator
    func setupQRCodeImage(_ text: String, image: UIImage?) -> UIImage {
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        
        if let outputImage = filter?.outputImage {
            
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
            
            
            return qrCodeImage
        }
        
        return UIImage()
    }
    
    @objc func onAddrCopy(){
        print("onAddrCopy")
    }
    
    @objc func onPubCopy(){
        print("onPubCopy")
    }
    
    
    func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
    
    @objc func onSaveImgAndShared(){

        var string : String?
        if let wallet = self.walletInstance as? Wallet{
            string = wallet.key?.address
        }else if let swallet = self.walletInstance as? SWallet{
            string = swallet.contractAddress
        }
        
        UIApplication.rootViewController().showLoadingHUD(text: Localized("SharedQRViewSaving"), animated: true)
        DispatchQueue.global().async {
            let image = self.setupQRCodeImage(string!, image: nil)
            DispatchQueue.main.async {
                
                if let wallet = self.walletInstance as? Wallet{
                    self.sharedQRView.qrImageView.image = image
                    self.sharedQRView.walletAddress.text = wallet.key?.address
                    //self.sharedQRView.walletName.text = wallet.name
                    self.sharedQRView.logoImage.image = UIImage(named: (wallet.key?.address.walletAddressLastCharacterAvatar())!)
                    
                }else if let swallet = self.walletInstance as? SWallet{
                    self.sharedQRView.qrImageView.image = image
                    self.sharedQRView.walletAddress.text = swallet.contractAddress
                    //self.sharedQRView.walletName.text = swallet.name
                    self.sharedQRView.logoImage.image = UIImage(named: (swallet.contractAddress.walletAddressLastCharacterAvatar()))
                }
                
                let vc = SharedPresentedVC()
                vc.transitionView = self.sharedQRView
           
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    
                    let image = self.sharedQRView.asImage()
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                })


            }
            
        }

    }
     
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        UIApplication.rootViewController().hideLoadingHUD()
        if error != nil {
            self.showMessage(text: Localized("SharedQRView_photolib_unauthorized_tips"))
        } else {
            self.showMessage(text: Localized("QRDisplayViewController_share"))
            self.onNavRight()
        }
    }
    
}
