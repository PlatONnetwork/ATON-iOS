//
//  AssetWalletsHeaderView.swift
//  platonWallet
//
//  Created by Admin on 23/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class AssetWalletsHeaderView: UIView {

    let totalBalanceLabel = UILabel()
    let hideAssetButton = UIButton()
    let menuButton = UIButton()
    let scanButton = UIButton()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 44)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.backgroundColor = UIColor(rgb: 0xf9fbff)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(WalletCollectionViewCell.self, forCellWithReuseIdentifier: WalletCollectionViewCell.cellIdentifier())
        collectionView.register(CreateImportCollectionViewCell.self, forCellWithReuseIdentifier: CreateImportCollectionViewCell.cellIdentifier())
        return collectionView

    }()

    var viewModel: AssetHeaderViewModel {
        return controller.viewModel
    }

    let controller: AssetWalletsHeaderController

    required init(controller: AssetWalletsHeaderController) {
        self.controller = controller
        super.init(frame: .zero)

        initView()
        initBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initBinding() {
        viewModel.walletViewModels.addObserver { [weak self] (_) in
            guard let self = self else { return }
            let rowModels = self.viewModel.walletViewModels.value
            self.collectionView.reloadData()
            for (i, v) in rowModels.enumerated() {
                if let md = v as? AssetWalletViewModel {
                    if md.isWalletSelected == true {
                        self.layoutIfNeeded()
                        let indexPath = IndexPath(item: i, section: 0)
//                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                        guard let attr = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }
                        let rect = CGRect(x: attr.frame.origin.x - 20, y: attr.frame.origin.y, width: self.collectionView.frame.width, height: attr.frame.height)
                        self.collectionView.scrollRectToVisible(rect, animated: true)
                        break
                    }
                }
            }
        }

        viewModel.assetIsHide.addObserver { [weak self] (isHidden) in
            if isHidden {
                self?.hideAssetButton.setImage(UIImage(named: "pwdInvisable"), for: .normal)
                self?.totalBalanceLabel.text = "***"
            } else {
                self?.hideAssetButton.setImage(UIImage(named: "pwdvisable"), for: .normal)
                let totalDes = self?.viewModel.totalBalance.value.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
                self?.totalBalanceLabel.text = totalDes
            }
        }

        viewModel.totalBalance.addObserver { [weak self] (balanceBInt) in
            guard let self = self else { return }
            if self.viewModel.assetIsHide.value {
                self.totalBalanceLabel.text = "***"
            } else {
                let totalDes = balanceBInt.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
                self.totalBalanceLabel.text = totalDes
            }
        }
        controller.onwalletsSelect = { [weak self] in
            guard let self = self else { return }
            let rowModels = self.viewModel.walletViewModels.value
            self.collectionView.reloadData()
            for (i, v) in rowModels.enumerated() {
                if let md = v as? AssetWalletViewModel {
                    if md.isWalletSelected == true {
                        self.layoutIfNeeded()
                        let indexPath = IndexPath(item: i, section: 0)
//                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                        guard let attr = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }
                        let rect = CGRect(x: attr.frame.origin.x - 20, y: attr.frame.origin.y, width: self.collectionView.frame.width, height: attr.frame.height)
                        self.collectionView.scrollRectToVisible(rect, animated: true)
                        break
                    }
                }
            }
            self.collectionView.reloadData()
        }
//        controller.onExchangeWalletToDisplay = {[weak self](walletAddress) in
//            guard let self = self else { return }
//            
//        }
    }

    func initView() {
        backgroundColor = UIColor(rgb: 0xf9fbff)

        let contentView = UIView()
        contentView.backgroundColor = .white
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "asset_bj1")?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 230, right: 370))
        bgImageView.isUserInteractionEnabled = true
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let walletNameLabel = UILabel()
        walletNameLabel.setContentHuggingPriority(.required, for: .vertical)
        walletNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        walletNameLabel.localizedText = "asset_header_title"
        walletNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        walletNameLabel.textColor = .black
        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height + 18)
        }

        menuButton.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        menuButton.setImage(UIImage(named: "1.icon_add"), for: .normal)
        contentView.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(walletNameLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
            make.height.width.equalTo(30)
        }

        scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        scanButton.setImage(UIImage(named: "1.icon_scanning"), for: .normal)
        contentView.addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.centerY.equalTo(walletNameLabel.snp.centerY)
            make.height.width.equalTo(30)
            make.trailing.equalTo(menuButton.snp.leading).offset(-10)
            make.leading.greaterThanOrEqualTo(walletNameLabel.snp.trailing).offset(5)
        }

        let totalBalanceTipLabel = UILabel()
        totalBalanceTipLabel.setContentHuggingPriority(.required, for: .vertical)
        totalBalanceTipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        totalBalanceTipLabel.localizedText = "asset_header_total_asset"
        totalBalanceTipLabel.font = UIFont.systemFont(ofSize: 14)
        totalBalanceTipLabel.textColor = .black
        contentView.addSubview(totalBalanceTipLabel)
        totalBalanceTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(walletNameLabel.snp.bottom).offset(18)
            make.bottom.equalToSuperview().offset(-17)
        }

        totalBalanceLabel.adjustsFontSizeToFitWidth = true
        totalBalanceLabel.setContentHuggingPriority(.required, for: .vertical)
        totalBalanceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        totalBalanceLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        totalBalanceLabel.textColor = .black
        contentView.addSubview(totalBalanceLabel)
        totalBalanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(totalBalanceTipLabel)
            make.leading.equalTo(totalBalanceTipLabel.snp.trailing).offset(10)
        }

        hideAssetButton.addTarget(self, action: #selector(onAssetHide), for: .touchUpInside)
        hideAssetButton.setImage(UIImage(named: "1.icon_visible"), for: .normal)
        contentView.addSubview(hideAssetButton)
        hideAssetButton.snp.makeConstraints { make in
            make.centerY.equalTo(totalBalanceLabel.snp.centerY)
            make.width.equalTo(44)
            make.height.equalTo(37)
            make.leading.equalTo(totalBalanceLabel.snp.trailing)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72)
        }
    }

    @objc func onMenu() {
        viewModel.menuBtnPressed?()
    }

    @objc func onScan() {
        viewModel.scanBtnPressed?()
    }

    @objc func onAssetHide() {
        viewModel.visibleBtnPressed?()
    }
}

extension AssetWalletsHeaderView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.walletViewModels.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rowviewModel = viewModel.walletViewModels.value[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: controller.cellIdentifier(for: rowviewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowviewModel)
        }

        cell.layoutIfNeeded()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowViewModel = viewModel.walletViewModels.value[indexPath.row] as? ViewModelPressible
        rowViewModel?.cellPressed?()
    }
}
