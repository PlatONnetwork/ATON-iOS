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
                guard let newData = data as? [TransactionsStatusByHash], newData.count > 0 else { return }

                for tx in newData {
                    guard let localTx = txs.first(where: { $0.txhash?.lowercased() == tx.hash?.lowercased() }) else { break }
                    guard let txhash = tx.hash, var status = tx.localStatus else { break }

                    var getReceiptTimeout = false
                    let cdata = Date(milliseconds: UInt64(localTx.createTime))

                    let expiredDate = Date(timeInterval: SettingService.shareInstance.remoteConfig?.timeoutSecond ?? TimeInterval(24 * 3600), since: cdata)
                    if Date().compare(expiredDate) == .orderedDescending && localTx.createTime != 0 {
                        getReceiptTimeout = true
                    }

                    //超过24小时后通过hash取回执返回pending，就认为是超时
                    if status == .pending && getReceiptTimeout {
                        status = .timeout
                    }

                    if status != .pending {
                        TransferPersistence.delete(txhash)
                    }

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateTransactionByHash, object: tx)
                    }
                }
            case .fail:
                break
            }
        }
    }

    func sendAPTTransfer(from : String,to : String, amount : String, InputGasPrice : BigUInt, estimatedGas : String, memo : String, pri : String,completion : PlatonCommonCompletion?) -> Transaction {
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

            web3.platon.sendRawTransaction(transaction: signedTx!, response: { (resp) in
                switch resp.status {
                case .success:
                    DispatchQueue.main.async {
                        ptx.txhash = resp.result?.hex()
                        ptx.createTime = Date().millisecondsSince1970
                        ptx.value = String(value.quantity)
                        ptx.gasUsed = (gasPrice.quantity * txgas.quantity).description
                        ptx.gas = String(txgas.quantity)
                        ptx.memo = memo
                        ptx.transactionType = 0
                        ptx.direction = .Sent
                        TransferPersistence.add(tx: ptx)
                    }
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                case .failure(let error):
                    self.failCompletionOnMainThread(code: error.code, errorMsg: error.message, completion: &completion)
                }
            })
        }
        return ptx
    }
}
