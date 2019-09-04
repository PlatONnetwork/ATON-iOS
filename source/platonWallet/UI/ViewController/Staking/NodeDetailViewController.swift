//
//  NodeDetailViewController.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class NodeDetailViewController: BaseViewController {
    
    public let nodeInfoView = NodeBaseInfoView()
    public let institutionalLabel = UILabel()
    public let websiteLabel = UILabel()
    public let doubtLabel = UILabel()
    
    lazy var delegateButton = { () -> PButton in
        let button = PButton()
        button.setTitle(Localized("statking_validator_Delegate"), for: .normal)
        button.addTarget(self, action: #selector(delegateTapAction), for: .touchUpInside)
        return button
    }()
    
    var nodeId: String?
    
    var nodeDetail: NodeDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "delegate_validator_detail_title"
        view.backgroundColor = normal_background_color

        // Do any additional setup after loading the view.
        nodeInfoView.nodeNameButton.addTarget(self, action: #selector(openWebSiteController), for: .touchUpInside)
        
        view.addSubview(nodeInfoView)
        nodeInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(236)
        }
        
        let institutionalTipLabel = UILabel()
        institutionalTipLabel.text = Localized("statking_validator_Institutional")
        institutionalTipLabel.textColor = common_darkGray_color
        institutionalTipLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(institutionalTipLabel)
        institutionalTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(nodeInfoView.snp.bottom).offset(20)
        }
        
        institutionalLabel.textColor = .black
        institutionalLabel.font = .systemFont(ofSize: 14)
        institutionalLabel.text = "--"
        view.addSubview(institutionalLabel)
        institutionalLabel.snp.makeConstraints { make in
            make.leading.equalTo(institutionalTipLabel)
            make.top.equalTo(institutionalTipLabel.snp.bottom).offset(10)
        }
        
        let websiteTipLabel = UILabel()
        websiteTipLabel.text = Localized("statking_validator_Website")
        websiteTipLabel.textColor = common_darkGray_color
        websiteTipLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(websiteTipLabel)
        websiteTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(institutionalLabel.snp.bottom).offset(16)
        }
        
        websiteLabel.isUserInteractionEnabled = true
        websiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openWebSiteController)))
        websiteLabel.textColor = common_blue_color
        websiteLabel.font = .systemFont(ofSize: 14)
        websiteLabel.text = "--"
        view.addSubview(websiteLabel)
        websiteLabel.snp.makeConstraints { make in
            make.leading.equalTo(websiteTipLabel)
            make.top.equalTo(websiteTipLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(delegateButton)
        
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -2, width: 10, height: 10)
        attachment.image = UIImage(named: "3.icon_warning")
        
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(attachment: attachment))
        attr.append(NSAttributedString(string: " "))
        attr.append(NSAttributedString(string: Localized("staking_validator_isInit_doubt")))

        doubtLabel.attributedText = attr
        doubtLabel.textColor = common_darkGray_color
        doubtLabel.textAlignment = .center
        doubtLabel.font = .systemFont(ofSize: 12)
        doubtLabel.numberOfLines = 0
        view.addSubview(doubtLabel)
        doubtLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(delegateButton)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-30)
            make.top.equalTo(delegateButton.snp.bottom).offset(15)
        }
        
        
        
        let doubtButtonItem = UIBarButtonItem(image: UIImage(named: "3.icon_doubt"), style: .done, target: self, action: #selector(doubtTapAction))
        doubtButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = doubtButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewLoaded {
            fetchData()
        }
    }
    
    private func setupData() {
        nodeInfoView.nodeAvatarIV.kf.setImage(with: URL(string: nodeDetail?.node.url ?? ""), placeholder: UIImage(named: "3.icon_default"))
        nodeInfoView.nodeNameLabel.text = nodeDetail?.node.name ?? "--"
        nodeInfoView.nodeAddressLabel.text = nodeDetail?.node.nodeId?.nodeIdForDisplay() ?? "--"
        nodeInfoView.rateLabel.text = nodeDetail?.node.rate ?? "--"
        nodeInfoView.totalStakedLabel.text = nodeDetail?.totalStaked ?? "--"
        nodeInfoView.delegationsLabel.text = nodeDetail?.delegations ?? "--"
        nodeInfoView.delegatorsLabel.text = nodeDetail?.delegate
        nodeInfoView.slashLabel.text = nodeDetail?.slash ?? "--"
        nodeInfoView.blocksLabel.text = nodeDetail?.blockOut ?? "--"
        nodeInfoView.blocksRateLabel.text = nodeDetail?.bRate ?? "--"
        
        nodeInfoView.statusButton.setTitle(nodeDetail?.node.status.0 ?? "--", for: .normal)
        nodeInfoView.statusButton.setTitleColor(nodeDetail?.node.status.1 ?? status_blue_color, for: .normal)
        nodeInfoView.statusButton.layer.borderColor = (nodeDetail?.node.status.1 ?? status_blue_color).cgColor
        
        institutionalLabel.text = nodeDetail?.institutionalForDisplay ?? "--"
        websiteLabel.text = nodeDetail?.websiteForDisplay ?? "--"
        
        nodeInfoView.isHidden = (nodeDetail?.website == nil)
        
        if nodeDetail?.node.isInit == true {
            delegateButton.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
            view.layoutIfNeeded()
            delegateButton.style = .disable
        } else {
            delegateButton.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-30)
            }
            view.layoutIfNeeded()
            delegateButton.style = .blue
        }
        doubtLabel.isHidden = (nodeDetail?.node.isInit == false)
    }
    
    private func fetchData() {
        guard let nId = nodeId else { return }
        showLoadingHUD()
        StakingService.sharedInstance.getNodeDetail(nodeId: nId) { [weak self] (result, data) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                if let newData = data as? NodeDetail {
                    self?.nodeDetail = newData
                    self?.setupData()
                }
            case .fail(_, _):
                break
            }
        }
    }
    
    @objc private func openWebSiteController() {
        let controller = WebCommonViewController()
        controller.requestUrl = nodeDetail?.website
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func delegateTapAction() {
        guard (AssetVCSharedData.sharedData.walletList as! [Wallet]).count > 0 else {
            showMessage(text: Localized("error_no_wallet"))
            return
        }
        
        let hasBalance = AssetService.sharedInstace.balances.filter { (balance) -> Bool in
            let free = BigUInt(balance.free ?? "0")
            let lock = BigUInt(balance.lock ?? "0")
            return free! + lock! > BigUInt.zero
        }
        
        if hasBalance.count == 0 {
            showMessage(text: Localized("error_wallet_no_balance"))
            return
        }
        
        guard delegateButton.style != .disable else { return }
        guard let node = nodeDetail?.node else { return }
        let controller = DelegateViewController()
        controller.currentNode = node
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func doubtTapAction() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10
        
        let titleAttr = NSAttributedString(string: Localized("staking_alert_annualized_rate") + "\n", attributes: [NSAttributedString.Key.foregroundColor: text_blue_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let detailAttr = NSAttributedString(string: Localized("staking_alert_annualized_rate_detail") + "\n", attributes: [NSAttributedString.Key.foregroundColor: common_darkGray_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithText(attributedStrings: [titleAttr, detailAttr])
        alertVC.onAction(confirm: { (text, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
