//
//  KeyStore.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import platonWeb3

public let DefaultRPCTimeOut = 30.0
public let DefaultAddress = "0x0000000000000000000000000000000000000000"

class TransactionService : BaseService {
    static let service = TransactionService()
    private var pendingTransactionPollingTimer : Timer?
    public var minGasPrice: BigUInt = SettingService.shareInstance.remoteConfig?.minGasPriceBInt ?? PlatonConfig.FuncGasPrice.minGasPrice
    public var defaultGasPrice: BigUInt = SettingService.shareInstance.remoteConfig?.minGasPriceBInt ?? PlatonConfig.FuncGasPrice.minGasPrice

    public var sliderDefaultValue: Float {
        if defaultGasPrice == minGasPrice {
            return 0.00
        } else {
            let maxGasPrice = defaultGasPrice.multiplied(by: BigUInt(6))

            let unit10 = BigUInt(10).power(minGasPrice.description.count - 3)
            let tmpMaxGasPrice = Float((maxGasPrice/unit10).description) ?? 0.00
            let tmpMinGasPrice = Float((minGasPrice/unit10).description) ?? 0.00
            let tmpDefaultPrice = Float((defaultGasPrice/unit10).description) ?? 0.00

            return (tmpDefaultPrice - tmpMinGasPrice)/(tmpMaxGasPrice - tmpMinGasPrice)
        }
    }

