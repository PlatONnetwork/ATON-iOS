
//  Created by matrixelement on 9/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import Localize_Swift

let PlatonTxTypeFunc = Data.newData(unsignedLong: UInt64(2), bigEndian: true)
let PlatonTxTypeDeploy = Data.newData(unsignedLong: UInt64(1), bigEndian: true)



extension Web3.Eth{
    
    func platonDeployContract(abi : String,
                              bin : Data,
                              sender : String,
                              privateKey : String,
                              gasPrice : BigUInt,
                              gas : BigUInt,
                              estimateGas : Bool,
                              timeout: dispatch_time_t,
                              completion : ContractDeployCompletion?
        ){
        
        var completion = completion
        let txTypePart = RLPItem(bytes: PlatonTxTypeDeploy.bytes)
        let binPart = RLPItem(bytes: (bin.bytes))
        let abiPart = RLPItem(bytes: (abi.data(using: .utf8)?.bytes)!)
        
        let rlp = RLPItem.array(txTypePart,binPart,abiPart)
        let rawRlp = try? RLPEncoder().encode(rlp)

        let semaphore = DispatchSemaphore(value: 0)
        
        let deployQueue = DispatchQueue(label: "platonDeployContractIdentifer")
        
        var estimatedGas : EthereumQuantity?
        deployQueue.async {
            let to = EthereumAddress(hexString: "0x0000000000000000000000000000000000000000")
            print("platonDeployContract estimatedGas begin 💪 semaphone\(semaphore)")
            let call = EthereumCall(from: nil, to: to!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: rawRlp!))
            self.estimateGas(call: call) { (gasestResp) in
                switch gasestResp.status{
                case .success(_):
                    do {
                        estimatedGas = gasestResp.result
                        print("platonDeployContract estimatedGas done😀")
                        semaphore.signal()
                    }
                case .failure(_):
                    do{
                        DispatchQueue.main.async {
                            completion?(PlatonCommonResult.fail(-1, gasestResp.getErrorLocalizedDescription()),nil,nil)
                            completion = nil
                        }
                        print("platonDeployContract estimatedGas fail😭")
                        semaphore.signal()
                        return
                    }
                }
            }
        }
        
        var nonce : EthereumQuantity?
        deployQueue.async {
            let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            if estimatedGas == nil{
                semaphore.signal()
                return
            }
            
            let address = try! EthereumAddress(hex: sender, eip55: false)
            self.getTransactionCount(address: address, block: .latest, response: {
                nonceResp in
                
                switch nonceResp.status{
                case .success(_):
                    do{
                        nonce = nonceResp.result
                        print("platonDeployContract get nonce done😀" + "nonce:" + String((nonceResp.result?.quantity)!))
                        semaphore.signal()
                        
                    }
                case .failure(_):
                    do{
                        DispatchQueue.main.async {
                            completion?(PlatonCommonResult.fail(-1, nonceResp.getErrorLocalizedDescription()),nil,nil)
                            completion = nil
                        }
                        print("platonDeployContract get nonce fail😭")
                        semaphore.signal()
                        return
                    }
                    
                }
                })
            
            }

