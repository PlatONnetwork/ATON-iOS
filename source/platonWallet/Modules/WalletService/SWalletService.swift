//
//  SWalletService.swift
//  platonWallet
//
//  Created by matrixelement on 15/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import BigInt
import platonWeb3


let BigUIntZero = BigUInt("0")!

let deploy_ShouldUseStipulatedGas = true

let deploy_UseStipulatedGas = BigUInt("240943980")!

let initWallet_ShouldUseStipulatedGas = true

let initWallet_UseStipulatedGas = BigUInt("546370")!

let submit_ShouldUseStipulatedGas = true

let submit_StipulatedGas = BigUInt("287760")!

let approve_ShouldUseStipulatedGas = true

let approve_StipulatedGas = BigUInt("1334230")!

let revoke_ShouldUseStipulatedGas = true

let revoke_StipulatedGas = BigUInt("1304050")!

let GasMutipyTime = 10

let DefaultAddress = "0x0000000000000000000000000000000000000000"

//should be always to false
let UIDisplay_addInitWalletGas = false

//should be always to false
let UIDisplay_addConfirmGas = false

class SWalletService: BaseService{
    
    static let sharedInstance = SWalletService()
    
    //db initialized wallets
    private(set) var wallets : [SWallet] = []
    
    //memory initializing joint wallets
    var creatingWallets : [SWallet] = []
    
    //format: contractAddress:transactionID e.g.:"0xabcef000000000000000000000000000000abcde_1"
    var outwardHash : [String] = []
    
    required override init() {
        super.init()
        refreshDB()
    }
    
    func willOwnerWalletBeingDelete(ownerWallet : Wallet){
        
        /*
        for swallet in wallets{
            if (ownerWallet.key?.address.ishexStringEqual(other: swallet.walletAddress))!{
                self.deleteWallet(swallet: swallet)
            }
        }
         */
    }
    
