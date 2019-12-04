//
//  AssetReceiveViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class AssetReceiveViewControllerV060: BaseViewController {

    let qrCodeView = UIView.viewFromXib(theClass: QRCodeView.self) as! QRCodeView

    let sharedQRView = UIView.viewFromXib(theClass: SharedQRView.self) as! SharedQRView

    var walletInstance: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(qrCodeView)
        qrCodeView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        let qrImage = UIImage.geneQRCodeImageFor(AssetVCSharedData.sharedData.selectedWalletAddress!, size: 300.0)
//        let qrImage = setupQRCodeImage(AssetVCSharedData.sharedData.selectedWalletAddress!, image: nil)
        qrCodeView.qrCodeImageView.image = qrImage
        qrCodeView.saveImgAndShreadBtn.addTarget(self, action: #selector(onSaveImgAndShared), for: .touchUpInside)
        qrCodeView.addressLabel.text = AssetVCSharedData.sharedData.selectedWalletAddress

        AssetVCSharedData.sharedData.registerHandler(object: self) {[weak self] in
            let qrImage = UIImage.geneQRCodeImageFor(AssetVCSharedData.sharedData.selectedWalletAddress!, size: 300.0)
//            let qrImage = self?.setupQRCodeImage(AssetVCSharedData.sharedData.selectedWalletAddress!, image: nil)
            self?.qrCodeView.qrCodeImageView.image = qrImage
            self?.qrCodeView.addressLabel.text = AssetVCSharedData.sharedData.selectedWalletAddress
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
    }

    func displayAlert() {

        let alertC = PAlertController(title: Localized("QRView_transfer_tip_title"), message: Localized("QRView_transfer_tip"))
        alertC.titleLabel?.textColor = #colorLiteral(red: 1, green: 0.2784313725, blue: 0.2784313725, alpha: 1)
        alertC.addAction(title: Localized("alert_disclaimer_confirmBtn_title")) {

        }
        alertC.show(inViewController: self)
    }

    // MARK: QR generator
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

    @objc func onAddrCopy() {
        print("onAddrCopy")
    }

    @objc func onPubCopy() {
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
        bitmapRef.scaleBy(x: proportion, y: proportion)
        bitmapRef.draw(bitmapImage, in: integral)
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }

    @objc func onSaveImgAndShared() {

        let string: String = AssetVCSharedData.sharedData.selectedWalletAddress!
        UIApplication.rootViewController().showLoadingHUD(text: Localized("SharedQRViewSaving"), animated: true)
        DispatchQueue.global().async {
            let image = UIImage.geneQRCodeImageFor(string, size: 300.0)
            DispatchQueue.main.async {

                if let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet {
                    self.sharedQRView.qrImageView.image = image
                    self.sharedQRView.walletAddress.text = wallet.address
                    self.sharedQRView.walletName.text = wallet.name
                    self.sharedQRView.logoImage.image = UIImage(named: wallet.address.walletAddressLastCharacterAvatar())

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
            self.onNavRight(image: image)
        }
    }

    @objc func onNavRight(image: UIImage) {
        let popUpVC = PopUpViewController()
        let view = SharedView(frame: .zero)
        view.shareObject = image
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: SharedView.getSharedViewHeight()))
        popUpVC.setCloseEvent(button: view.closeBtn)
        popUpVC.show(inViewController: self)
    }

}
