//
//  CheckUpdateVC.swift
//  platonWallet
//
//  Created by juzix on 2020/7/23.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class CheckUpdateVC: BaseViewController {
    
    var confirmCallback: (() -> Void)?
    
    var cancelCallback: (() -> Void)?
    
    fileprivate let contentView = UIView()
    fileprivate let headerImageView = UIImageView(image: UIImage(named: "alertTipImage"))
    fileprivate let headerLabel = UILabel()
    fileprivate let versionLabel = UILabel()
    fileprivate let updateInfoTextView = UITextView()
    fileprivate var version: String = ""
    fileprivate var updateInfo: String = ""
    fileprivate var isForceUpdate: Bool = false
    
    fileprivate lazy var confirmButton = { () -> PButton in
        let btn = PButton(frame: .zero)
        btn.localizedNormalTitle = "Update_Now"
        btn.style = .blue
        btn.addTarget(self, action: #selector(confirmButtonClick(sender:)), for: .touchUpInside)
        return btn
    }()
    fileprivate let cancelButton = UIButton(type: .custom)
    
    convenience init(isForceUpdate: Bool, version: String, updateInfo: String) {
        self.init()
        self.isForceUpdate = isForceUpdate
        self.version = version
        self.updateInfo = updateInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        configContent()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showContent()
    }
    
    func configContent() {
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 6.0
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(270)
            make.height.equalTo(353)
            make.top.equalTo(view.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        view.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView.snp.top)
            make.width.height.equalTo(110)
        }
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(updateInfoTextView)
        contentView.addSubview(confirmButton)
        contentView.addSubview(cancelButton)
        
        headerLabel.font = UIFont.systemFont(ofSize: 17)
        headerLabel.textAlignment = .center
        headerLabel.text = Localized("New_version_released")
        headerLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(67)
        }
        
        versionLabel.textColor = UIColor(hex: "105CFE")
        versionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        init(name: "SFProText-Bold", size: 20)
        versionLabel.textAlignment = .center
        versionLabel.text = version
        versionLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(105)

        }
        
        updateInfoTextView.isEditable = false
        updateInfoTextView.font = UIFont.systemFont(ofSize: 14)
        updateInfoTextView.text = updateInfo
        updateInfoTextView.snp.makeConstraints { (make) in
            make.leading.equalTo(19)
            make.trailing.equalTo(-18)
            make.top.equalTo(149)
            make.height.equalTo(75)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.width.equalTo(222)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(isForceUpdate == true ? -18 : -52)
        }
        
        cancelButton.isHidden = isForceUpdate == true
        cancelButton.setTitle(Localized("Update_Later"), for: .normal)
        cancelButton.setTitleColor(UIColor(hex: "105CFE"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick(sender:)), for: .touchUpInside)
        cancelButton.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(60)
            make.width.lessThanOrEqualTo(confirmButton)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-16)
        }
    }

    func showContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.contentView.snp.remakeConstraints { (make) in
                make.width.equalTo(270)
                make.height.equalTo(353)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-12)
            }
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: CGFloat(0.75), initialSpringVelocity: CGFloat(3.0), options: UIView.AnimationOptions.allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        })
    }

    func hide() {
        UIView.animate(withDuration: 0.15) {
//            self.contentView.frame = CGRect(x: self.view.bounds.width, y: 0, width: 290, height: self.view.bounds.height)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func show(from viewController: UIViewController) {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        viewController.present(self, animated: true, completion: nil)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch: AnyObject in touches {
//            let t:UITouch = touch as! UITouch
//            let touchPoint = t.location(in: self.view)
//            if !self.contentView.frame.contains(touchPoint) {
//                if self.isForceUpdate == true { return }
//                hide()
//            }
//        }
//    }
    
    @objc private func confirmButtonClick(sender: UIButton) {
        hide()
        guard let callback = self.confirmCallback else { return }
        callback()
    }
    
    
    @objc private func cancelButtonClick(sender: UIButton) {
        hide()
        guard let callback = self.cancelCallback else { return }
        callback()
    }
    
}