    func removeFromCreatingWallets(swallet: SWallet){
        var i = -1
        for (index, element) in creatingWallets.enumerated() {
            if element.deployHash == swallet.deployHash{
                i = index
                break
            }
        }
        
        if i != -1{
            creatingWallets.remove(at: i)
        }
    }
    
    
    func deleteWallet(swallet : SWallet){
        NotificationCenter.default.post(name: NSNotification.Name(WillDeleateWallet_Notification), object: swallet)
        AssetService.sharedInstace.assets.removeValue(forKey: swallet.contractAddress)
        self.wallets.removeAll { sw -> Bool in
            return sw.contractAddress.ishexStringEqual(other: swallet.contractAddress)
        }
        NotificationCenter.default.post(name: NSNotification.Name(updateWalletList_Notification), object: nil)
        /*
         keep STransaction for individual wallet
         STransferPersistence.deleteByContractAddress(swallet.contractAddress)
         */
        
        //update associated shared wallet transactions swallet delete tag
        STransferPersistence.updateSharedWalletDeleteTag(contractAddress: swallet.contractAddress, deleted: DeleteTag.YES)
        
        AssetVCSharedData.sharedData.willDeleteWallet(object: swallet)
        
        RealmInstance?.beginWrite()
        RealmInstance?.delete(swallet)
        try? RealmInstance?.commitWrite()
        SWalletService.sharedInstance.refreshDB()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //delay for UI datasouce updating
            SWalletService.sharedInstance.getAllSharedWalletTransactionList()
        }
    }
    
    //MARK: - utility
    
    func getATPWalletByAddress(address : String) -> Wallet?{
        for wallet in WalletService.sharedInstance.wallets{
            if address.ishexStringEqual(other: wallet.key?.address) {
                return wallet
            }
        }
        return nil
    }
    
    func getJointWalletByContractAddress(contractAddress: String) -> SWallet?{
        for jointWallet in self.wallets{
            if jointWallet.contractAddress.ishexStringEqual(other: contractAddress){
                return jointWallet
            }
        }
        return nil
    }
    
    
    func getSWalletByOwnerAddress(ownerAddress : String) -> SWallet?{
        
        for swallet in wallets{
            if swallet.walletAddress.lowercased() == ownerAddress.lowercased(){
                return swallet
            }
        }
        return nil
        
    }
    func getSWalletByContractAddress(contractAddress : String) -> SWallet?{
        for item in wallets{
            if item.contractAddress == contractAddress{
                return item
            }
        }
        return nil
    }
    

    
    func refreshDB() {
        wallets.removeAll()
        wallets.append(contentsOf: SWalletPersistence.getAll())
    }
    
    //MARK: - gas estimation
    
    func estimateCreateWalletGas(sender: String,addresses: [String],require: UInt64, completion : PlatonCommonCompletion?){
        var completion = completion
        if deploy_ShouldUseStipulatedGas{
            self.successCompletionOnMain(obj: (deploy_UseStipulatedGas,initWallet_UseStipulatedGas) as AnyObject, completion: &completion)

            return;
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "estimateCreateWalletGas")
        
        var deployGas : BigUInt?
        queue.async {
            let from = EthereumAddress(hexString: sender)
            let call = EthereumCall(from: from, to: nil, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: (self.getDeployData()?.bytes)!))
            web3.eth.estimateGas(call: call) { (gasestResp) in
                switch gasestResp.status{
                case .success(_):
                    deployGas = gasestResp.result?.quantity.gasMutiply(GasMutipyTime)
                    print("estimate gas deploy:\(String(deployGas!)) original:\(String((gasestResp.result?.quantity)!))")
                    semaphore.signal()
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                    semaphore.signal()
                }
            }
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if deployGas == nil{
                //fail completion has been trigger
                return
            }

            print("deploy \(deploy_ShouldUseStipulatedGas) use stipulated gas")
            if deploy_ShouldUseStipulatedGas{
                deployGas = deploy_UseStipulatedGas
            }
            
            if deployGas == nil{
                return
            }
            
            self.successCompletionOnMain(obj: (deployGas,deployGas) as AnyObject, completion: &completion)

        }
        
    }
    
   
    
    func estimateRevokeConfirmation(contractAddress: String,transactionId: UInt64,completion : PlatonCommonCompletion?){
        
        var completion = completion
        
        if revoke_ShouldUseStipulatedGas{
            self.successCompletionOnMain(obj: revoke_StipulatedGas as AnyObject, completion: &completion)
            return
        }
        
        let bytes = self.build_revokeConfirmation(transactionID: transactionId)
        let initWalletCall = EthereumCall(from: nil, to: EthereumAddress(hexString: contractAddress)!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: bytes))
        
        web3.eth.estimateGas(call: initWalletCall) { (gasestResp) in
            switch gasestResp.status{
            case .success(_):
                let gas = gasestResp.result?.quantity.gasMutiply(GasMutipyTime)
                print("estimate gas revoke:\(String(gas!)) original:\(String((gasestResp.result?.quantity)!))")
                self.successCompletionOnMain(obj: gas as AnyObject, completion: &completion)
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                return
            }
        }
    }
    
    func estimateConfirmTransaction(contractAddress: String,transactionId: UInt64,completion : PlatonCommonCompletion?){
        
        var completion = completion
        
        if approve_ShouldUseStipulatedGas{
            self.successCompletionOnMain(obj: approve_StipulatedGas as AnyObject, completion: &completion)
            return
        }
        
        let bytes = self.build_confirmTransaction(transactionID: transactionId)
        let initWalletCall = EthereumCall(from: nil, to: EthereumAddress(hexString: contractAddress)!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: bytes))
        
        web3.eth.estimateGas(call: initWalletCall) { (gasestResp) in
            switch gasestResp.status{
            case .success(_):
                let gas = gasestResp.result?.quantity.gasMutiply(GasMutipyTime)
                print("estimate gas approve:\(String(gas!)) original:\(String((gasestResp.result?.quantity)!))")
                self.successCompletionOnMain(obj: gas as AnyObject, completion: &completion)
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                return
            }
        }
    }
    
    func estimateSubmitAndConfirm(
        walltAddress : String,
        privateKey : String,
        contractAddress : String,
        gasPrice : BigUInt,
        gas : BigUInt,
        memo : String,
        destination : String,
        value : BigUInt,
        len : BigUInt,
        time : UInt64,
        fee : BigUInt,
        completion : PlatonCommonCompletion?){
        
        var completion = completion
        
        let submitBytes = self.build_submitTransaction(walltAddress: walltAddress, privateKey: privateKey, contractAddress: contractAddress, gasPrice: gasPrice, gas: gas, memo: memo, destination: destination, value: value, time: time, fee: fee)
    
        var submitGas : BigUInt?
        var confirmGas : BigUInt?
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "estimateSubmitAndConfirm")
        
        if submit_ShouldUseStipulatedGas{
            var memoGas = BigUInt("100")?.gasMutiply((memo.data(using: .utf8)?.count)!)
            memoGas?.multiplyAndAdd(submit_StipulatedGas, 1)
            let tuple = (memoGas,approve_StipulatedGas)
            self.successCompletionOnMain(obj: tuple as AnyObject, completion: &completion)
            return
        }
        
        
        queue.async {
            let to = EthereumAddress(hexString: contractAddress)
            let call = EthereumCall(from: nil, to: to!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: submitBytes))
            web3.eth.estimateGas(call: call) { (gasestResp) in
                switch gasestResp.status{
                case .success(_):
                    submitGas = gasestResp.result?.quantity.gasMutiply(GasMutipyTime)
                    print("estimate submit gas :\(String(submitGas!)) original:\(String((gasestResp.result?.quantity)!))")
                    semaphore.signal()
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                    semaphore.signal()
                    
                }
            }
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if submitGas == nil{
                //fail compleiton has been execute
                return
            }
            
            NSLog("submit\(submit_ShouldUseStipulatedGas) use stipulted")
            if submit_ShouldUseStipulatedGas{
                submitGas = submit_StipulatedGas
            }
         
            
            let confirmBytes = self.build_confirmTransaction(transactionID: 0)

            let initWalletCall = EthereumCall(from: nil, to: to!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: confirmBytes))
            
            web3.eth.estimateGas(call: initWalletCall) { (gasestResp) in
                
                switch gasestResp.status{
                case .success(_):
                    confirmGas = gasestResp.result?.quantity

                    let tuple = (submitGas?.gasMutiply(GasMutipyTime),confirmGas?.gasMutiply(GasMutipyTime))
                    self.successCompletionOnMain(obj: tuple as AnyObject, completion: &completion)
                    
                    semaphore.signal()
                    
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                    semaphore.signal()
                    return
                }
            }
        }
        
    }
    

    //MARK: - public
    
    func createWallet(sharedWallet: SWallet,sender :String, deployGasPrice: BigUInt, deployGgas: BigUInt, initGasPrice: BigUInt, initGgas: BigUInt, privateKey: String, addresses: [String],require: UInt64, completion: PlatonCommonCompletion?){
        
        var completion = completion
        
        let bin = self.getBIN()
        let abiS = self.getABI()
  
        NSLog("deployGasPrice:\(String(deployGasPrice))")
        NSLog("deployGgas:\(String(deployGgas))")
        web3.eth.platonDeployContract(abi: abiS!, bin: bin!, sender: sender, privateKey: privateKey, gasPrice: deployGasPrice, gas: deployGgas, estimateGas: false, waitForTransactionReceipt: true, timeout: 20, completion:{
            (result,transactionHash,contractAddress,receipt) in
            
            switch result{
            case .success:
                do {

                    //add shared wallet transaction
                    let stransaction = STransaction(swallet: sharedWallet)
                    stransaction.from = sender
                    stransaction.to = contractAddress
                    stransaction.gas = String(deployGgas)
                    stransaction.gasPrice = String(deployGasPrice)
                    let totalGas = deployGasPrice.multiplied(by: deployGgas) + initGasPrice.multiplied(by: initGgas)
                    stransaction.fee = String( totalGas)
                    stransaction.transactionType = 2
                    stransaction.txhash = transactionHash
                    stransaction.value = "0"
                    stransaction.readTag = ReadTag.Readed.rawValue
                    stransaction.transactionCategory = TransanctionCategory.JointWalletCreation.rawValue
                    STransferPersistence.add(tx: stransaction)
                    
                    self.initSharedWallet(sender: sharedWallet.walletAddress, privateKey: privateKey, contractAddress: contractAddress!,addresses: addresses, require: require, gasPrice: initGasPrice, gas: initGgas,completion: { (result,data) in
                        switch result{
                            
                        case .success:
                            
                            DispatchQueue.main.async { 
                                let sw = SWallet(value: sharedWallet)
                                sw.contractAddress = contractAddress!
                                SWalletPersistence.add(swallet: sw)
                                self.refreshDB()
                                self.successCompletionOnMain(obj: contractAddress as AnyObject, completion: &completion)
                            }
                        case .fail(let fret, let fdes):
                            self.failCompletionOnMainThread(code: fret!, errorMsg: fdes!, completion: &completion)
                        }
                    })
                }
            case .fail(let fret, let fdes):
                self.failCompletionOnMainThread(code: fret!, errorMsg: fdes!, completion: &completion)
            }
            
        })
    }
    
    func createWalletAsync(sharedWallet: SWallet,sender :String, deployGasPrice: BigUInt, deployGgas: BigUInt, initGasPrice: BigUInt, initGgas: BigUInt, privateKey: String, addresses: [String],require: UInt64, completion: PlatonCommonCompletion?){
        
        var completion = completion
        
        let bin = self.getBIN()
        let abiS = self.getABI()
        
        web3.eth.platonDeployContract(abi: abiS!, bin: bin!, sender: sender, privateKey: privateKey, gasPrice: deployGasPrice, gas: deployGgas, estimateGas: false, waitForTransactionReceipt: false, timeout: dispatch_time_t(DefaultRPCTimeOut), completion:{
            (result,transactionHash,_,receipt) in
            
            switch result{
            case .success:
                //add shared wallet transaction
                let stransaction = STransaction(swallet: sharedWallet)
                stransaction.gas = String(deployGgas)
                stransaction.gasPrice = String(deployGasPrice)
                stransaction.from = sender
                stransaction.to = "--"
                stransaction.fee = String(deployGgas.multiplied(by: deployGasPrice))
                stransaction.transactionType = 0
                stransaction.txhash = transactionHash
                stransaction.value = "0"
                stransaction.readTag = ReadTag.Readed.rawValue
                stransaction.transactionCategory = TransanctionCategory.JointWalletCreation.rawValue
                STransferPersistence.add(tx: stransaction)
                
                
                let initwalletdata = self.build_initWallet(addresses: addresses, require: require)
                let initWalletCall = EthereumCall(from: nil, to: EthereumAddress(hexString: DefaultAddress), gas: EthereumQuantity(quantity: initGgas), gasPrice: EthereumQuantity(quantity: initGasPrice), value: nil, data: EthereumData(bytes: (initwalletdata?.bytes)!))
                
                //init memory SWallet Object
                sharedWallet.initWalletCall = initWalletCall 
                sharedWallet.creationStatus = ECreationStatus.deploy_HashGenerated.rawValue
                sharedWallet.deployHash = transactionHash ?? ""
                sharedWallet.privateKey = privateKey
                
                SWalletService.sharedInstance.creatingWallets.append(sharedWallet)
                
                self.successCompletionOnMain(obj: nil, completion: &completion)
                 
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: transactionHash)
                })
                
            case .fail(let fret, let fdes):
                self.failCompletionOnMainThread(code: fret!, errorMsg: fdes!, completion: &completion)
            }
            
        })
        
        
    }
    
    func initSharedWallet(wallet: SWallet, completion: PlatonCommonCompletion?){
        
        let data = wallet.initWalletCall?.data?.bytes
        let gasPrice = wallet.initWalletCall?.gasPrice?.quantity
        let gas = wallet.initWalletCall?.gas?.quantity
        
        
        
        web3.eth.platonSendRawTransaction(contractAddress: wallet.contractAddress, data: data!, sender: wallet.walletAddress, privateKey: wallet.privateKey!, gasPrice: gasPrice!, gas: gas!, value: EthereumQuantity(quantity: BigUInt(integerLiteral: 0)), estimated: false
            , completion: { (result, data) in
                
                switch result{
                    
                case .success:
                    if let txHash =  data?.hexString{
                        
                        let stransaction = STransaction(swallet: wallet)
                        stransaction.from = wallet.walletAddress
                        stransaction.to = wallet.contractAddress
                        stransaction.gas = String(gas ?? BigUInt(0))
                        stransaction.gasPrice = String(gasPrice ?? BigUInt(0))
                        stransaction.fee = String((gasPrice?.multiplied(by: gas!))!)
                        stransaction.transactionType = 0
                        stransaction.txhash = txHash
                        stransaction.value = "0"
                        stransaction.readTag = ReadTag.Readed.rawValue
                        stransaction.transactionCategory = TransanctionCategory.JointWalletExecution.rawValue
                        STransferPersistence.add(tx: stransaction)
                        
                        wallet.initWalletHash = txHash
                        wallet.creationStatus = ECreationStatus.initWallet_HashGenerated.rawValue
                        NotificationCenter.default.post(name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: wallet.deployHash)
                    }
                case .fail(_, _):
                    do{}
                }
                
                
        })
        
    }
    
    func initSharedWallet(sender : String, privateKey : String, contractAddress: String, addresses: [String],require: UInt64, gasPrice: BigUInt, gas: BigUInt,completion: PlatonCommonCompletion?){
        
        var completion = completion
        let queue = DispatchQueue(label: "initSharedWallet")
        let semaphore = DispatchSemaphore(value: 0)
        
        var initWalletGas : BigUInt?
        let initwalletdata = self.build_initWallet(addresses: addresses, require: require)
        
        queue.async {
            
            if initWallet_ShouldUseStipulatedGas{
               initWalletGas = initWallet_UseStipulatedGas
            }else{
                
                let initWalletCall = EthereumCall(from: nil, to: EthereumAddress(hexString: contractAddress), gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: (initwalletdata?.bytes)!))
                
                web3.eth.estimateGas(call: initWalletCall) { (gasestResp) in
                    
                    switch gasestResp.status{
                    case .success(_):
                        initWalletGas = gasestResp.result?.quantity.gasMutiply(GasMutipyTime)
                        print("estimate gas initwallet:\(String(initWalletGas!)) original:\(String((gasestResp.result?.quantity)!))")
                        semaphore.signal()
                    case .failure(_):
                        self.failCompletionOnMainThread(code: gasestResp.getErrorCode(), errorMsg: gasestResp.getErrorLocalizedDescription(), completion: &completion)
                        semaphore.signal()
                        return
                    }
                }
                
                if semaphore.wait(wallTimeout: .now() + DefaultRPCTimeOut) == .timedOut{
                    self.timeOutCompletionOnMainThread(completion: &completion)
                    return
                }
            }
            

            if initWalletGas == nil{
                return
            }
            
            let accounts = self.addressConcatenate(addresses: addresses)
            let callpraram = accounts.data(using: .utf8)
            let rquire = Data.newData(unsignedLong: UInt64(require), bigEndian: true)
            print("initSharedWallet: gasPrice\(String(gasPrice)), gas:\(String(initWalletGas!))")
            web3.eth.platonSendRawTransaction(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "initWallet", params: [callpraram!,rquire], sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: initWalletGas!,value: nil, estimated: false, completion: { (result, data) in
                switch result{
                case .success:
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                case .fail(let fret, let fdes):
                    self.failCompletionOnMainThread(code: fret!, errorMsg: fdes!, completion: &completion)
                }
            })
            
        }
        
        
        

        
    }
    
    func getOwners(contractAddress : String, from: String, completion : PlatonCommonCompletion?){
        
        var completion = completion
        
        let paramter = SolidityFunctionParameter(name: "", type: .string)
        web3.eth.platonCall(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "getOwners", from: from, params: [], outputs: [paramter], completion: {(callRes,dataRet)in
            switch callRes{
                case .success:
                    guard let data = dataRet as? Dictionary<String, Any> ,data.values.count > 0 else {
                        completion?(.success,[] as AnyObject)
                        return
                    }
                    
                    let concatenateString = data[paramter.name] as? String
                    let owners = self.ownerParser(concatenated: concatenateString!)
                    completion?(PlatonCommonResult.success,owners as AnyObject)
                case .fail(let code, let errMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
            }
        })
    }
    
    
    func submitTransaction(
        walltAddress : String,
        privateKey : String,
        contractAddress : String,
        submitGasPrice : BigUInt,
        submitGas : BigUInt,
        confirmGasPrice: BigUInt,
        confirmGas: BigUInt,
        memo : String,
        destination : String,
        value : BigUInt,
        time : UInt64,
        fee : BigUInt,
        completion : PlatonCommonCompletion?){
        
        var completion = completion
        
        NSLog("submitGasPrice:\(String(submitGasPrice))")
        NSLog("submitGas:\(String(submitGas))")
        
        let data = self.build_submitTransaction(walltAddress: walltAddress, privateKey: privateKey, contractAddress: contractAddress, gasPrice: confirmGasPrice, gas: submitGas, memo: memo, destination: destination, value: value, time: time, fee: fee)
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "submitTransactionQueue")
        var transactionId : UInt64 = UInt64.max
        var submitTxHash : String?
        var confirmTxHash : String?
        
        queue.async {
            web3.eth.platonSendRawTransaction(contractAddress: contractAddress, data: data, sender: walltAddress, privateKey: privateKey, gasPrice: submitGasPrice, gas: submitGas,value: nil,  estimated: false,completion: { (result, data) in
                switch result{
                case .success:
                    submitTxHash =  data?.hexString  
                    semaphore.signal()
                case .fail(let code, let errMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
                    semaphore.signal()
                    return
                    
                }
            })
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if submitTxHash == nil || submitTxHash?.length == 0{
                self.failWithEmptyResponseCompletionOnMainThread(completion: &completion)
                return
            }
            
            web3.eth.platonGetTransactionReceipt(txHash: submitTxHash!, loopTime: 30, completion: { (result, data) in
                switch result{
                    
                case .success:
                    
                    guard let receipt = data as? EthereumTransactionReceiptObject else{
                        semaphore.signal()
                        return
                    }
                    
                    if receipt.logs.count == 0{
                        semaphore.signal()
                        NSLog("submitTransaction log empty,hash:\(String(describing: submitTxHash))")
                        return
                    }
                    
                    //add shared wallet transaction
                    if let sharedWallet = self.getSWalletByOwnerAddress(ownerAddress: walltAddress){
                        let stransaction = STransaction(swallet: sharedWallet)
                        stransaction.from = walltAddress
                        stransaction.to = contractAddress
                        stransaction.gas = String(submitGas)
                        stransaction.gasPrice = String(submitGasPrice)
                        stransaction.fee = String(submitGas.multiplied(by: submitGasPrice))
                        stransaction.transactionType = 0
                        stransaction.txhash = submitTxHash
                        stransaction.value = "0"
                        stransaction.readTag = ReadTag.Readed.rawValue
                        stransaction.transactionCategory = TransanctionCategory.JointWalletSubmit.rawValue
                        STransferPersistence.add(tx: stransaction)
                    }
                    
                    let logdata = receipt.logs[0].data
                    let rlpItem = try? RLPDecoder().decode(logdata.bytes)
                    transactionId = Data(bytes: rlpItem!.array![0].bytes!).safeGetUnsignedLong(at: 0, bigEndian: true) 
                    self.outwardHash.append(contractAddress + "_" + String(transactionId))
                    semaphore.signal()
                    
                case .fail(let code, let error):
                    self.failCompletionOnMainThread(code: code!, errorMsg: error!, completion: &completion)
                    semaphore.signal()
                    return
                }
            })
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if transactionId == UInt64.max{
                NSLog("0x\(submitTxHash ?? ""):can't get transactionId")
                self.failCompletionOnMainThread(code: -1, errorMsg: "can't get transactionId", completion: &completion)
                return
            }
            
            let tmpTx = STransaction()
            tmpTx.transactionID = String(transactionId)
            self.confirmTransaction(walltAddress: walltAddress, privateKey: privateKey, contractAddress: contractAddress, gasPrice: confirmGasPrice, gas: confirmGas, tx: tmpTx, estimated: false, completion: { (result, data) in
                switch result{
                case .success:
                    guard let tdata = data as? Data else{
                        semaphore.signal()
                        return
                    }
                    
                    confirmTxHash = tdata.toHexString()
                    semaphore.signal()
                case .fail(let code, let errMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
                    semaphore.signal()
                }
            })
            
            if semaphore.wait(wallTimeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if confirmTxHash == nil || confirmTxHash?.length == 0{
                self.failWithEmptyResponseCompletionOnMainThread(completion: &completion)
                return
            }
            
            web3.eth.platonGetTransactionReceipt(txHash: confirmTxHash!, loopTime: 15, completion: { (result, data) in
                switch result{
                case .success:
                    self.getTransactionList(contractAddress: contractAddress, sender: walltAddress, from: 0, to: UInt64(UInt32.max), completion:nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.successCompletionOnMain(obj: nil, completion: &completion)
                    })
                    semaphore.signal()
                case .fail(let code, let errMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
                    semaphore.signal()
                    return
                }
            })
            
            
        }//end of queue
        
    }//end of function
    
    
    func confirmTransaction(walltAddress : String, privateKey : String, contractAddress : String, gasPrice : BigUInt, gas : BigUInt, tx: STransaction ,estimated: Bool, completion : PlatonCommonCompletion?){
        
        NSLog("confirm gasPrice:\(String(gasPrice))")
        NSLog("confirm gas:\(String(gas))")
        NSLog("tx.transactionID:\(tx.transactionID)")
        
        var completion = completion

        let data = self.build_confirmTransaction(transactionID: UInt64(tx.transactionID)!)
        
        web3.eth.platonSendRawTransaction(contractAddress: contractAddress, data: data, sender: walltAddress, privateKey: privateKey, gasPrice: gasPrice, gas: gas,value: nil,  estimated: false) { (result, data) in
            switch result{
            case .success:
                NSLog("confirm hash:\(data?.hexString ?? "empty")")
                if (data?.hexString.length)! > 0{
                    //update transaction Hash
                    STransferPersistence.updateByTransactionId(tx: tx, hash: (data?.hexString)!)
                    
                    //add shared wallet transaction
                    if let sharedWallet = self.getSWalletByOwnerAddress(ownerAddress: walltAddress){
                        let stransaction = STransaction(swallet: sharedWallet)
                        stransaction.from = walltAddress
                        stransaction.to = contractAddress
                        stransaction.gas = String(gas)
                        stransaction.gasPrice = String(gasPrice)
                        stransaction.fee = String(gas.multiplied(by: gasPrice))
                        stransaction.transactionType = 0
                        stransaction.txhash = (data?.hexString)!
                        stransaction.value = "0"
                        stransaction.readTag = ReadTag.Readed.rawValue
                        stransaction.transactionCategory = TransanctionCategory.JointWalletApprove.rawValue
                        STransferPersistence.add(tx: stransaction)
                    }
                }
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
            }
            self.getTransactionList(contractAddress: contractAddress, sender: walltAddress, from: 0, to: UInt64(UInt32.max), completion: { (_, _) in
            })
        }
    }
    
    func revokeConfirmation(walltAddress : String, privateKey : String, contractAddress : String, gasPrice : BigUInt, gas : BigUInt, tx: STransaction, estimated: Bool, completion: PlatonCommonCompletion?){
        
        NSLog("revoke gasPrice:\(String(gasPrice))")
        NSLog("revoke gas:\(String(gas))")
        
        var completion = completion
        let txid = Data.newData(unsignedLong: UInt64(tx.transactionID)!, bigEndian: true)
        
        web3.eth.platonSendRawTransaction(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "revokeConfirmation", params: [txid], sender: walltAddress, privateKey: privateKey, gasPrice: gasPrice, gas: gas,value: nil,  estimated: estimated ) { (result, data) in
            switch result{
            case .success:
                if (data?.hexString.length)! > 0{
                    //update transaction Hash
                    STransferPersistence.updateByTransactionId(tx: tx, hash: (data?.hexString)!)
                    
                    //add shared wallet transaction
                    if let sharedWallet = self.getSWalletByOwnerAddress(ownerAddress: walltAddress){
                        let stransaction = STransaction(swallet: sharedWallet)
                        stransaction.from = walltAddress
                        stransaction.to = contractAddress
                        stransaction.gas = String(gas)
                        stransaction.gasPrice = String(gasPrice)
                        stransaction.fee = String(gas.multiplied(by: gasPrice))
                        stransaction.transactionType = 0
                        stransaction.txhash = (data?.hexString)!
                        stransaction.value = "0"
                        stransaction.readTag = ReadTag.Readed.rawValue
                        stransaction.transactionCategory = TransanctionCategory.JointWalletRevoke.rawValue
                        STransferPersistence.add(tx: stransaction)
                    }
                }
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
            }
            
            self.getTransactionList(contractAddress: contractAddress, sender: walltAddress, from: 0, to: UInt64(UInt32.max), completion: { (_, _) in
            })

        }
    }
    
    func getConfirmationCount(contractAddress: String,sender: String, completion: PlatonCommonCompletion?){
    
        var completion = completion
        let txId = Data.newData(unsignedLong: 2, bigEndian: true)
        let paramter = SolidityFunctionParameter(name: "", type: .string)
        web3.eth.platonCall(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "getConfirmationCount", from: sender, params: [txId], outputs: [paramter]) { (result, data) in
            switch result{
                
            case .success:
                do{}
                completion?(PlatonCommonResult.success,data as AnyObject)
                completion = nil
            case .fail(let code, let errMsg):
                do{}
                completion?(PlatonCommonResult.fail(code, errMsg),nil)
                completion = nil
            }
        }
        
    }
 
    
    func addShardWallet(contractAddress: String, sender: String,name:String, walletAddress: String, completion: PlatonCommonCompletion?){
        var completion = completion
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "addShardWalletIdentifer")
        
        let swallet = SWallet()
        swallet.name = name
        swallet.walletAddress = walletAddress
        swallet.contractAddress = contractAddress

        var contractVerifyResult = false
        
        queue.async {
            
            let address = EthereumAddress(hexString: contractAddress)
            web3.eth.getCode(address: address!, block: EthereumQuantityTag.latest, response: { resp in
                switch resp.status{
                case .success(_):
                    if resp.result?.bytes.count == 0{
                        self.failCompletionOnMainThread(code: -1, errorMsg: Localized("sharedWallet_sharedWallet_no_existed"), completion: &completion)
                        return
                    }
                    let remoteData = Data((resp.result?.bytes)!)
                    
                    if remoteData.sha256() == self.getDeployData()?.sha256(){
                        contractVerifyResult = true
                    }else{
                        contractVerifyResult = false
                    }
                    
                case .failure(_):
                    self.failCompletionOnMainThread(code: -1, errorMsg: resp.getErrorLocalizedDescription(), completion: &completion)
                }
                
                semaphore.signal()
            })
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if !contractVerifyResult{
                self.failCompletionOnMainThread(code: -1, errorMsg: Localized("sharedWallet_sharedWallet_no_existed"), completion: &completion)
                return
            }
            
            
            self.getRequired(contractAddress: contractAddress, from: sender) { (result, data) in
                switch result{
                case .success:
                    guard let theData = data as? Dictionary<String, UInt64>, theData.values.count > 0 else{
                        self.failCompletionOnMainThread(code: -1, errorMsg: Localized("sharedWallet_sharedWallet_no_existed"), completion: &completion)
                        semaphore.signal()
                        return
                    }
                    swallet.required = Int(theData[""]!)
                    
                case .fail(let code, let errorMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
                }
                semaphore.signal()
            }
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            
            if swallet.required == 0{
                self.failCompletionOnMainThread(code: -1, errorMsg: Localized("sharedWallet_sharedWallet_no_existed"), completion: &completion)
                return
            }
            
            self.getOwners(contractAddress: contractAddress, from: sender) { (result, data) in
                
                semaphore.signal()
                
                switch result{
                case .success:

                    guard let owners = data as? [String], owners.count > 0 else{
                        self.failCompletionOnMainThread(code: -1, errorMsg: Localized("no members"), completion: &completion)
                        return
                    }
                    
                    var ownerAddrInfos : [AddressInfo] = []
                    var index = 1
                    var isIncludeSender = false
                    for element in owners{
                        if sender.ishexStringEqual(other: element){
                            isIncludeSender = true
                        }
                        let addr = AddressInfo()
                        addr.walletAddress = element
                        addr.addressType = AddressType_SharedWallet
                        addr.walletName = Localized("sharedWalletDefaltMemberName") + String(index)
                        index = index + 1
                        ownerAddrInfos.append(addr)
                    }
                    
                    if !isIncludeSender{
                        self.failCompletionOnMainThread(code: -1, errorMsg: Localized("sharedWallet_sharedWallet_forbidden"), completion: &completion)
                        return
                    }
                    
                    swallet.owners.append(objectsIn: ownerAddrInfos)
                    SWalletPersistence.add(swallet: swallet)
                    SWalletService.sharedInstance.refreshDB()
                    
                    //update associated shared wallet transactions swallet delete tag
                    STransferPersistence.updateSharedWalletDeleteTag(contractAddress: swallet.contractAddress, deleted: DeleteTag.NO)
                    
                    self.successCompletionOnMain(obj: nil, completion: &completion)
                    
                    SWalletService.sharedInstance.getTransactionList(contractAddress: contractAddress, sender: sender, from: 0, to: UInt64.max, completion: { (result, data) in
                    })
                    
                case .fail(let code, let errorMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
                    
                }
            }
        }
        
       
    }
    
    func getRequired(contractAddress: String, from: String,completion: PlatonCommonCompletion?){
        let paramter = SolidityFunctionParameter(name: "", type: .uint64)
        web3.eth.platonCall(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "getRequired", from: from, params: [], outputs: [paramter]) { (result, data) in
            switch result{
                
            case .success:
                completion?(PlatonCommonResult.success,data as AnyObject)
            case .fail(let code, let errMsg):
                completion?(PlatonCommonResult.fail(code, errMsg),nil)
            }
        }
        
    }
    
    
    func getAllSharedWalletTransactionList(){
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "getAllSharedWalletTransactionList")
        var rwallets : [SWallet] = []
        for item in self.wallets{
            rwallets.append(SWallet(value: item))
        }
        
        queue.async {
            for item in rwallets{
                self.getTransactionList(contractAddress: item.contractAddress, sender: item.walletAddress, from: UInt64(0), to: UInt64(UInt64.max), completion:{ (ret, data) in
                    semaphore.signal()
                })
                let result = semaphore.wait(timeout: .now() + 10)
                if result == .success{
                    continue
                }else{
                    break
                }
            }
            if rwallets.count > 0{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(WillUpdateUnreadDot_Notification), object: nil, userInfo: nil)
                }
            }
            
        }
    
    }
    
    func getTransactionList(contractAddress: String, sender : String,from: UInt64, to: UInt64 ,completion: PlatonCommonCompletion?){
        
        var completion = completion
        
        let from_d = Data.newData(unsignedLong: from, bigEndian: true)
        let to_d = Data.newData(unsignedLong: to, bigEndian: true)
        let paramter = SolidityFunctionParameter(name: "", type: .string)
        
        var txs : [STransaction] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "getTransactionList")

        queue.async {
            
            web3.eth.platonCall(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "getTransactionList", from: sender, params: [from_d,to_d], outputs: [paramter]) { (result, dataRet) in
                switch result{
                    
                case .success:
                    do{
                        guard let data = dataRet as? Dictionary<String, Any> else {
                            semaphore.signal()
                            return
                        }
                        let concatenateString = data[paramter.name] as? String
                        guard concatenateString != nil else{
                            semaphore.signal()
                            return
                        }
                        let swallet = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: contractAddress)
                        let detachedSwallet = swallet?.fullDetach()
                        DispatchQueue.global().async {
                            let rettxs = STransaction.sTrsancationParser(concatenated: concatenateString!, contractAddress: contractAddress, swallet: detachedSwallet)
                            txs.removeAll()
                            txs.append(contentsOf: rettxs)
                            semaphore.signal()
                        }
                        
                    }
                case .fail(let code,let errorMsg):
                    self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
                    semaphore.signal()
                }
            }
            
            if semaphore.wait(timeout: .now() + DefaultRPCTimeOut) == .timedOut{
                self.timeOutCompletionOnMainThread(completion: &completion)
                return
            }
            if txs.count == 0{
                self.successCompletionOnMain(obj: txs as AnyObject, completion: &completion)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification), object: nil, userInfo: nil)
                }
                return
            }
            
            var trasactionIds = ""
            var index = 0
            for item in txs{
                trasactionIds = trasactionIds + item.transactionID
                if index < txs.count - 1{
                    trasactionIds = trasactionIds + ","
                }
                index = index + 1
            }
             
            let idsData = trasactionIds.data(using: .utf8)
            let getMultiSigListParamter = SolidityFunctionParameter(name: "", type: .string)
             
            web3.eth.platonCall(code: ExecuteCode.ContractExecute,contractAddress: contractAddress, functionName: "getMultiSigList", from: sender, params: [idsData!], outputs: [getMultiSigListParamter]) { (result, dataRet) in
                semaphore.signal()
                 
                switch result{
                case .success:
                    
                    DispatchQueue.global().async {
                        guard let data = dataRet as? Dictionary<String, Any> else {
                            completion?(.success,[] as AnyObject)
                            completion = nil
                            return
                        }
                        let concatenateString = data[paramter.name] as? String
                        guard concatenateString != nil,(concatenateString?.length)! > 0 else{
                            completion?(.success,[] as AnyObject)
                            completion = nil
                            return
                        } 
                        
                        let txsWithStatus = STransaction.sTransactionParse(txs: txs, concatenated: concatenateString!)
                        for item in txsWithStatus{
                            item.contractAddress = contractAddress
                            item.transactionCategory = TransanctionCategory.ATPTransfer.rawValue
                            STransferPersistence.add(tx: item) 
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification), object: nil, userInfo: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(WillUpdateUnreadDot_Notification), object: nil, userInfo: nil)
                            completion?(.success,txsWithStatus as AnyObject)
                            completion = nil
                        }
                    }

                    
                case .fail(let code, let errMsg):
                    do{
                        completion?(.fail(code!, errMsg!),nil)
                        completion = nil
                    }
                }
            }
        }
        
        
    }
    
    func checkArrayisSharedWalletContract(addresses: [String],completion: PlatonCommonCompletion?){
        
        var completion = completion
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "checkArrayisSharedWalletContract")
        
        queue.async {
            
            var result = true
            var networkfail = false
            for item in addresses{
                let address = EthereumAddress(hexString: item)
                web3.eth.getCode(address: address!, block: EthereumQuantityTag.latest, response: { resp in
                    switch resp.status{
                    case .success(_):
                        if resp.result?.bytes.count == 0{
                            semaphore.signal()
                            return
                        }
                        let remoteData = Data((resp.result?.bytes)!)
                        
                        if remoteData.sha256() == self.getDeployData()?.sha256(){
                            result = false
                        }
                        semaphore.signal()
                    case .failure(_):
                        self.failCompletionOnMainThread(code: -1, errorMsg: resp.getErrorLocalizedDescription(), completion: &completion)
                        networkfail = true
                    }
                    
                })
                
                if semaphore.wait(wallTimeout: .now() + DefaultRPCTimeOut) == .timedOut{
                    self.timeOutCompletionOnMainThread(completion: &completion)
                    break
                }
                
                if networkfail{
                    break
                }
                
                if !result{
                    self.failCompletionOnMainThread(code: -1, errorMsg: Localized("invalidwalletaddress"), completion: &completion)
                }   
            }
            self.successCompletionOnMain(obj: result as AnyObject, completion: &completion)

        }
        
    }
    

    

}

//MARK: - Notification

extension SWalletService{
    
}
