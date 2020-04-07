//
//  OfflineSignatureTransactionViewController.swift
//  platonWallet
//
//  Created by Admin on 24/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import BigInt
import Localize_Swift
import platonWeb3

class OfflineSignatureTransactionViewController: BaseViewController {

    var listData: [(title: String, value: String)] = []
    var qrcode: QrcodeData<[TransactionQrcode]>?

    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "TransactionDetailTableViewCell")
        tbView.separatorStyle = .none
        tbView.tableFooterView = UIView()
        tbView.estimatedRowHeight = 50.0
        return tbView
    }()

    let valueLabel = UILabel()
    let submitButton = PButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        leftNavigationTitle = "offline_signature_title"
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        guard let result = qrcode else { return }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 155))
        valueLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        valueLabel.textColor = common_blue_color
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        headerView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        let lineV = UIView()
        lineV.backgroundColor = common_line_color
        headerView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(headerView.snp.bottom).offset(-18)
            make.height.equalTo(1/UIScreen.main.scale)
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 112))
        submitButton.localizedNormalTitle = "confirm_authorize_button_send"
        submitButton.addTarget(self, action: #selector(authorizeTransaction), for: .touchUpInside)
        footerView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        footerView.layoutIfNeeded()
        submitButton.style = .blue

        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView

        guard let codes = result.qrCodeData, codes.count > 0 else {
            return
        }

        let totalAmount = codes.reduce(BigUInt.zero) { (result, txCode) -> BigUInt in
            return result + BigUInt(txCode.amount ?? "0")!
        }

        let totalLAT = totalAmount.description.vonToLATString ?? "0.00"
        let unionAttr = NSAttributedString(string: " LAT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        let attributed = NSMutableAttributedString(string: totalLAT)
        attributed.append(unionAttr)
        valueLabel.attributedText = attributed

        listData.append((title: Localized("confirm_authorize_function_type"), value: codes.first?.typeString ?? "--"))

        if codes.first?.functionType == 1004 {
            listData.append((title: Localized("confirm_authorize_from"), value:  codes.first?.fromName ?? "--"))
            listData.append((title: Localized("confirm_authorize_delegate_to"), value:  codes.first?.toName ?? "--"))
        } else if codes.first?.functionType == 1005 {
            listData.append((title: Localized("confirm_authorize_from"), value:  codes.first?.fromName ?? "--"))
            listData.append((title: Localized("confirm_authorize_undelegate_to"), value:  codes.first?.toName ?? "--"))
        } else if codes.first?.functionType == 5000 {
            listData.append((title: Localized("confirm_reward_wallet"), value: codes.first?.fromName ?? "--"))
            listData.append((title: Localized("confirm_reward_amount"), value: totalLAT))
        } else {
            listData.append((title: Localized("confirm_send_from"), value:  codes.first?.fromName ?? "--"))
            listData.append((title: Localized("confirm_authorize_to"), value: codes.first?.toName ?? "--"))
        }

        let totalGas = codes.reduce(BigUInt.zero) { (result, txCode) -> BigUInt in
            let gasPrice = BigUInt(txCode.gasPrice ?? "0") ?? BigUInt.zero
            let gasLimit = BigUInt(txCode.gasLimit ?? "0") ?? BigUInt.zero
            let gas = gasPrice.multiplied(by: gasLimit)
            return result + gas
        }

        listData.append((title: Localized("confirm_authorize_fee"), value: (totalGas.description.vonToLATString ?? "0.00").ATPSuffix()))
        if let memo = codes.first?.rk, memo.count > 0 {
            listData.append((title: Localized("TransactionDetailVC_memo"), value: memo))
        }
    }

    func generateQrcodeForSignedTx(content: String) {
        let qrcodeWidth = PopUpContentWidth - 32
        let qrcodeImage = UIImage.geneQRCodeImageFor(content, size: qrcodeWidth, isGzip: true)

        let qrcodeView = OfflineSignatureQRCodeView()
        qrcodeView.imageView.image = qrcodeImage

        let type = ConfirmViewType.qrcodeGenerate(contentView: qrcodeView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_generate_qrcode_for_signed_tx"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_generate_qrcode_for_signed_tx_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_signed_tx"

        let controller = PopUpViewController()
        controller.setUpConfirmView(view: offlineConfirmView)
        controller.show(inViewController: self)
        controller.onCompletion = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    @objc func authorizeTransaction() {
        guard let codes = qrcode?.qrCodeData, codes.count > 0 else {
            return
        }

        guard let wallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).first(where: { $0.address.lowercased() == codes.first?.from?.lowercased() }) else {
            showErrorMessage(text: Localized("offline_signature_not_privatekey"), delay: 2.0)
            return
        }

        guard wallet.type != .observed else {
            showErrorMessage(text: Localized("offline_signature_not_privatekey"))
            return
        }

        showPasswordInputPswAlert(for: wallet) { [weak self] (privateKey, _, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }

            var signedStrings: [String] = []
            for code in codes {
                if code.functionType == 1004 {
                    guard let signatureString = self.signedDelegateTx(pri: pri, txQrcode: code) else { continue }
                    signedStrings.append(signatureString)
                } else if code.functionType == 1005 {
                    guard let signatureString = self.signedWithdrawTx(pri: pri, txQrcode: code) else { continue }
                    signedStrings.append(signatureString)
                } else if code.functionType == 5000 {
                    guard let signatureString = self.signedClaimRewardTx(pri: pri, txQrcode: code) else { continue }
                    signedStrings.append(signatureString)
                } else {
                    guard let signatureString = self.signedTransferTx(pri: pri, txQrcode: code) else { continue }
                    signedStrings.append(signatureString)
                }
            }

            guard
                let code = codes.first,
                let from = code.from,
                let type = code.functionType,
                let signedData = signedStrings.first
            else { return }

            let signedResult = TransactionService.service.signQrcodeData(signedData: signedData, remark: code.rk ?? "", privateKey: pri)
            let qrcodeData = QrcodeData(qrCodeType: 1, qrCodeData: signedStrings, chainId: web3.chainId, functionType: type, from: from, nodeName: code.nodeName, rn: self.qrcode?.rn ?? code.amount, timestamp: self.qrcode?.timestamp, rk: code.rk ?? "", si: signedResult, v: 1)

            guard
                let jsonData = try? JSONEncoder().encode(qrcodeData),
                let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            self.generateQrcodeForSignedTx(content: jsonString)
        }
    }

    func signedTransferTx(pri: String, txQrcode: TransactionQrcode) -> String? {
        guard
            let sender = txQrcode.from,
            let amountBigInt = BigUInt(txQrcode.amount ?? "0"),
            let to = txQrcode.to,
            let gasPrice = BigUInt(txQrcode.gasPrice ?? "0"),
            let gasLimit = BigUInt(txQrcode.gasLimit ?? "0"),
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0") else { return nil }
        let nonce = EthereumQuantity(quantity: nonceBigInt)
        let amount = EthereumQuantity(quantity: amountBigInt)

        let txSigned = web3.platon.platonSignTransaction(to: to, nonce: nonce, data: [], sender: sender, privateKey: pri, gasPrice: gasPrice, gas: gasLimit, value: amount, estimated: true)
        guard
            let transactionSigned = txSigned else { return nil }

        if (qrcode?.v ?? 0) >= 1 {
            let signedString = transactionSigned.rlp().ethereumValue().string
            return signedString
        }

        let bytes = try? RLPEncoder().encode(transactionSigned.rlp())

        guard
            let signedString = bytes?.toHexString().add0x() else { return nil }
        return signedString
    }

    func signedWithdrawTx(pri: String, txQrcode: TransactionQrcode) -> String? {
        guard
            let stakingBlockNum = UInt64(txQrcode.stakingBlockNum ?? "0"),
            let nodeId = txQrcode.nodeId,
            let sender = txQrcode.from,
            let amount = BigUInt(txQrcode.amount ?? "0"),
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0"),
            let gasPrice = BigUInt(txQrcode.gasPrice ?? "0"),
            let gasLimit = BigUInt(txQrcode.gasLimit ?? "0")
        else { return nil }
        let nonce = EthereumQuantity(quantity: nonceBigInt)

        let funcType = FuncType.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount)
        let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonce, data: funcType.rlpData.bytes, sender: sender, privateKey: pri, gasPrice: gasPrice, gas: gasLimit, value: nil, estimated: true)
        guard
            let transactionSigned = txSigned else { return nil }

        if (qrcode?.v ?? 0) >= 1 {
            let signedString = transactionSigned.rlp().ethereumValue().string
            return signedString
        }

        let bytes = try? RLPEncoder().encode(transactionSigned.rlp())

        guard
            let signedString = bytes?.toHexString().add0x() else { return nil }
        return signedString
    }

    func signedDelegateTx(pri: String, txQrcode: TransactionQrcode) -> String? {
        guard
            let typ = txQrcode.typ,
            let sender = txQrcode.from,
            let nodeId = txQrcode.nodeId,
            let amount = BigUInt(txQrcode.amount ?? "0"),
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0"),
            let gasPrice = BigUInt(txQrcode.gasPrice ?? "0"),
            let gasLimit = BigUInt(txQrcode.gasLimit ?? "0")
        else {
                self.showErrorMessage(text: "qrcode is invalid", delay: 2.0)
                return nil
        }

        let nonce = EthereumQuantity(quantity: nonceBigInt)
        let funcType = FuncType.createDelegate(typ: typ, nodeId: nodeId, amount: amount)
        let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonce, data: funcType.rlpData.bytes, sender: sender, privateKey: pri, gasPrice: gasPrice, gas: gasLimit, value: nil, estimated: true)

        guard
            let transactionSigned = txSigned else { return nil }

        if (qrcode?.v ?? 0) >= 1 {
            let signedString = transactionSigned.rlp().ethereumValue().string
            return signedString
        }

        let bytes = try? RLPEncoder().encode(transactionSigned.rlp())

        guard
            let signedString = bytes?.toHexString().add0x() else { return nil }
        return signedString
    }

    func signedClaimRewardTx(pri: String, txQrcode: TransactionQrcode) -> String? {
        guard
            let sender = txQrcode.from,
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0"),
            let gasPrice = BigUInt(txQrcode.gasPrice ?? "0"),
            let gasLimit = BigUInt(txQrcode.gasLimit ?? "0")
            else {
                self.showErrorMessage(text: "qrcode is invalid", delay: 2.0)
                return nil
        }

        let nonce = EthereumQuantity(quantity: nonceBigInt)
        let funcType = FuncType.withdrawDelegateReward
        let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.rewardContractAddress, nonce: nonce, data: funcType.rlpData.bytes, sender: sender, privateKey: pri, gasPrice: gasPrice, gas: gasLimit, value: nil, estimated: true)

        guard
            let transactionSigned = txSigned else { return nil }
        
        if (qrcode?.v ?? 0) >= 1 {
            let signedString = transactionSigned.rlp().ethereumValue().string
            return signedString
        }

        let bytes = try? RLPEncoder().encode(transactionSigned.rlp())

        guard
            let signedString = bytes?.toHexString().add0x() else { return nil }
        return signedString
    }

}

extension OfflineSignatureTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailTableViewCell") as! TransactionDetailTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = listData[indexPath.row].title
        cell.valueLabel.text = listData[indexPath.row].value
        return cell
    }
}
