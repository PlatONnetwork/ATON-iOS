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
    var qrcode: QrcodeData<TransactionQrcode>?
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "TransactionDetailTableViewCell")
        tbView.separatorStyle = .none
        tbView.tableFooterView = UIView()
        return tbView
    }()
    
    
    let valueLabel = UILabel()
    let submitButton = PButton()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
//        let dic = [
//            "qrCodeType": 0,
//            "qrCodeData": [
//                "amount": "10000",
//                "chainId": "100",
//                "from": "0x0772fd8e5126C01b98D3a93C64546306149202ED",
//                "to": "0x2e95e3ce0a54951eb9a99152a6d5827872dfb4fd",
//                "gasLimit": "1000000000",
//                "gasPrice": "1000000000",
//                "nonce": "100",
//                "platOnFunction": [
//                    "type": 0,
//                    "parameters": [
//                        [
//                            "nodeId": "0x0",
//                            "sender": "0x0",
//                            "amount": "10000"
//                        ]
//                    ]
//                ]
//            ]
//            ] as [String : Any]
        
//        let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
//        let result = try! JSONDecoder().decode(QrcodeData<TransactionQrcode>.self, from: data)
//        qrcode = result
        
        
        if let totalString = result.qrCodeData?.amount {
            let totalLAT = totalString.vonToLAT.description
            let unionAttr = NSAttributedString(string: " LAT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
            let attributed = NSMutableAttributedString(string: totalLAT)
            attributed.append(unionAttr)
            valueLabel.attributedText = attributed
        } else {
            valueLabel.text = "--"
        }
        
        if let function = result.qrCodeData?.platOnFunction {
            listData.append((title: Localized("confirm_authorize_function_type"), value: function.typeString))
        } else {
            listData.append((title: Localized("confirm_authorize_function_type"), value: Localized("TransactionStatus_sending_title")))
        }
        
        listData.append((title: Localized("confirm_authorize_from"), value: result.qrCodeData?.from ?? "--"))
        listData.append((title: Localized("confirm_authorize_to"), value: result.qrCodeData?.to ?? "--"))
        
        if
            let gasPrice = result.qrCodeData?.gasPrice,
            let gasLimited = result.qrCodeData?.gasLimit,
            let gasPriceInt = BigUInt(gasPrice),
            let gasLimitedInt = BigUInt(gasLimited) {
            let gas = gasPriceInt.multiplied(by: gasLimitedInt).description.vonToLAT
            listData.append((title: Localized("confirm_authorize_fee"), value: gas.description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()))
        } else {
            listData.append((title: Localized("confirm_authorize_fee"), value: "--"))
        }
    }
    
    func generateQrcodeForSignedTx(content: String) {
        let qrcodeImage = UIImage.geneQRCodeImageFor(content, size: 160)
        
        let qrcodeView = OfflineSignatureQRCodeView()
        qrcodeView.imageView.image = qrcodeImage
        
        let type = ConfirmViewType.qrcodeGenerate(contentView: qrcodeView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_generate_qrcode_for_signed_tx"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_generate_qrcode_for_signed_tx_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_signed_tx"
        
        let controller = PopUpViewController()
        controller.setUpConfirmView(view: offlineConfirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
        controller.onCompletion = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func authorizeTransaction() {
        guard let txQrcode = qrcode?.qrCodeData else { return }
        guard let wallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).first(where: { $0.address.lowercased() == txQrcode.from?.lowercased() }) else { return }
        
        showPasswordInputPswAlert(for: wallet) { [weak self] (privateKey, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }
            
            if txQrcode.platOnFunction?.type == 1004 {
                self.signedDelegateTx(pri: pri, txQrcode: txQrcode)
            } else if txQrcode.platOnFunction?.type == 1005 {
                self.signedWithdrawTx(pri: pri, txQrcode: txQrcode)
            } else {
                self.signedTransferTx(pri: pri, txQrcode: txQrcode)
            }
        }
    }
    
    func signedTransferTx(pri: String, txQrcode: TransactionQrcode) {
        guard
            let sender = txQrcode.from,
            let amountBigInt = BigUInt(txQrcode.amount ?? "0"),
            let to = txQrcode.to,
            let gasPrice = BigUInt(txQrcode.gasPrice ?? "0"),
            let gasLimit = BigUInt(txQrcode.gasLimit ?? "0"),
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0") else { return }
        let nonce = EthereumQuantity(quantity: nonceBigInt)
        let amount = EthereumQuantity(quantity: amountBigInt)
        
        web3.platon.platonSignTransaction(to: to, nonce: nonce, data: [], sender: sender, privateKey: pri, gasPrice: gasPrice, gas: gasLimit, value: amount, estimated: true) { (result, txSigned) in
            switch result {
            case .success:
                guard
                    let transactionSigned = txSigned,
                    let txSignedString = transactionSigned.rlp().bytes?.toHexString()
                    else { return }
                let signedData = SignatureQrcode(signedDatas: [txSignedString], from: sender, type: 0)
                let qrcodeData = QrcodeData(qrCodeType: 1, qrCodeData: signedData)
                guard
                    let jsonData = try? JSONEncoder().encode(qrcodeData),
                    let jsonString = String(data: jsonData, encoding: .utf8) else { return }
                self.generateQrcodeForSignedTx(content: jsonString)
            case .fail(let code, let message):
                break
            }
        }
    }
    
    func signedWithdrawTx(pri: String, txQrcode: TransactionQrcode) {
        guard
            let withdrawCodes = txQrcode.platOnFunction?.withdrawCode,
            let sender = txQrcode.from else { return }
        
        var signedStrings: [String] = []
        
        for code in withdrawCodes {
            guard
                let stakingBlockNum = UInt64(code.stakingBlockNum ?? "0"),
                let nodeId = code.nodeId,
                let sender = code.sender,
                let amount = BigUInt(code.amount ?? "0"),
                let nonceBigInt = BigUInt(txQrcode.nonce ?? "0") else { continue }
            let nonce = EthereumQuantity(quantity: nonceBigInt)
            let funcType = FuncType.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount)
            web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonce, data: funcType.rlpData.bytes, sender: sender, privateKey: pri, gasPrice: funcType.gasPrice, gas: funcType.gas, value: nil, estimated: true) { (result, txSigned) in
                switch result {
                case .success:
                    guard
                        let transactionSigned = txSigned,
                        let txSignedString = transactionSigned.rlp().bytes?.toHexString()
                        else { return }
                    signedStrings.append(txSignedString)
                case .fail(let code, let message):
                    return
                }
            }
        }
        
        let signedData = SignatureQrcode(signedDatas: signedStrings, from: sender, type: 1005)
        let qrcodeData = QrcodeData(qrCodeType: 1, qrCodeData: signedData)
        guard
            let jsonData = try? JSONEncoder().encode(qrcodeData),
            let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        generateQrcodeForSignedTx(content: jsonString)
    }
    
    func signedDelegateTx(pri: String, txQrcode: TransactionQrcode) {
        guard
            let delegateCode = txQrcode.platOnFunction?.delegateCode?.first,
            let typ = delegateCode.typ,
            let nodeId = delegateCode.nodeId,
            let sender = txQrcode.from,
            let amount = BigUInt(delegateCode.amount ?? "0"),
            let nonceBigInt = BigUInt(txQrcode.nonce ?? "0") else {
                self.showErrorMessage(text: "qrcode is invalid", delay: 2.0)
                return
        }
        let nonce = EthereumQuantity(quantity: nonceBigInt)
        let funcType = FuncType.createDelegate(typ: typ, nodeId: nodeId, amount: amount)
        web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonce, data: funcType.rlpData.bytes, sender: sender, privateKey: pri, gasPrice: funcType.gasPrice, gas: funcType.gas, value: nil, estimated: true) { (result, txSigned) in
            switch result {
            case .success:
                guard
                    let transactionSigned = txSigned,
                    let txSignedString = transactionSigned.rlp().bytes?.toHexString()
                    else { return }
                let signedData = SignatureQrcode(signedDatas: [txSignedString], from: sender, type: 1004)
                let qrcodeData = QrcodeData(qrCodeType: 1, qrCodeData: signedData)
                guard
                    let jsonData = try? JSONEncoder().encode(qrcodeData),
                    let jsonString = String(data: jsonData, encoding: .utf8) else { return }
                self.generateQrcodeForSignedTx(content: jsonString)
            case .fail(let code, let message):
                break
            }
        }
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
