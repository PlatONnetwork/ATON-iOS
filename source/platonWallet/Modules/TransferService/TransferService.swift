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



class TransferService : BaseService{

    static let service = TransferService()
    
    var timer : Timer? = nil
    
    public var lastedBlockNumber : String?
    
    public override init() {
        super.init()
        if enableBlockNumberQueryTimer {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(TimerInterval_BlockNumber_Query), target: self, selector: #selector(timerFirer), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    @objc func timerFirer() {
        
        web3.eth.getBlockByNumber(block: .latest, fullTransactionObjects: true) { resp in
            //EthereumBlockObject
            guard let blockObj = resp.result else{
                return
            }
            self.lastedBlockNumber = String((blockObj!.number?.quantity)!)
            //NSLog("lasted BlockNumber \(String((blockObj!.number?.quantity)!))")
        }
        
        self.ATPTransactionsPool()
        self.SharedWalletTransactionsPool()
        
    }
    
    func ATPTransactionsPool(){
        let txs = TransferPersistence.getUnConfirmedTransactions()
        for item in txs{
            guard (item.txhash != nil) else{
                continue
            }
            let byteCode = try! EthereumData(ethereumValue: item.txhash!)
            let data = try! EthereumData(ethereumValue: byteCode)
            web3.eth.getTransactionByHash(blockHash: data, response: { txResp in
                DispatchQueue.main.async {
                    //update blockNumber if exist
                    
                    guard txResp.result??.blockNumber != nil, self.lastedBlockNumber != nil, !(RealmInstance?.isInWriteTransaction)! else{
                        return
                    }
                    
                    var lastedN = BigUInt(self.lastedBlockNumber!)
                    let txblockN = (txResp.result??.blockNumber!.quantity)!
                    let overflow = lastedN?.subtractReportingOverflow(txblockN, shiftedBy: 0)
                    if !overflow!{
                        RealmInstance?.beginWrite()
                        item.blockNumber = String((txResp.result??.blockNumber!.quantity)!)
                        let confirms =  BigUInt(self.lastedBlockNumber!)?.subtracting(txblockN)
                        item.confirmTimes = Int(String(confirms!))!
                        item.gas = String((txResp.result??.gas.quantity)!)
                        item.gasPrice = String((txResp.result??.gasPrice.quantity)!)
                        item.input = txResp.result??.input.hex()
                        try? RealmInstance?.commitWrite()
                        NotificationCenter.default.post(name: NSNotification.Name(DidUpdateTransactionByHashNotification), object: nil)
                    }
                }
                
            })
        }
    }
    
    
    func SharedWalletTransactionsPool(){
        let txs = STransferPersistence.getUnConfirmedTransactions()
        for item in txs{
            guard (item.txhash != nil) else{
                continue
            }
            let byteCode = try! EthereumData(ethereumValue: item.txhash!)
            let data = try! EthereumData(ethereumValue: byteCode)
            web3.eth.getTransactionByHash(blockHash: data, response: { txResp in
                DispatchQueue.main.async {
                    //update blockNumber if exist
                    
                    guard txResp.result??.blockNumber != nil, self.lastedBlockNumber != nil, !(RealmInstance?.isInWriteTransaction)! else{
                        return
                    }
                    
                    var lastedN = BigUInt(self.lastedBlockNumber!)
                    let txblockN = (txResp.result??.blockNumber!.quantity)!
                    let overflow = lastedN?.subtractReportingOverflow(txblockN, shiftedBy: 0)
                    if !overflow!{
                        RealmInstance?.beginWrite()
                        item.blockNumber = String((txResp.result??.blockNumber!.quantity)!)
                        let confirms =  BigUInt(self.lastedBlockNumber!)?.subtracting(txblockN)
                        item.confirmTimes = Int(String(confirms!))!
                        try? RealmInstance?.commitWrite()
                        NotificationCenter.default.post(name: NSNotification.Name(DidUpdateTransactionByHashNotification), object: nil)
                    }
                }
                
            })
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
        
        var data = EthereumData(bytes: [])
        if memo.length > 0{
            let dataContent = Data((memo).utf8)
            let array = [UInt8](dataContent)
            data = EthereumData(bytes: array)
        }
        
        try? walletAddr = EthereumAddress(hex: from, eip55: false)
        try? toAddr = EthereumAddress(hex: to, eip55: false)
        try? fromAddr = EthereumAddress(hex: from, eip55: false)
        try? pk = EthereumPrivateKey(hexPrivateKey: pri)

        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendAPTTransfer")
        queue.async {
            var nonce : EthereumQuantity?
            web3.eth.getTransactionCount(address: walletAddr!, block: EthereumQuantityTag(tagType: .latest)) { resp in
                
                switch resp.status{
                    
                case .success(_):
                    nonce = resp.result
                    semaphore.signal()
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: resp.getErrorLocalizedDescription(), completion: &completion)
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
            
            
            let chainID = EthereumQuantity(quantity: BigUInt(DefaultChainId)!)
            let signedTx = try? tx.sign(with: pk!, chainId: chainID) as EthereumSignedTransaction
            
            web3.eth.sendRawTransaction(transaction: signedTx!, response: { (resp) in
                
                switch resp.status{
                    
                case .success(_):
                    ptx.txhash = resp.result?.hex()
                    ptx.createTime = Date().millisecondsSince1970
                    ptx.value = String(value.quantity)
                    ptx.gasPrice = String(gasPrice.quantity)
                    ptx.gas = String(txgas.quantity)
                    ptx.memo = memo
                    TransferPersistence.add(tx: ptx)
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: resp.getErrorLocalizedDescription(), completion: &completion)
                }
            })
        }
        
        return ptx;
    }
    
    func getEstimateGas(memo : String?, completion : PlatonCommonCompletion?){
        var completion = completion
        var toAddr : EthereumAddress?
        try? toAddr = EthereumAddress(hex: DefaultAddress, eip55: false)
        var data = EthereumData(bytes: [])
        if memo!.length > 0{
            let dataContent = Data((memo)!.utf8)
            let array = [UInt8](dataContent)
            data = EthereumData(bytes: array)
        }
        let call = EthereumCall(from: nil, to: toAddr!, gas: nil, gasPrice: nil, value: nil, data: data)
        web3.eth.estimateGas(call: call) { (resp) in
            switch resp.status{
            case .success(_):
                self.successCompletionOnMain(obj: resp.result?.quantity.gasMutiply(4) as AnyObject, completion: &completion)
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: resp.getErrorLocalizedDescription(), completion: &completion)
            }
        }
    }

    
    
    
}

