//
//  SWalletService+builder.swift
//  platonWallet
//
//  Created by matrixelement on 7/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3



extension SWalletService{
    
    func build_submitTransaction(
        walltAddress : String,
        privateKey : String,
        contractAddress : String,
        gasPrice : BigUInt,
        gas : BigUInt,
        memo : String,
        destination : String,
        value : BigUInt,
        time : UInt64,
        fee : BigUInt
        ) -> Bytes{
        
        //1.destination string
        let destination_d = destination.data(using: .utf8)
        
        //2.from string
        let from_d = contractAddress.data(using: .utf8)
        
        /*
        let valueQ = EthereumQuantity(quantity: value)
        let value_d = Data(bytes: valueQ.makeBytes())
         */
        //3.vs string
        let value_d = String(value).data(using: .utf8)
        
        //4.data string
        let data_d = memo.data(using: .utf8)
        
        //5.len uint64
        let len_d = Data.newData(unsignedLong: UInt64(data_d!.count), bigEndian: true)
        
        //6. time uint64
        let time_d = Data.newData(unsignedLong: time, bigEndian: true)
        
        /*
         let feeQ = EthereumQuantity(quantity: fee)
         let fee_d = Data(bytes: feeQ.makeBytes())
         */
        
        //7. fs string
        let fee_d = String(fee).data(using: .utf8)
        
        
        let params = [destination_d!,from_d!,value_d,data_d!,len_d,time_d,fee_d]
        
        let txTypePart = RLPItem(bytes: ExecuteCode.ContractExecute.DataValue.bytes)
        let funcItemPart = RLPItem(bytes: ("submitTransaction".data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        
        for sdata in params{
            items.append(RLPItem(bytes: sdata!.bytes))
        }
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return rawRlp!
    }
    
    func build_confirmTransaction(transactionID: UInt64) -> Bytes{
        
        let txid = Data.newData(unsignedLong: transactionID, bigEndian: true)
        let txTypePart = RLPItem(bytes: ExecuteCode.ContractExecute.DataValue.bytes)
        let funcItemPart = RLPItem(bytes: ("confirmTransaction".data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        items.append(RLPItem(bytes: txid.bytes))
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return rawRlp!
        
    }
    
    func build_revokeConfirmation(transactionID: UInt64) -> Bytes{
        
        let txid = Data.newData(unsignedLong: transactionID, bigEndian: true)
        let txTypePart = RLPItem(bytes: ExecuteCode.ContractExecute.DataValue.bytes)
        let funcItemPart = RLPItem(bytes: ("revokeConfirmation".data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        items.append(RLPItem(bytes: txid.bytes))
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return rawRlp!
        
    }
    
    func build_initWallet(addresses: [String],require: UInt64) -> Data?{
        
        let txTypePart = RLPItem(bytes: ExecuteCode.ContractExecute.DataValue.bytes)
        let funcItemPart = RLPItem(bytes: ("initWallet".data(using: .utf8)?.bytes)!)
        let addressesData = self.addressConcatenate(addresses: addresses).data(using: .utf8)
        let rquireData = Data.newData(unsignedLong: UInt64(require), bigEndian: true)
        
        let rlp = RLPItem.array([txTypePart,funcItemPart,RLPItem(bytes: (addressesData?.bytes)!),RLPItem(bytes: rquireData.bytes)])
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return Data(bytes: rawRlp!)
        
    }
    
    
    
    func getABI() -> String?{
        
        let abiPath = Bundle.main.path(forResource: "PlatonAssets/multisig.cpp.abi", ofType: "json")
        var abiS = try? String(contentsOfFile: abiPath!)
        abiS = abiS?.replacingOccurrences(of: "\r\n", with: "")
        abiS = abiS?.replacingOccurrences(of: "\n", with: "")
        abiS = abiS?.replacingOccurrences(of: " ", with: "")
        
        return abiS
    }
    
    func getBIN() -> Data?{
        let binPath = Bundle.main.path(forResource: "PlatonAssets/multisig", ofType: "wasm")
        let bin = try? Data(contentsOf: URL(fileURLWithPath: binPath!))
        return bin
    }
    
    func getDeployData() -> Data?{
        let bin = self.getBIN()
        let abi = self.getABI()
        
        let txTypePart = RLPItem(bytes: ExecuteCode.ContractDeploy.DataValue.bytes)
        let binPart = RLPItem(bytes: (bin!.bytes))
        let abiPart = RLPItem(bytes: (abi!.data(using: .utf8)?.bytes)!)
        
        let rlp = RLPItem.array(txTypePart,binPart,abiPart)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        let data = Data(bytes: rawRlp!)
        return data;
    }
    
    //MARK: - private
    
    func ownerParser(concatenated : String) -> [String]{
        var txs : [String] = []
        let ownerComponents = concatenated.components(separatedBy: ":")
        for item in ownerComponents{
            if !item.hasPrefix("0x"){
                txs.append("0x"+item)
            }else{
                txs.append(item)
            }
        }
        return txs
    }
    
    
    func addressConcatenate(addresses :[String]) -> String{
        var accounts = ""
        for item in addresses{
            if accounts.length == 0{
                accounts = accounts + item
            }else{
                accounts = accounts + ":" + item
            }
        }
        return accounts
    }
    
}
