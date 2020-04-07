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

    let sharedQRView = UIView.viewFromXib(theClass: SharedQRView.self) as! SharedQRView

    var walletInstance: AnyObject?

    lazy var saveImgAndShreadBtn: PButton = {
        let button = PButton()
        button.localizedNormalTitle = "QRViewSaveAndShared"
        return button
    }()

    lazy var qrCodeIV: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialUI()
    }

    func initialUI() {
        leftNavigationTitle = "ReceiveVC_nav_title"
        
        saveImgAndShreadBtn.style = .blue
        view.addSubview(saveImgAndShreadBtn)
        saveImgAndShreadBtn.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-20)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let fixedTopView = UIView()
        fixedTopView.backgroundColor = UIColor(rgb: 0xFFE6D1)
        view.addSubview(fixedTopView)
        fixedTopView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let tipsIcon = UIImageView()
        tipsIcon.image = UIImage(named: "3.icon_warning")
        fixedTopView.addSubview(tipsIcon)
        tipsIcon.snp.makeConstraints { make in
            make.height.width.equalTo(14)
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }

        let tipsLabel = UILabel()
        tipsLabel.textColor = UIColor(rgb: 0xFF6B00)
        tipsLabel.font = .systemFont(ofSize: 14)
        tipsLabel.numberOfLines = 0
        fixedTopView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.leading.equalTo(tipsIcon.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        view.addSubview(qrCodeIV)
        qrCodeIV.snp.makeConstraints { make in
            make.width.height.equalTo(220)
            make.centerX.equalToSuperview()
            make.top.equalTo(fixedTopView.snp.bottom).offset(60)
        }

        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qrCodeIV.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().offset(-35)
        }

        let button = UIButton()
        button.setImage(UIImage(named: "10.icon_copy"), for: .normal)
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        let qrImage = UIImage.geneQRCodeImageFor(AssetVCSharedData.sharedData.selectedWalletAddress!, size: 300.0)
        qrCodeIV.image = qrImage

        saveImgAndShreadBtn.addTarget(self, action: #selector(onSaveImgAndShared), for: .touchUpInside)
        addressLabel.text = AssetVCSharedData.sharedData.selectedWalletAddress

        let attribute_1 = NSAttributedString(string: "wallet_receive_qrcode_warning_1")
        let attribute_2 = NSAttributedString(string: "wallet_receive_qrcode_warning_2")

        let attr = NSMutableAttributedString()
        attr.append(attribute_1)
        attr.append(NSAttributedString(string: SettingService.shareInstance.currentNetworkName))
        attr.append(attribute_2)
        tipsLabel.localizedAttributedTexts = [attribute_1, NSAttributedString(string: SettingService.shareInstance.currentNetworkDesc), attribute_2]
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
        popUpVC.setCloseEvent(button: view.closeButton)
        popUpVC.show(inViewController: self)
    }

    @objc func onTap() {
        if (addressLabel.text?.length)! > 0 {
            let pasteboard = UIPasteboard.general
            pasteboard.string = addressLabel.text
            UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("ExportVC_copy_success"))
        }
    }

}
