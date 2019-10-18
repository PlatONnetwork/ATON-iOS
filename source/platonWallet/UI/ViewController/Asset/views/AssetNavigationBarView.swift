//
//  AssetNavigationBarView.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Spring
import Localize_Swift

let selectedScale : CGFloat = 1.2

class AssetNavigationBarView: UIView {

    let unreadDot = UIView(frame: .zero)

    @IBOutlet weak var leftButton: SpringButton!
    @IBOutlet weak var rightButton: SpringButton!

    //iOS must override this getter property
    override var intrinsicContentSize: CGSize {
        return CGSize(width: kUIScreenWidth - 120, height: 55)
    }

    override func awakeFromNib() {

        backgroundColor = .clear
        //leftButton.setTitle(Localized("navigationbar_wallet_title"), for: .normal)
        leftButton.localizedNormalTitle = "navigationbar_wallet_title"
        leftButton.backgroundColor = UIColor.clear
        leftButton.setTitleColor(nav_title_unselected_title, for: .normal)

        //rightButton.setTitle(Localized("navigationbar_sharedwallet_title"), for: .normal)
        rightButton.localizedNormalTitle = "navigationbar_sharedwallet_title"
        rightButton.backgroundColor = UIColor.clear
        rightButton.setTitleColor(nav_title_unselected_title, for: .normal)

        setLeftButtonSelect()

        self.addSubview(unreadDot)

        unreadDot.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 6, height: 6))
            make.leading.equalTo((rightButton.snp_trailingMargin)).offset(4*pow(selectedScale, 7))
            make.top.equalTo((rightButton.snp_topMargin))
        }
        unreadDot.backgroundColor = UIColor(rgb: 0xFF4747)
        unreadDot.layer.masksToBounds = true
        unreadDot.layer.cornerRadius = 3

        unreadDot.isHidden = true
    }

    @IBAction func onLeft(_ sender: Any) {
        setLeftButtonSelect()
    }
    @IBAction func onRight(_ sender: Any) {
        setRightButtonSelect()
    }

    func setLeftButtonSelect() {
        leftButton.setTitleColor(nav_title_selected_title, for: .normal)
        rightButton.setTitleColor(nav_title_unselected_title, for: .normal)
        scale(viwe: leftButton, fromScale: 1.0, toScale: selectedScale)
        scale(viwe: rightButton, fromScale: selectedScale, toScale: 1.0)

        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.4)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }

    func setRightButtonSelect() {
        leftButton.setTitleColor(nav_title_unselected_title, for: .normal)
        rightButton.setTitleColor(nav_title_selected_title, for: .normal)
        scale(viwe: rightButton, fromScale: 1.0, toScale: selectedScale)
        scale(viwe: leftButton, fromScale: selectedScale, toScale: 1.0)

        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.4)
    }

    func scale(viwe : UIView,fromScale : CGFloat,toScale : CGFloat) {
        viwe.transform = CGAffineTransform(scaleX: fromScale, y: fromScale)

        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(1.0),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        //self.rightButton.transform = CGAffineTransform.identity
                        viwe.transform = CGAffineTransform(scaleX: toScale, y: toScale)

        },completion: { _ in()
        })
    }
}
