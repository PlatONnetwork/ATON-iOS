//
//  CustomLoading.swift
//  platonWallet
//
//  Created by Ned on 2019/4/4.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class CustomLoading: NSObject {

    static let shardInstance = CustomLoading()

    let container = UIView()
    let imageView = UIImageView()
    let descriptionLabel = UILabel()

    var imgListArray : [UIImage]  = []
    override init() {

        for countValue in 1...15 {
            let strImageName : String = "sequence\(countValue).png"
            let image  = UIImage(named:strImageName)
            imgListArray.append(image!)
        }
        imageView.animationImages = imgListArray
        imageView.animationDuration = 0.6
    }

    static func startLoading(viewController: UIViewController) {
        DispatchQueue.main.async {
            CustomLoading.shardInstance.startLoading(viewController: viewController)
        }
    }

    static func viewWillAppear() {
        CustomLoading.shardInstance.imageView.rotate()
    }

    static func hideLoading(viewController: UIViewController) {
        DispatchQueue.main.async {
            CustomLoading.shardInstance.hdie(viewController: viewController)
        }
    }

    func hdie(viewController: UIViewController) {
        if viewController.view.subviews.contains(container) {
            container.removeFromSuperview()
        }
    }

    func startLoading(viewController: UIViewController) {

        if !viewController.view.subviews.contains(container) {

            container.layer.cornerRadius = 5
            container.layer.masksToBounds = true

            viewController.view .addSubview(container)
            container.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 88, height: 88))
            }
            container.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.size.equalTo(CGSize(width: 50 * 0.5, height: 50 * 0.5))
            }

            container.addSubview(descriptionLabel)
            descriptionLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(imageView).offset(20)
            }

            container.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.5)

            descriptionLabel.textColor = UIColor.white
            descriptionLabel.font = UIFont.systemFont(ofSize: 12)
            descriptionLabel.localizedText = "loading"
            descriptionLabel.textAlignment = .center

        }

        imageView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {[weak self] in
            self?.imageView.stopAnimating()
            self?.imageView.image = self?.imgListArray.last
            self?.imageView.rotate()
        }

    }
}
