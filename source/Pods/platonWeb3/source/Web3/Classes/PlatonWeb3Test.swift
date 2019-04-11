//
//  PlatonWeb3Test.swift
//  platonWallet
//
//  Created by matrixelement on 3/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

let platonWeb3 = Web3(rpcURL: "http://192.168.7.184:8545")

class PlatonWeb3Test {
    
    func testTransfer(){
        
        
        let functionName = "transfer02"
        let contractAddress = EthereumAddress(hexString: "0x43355c787c50b647c425f594b441d4bd751951c1")
        
        let txTypePart = RLPItem(bytes: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02])
        let funcItemPart = RLPItem(bytes: (functionName.data(using: .utf8)?.bytes)!)
        let param_from = RLPItem(bytes: ("0x60ceca9c1290ee56b98d4e160ef0453f7c40d219".data(using: .utf8)?.bytes)!)
        let param_to = RLPItem(bytes: ("0xaa31ca9d892800aa67383bb88114b61868221ee5".data(using: .utf8)?.bytes)!)
        let param_assert = RLPItem(bytes: [0x00,0x00,0x00,0x14])//UInt32
        
        let rlp = RLPItem.array(txTypePart,funcItemPart,param_from,param_to,param_assert)
        let rawRlp = try? RLPEncoder().encode(rlp)
        let rlpHex = rawRlp?.toHexString()
        
        
        var gasPrice = EthereumQuantity(quantity: BigUInt("22000000000")!)
        var gas = EthereumQuantity(quantity: BigUInt("4300000")!)
        var value = EthereumQuantity(quantity: BigUInt("0")!)
        
