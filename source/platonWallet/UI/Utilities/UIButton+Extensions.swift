//
//  UIButton+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

private var AssociatedKey: UInt8 = 1
private var AssociatedKey2: UInt8 = 2

extension UIButton {

    @IBInspectable
    public var localizedSelectedTitle: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey2) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey2, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup()
            updateLocalization()
        }
    }

    @IBInspectable
    public var localizedNormalTitle: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup()
            updateLocalization()
        }
    }

    func localizationSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc public func updateLocalization() {
        if let localizedNormalTitle = localizedNormalTitle, !localizedNormalTitle.isEmpty {
            titleLabel?.text = Localized(localizedNormalTitle)
            setTitle(Localized(localizedNormalTitle), for: .normal)
        }
        if let localizedSelectedTitle = localizedSelectedTitle, !localizedSelectedTitle.isEmpty {
            setTitle(Localized(localizedSelectedTitle), for: .selected)
        }
    }

}

extension UIButton {

    struct RuntimeKey {
        static let btnKey = UnsafeRawPointer.init(bitPattern: "BTNKey".hashValue)
    }

    var hitTestEdgeInsets: UIEdgeInsets? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.btnKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            return (objc_getAssociatedObject(self, RuntimeKey.btnKey!) as? UIEdgeInsets) ?? UIEdgeInsets.zero
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitTestEdgeInsets! == .zero || !isEnabled || isHidden {
            return super.point(inside: point, with: event)
        }
        let relativeFrame = bounds
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets!)
        //let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets!)
        return hitFrame.contains(point)
    }

}

extension UIButton {

    func setCommonEanbleStyle(_ enable: Bool) {
        if enable {
            self.backgroundColor = UIColor(rgb: 0xEFF0F5)
            self.isUserInteractionEnabled = true
            self.setTitleColor(UIColor(rgb: 0x1b2137), for: .normal)
        } else {
            self.backgroundColor = UIColor(rgb: 0x272E47)
            self.isUserInteractionEnabled = false
            self.setTitleColor(UIColor(rgb: 0x626980), for: .normal)
        }
    }

    func setupSwitchWalletStyle() {
        self.addMaskView(corners: [.bottomRight,.topRight], cornerRadiiV: 5)
        let chooseWalletImgView = UIImageView(image: UIImage(named: "chooseWallet"))
        chooseWalletImgView.isUserInteractionEnabled = true
        self.addSubview(chooseWalletImgView)
        chooseWalletImgView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalTo(self)
        }

        let Label = UILabel()
        Label.localizedText = "transferVC_switch_des"
        Label.textColor = UIColor(rgb: 0x105CFE)
        Label.font = UIFont.systemFont(ofSize: 12)
        Label.textAlignment = .right
        Label.sizeToFit()
        self.addSubview(Label)
        Label.snp.makeConstraints { (make) in
            make.trailing.equalTo(self).offset(-16)
            make.leading.equalTo(chooseWalletImgView.snp.trailing).offset(5)
            make.centerY.equalTo(self)
        }
    }

    static func getCommonBarButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(UIColor(rgb: 0x000000), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.sizeToFit()
        return btn
    }

}

class EnlargeTouchButton: UIButton {

    @IBInspectable var margin:CGFloat = 120.0
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        //increase touch area for control in all directions by 20

        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
//        let area = CGRectInset(self.bounds, -margin, -margin)

        return area.contains(point)
    }

}

extension UIButton {
    func setCornerFullBackgroundColorStyle(_ image: UIImage?, _ title: String) {
        self.layer.cornerRadius = 20.0
        self.backgroundColor = common_blue_color
        self.setTitleColor(.white, for: .normal)
        self.setImage(image, for: .normal)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
    }

    func setCornerLineStyle(_ image: UIImage?, _ title: String) {
        self.layer.cornerRadius = 20.0
        self.layer.borderColor = common_blue_color.cgColor
        self.layer.borderWidth = 1
        self.setTitleColor(common_blue_color, for: .normal)
        self.setImage(image, for: .normal)
        self.localizedNormalTitle = title
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
    }

    func setCellBottomStyle(_ image: UIImage?, _ disableImage: UIImage?, _ title: String) {
        self.setTitleColor(.black, for: .normal)
        self.setTitleColor(common_lightLightGray_color, for: .disabled)
        self.setImage(disableImage, for: .disabled)
        self.setTitleColor(common_lightLightGray_color, for: .selected)
        self.setImage(disableImage, for: .selected)
        self.setImage(image, for: .normal)
        self.localizedNormalTitle = title
        self.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
    }
}