        var txHash = EthereumData(bytes: [])
        deployQueue.async {
            let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            if nonce == nil{
                semaphore.signal()
                return
            }
            
            let data = EthereumData(bytes: rawRlp!)
            var fgas : EthereumQuantity?
            if estimateGas{
                fgas = estimatedGas
            }else{
                fgas = EthereumQuantity(quantity: gas)
            }
            let tx = EthereumTransaction(nonce: nonce, gasPrice: EthereumQuantity(quantity: gasPrice), gas: fgas, from: nil, to: nil, value: EthereumQuantity(quantity: BigUInt("0")!), data: data)
            let chainID = EthereumQuantity(quantity: BigUInt(DefaultChainId)!)
            let signedTx = try? tx.sign(with: try! EthereumPrivateKey(hexPrivateKey: privateKey), chainId: chainID) as EthereumSignedTransaction
            
            self.sendRawTransaction(transaction: signedTx!, response: { (sendTxResp) in
                switch sendTxResp.status{
                case .success(_):
                    txHash = sendTxResp.result!
                    print("platonDeployContract Deploy done😀")
                    semaphore.signal()
                case .failure(_):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(-1, sendTxResp.getErrorLocalizedDescription()),nil,nil)
                        completion = nil
                    }
                    print("platonDeployContract Deploy fail😭")
                    semaphore.signal()
                    return
                }
            })
        }
        
        deployQueue.async {
            let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            if txHash.bytes.count == 0{
                semaphore.signal()
                return
            }
            
            self.platongetTransactionReceipt(txHash: txHash.hex(), loopTime: 10, completion: { (ret, data) in
                switch ret{
                case .success:
                    DispatchQueue.main.async {
                        guard let receptionresp = data as? EthereumTransactionReceiptObject else{
                            return
                        }
                        completion?(PlatonCommonResult.success,receptionresp.contractAddress?.hex(), txHash.hex())
                        completion = nil
                    }
                    print("platonDeployContract Receipt done😀")
                    semaphore.signal()
                case .fail(let code, let errMsg):
                    
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(code, errMsg),nil,nil)
                        completion = nil
                    }
                    print("platonDeployContract Receipt fail😭")
                    semaphore.signal()
                    return
                }
            })
        }
    }
    
    
    func addevent(){
        
        self.getTransactionReceipt(transactionHash: EthereumData(bytes: [0x00]), response: { receptionresp in
            switch receptionresp.status{
            case .success(_):
                do {
                    let firstTopicBytes = receptionresp.result??.logs[0].topics[0].bytes
                    let logdata = receptionresp.result??.logs[0].data
                    let decoderesult = try? RLPDecoder().decode((logdata?.bytes)!)
                    
                    let value = decoderesult?.array![0].bytes
                    let result = String(bytes: (decoderesult?.array![1].bytes)!)
                }
            case .failure(_):
                do {
                    
                }
            }
            
        })
    }
    
    
    func platonCall(contractAddress : String,functionName : String, from: String, _ params : [Data],outputs: [SolidityParameter],completion : ContractCallCompletion?) {
        var completion = completion
        let txTypePart = RLPItem(bytes: PlatonTxTypeFunc.bytes)
        let funcItemPart = RLPItem(bytes: (functionName.data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        for data in params{
            items.append(RLPItem(bytes: data.bytes))
        }
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        let fromE = try? EthereumAddress(hex: from, eip55: false)
        let callParam = EthereumCall(from: fromE, to: EthereumAddress(hexString: contractAddress)!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: rawRlp!))
    
        call(call: callParam, block: .latest) { (resp) in
            switch resp.status{
            case .success(_):
                let data = Data(bytes: (resp.result?.bytes)!)
                let dictionary = try? ABI.decodeParameters(outputs, from: data.toHexString())
                //NSLog("\(functionName) call result:\n\(dictionary)")
                DispatchQueue.main.async {
                    completion?(PlatonCommonResult.success,dictionary as AnyObject)
                    completion = nil
                }
            case .failure(_):
                DispatchQueue.main.async {
                    completion?(PlatonCommonResult.fail(-1, resp.getErrorLocalizedDescription()),nil)
                    completion = nil
                }
            }
        }
    }
    
    
    func plantonSendRawTransaction(contractAddress : String,data: Bytes, sender: String, privateKey: String, gasPrice : BigUInt, gas : BigUInt, estimated: Bool ,completion: ContractSendRawCompletion?){
        
        var completion = completion
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "plantonSendRawTransactionQueue")
        
        var nonce : EthereumQuantity?
        queue.async {
            let address = try! EthereumAddress(hex: sender, eip55: false)
            self.getTransactionCount(address: address, block: .latest, response: {
                nonceResp in
                
                switch nonceResp.status{
                case .success(_):
                    nonce = nonceResp.result
                    semaphore.signal()
                case .failure(_):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(-1, nonceResp.getErrorLocalizedDescription()),nil)
                        completion = nil
                    }
                    semaphore.signal()
                    return
                    
                }
            })
        }
        
        var estimatedGas : EthereumQuantity?
        queue.async {
            semaphore.wait()
            let tmpToaddr = EthereumAddress(hexString: DefaultAddress)
            let call = EthereumCall(from: nil, to: tmpToaddr!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: data))
            self.estimateGas(call: call) { (gasestResp) in
                
                switch gasestResp.status{
                case .success(_):
                    
                    estimatedGas = gasestResp.result
                    semaphore.signal()
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(-1, gasestResp.getErrorLocalizedDescription()),nil)
                        completion = nil
                    }
                    semaphore.signal()
                    return
                }
            }
        }
        
        
        
        queue.async {
            let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            let data = EthereumData(bytes: data)
            let ethConAddr = try? EthereumAddress(hex: contractAddress, eip55: false)
            let egasPrice = EthereumQuantity(quantity: gasPrice)
            var egas = EthereumQuantity(quantity: gas)
            if estimated{
                egas = estimatedGas!
            }
            let from = try? EthereumAddress(hex: sender, eip55: false)
            let tx = EthereumTransaction(nonce: nonce, gasPrice: egasPrice, gas: egas, from: from, to: ethConAddr, value: EthereumQuantity(quantity: BigUInt("0")!), data: data)
            let signedTx = try? tx.sign(with: try! EthereumPrivateKey(hexPrivateKey: privateKey), chainId: 0) as EthereumSignedTransaction
            
            var txHash = EthereumData(bytes: [])
            self.sendRawTransaction(transaction: signedTx!, response: { (sendTxResp) in
                
                switch sendTxResp.status{
                case .success(_):
                    txHash = sendTxResp.result!
                    semaphore.signal()
                    DispatchQueue.main.async {
                        completion!(.success,Data(bytes: txHash.bytes))
                        completion = nil
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.fail(-1, sendTxResp.getErrorLocalizedDescription()),nil)
                        completion = nil
                    }
                    semaphore.signal()
                    return
                }
            })
        }
        
    }

    func plantonSendRawTransaction(contractAddress : String,
                                   functionName : String,
                                   _ params : [Data],
                                   sender: String,
                                   privateKey: String,
                                   gasPrice : BigUInt,
                                   gas : BigUInt,
                                   estimated: Bool,
                                   completion: ContractSendRawCompletion?){
        
        let txTypePart = RLPItem(bytes: PlatonTxTypeFunc.bytes)
        let funcItemPart = RLPItem(bytes: (functionName.data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        for data in params{
            items.append(RLPItem(bytes: data.bytes))
        }
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        self.plantonSendRawTransaction(contractAddress: contractAddress, data: rawRlp!, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, estimated: estimated, completion: completion)
        
    }
    
    
    func platongetTransactionReceipt(txHash: String, loopTime: Int, completion: PlatonCommonCompletion?) {
        
        var completion = completion
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "platongetTransactionReceipt")
        var time = loopTime
        queue.async {
            repeat{
                NSLog("begin getTransactionReceipt 💪")
                self.getTransactionReceipt(transactionHash: EthereumData(bytes: Data(hex: txHash).bytes)) { (response) in
                    time = time - 1
                    switch response.status{
                    case .success(_):
                        
                        DispatchQueue.main.async {
                            NSLog("success getTransactionReceipt 🙂")
                            completion?(.success,response.result as AnyObject)
                            completion = nil
                        }
                        semaphore.signal()
                        time = 0
                    case .failure(_):
                        NSLog("fail getTransactionReceipt 😭")
                        if time == 0{
                            DispatchQueue.main.async {
                                completion?(PlatonCommonResult.fail(-1, response.getErrorLocalizedDescription()),nil)
                                completion = nil
                            }
                            semaphore.signal()
                            time = 0
                        }
                        semaphore.signal()
                    }
                }
                sleep(UInt32(3.0))
                semaphore.wait(timeout: .now() + 3)
            }while time > 0
        }
       
        

    }
    
    
       
}
