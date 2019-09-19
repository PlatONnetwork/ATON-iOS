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

class TransactionService : BaseService{

    static let service = TransactionService() 
    
    var timer : Timer? = nil
    
    private var pendingTransactionPollingTimer : Timer? = nil

    public var ethGasPrice : BigUInt?
    
    public var lastedBlockNumber : String?
    
    public override init() {
        super.init()
        
        if AppConfig.TimerSetting.blockNumberQueryTimerEnable {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.blockNumberQueryTimerInterval), target: self, selector: #selector(OnTimerFirer), userInfo: nil, repeats: true)
            timer?.fire()
        }
        
        if AppConfig.TimerSetting.pendingTransactionPollingTimerEnable{
            pendingTransactionPollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.pendingTransactionPollingTimerInterval), target: self, selector: #selector(OnPendingTxPolling), userInfo: nil, repeats: true)
            pendingTransactionPollingTimer?.fire() 
        }
        
        self.getEthGasPrice(completion: nil)
    }
    
    //MARK: - Timer Selector
    
    @objc func OnTimerFirer() {
        
        web3.platon.getBlockByNumber(block: .latest, fullTransactionObjects: true) { resp in
            //EthereumBlockObject
            guard let blockObj = resp.result else{
                return
            }
            self.lastedBlockNumber = String((blockObj!.number?.quantity)!)
            //NSLog("lasted BlockNumber \(String((blockObj!.number?.quantity)!))")
        }
        
        self.getEthGasPrice(completion: nil)
    }
    
    @objc func OnPendingTxPolling(){
        EnergonTransferPooling()
    }
    
    func getEthGasPrice(completion: PlatonCommonCompletion?){
        web3.platon.gasPrice { (res) in
            switch res.status{
            case .success(_):
                DispatchQueue.main.async {
                    self.ethGasPrice = res.result?.quantity
                    NotificationCenter.default.post(name: Notification.Name.ATON.DidNodeGasPriceUpdate, object: nil)

                }
            case .failure(_):
                do{}
            }
        }
    }
     
    func EnergonTransferPooling(){
        TransferPersistence.getUnConfirmedTransactions { (txs) in
            for item in txs {
                guard (item.txhash != nil) else{
                    continue
                }
                
                guard let txtype = item.txType else {
                    continue
                }
                
                let byteCode = try! EthereumData(ethereumValue: item.txhash!)
                let data = try! EthereumData(ethereumValue: byteCode)
                let newItem = Transaction.init(value: item)
                newItem.txhash = item.txhash
                
                web3.platon.getTransactionReceipt(transactionHash: data) { (txResp) in
                    switch txResp.status{
                    case .success(let resp):
                        if txtype == .transfer {
                            guard let txhash = newItem.txhash else { return }
                            let blockNumber = String(txResp.result??.blockNumber.quantity ?? BigUInt(0))
                            let gasUsed = String(txResp.result??.gasUsed.quantity ?? BigUInt(0))
                            TransferPersistence.update(txhash: txhash, status: 1, blockNumber: blockNumber, gasUsed: gasUsed, {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateTransactionByHash, object: txhash)
                                })
                            })
                        } else {
                            guard let receipt = resp, receipt.logs.count > 0, receipt.logs[0].data.hex().count > 0 else{
                                return
                            }
                            guard let rlpItem = try? RLPDecoder().decode(receipt.logs[0].data.bytes), let respBytes = rlpItem.array?[0].bytes else {
                                return
                            }
                            guard let dic = try? JSONSerialization.jsonObject(with: Data(bytes: respBytes), options: .mutableContainers) as? [String:Any] else{
                                return
                            }
                            DispatchQueue.main.async {
                                guard let status = dic?["Code"] as? Int else { return }
                                guard let txhash = newItem.txhash else { return }
                                let blockNumber = String(receipt.blockNumber.quantity)
                                let gasUsed = String(receipt.gasUsed.quantity)
                                TransferPersistence.update(txhash: txhash, status: status, blockNumber: blockNumber, gasUsed: gasUsed, {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                        NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateTransactionByHash, object: txhash)
                                        
                                    })
                                })
                            }
                        }
                        
                    case .failure(_):
                        do{}
                    }
                }
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
        
        let gasPrice = EthereumQuantity(quantity: PlatonConfig.FuncGasPrice.defaultGasPrice)
        
        let txgas = EthereumQuantity(quantity: BigUInt(estimatedGas)!)
        
        let amountOfwei = BigUInt.mutiply(a: amount, by: ETHToWeiMultiplier)
        let value = EthereumQuantity(quantity: amountOfwei!)
        
        let txTypePart = RLPItem(bytes: [])
        let rlp = RLPItem.array([txTypePart])
        let rawRlp = try? RLPEncoder().encode(rlp)
        let data = EthereumData(bytes: rawRlp!)
//        let data = EthereumData(bytes: Bytes())
        
        try? walletAddr = EthereumAddress(hex: from, eip55: false)
        try? toAddr = EthereumAddress(hex: to, eip55: false)
        try? fromAddr = EthereumAddress(hex: from, eip55: false)
        try? pk = EthereumPrivateKey(hexPrivateKey: pri)

        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")
        queue.async {
            var nonce : EthereumQuantity?
            web3.platon.getTransactionCount(address: walletAddr!, block: EthereumQuantityTag(tagType: .latest)) { resp in
                
                switch resp.status{
                    
                case .success(_):
                    nonce = resp.result
                    semaphore.signal()
                case .failure(let error):
                    self.failCompletionOnMainThread(code: error.code, errorMsg: error.message, completion: &completion)
                    semaphore.signal()
                }
            }
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if nonce == nil{
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
                
                switch resp.status{
                    
                case .success(_):
                    DispatchQueue.main.async {
                        ptx.txhash = resp.result?.hex()
                        ptx.createTime = Date().millisecondsSince1970
                        ptx.value = String(value.quantity)
                        ptx.gasPrice = String(gasPrice.quantity)
                        ptx.gas = String(txgas.quantity)
                        ptx.memo = memo
                        ptx.transactionType = 0
                        TransferPersistence.add(tx: ptx)
                    }
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                case .failure(let error):
                    self.failCompletionOnMainThread(code: error.code, errorMsg: error.message, completion: &completion)
                }
            })
        }
        
        return ptx;
    }
}

