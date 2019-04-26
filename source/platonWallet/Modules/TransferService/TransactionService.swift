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



class TransactionService : BaseService{

    static let service = TransactionService()
    
    var timer : Timer? = nil
    
    private var jointWalletCreationTimer : Timer? = nil
    
    private var allJointWalletPollingTimer : Timer? = nil
    
    private var pendingTransactionPollingTimer : Timer? = nil

    public var ethGasPrice : BigUInt?
    
    public var lastedBlockNumber : String?
    
    public override init() {
        super.init()
        
        if blockNumberQueryTimerEnable {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(blockNumberQueryTimerInterval), target: self, selector: #selector(OnTimerFirer), userInfo: nil, repeats: true)
            timer?.fire()
        }
        
        if jointWalletCreationTimerEnable{
            jointWalletCreationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(JointWalletCreationTimerInterval), target: self, selector: #selector( OnJointWalletCreationTimer), userInfo: nil, repeats: true)
            jointWalletCreationTimer?.fire()
        }
        
        if allJointWalletPollingTxsTimerEnable{
            allJointWalletPollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(allJointWalletPollingTxsTimerInterval), target: self, selector: #selector( OnAllJointWalletPollingTxs), userInfo: nil, repeats: true)
            allJointWalletPollingTimer?.fire()
        }
        
        if pendingTransactionPollingTimerEnable{
            pendingTransactionPollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(pendingTransactionPollingTimerInterval), target: self, selector: #selector( OnPendingTxPolling), userInfo: nil, repeats: true)
            pendingTransactionPollingTimer?.fire() 
        }
        
        self.getEthGasPrice(completion: nil)
    }
    
    //MARK: - Timer Selector
    
    @objc func OnTimerFirer() {
        
        web3.eth.getBlockByNumber(block: .latest, fullTransactionObjects: true) { resp in
            //EthereumBlockObject
            guard let blockObj = resp.result else{
                return
            }
            self.lastedBlockNumber = String((blockObj!.number?.quantity)!)
            //NSLog("lasted BlockNumber \(String((blockObj!.number?.quantity)!))")
        }
        
        self.getEthGasPrice(completion: nil)
    }
    
    @objc func OnJointWalletCreationTimer(){
        self.JointWalletCreationPooling()
    }
    
    @objc func OnAllJointWalletPollingTxs(){
        SWalletService.sharedInstance.getAllSharedWalletTransactionList()
    }
    
    @objc func OnPendingTxPolling(){
        self.EnergonTransferPooling()
        self.JointWalletTransferPooling()
        self.VotePooling()
    }
    
    //MARK: - Polling method
    
    func getEthGasPrice(completion: PlatonCommonCompletion?){
        web3.eth.gasPrice { (res) in
            switch res.status{
            case .success(_):
                DispatchQueue.main.async {
                    self.ethGasPrice = res.result?.quantity
                    NotificationCenter.default.post(name: NSNotification.Name(DidNodeGasPriceUpdateNotification), object: nil)

                }
            case .failure(_):
                do{}
            }
        }
    }
     