    func startTimerFire() {
        if AppConfig.TimerSetting.pendingTransactionPollingTimerEnable {
            pendingTransactionPollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.pendingTransactionPollingTimerInterval), target: self, selector: #selector(onPendingTxPolling), userInfo: nil, repeats: true)
            pendingTransactionPollingTimer?.fire()
        }
    }

    func getGasPrice() {
        getEthGasPrice(completion: nil)
    }

    @objc func onPendingTxPolling() {
        transactionStatusPooling()
    }

    func getEthGasPrice(completion: PlatonCommonCompletion?) {
        web3.platon.gasPrice { (res) in
            switch res.status {
            case .success:
                DispatchQueue.main.async {
                    if let gasPrice = res.result?.quantity, gasPrice > PlatonConfig.FuncGasPrice.minGasPrice {
                        self.defaultGasPrice = gasPrice
                    } else {
                        self.defaultGasPrice = PlatonConfig.FuncGasPrice.minGasPrice
                    }

                    let defaultGasPricePercent50 = self.defaultGasPrice.multiplied(by: BigUInt(Int(0.5 * 10))) / BigUInt(10)
                    self.minGasPrice = defaultGasPricePercent50 > PlatonConfig.FuncGasPrice.minGasPrice ? defaultGasPricePercent50 : PlatonConfig.FuncGasPrice.minGasPrice
                    NotificationCenter.default.post(name: Notification.Name.ATON.DidNodeGasPriceUpdate, object: nil)
                }
            case .failure:
                do {}
            }
        }
    }

    func transactionStatusPooling() {
        let txs = TransferPersistence.getUnConfirmedTransactions()
        guard txs.count > 0 else { return }

        let hashes = txs.filter { $0.txhash != nil }.map { $0.txhash!.lowercased() }
        getTransactionStatus(hashes: hashes) { (result, data) in
            switch result {
            case .success:
                guard let newData = data, newData.count > 0 else { return }
                for tx in newData {
                    guard let localTx = txs.first(where: { $0.txhash?.lowercased() == tx.hash?.lowercased() }) else { break }
                    guard let txhash = tx.hash, var status = tx.txReceiptStatus else { break }

                    var notificateTx = tx
                    var getReceiptTimeout = false
                    let cdata = Date(milliseconds: UInt64(localTx.createTime > 0 ? localTx.createTime : localTx.confirmTimes))

                    let expiredDate = Date(timeInterval: SettingService.shareInstance.remoteConfig?.timeoutSecond ?? TimeInterval(24 * 3600), since: cdata)
                    if Date().compare(expiredDate) == .orderedDescending && (localTx.createTime != 0 || localTx.confirmTimes != 0) {
                        getReceiptTimeout = true
                    }

                    //超过24小时后通过hash取回执返回pending，就认为是超时
                    if status == .pending && getReceiptTimeout {
                        status = .timeout
                        notificateTx.txReceiptStatus = .timeout
                    }

                    // 发现获取交易状态接口的虽然发生改变，但是交易记录列表接口不一定更新的，延时删除这条数据
                    if status != .pending {
                        TransferPersistence.update(txhash: txhash, status: status.rawValue)
//                        TransferPersistence.delete(txhash)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                         NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateTransactionByHash, object: notificateTx)
                    })
                }
            case .failure:
                do {}
            }
        }
    }

    func sendAPTTransfer(from: String, to: String, amount: String, InputGasPrice: BigUInt, estimatedGas: String, remark: String? = nil, pri : String, completion : PlatonCommonCompletion?) -> Transaction {
        var completion = completion
        let ptx = Transaction()
        var walletAddr : EthereumAddress?
        var toAddr : EthereumAddress?
        var fromAddr : EthereumAddress?
        var pk : EthereumPrivateKey?
        let gasPrice = EthereumQuantity(quantity: InputGasPrice)
        let txgas = EthereumQuantity(quantity: BigUInt(estimatedGas)!)
        let amountOfwei = BigUInt.mutiply(a: amount, by: ETHToWeiMultiplier)
        let value = EthereumQuantity(quantity: amountOfwei!)

        let data = EthereumData(bytes: [])
        try? walletAddr = EthereumAddress(hex: from, eip55: false)
        try? toAddr = EthereumAddress(hex: to, eip55: false)
        try? fromAddr = EthereumAddress(hex: from, eip55: false)
        try? pk = EthereumPrivateKey(hexPrivateKey: pri)
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")
        queue.async {
            var nonce : EthereumQuantity?
            web3.platon.getTransactionCount(address: walletAddr!, block: EthereumQuantityTag(tagType: .latest)) { resp in

                switch resp.status {
                case .success:
                    nonce = resp.result
                    semaphore.signal()
                case .failure(let error):
                    self.failCompletionOnMainThread(code: error.code, errorMsg: error.message, completion: &completion)
                    semaphore.signal()
                }
            }

            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut {
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }

            if nonce == nil {
                self.failWithEmptyResponseCompletionOnMainThread(completion: &completion)
                return
            }

            let tx = EthereumTransaction(
                nonce: nonce,
                gasPrice: gasPrice,
                gas: txgas,
                from:fromAddr,
                to: toAddr,
                value: value,
                data : data
                )
            ptx.to = toAddr?.hex(eip55: true)
            ptx.from = walletAddr?.hex(eip55: true)
            let chainID = EthereumQuantity(quantity: BigUInt(web3.chainId)!)
            let signedTx = try? tx.sign(with: pk!, chainId: chainID) as EthereumSignedTransaction

            guard let signedData = signedTx?.rlp().ethereumValue().string else {
                self.failCompletionOnMainThread(code: -1, errorMsg: "sign error", completion: &completion)
                return
            }

            let signedTxWithRemark = SignedTransaction(signedData: signedData, remark: remark)
            self.sendRawTransaction(data: signedTxWithRemark, privateKey: pri, completion: { (result, response) in
                switch result {
                case .success:
                    ptx.txhash = signedTx?.hash?.add0x()
                    ptx.createTime = Date().millisecondsSince1970
                    ptx.value = String(value.quantity)
                    ptx.gasUsed = (gasPrice.quantity * txgas.quantity).description
                    ptx.gas = String(txgas.quantity)
                    ptx.memo = remark
                    ptx.transactionType = 0
                    ptx.direction = .Sent
                    ptx.memo = remark

                    let thTx = TwoHourTransaction()
                    thTx.createTime = Date().millisecondsSince1970
                    thTx.to = toAddr?.hex(eip55: true).lowercased()
                    thTx.from = walletAddr?.hex(eip55: true).lowercased()
                    thTx.value = String(value.quantity)

                    TransferPersistence.add(tx: ptx)
                    TwoHourTransactionPersistence.add(tx: thTx)
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                case .failure(let error):
                    guard let err = error else { return }
                    self.failCompletionOnMainThread(code: err.code, errorMsg: err.message, completion: &completion)
                }
            })
        }
        return ptx
    }

    func createDelgate(typ: UInt16,
                       nodeId: String,
                       amount: BigUInt,
                       sender: String,
                       privateKey: String,
                       gas: BigUInt,
                       gasPrice: BigUInt,
                       completion: PlatonCommonCompletion?) {

        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")

        queue.async {
            var nonce: EthereumQuantity?
            web3.platon.platonGetNonce(sender: sender) { (result, blockNonce) in
                switch result {
                case .success:
                    nonce = blockNonce
                    semaphore.signal()
                case .fail(_, let message):
                    completion?(PlatonCommonResult.fail(-1, message), nil)
                    semaphore.signal()
                }
            }

            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut {
                completion?(PlatonCommonResult.fail(-1, "nonce timeout"), nil)
                return
            }

            guard let nonceQuantity = nonce else {
                completion?(PlatonCommonResult.fail(-1, "nonce empty"), nil)
                return
            }

            let funcType = FuncType.createDelegate(typ: typ, nodeId: nodeId, amount: amount)
            let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonceQuantity, data: funcType.rlpData.bytes, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: nil, estimated: true)

            guard let signedData = txSigned?.rlp().ethereumValue().string else {
                completion?(PlatonCommonResult.fail(-1, "sign error"), nil)
                return
            }

            let signedTxWithRemark = SignedTransaction(signedData: signedData, remark: "")
            self.sendRawTransaction(data: signedTxWithRemark, privateKey: privateKey, completion: { (result, response) in
                switch result {
                case .success:
                    let transaction = Transaction()
                    transaction.txhash = txSigned?.hash
                    transaction.from = sender
                    transaction.txType = .delegateCreate
                    transaction.toType = .contract
                    transaction.txReceiptStatus = -1
                    transaction.value = amount.description
                    transaction.nodeId = nodeId
                    transaction.direction = .Sent
                    transaction.createTime = Int(Date().timeIntervalSince1970 * 1000)
                    transaction.to = PlatonConfig.ContractAddress.stakingContractAddress
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, transaction as AnyObject)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(error?.code, error?.message), nil)
                    }
                }
            })
        }
    }

    func withdrawDelegate(stakingBlockNum: UInt64,
                          nodeId: String,
                          amount: BigUInt,
                          sender: String,
                          privateKey: String,
                          gas: BigUInt?,
                          gasPrice: BigUInt?,
                          _ completion: PlatonCommonCompletion?) {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")

        queue.async {
            var nonce: EthereumQuantity?
            web3.platon.platonGetNonce(sender: sender) { (result, blockNonce) in
                switch result {
                case .success:
                    nonce = blockNonce
                    semaphore.signal()
                case .fail(_, let message):
                    completion?(PlatonCommonResult.fail(-1, message), nil)
                    semaphore.signal()
                }
            }

            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut {
                completion?(PlatonCommonResult.fail(-1, "nonce timeout"), nil)
                return
            }

            guard let nonceQuantity = nonce else {
                completion?(PlatonCommonResult.fail(-1, "nonce empty"), nil)
                return
            }

            let funcType = FuncType.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount)
            let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.stakingContractAddress, nonce: nonceQuantity, data: funcType.rlpData.bytes, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: nil, estimated: true)

            guard let signedData = txSigned?.rlp().ethereumValue().string else {
                completion?(PlatonCommonResult.fail(-1, "sign error"), nil)
                return
            }

            let signedTxWithRemark = SignedTransaction(signedData: signedData, remark: "")
            self.sendRawTransaction(data: signedTxWithRemark, privateKey: privateKey, completion: { (result, response) in
                switch result {
                case .success:
                    let transaction = Transaction()
                    transaction.txhash = txSigned?.hash
                    transaction.from = sender
                    transaction.txType = .delegateWithdraw
                    transaction.toType = .contract
                    transaction.txReceiptStatus = -1
                    transaction.value = amount.description
                    transaction.unDelegation = amount.description
                    transaction.nodeId = nodeId
                    transaction.createTime = Int(Date().timeIntervalSince1970 * 1000)
                    transaction.direction = .Receive
                    transaction.to = PlatonConfig.ContractAddress.stakingContractAddress
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, transaction as AnyObject)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(error?.code, error?.message), nil)
                    }
                }
            })
        }
    }

    func rewardClaim(from: String, privateKey: String, gas: RemoteGas, completion: CommonCompletion<Transaction>?) {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")

        queue.async {
            var nonce: EthereumQuantity?
            web3.platon.platonGetNonce(sender: from) { (result, blockNonce) in
                switch result {
                case .success:
                    nonce = blockNonce
                    semaphore.signal()
                case .fail(_, let message):
                    completion?(PlatonCommonResult.fail(-1, message), nil)
                    semaphore.signal()
                }
            }

            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut {
                completion?(PlatonCommonResult.fail(-1, "nonce timeout"), nil)
                return
            }

            guard let nonceQuantity = nonce else {
                completion?(PlatonCommonResult.fail(-1, "nonce empty"), nil)
                return
            }

            let funcType = FuncType.withdrawDelegateReward
            let txSigned = web3.platon.platonSignTransaction(to: PlatonConfig.ContractAddress.rewardContractAddress, nonce: nonceQuantity, data: funcType.rlpData.bytes, sender: from, privateKey: privateKey, gasPrice: gas.gasPriceBInt, gas: gas.gasLimitBInt, value: nil, estimated: true)

            guard let signedData = txSigned?.rlp().ethereumValue().string else {
                completion?(PlatonCommonResult.fail(-1, "sign error"), nil)
                return
            }

            let signedTxWithRemark = SignedTransaction(signedData: signedData, remark: "")
            self.sendRawTransaction(data: signedTxWithRemark, privateKey: privateKey, completion: { (result, response) in
                switch result {
                case .success:
                    let transaction = Transaction()
                    transaction.txhash = txSigned?.hash
                    transaction.from = from
                    transaction.txType = .claimReward
                    transaction.toType = .contract
                    transaction.txReceiptStatus = -1
                    transaction.createTime = Int(Date().timeIntervalSince1970 * 1000)
                    transaction.direction = .Receive
                    transaction.to = PlatonConfig.ContractAddress.rewardContractAddress
                    transaction.gasPrice = gas.gasPrice
                    transaction.gas = gas.gasLimit
                    transaction.gasUsed = gas.gasUsed
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, transaction)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(error?.code, error?.message), nil)
                    }
                }
            })
        }
    }
}
