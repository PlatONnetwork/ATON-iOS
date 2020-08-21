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

    let nodeInfoView = NodeBaseInfoView()
    let doubtLabel = UILabel()

    var listData: [(String, String)] = []

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeDetailCell.self, forCellReuseIdentifier: "NodeDetailCell")
        tbView.register(NodeDetailGroupCell.self, forCellReuseIdentifier: "NodeDetailGroupCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = .white
        tbView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    lazy var delegateButton = { () -> PButton in
        let button = PButton()
        button.setTitle(Localized("statking_validator_Delegate"), for: .normal)
        button.addTarget(self, action: #selector(delegateTapAction), for: .touchUpInside)
        return button
    }()

    lazy var noNetworkEmptyView = { () -> UIView in
        let contentView = UIView()
        contentView.backgroundColor = normal_background_color
        let emptyView = NoNetWorkView()
        emptyView.refreshHandler = { [weak self] in
            self?.refreshData()
        }
        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        })
        return contentView
    }()

    var nodeId: String?

    var nodeDetail: NodeDetail?

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "delegate_validator_detail_title"

        // Do any additional setup after loading the view.
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewLoaded {
            fetchData()
        }
    }

    func setupView() {

        view.addSubview(delegateButton)
        delegateButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-40)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(delegateButton.snp.top)
        }

        nodeInfoView.nodeNameButton.addTarget(self, action: #selector(openWebSiteController), for: .touchUpInside)
        tableView.tableHeaderView = nodeInfoView
        nodeInfoView.setNeedsLayout()
        nodeInfoView.layoutIfNeeded()
        nodeInfoView.frame.size = nodeInfoView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = nodeInfoView
        nodeInfoView.nodeLinkHandler = { [weak self] in
            self?.openWebSiteController()
        }
        nodeInfoView.tipsShowHandler = { [weak self] in
            self?.rewardDoubtTapAction()
        }
        nodeInfoView.tipsShowYieldHandler = { [weak self] in
            self?.doubtTapAction()
        }

        let attr = configDoubtAttr(text: Localized("staking_validator_isInit_doubt"))

        doubtLabel.attributedText = attr
        doubtLabel.textColor = UIColor(rgb: 0xFF6B00)
        doubtLabel.textAlignment = .center
        doubtLabel.font = .systemFont(ofSize: 12)
        doubtLabel.numberOfLines = 0
        doubtLabel.isHidden = true
        view.addSubview(doubtLabel)
        doubtLabel.snp.makeConstraints { make in
            make.width.equalTo(238)
            make.centerX.equalTo(delegateButton.snp.centerX)
//            make.leading.trailing.equalTo(delegateButton)
//            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-30)
            make.top.equalTo(delegateButton.snp.bottom).offset(8)
        }

        noNetworkEmptyView.isHidden = true
        view.addSubview(noNetworkEmptyView)
        noNetworkEmptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 配置富文本警告提示
    func configDoubtAttr(text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -2, width: 10, height: 10)
        attachment.image = UIImage(named: "3.icon_warning")

        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(attachment: attachment))
        attr.append(NSAttributedString(string: " "))
        attr.append(NSAttributedString(string: text))
        return attr
    }

    private func setupData() {
        nodeInfoView.nodeAvatarIV.kf.setImage(with: URL(string: nodeDetail?.node.url ?? ""), placeholder: UIImage(named: "3.icon_default"))
        nodeInfoView.nodeNameLabel.text = nodeDetail?.node.name ?? "--"
        nodeInfoView.nodeAddressLabel.text = nodeDetail?.node.nodeId?.nodeIdForDisplay() ?? "--"
        nodeInfoView.rateLabel.text = nodeDetail?.node.rate ?? "--"
        nodeInfoView.rewardRatioLabel.text = nodeDetail?.delegatedRewardPerValue
        nodeInfoView.totalRewardLabel.text = nodeDetail?.cumulativeRewardValue

        nodeInfoView.nodeNameButton.isHidden = (nodeDetail?.website == nil || nodeDetail?.website?.count == 0)
        nodeInfoView.statusButton.setTitle(nodeDetail?.node.status.0 ?? "--", for: .normal)
        nodeInfoView.ratePATrend = nodeDetail?.delegatedRatePATrend

        if nodeDetail?.node.isInit == true {
            delegateButton.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
            view.layoutIfNeeded()
            delegateButton.style = .disable
            doubtLabel.isHidden = false
        } else {
            delegateButton.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-40)
            }
            view.layoutIfNeeded()
            // 若钱包数非空，并且节点状态为Active或Candidate才能执行委托操作
            delegateButton.style = (AssetVCSharedData.sharedData.walletList.count > 0) && ((nodeDetail?.node.nodeStatus == "Active") || (nodeDetail?.node.nodeStatus == "Candidate")) ?  .blue : .disable
            if  nodeDetail?.node.nodeStatus == "Locked" {
                doubtLabel.isHidden = false
                doubtLabel.attributedText = configDoubtAttr(text: Localized("locked_node_cant_be_delegate"))
            } else {
                doubtLabel.isHidden = true
            }
        }

        nodeInfoView.isInitNode = nodeDetail?.node.isInit ?? false
        nodeInfoView.setNeedsLayout()
        nodeInfoView.layoutIfNeeded()
        nodeInfoView.frame.size = nodeInfoView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = nodeInfoView

        var details: [(String, String)] = []
        details.append((Localized("statking_validator_total_staked"), nodeDetail?.totalStaked ?? "--"))
        details.append((Localized("statking_validator_delegations"), nodeDetail?.delegations ?? "--"))
        details.append((Localized("statking_validator_delegators"), nodeDetail?.node.delegate ?? "--"))
        details.append((Localized("statking_validator_blocks"), nodeDetail?.blockOut ?? "--"))
        details.append((Localized("statking_validator_blocks_rate"), nodeDetail?.bRate ?? "--"))
        details.append((Localized("statking_validator_slash"), nodeDetail?.slash ?? "--"))
        details.append((nodeDetail?.websiteForDisplay ?? "--", nodeDetail?.institutionalForDisplay ?? "--"))
        listData = details
        tableView.reloadData()
    }

    func refreshData() {
        fetchData()
    }

    private func fetchData() {
        guard let nId = nodeId else { return }
        showLoadingHUD()
        StakingService.getNodeDetail(nodeId: nId) { [weak self] (result, data) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                if let newData = data {
                    self?.nodeDetail = newData
                    self?.setupData()
                    self?.noNetworkEmptyView.isHidden = true
                }
            case .failure(let error):
                self?.noNetworkEmptyView.isHidden = false
                self?.showErrorMessage(text: error?.message ?? "server error")
            }
        }
    }

    @objc private func openWebSiteController() {
        guard let website = nodeDetail?.website, website.count > 0 else { return }
        let controller = WebCommonViewController()
        controller.requestUrl = nodeDetail?.website
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func delegateTapAction() {
        guard (AssetVCSharedData.sharedData.walletList as! [Wallet]).count > 0 else {
            return
        }

        guard delegateButton.style != .disable else { return }
        guard let node = nodeDetail?.node else { return }
        let controller = DelegateViewController()
        controller.currentNode = node
        controller.currentAddress = (AssetVCSharedData.sharedData.selectedWallet as? Wallet)?.address
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func doubtTapAction() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10

        let titleAttr = NSAttributedString(string: Localized("staking_alert_annualized_rate") + "\n", attributes: [NSAttributedString.Key.foregroundColor: text_blue_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let detailAttr = NSAttributedString(string: Localized("staking_alert_annualized_rate_detail") + "\n", attributes: [NSAttributedString.Key.foregroundColor: common_darkGray_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.paragraphStyle: paragraphStyle])

        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithText(attributedStrings: [titleAttr, detailAttr])
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }

    @objc private func rewardDoubtTapAction() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10

        let titleAttr = NSAttributedString(string: Localized("staking_alert_annualized_reward") + "\n", attributes: [NSAttributedString.Key.foregroundColor: text_blue_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let detailAttr = NSAttributedString(string: Localized("staking_alert_annualized_reward_detail") + "\n", attributes: [NSAttributedString.Key.foregroundColor: common_darkGray_color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.paragraphStyle: paragraphStyle])

        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithText(attributedStrings: [titleAttr, detailAttr])
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
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

extension NodeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == listData.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NodeDetailGroupCell") as! NodeDetailGroupCell
            let item = listData[indexPath.row]
            cell.websiteLabel.text = item.0
            cell.institutionalLabel.text = item.1
            cell.websiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openWebSiteController)))
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeDetailCell") as! NodeDetailCell
        let item = listData[indexPath.row]
        cell.titleLabel.text = item.0
        cell.valueLabel.text = item.1
        return cell
    }
}

class NoNetWorkView: UIView {
    var refreshHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        let imageView = UIImageView(image: UIImage(named: "img-No network"))
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(201)
            make.height.equalTo(139)
            make.top.equalToSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.text = Localized("empty_view_no_network_title")
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(rgb: 0x61646e)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(24)
        }

        let subTitleLabel = UILabel()
        subTitleLabel.text = Localized("empty_view_no_network_message")
        subTitleLabel.font = .systemFont(ofSize: 13)
        subTitleLabel.textColor = UIColor(rgb: 0x61646e)
        subTitleLabel.textAlignment = .center
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }

        let button = UIButton()
        button.setTitle(Localized("empty_view_refresh_title"), for: .normal)
        button.setTitleColor(UIColor(rgb: 0x105cfe), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(30)
            make.bottom.equalToSuperview()
        }
    }

    @objc func refreshAction() {
        refreshHandler?()
    }
}