        let from = try! EthereumAddress(hex: "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219", eip55: false)
        let data = EthereumData(bytes: rawRlp!)
        let privateKey = try! EthereumPrivateKey(hexPrivateKey: "4484092b68df58d639f11d59738983e2b8b81824f3c0c759edd6773f9adadfe7")
        platonWeb3.eth.getTransactionCount(address: from, block: .latest, response: {
            nonceResp in
            let tx = EthereumTransaction(nonce: nonceResp.result, gasPrice: gasPrice, gas: gas, from:nil , to: contractAddress, value: value, data: data)
            let signedTx = try? tx.sign(with: privateKey, chainId: 10) as EthereumSignedTransaction
            if signedTx != nil{
                self.handleSend(signedTx: signedTx,web3: platonWeb3)
            }
            
        })
        
        
    }
    
    func testRLPCode(){
        let b = "0000000000000001".hexToBytes()
        let tmpbin = "999999".hexToBytes()
        let tmpabi = "nnnnnn".data(using: .utf8)?.bytes
        let tmprlp = RLPItem.array(RLPItem.bytes(b),RLPItem.bytes(tmpbin),RLPItem.bytes(tmpabi!))
        let tmprawRlp = try? RLPEncoder().encode(tmprlp)
        let tmpStr = tmprawRlp?.toHexString()
    }
    
    func testRLPDecode(){
        
        let txTypePart = RLPItem(integerLiteral: 0)
        let funcItemPart = RLPItem(bytes: ("transfer02 success.".data(using: .utf8)?.bytes)!)
        let tmprlp = RLPItem.array(txTypePart,funcItemPart)
        let tmprawRlp = try? RLPEncoder().encode(tmprlp)
        
        let tmpStr = tmprawRlp?.toHexString()
        
        
        let bytes = "80937472616e73666572303220737563636573732e".hexToBytes()
        let decoderesult = try? RLPDecoder().decode(bytes)
        
        print("")
    }
    
    func escapingCallTest(){
        
        let functionName = "getBalance"
        let contractAddress = EthereumAddress(hexString: "0x43355c787c50b647c425f594b441d4bd751951c1")
        
        let balanceOfAccout = "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219"
        let callpraram = balanceOfAccout.data(using: .utf8)?.bytes
        
        let txTypePart = RLPItem(bytes: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02])
        let funcItemPart = RLPItem(bytes: (functionName.data(using: .utf8)?.bytes)!)
        let callpram = RLPItem(bytes: callpraram!)
        
        let rlp = RLPItem.array(txTypePart,funcItemPart,callpram)
        let rawRlp = try? RLPEncoder().encode(rlp)
        let rlpHex = rawRlp?.toHexString()
        
        let call = EthereumCall(from: nil, to: contractAddress!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: rawRlp!))
        
        platonWeb3.eth.call(call: call, block: .latest) { (resp) in
            let resutl = BigUInt(bytes: (resp.result?.bytes)!)
            NSLog("result:\(String(resutl))")
        }
        
    }
    
    func web3AllTest(){
        let address = EthereumAddress(hexString: "0x")
        platonWeb3.eth.getCode(address: address!, block: .latest) { (result) in
            switch result.status{
                
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
    
        let blockHash = EthereumData(bytes: [0x00])
        platonWeb3.eth.getBlockByHash(blockHash: blockHash, fullTransactionObjects: true) {  (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.getBlockByNumber(block: .latest, fullTransactionObjects: true) {  (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        let uncleIndex = EthereumQuantity(quantity: BigUInt("1")!)
        platonWeb3.eth.getUncleByBlockNumberAndIndex(block: .latest, uncleIndex: uncleIndex) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.getUncleCountByBlockNumber(block: .latest) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        //let blockHash = EthereumData(bytes: Data(hex: "0x..."))
        platonWeb3.eth.getBlockTransactionCountByHash(blockHash: blockHash) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.getBlockTransactionCountByNumber(block: .latest) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        let transactionHash = EthereumData(bytes: Data(hex: "0x..").bytes)
        platonWeb3.eth.getTransactionByHash(blockHash: transactionHash) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
//        let blockHash = EthereumData(bytes: Data(hex: "0x..").bytes)
        let transactionIndex = EthereumQuantity(integerLiteral: 1)
        platonWeb3.eth.getTransactionByBlockHashAndIndex(blockHash: blockHash, transactionIndex: transactionIndex) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
 
//        let transactionHash = EthereumData(bytes: Data(hex: "0x..").bytes)
        platonWeb3.eth.getTransactionReceipt(transactionHash: transactionHash) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
//        let address = EthereumAddress(hexString: "0x..")
        platonWeb3.eth.getTransactionCount(address: address!, block: .latest) { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        
        let callData = EthereumData(bytes: Data(hex: "0x..").bytes)
        let contractAddress = EthereumAddress(hexString: "0x..")
        let thecall = EthereumCall(from: nil, to: contractAddress!, gas: nil, gasPrice: nil, value: nil, data: callData)
        platonWeb3.eth.estimateGas(call: thecall) { (gasestResp) in
            switch gasestResp.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.mining { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.hashrate { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.syncing{ (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.gasPrice { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.accounts { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.blockNumber { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
        
        platonWeb3.eth.protocolVersion { (result) in
            switch result.status{
            case .success(_):
                do{}
            case .failure(_):
                do{}
            }
        }
    }
    
    func escapingDeployTest(){
        
        let web3 = Web3(rpcURL: "http://192.168.7.184:8545")
        
        let binPath = Bundle.main.path(forResource: "PlatonAssets/demo01", ofType: "wasm")
        let bin = try? Data(contentsOf: URL(fileURLWithPath: binPath!))
        
        let abiPath = Bundle.main.path(forResource: "PlatonAssets/demo01.cpp.abi", ofType: "json")
        var abiS = try? String(contentsOfFile: abiPath!)
        abiS = abiS?.replacingOccurrences(of: "\r\n", with: "")
        abiS = abiS?.replacingOccurrences(of: "\n", with: "")
        
        let txTypePart = RLPItem(bytes: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01])
        
        let binPart = RLPItem(bytes: (bin?.bytes)!)
        let abiPart = RLPItem(bytes: (abiS!.data(using: .utf8)?.bytes)!)
        
        let rlp = RLPItem.array(txTypePart,binPart,abiPart)
        
        //let rlp = RLPItem(arrayLiteral: txTypePart,binPart,abiPart)
        
        let rawRlp = try? RLPEncoder().encode(rlp)
        let rlpHex = rawRlp?.toHexString()
        
        let tmpAddr = EthereumAddress(hexString: "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219")
        let tmpQuan = EthereumQuantity(quantity: BigUInt("0")!)
        let call = EthereumCall(from: nil, to: tmpAddr!, gas: nil, gasPrice: nil, value: nil, data: EthereumData(bytes: rawRlp!))
        
        platonWeb3.eth.estimateGas(call: call) { (gasresp) in
            print("\(gasresp)")
            print("\(String((gasresp.result?.quantity)!))")
            print("\(self)")
            
            let value = EthereumQuantity(quantity: BigUInt("0")!)
            let address = try! EthereumAddress(hex: "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219", eip55: false)
            let to = try! EthereumAddress(hex: "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219", eip55: false)
            //var gasPrice = gasresp.result
            //var gas = EthereumQuantity(quantity: 1.gwei)
            
            //
            var gasPrice = EthereumQuantity(quantity: BigUInt("22000000000")!)
            var gas = EthereumQuantity(quantity: BigUInt("4300000")!)
            
            let from = try! EthereumAddress(hex: "0x60ceca9c1290ee56b98d4e160ef0453f7c40d219", eip55: false)
            let data = EthereumData(bytes: rawRlp!)
            let privateKey = try! EthereumPrivateKey(hexPrivateKey: "4484092b68df58d639f11d59738983e2b8b81824f3c0c759edd6773f9adadfe7")
            platonWeb3.eth.getTransactionCount(address: address, block: .latest, response: {
                nonceResp in
                let tx = EthereumTransaction(nonce: nonceResp.result, gasPrice: gasPrice, gas: gas, from:nil , to: nil, value: value, data: data)
                let signedTx = try? tx.sign(with: privateKey, chainId: 10) as EthereumSignedTransaction
                if signedTx != nil{
                    self.handleSend(signedTx: signedTx,web3: web3)
                }
            })
        }
    }
    
    
    func handleSend(signedTx : EthereumSignedTransaction?, web3 : Web3){
        platonWeb3.eth.sendRawTransaction(transaction: signedTx!, response: { (resp) in
            
            switch resp.status{
                
            case .success(_):
                do{
                    print("transaction hash:\(resp.result?.hex())")
                    
                    let queue = DispatchQueue(label: "get.tx.queue")
                    var time = 10
                    queue.async {
                        repeat{
                            platonWeb3.eth.getTransactionReceipt(transactionHash: resp.result!, response: { receptionresp in
                                switch receptionresp.status{
                                    
                                case .success(_):
                                    do {
                                        let firstTopicBytes = receptionresp.result??.logs[0].topics[0].bytes
                                        let logdata = receptionresp.result??.logs[0].data
                                        let decoderesult = try? RLPDecoder().decode((logdata?.bytes)!)
                                        
                                        let value = decoderesult?.array![0].bytes
                                        let result = String(bytes: (decoderesult?.array![1].bytes)!)
                                        
                                        print("")
                                        time = 0
                                    }
                                case .failure(_):
                                    do {
                                        
                                    }
                                }
                                
                            })
                            sleep(1)
                            time = time - 1
                            
                        }while time > 0
                    }
                    
                    
                    
                }
            case .failure(let f):
                do{
                    let f4 = f as? RPCResponse<EthereumData>.Error
                    
                    return
                }
            }
        })
    }
}