    func EnergonTransferPooling(){
        TransferPersistence.getUnConfirmedTransactions { (txs) in
            for item in txs{
                guard (item.txhash != nil) else{
                    continue
                }
                guard TransanctionType(rawValue: item.transactionType) != .Vote else {
                    continue
                }
                let byteCode = try! EthereumData(ethereumValue: item.txhash!)
                let data = try! EthereumData(ethereumValue: byteCode)
                let newItem = Transaction.init(value: item)
                newItem.txhash = item.txhash
                web3.eth.getTransactionReceipt(transactionHash: data) { (txResp) in
                    switch txResp.status{
                    case .success(_):
                        let realm = RealmHelper.getNewRealm()
                        try? realm.write {
                            newItem.blockNumber = String(txResp.result??.blockNumber.quantity ?? BigUInt(0))
                            newItem.confirmTimes = 0
                            newItem.gasUsed = String(txResp.result??.gasUsed.quantity ?? BigUInt(0))
                            realm.add(newItem, update: true)
                        }
                        let hash = newItem.txhash
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(DidUpdateTransactionByHashNotification), object: hash)
                        }
                    case .failure(_):
                        do{}
                    }
                }
                
            }
        }

    }
     
    func VotePooling(){
        TransferPersistence.getUnConfirmedTransactions { (txs) in
            for item in txs{
                guard (item.txhash != nil) else{
                    continue
                }
                guard TransanctionType(rawValue: item.transactionType) == .Vote else {
                    continue
                }
                let byteCode = try! EthereumData(ethereumValue: item.txhash!)
                let data = try! EthereumData(ethereumValue: byteCode)
                let newItem = Transaction.init(value: item)
                newItem.txhash = item.txhash
                web3.eth.getTransactionReceipt(transactionHash: data) { (txResp) in
                    switch txResp.status{
                    case .success(let resp): 
                        guard let receipt = resp, receipt.logs.count > 0, receipt.logs[0].data.hex().count > 0 else{
                            return
                        }
                        guard let rlpItem = try? RLPDecoder().decode(receipt.logs[0].data.bytes), let respBytes = rlpItem.array?[0].bytes else {
                            return
                        }
                        guard let dic = try? JSONSerialization.jsonObject(with: Data(bytes: respBytes), options: .mutableContainers) as? [String:Any] else{
                            return
                        }
                        guard let responseJson = String(bytes: respBytes, encoding: .utf8) else{
                            return
                        }  
                        DispatchQueue.main.async {
                            
                            guard let dataString = dic?["Data"] as? String,
                                dataString.split(separator: ":").count == 2,
                                let validCountStr = String(dataString.split(separator: ":")[0]) as? String,
                                let priceStr = String(dataString.split(separator: ":")[1]) as? String else{
                                    return
                            }
                            
                            RealmWriteQueue.async {
                                autoreleasepool(invoking: {
                                    let realm = RealmHelper.getNewRealm()
                                    let hash = newItem.hash
                                    try? realm.write {
                                        newItem.blockNumber = String(receipt.blockNumber.quantity)
                                        newItem.gasUsed = String(receipt.gasUsed.quantity)
                                        newItem.extra = responseJson
                                        realm.add(newItem, update: true)
                                    }
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: NSNotification.Name(DidUpdateVoteTransactionByHashNotification), object: hash)
                                    }
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
    
    
    func JointWalletTransferPooling(){
        let txs = STransferPersistence.getUnConfirmedTransactions()
        for item in txs{
            guard (item.txhash != nil) else{
                continue
            }
            let byteCode = try! EthereumData(ethereumValue: item.txhash!)
            let data = try! EthereumData(ethereumValue: byteCode)
  
            web3.eth.getTransactionReceipt(transactionHash: data) { (txResp) in
                switch txResp.status{
                case .success(_):
                    DispatchQueue.main.async {
                        RealmInstance?.beginWrite()
                        item.blockNumber = String(txResp.result??.blockNumber.quantity ?? BigUInt(0))
                        item.confirmTimes = 0
                        item.gasUsed = String(txResp.result??.gasUsed.quantity ?? BigUInt(0))
                        try? RealmInstance?.commitWrite()
                        NotificationCenter.default.post(name: NSNotification.Name(DidUpdateTransactionByHashNotification), object: item.txhash)
                    }
                case .failure(_):
                    do{}
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
         
        let gasPrice = EthereumQuantity(quantity: InputGasPrice)
        
        let txgas = EthereumQuantity(quantity: BigUInt(estimatedGas)!)
        
        let amountOfwei = BigUInt.mutiply(a: amount, by: ETHToWeiMultiplier)
        let value = EthereumQuantity(quantity: amountOfwei!)
        
        let txTypePart = RLPItem(bytes: ExecuteCode.Transfer.DataValue.bytes)
        let rlp = RLPItem.array([txTypePart])
        let rawRlp = try? RLPEncoder().encode(rlp)
        let data = EthereumData(bytes: rawRlp!)
        
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
                    DispatchQueue.main.async {
                        ptx.txhash = resp.result?.hex()
                        ptx.createTime = Date().millisecondsSince1970
                        ptx.value = String(value.quantity)
                        ptx.gasPrice = String(gasPrice.quantity)
                        ptx.gas = String(txgas.quantity)
                        ptx.memo = memo
                        TransferPersistence.add(tx: ptx)
                    }
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
    
    func JointWalletCreationPooling(){
        
        for jointWallet in SWalletService.sharedInstance.creatingWallets{
            
            if jointWallet.creationStatus == ECreationStatus.deploy_HashGenerated.rawValue{
                self.poolingDeployReception(wallet: jointWallet)
            }else if jointWallet.creationStatus == ECreationStatus.deploy_ReceiptGenerated.rawValue{
                SWalletService.sharedInstance.initSharedWallet(wallet: jointWallet, completion: nil)
            }else if jointWallet.creationStatus == ECreationStatus.initWallet_HashGenerated.rawValue{
                self.poolingInitWalletReception(wallet: jointWallet)
            }
        }
    }
    
    func poolingDeployReception(wallet: SWallet?){
    
        let hash = try? EthereumData(bytes: EthereumData(bytes: Data(hex: (wallet?.deployHash)!).bytes))
        web3.eth.getTransactionReceipt(transactionHash: hash!) { (receptionResp) in
            DispatchQueue.main.async {
                wallet?.deployReceptionLooptime = (wallet?.deployReceptionLooptime)! + 1
                NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: wallet?.deployHash)
                switch receptionResp.status{
                case .success(_):
                    if receptionResp.result != nil && receptionResp.result??.contractAddress != nil{
                        wallet?.contractAddress = (receptionResp.result?!.contractAddress?.hex())!
                        wallet?.creationStatus = ECreationStatus.deploy_ReceiptGenerated.rawValue
                        
                        STransferPersistence.updateJointWalletCreation(contractAddress: (receptionResp.result??.contractAddress?.hex())!, hash: (receptionResp.result??.transactionHash.hex())!)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: wallet?.deployHash)
                    }
                    
                case .failure(_):
                    do{}
                }
                
            }
        }
        

    }
 
     
    func poolingInitWalletReception(wallet: SWallet?){
         
        let hash = try? EthereumData(bytes: EthereumData(bytes: Data(hex: (wallet?.initWalletHash)!).bytes))
        web3.eth.getTransactionReceipt(transactionHash: hash!) { (receptionResp) in
            DispatchQueue.main.async {
                wallet?.initWalletReceptionLooptime = (wallet?.initWalletReceptionLooptime)! + 1
                NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: wallet?.deployHash)
                switch receptionResp.status{
                case .success(_):
                    if receptionResp.result != nil{
                        wallet?.creationStatus = ECreationStatus.initWallet_ReceiptGenerated.rawValue
                        NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: wallet?.deployHash)
                        SWalletPersistence.add(swallet: wallet!)
                        SWalletService.sharedInstance.refreshDB()
                        SWalletService.sharedInstance.removeFromCreatingWallets(swallet: wallet!)
                        //after update memory and db joint-wallets ,need to update asset list
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name(updateWalletList_Notification), object: wallet?.deployHash)
                        })
                        
                    }
                    
                case .failure(_):
                    do{}
                }
                
            }
        }
        
    }
    
}

