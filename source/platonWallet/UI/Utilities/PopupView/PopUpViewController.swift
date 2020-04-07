//
//  PopUpViewController.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Spring

let PopUpContentWidth = kUIScreenWidth - 24 * 2

class PopUpViewController: UIViewController {

    var contentView : UIView?

    let bgView = UIView()

    let dismissView = UIView()

    var dismissCompletion: (() -> Void)?

    var onCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        view.addSubview(bgView)
        bgView.backgroundColor = UIColor(rgb: 0x111111, alpha: 0.5)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let tapGes = UITapGestureRecognizer(target: self, action: #selector(touchClose))
        dismissView.addGestureRecognizer(tapGes)
        dismissView.backgroundColor = UIColor(rgb: 0xff0000, alpha: 0)
    }

    // 0.7版本新增适配发送交易确认页面自动布局
    func setUpConfirmView(view: UIView) {
        contentView = view
        bgView.addSubview(contentView!)
        contentView?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bgView)
            make.bottom.equalTo(bgView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        })

        bgView.addSubview(dismissView)
        dismissView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(bgView)
            make.bottom.equalTo((contentView?.snp_topMargin)!)
        }

        if let confirmView = contentView as? TransferConfirmsView {
            confirmView.onCompletion = { [weak self] in
                guard let self = self else { return }
                self.onDismissViewController(animated: true, completion: {
                    self.onCompletion?()
                })
            }
            confirmView.dismissCompletion = { [weak self] in
                self?.onDismissViewController()
            }
        }

        if let confirmView = contentView as? OfflineSignatureConfirmView {
            confirmView.onCompletion = { [weak self] in
                guard let self = self else { return }
                self.onDismissViewController(animated: true, completion: {
                    self.onCompletion?()
                })
            }
            confirmView.onDismiss = { [weak self] in
                guard let self = self else { return }
                self.onDismissViewController()
            }
        }

        if let confirmView = contentView as? RewardClaimComfirmView {
            confirmView.onCompletion = { [weak self] in
                guard let self = self else { return }
                self.onDismissViewController(animated: true, completion: {
                    self.onCompletion?()
                })
            }

            confirmView.onDismiss = { [weak self] in
                guard let self = self else { return }
                self.onDismissViewController()
            }
        }
    }

    func setUpContentView(view : UIView, size : CGSize) {
        contentView = view
        bgView.addSubview(contentView!)
        contentView?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bgView)
            make.bottom.equalTo(bgView.snp.bottom).offset(size.height)
            make.width.equalToSuperview()
            make.height.equalTo(size.height + (ScreenDesignRatio == 1 ? 0 : 10))
        })

        bgView.addSubview(dismissView)
        dismissView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(bgView)
            make.bottom.equalTo((contentView?.snp_topMargin)!)
        }
        contentView?.layer.cornerRadius = 8
        contentView?.layer.masksToBounds = true

        if let confirmView = contentView as? ThresholdValueSelectView {
            confirmView.onCompletion = { [weak self] in
                self?.onDismissViewController()
            }
        }
    }

    func setCloseEvent(button : UIButton) {
        button.addTarget(self, action: #selector(touchClose), for: .touchUpInside)
    }

    @objc func touchClose() {
        self.onDismissViewController()
    }

    @objc func onDismissViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        if dismissCompletion != nil {
            dismissCompletion!()
        }
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: CGFloat(0.75), initialSpringVelocity: CGFloat(3.0), options: UIView.AnimationOptions.allowUserInteraction, animations: { [weak self] in
                guard let self = self else { return }
                self.contentView?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.bgView.snp.bottom).offset(kUIScreenHeight)
                })
                self.contentView!.superview!.layoutIfNeeded()
                self.bgView.alpha = 0
            }) { _ in
                self.presentingViewController?.dismiss(animated: false, completion: {
                    completion?()
                })
            }
        } else {
            presentingViewController?.dismiss(animated: false, completion: {
                completion?()
            })
        }
    }

    open func show(inViewController vc: UIViewController, animated: Bool = false) {
        modalPresentationStyle = .overCurrentContext
        var presentRootController = vc
        if let tabBarController = vc.tabBarController {
            presentRootController = tabBarController
        }
        
        presentRootController.present(self, animated: animated, completion: {
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.75),
                           initialSpringVelocity: CGFloat(3.0),
                           options: UIView.AnimationOptions.allowUserInteraction,
                           animations: {

                            self.contentView?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo(self.bgView.snp.bottom)
                            })
                            self.contentView!.superview!.layoutIfNeeded()

            },completion: { _ in()
            })
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bezierPath = UIBezierPath(roundedRect: contentView?.bounds ?? .zero, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 35, height: 35))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        contentView?.layer.mask = shapeLayer
    }

    deinit {
        print("PopupViewController deinit")
    }

}
