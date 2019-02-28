//
//  VoteManager+builder.swift
//  platonWallet
//
//  Created by Ned on 24/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import platonWeb3_local

extension VoteManager{
    
    private func build_commonInternalCall(funcName: String, param: String? = nil) -> Data {
        
        let txTypePart = RLPItem(bytes: ExecuteCode.InnerContract.DataValue.bytes)
        
        let funcItemPart = RLPItem(bytes: (funcName.data(using: .utf8)?.bytes)!)
        
        var items : [RLPItem] = []
        
        items.append(txTypePart)
        items.append(funcItemPart)
        
        if param != nil {
            let paramData = param!.data(using: .utf8)
            items.append(RLPItem(bytes: paramData!.bytes))
        }
        
        let rlp = RLPItem.array(items)
        
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return Data(bytes: rawRlp!)
    }
 
    func build_GetTicketPrice() -> Data{

        return build_commonInternalCall(funcName: "GetTicketPrice")
    }
    
    func build_GetPoolRemainder() -> Data {

        return build_commonInternalCall(funcName: "GetPoolRemainder")
    }
    
    func build_GetCandidateEpoch(candidateId: String) -> Data{
        
        return build_commonInternalCall(funcName: "GetCandidateEpoch", param: candidateId)
    }
    
    func build_CandidateDetails(candidateId: String) -> Data {
        
        return build_commonInternalCall(funcName: "CandidateDetails", param: candidateId)
    }
    
    func build_CandidateList() -> Data{
        
        return build_commonInternalCall(funcName: "CandidateList")
    }
    
    func build_GetTicketDetail(ticketId: String) -> Data{
        
        return build_commonInternalCall(funcName: "GetTicketDetail", param: ticketId)
    }
    
    func build_GetBatchTicketDetail(ticketIds: [String]) -> Data{
        
        let concatenate = ticketIds.joined(separator: ":")
        return build_commonInternalCall(funcName: "GetBatchTicketDetail", param: concatenate)
        
    }
    
    func build_GetBatchCandidateDetail(nodeIds: [String]) -> Data {
        
        let concatenate = nodeIds.joined(separator: ":")
        return build_commonInternalCall(funcName: "GetBatchCandidateDetail", param: concatenate)

    }
    
    func build_GetBatchCandidateTicketIds(nodeIds:[String]) -> Data {
        
        let concatenate = nodeIds.joined(separator: ":") 
        return build_commonInternalCall(funcName: "GetBatchCandidateTicketIds", param: concatenate)

    }
    
    func build_GetBatchCandidateTicketCount(nodeIds:[String]) -> Data {
        let concatenate = nodeIds.joined(separator: ":") 
        return build_commonInternalCall(funcName: "GetBatchCandidateTicketCount", param: concatenate)
    }
    
    func build_VoteTicket(count: UInt64, price: BigUInt,nodeId: String) -> Data{
        
        let count_d = Data.newData(unsignedLong: count, bigEndian: true)
        
        
        let priceV = SolidityWrappedValue(value: price, type: SolidityType.uint256)
        let price_d = Data(hex: priceV.value.abiEncode(dynamic: false)!)
        
        //let price_d = Data(price.makeBytes())
        
        
        //let nodeId_d = Data(hex: nodeId)
        
        let nodeId_d = nodeId.data(using: .utf8)
        
        let params = [count_d,price_d,nodeId_d]
        
        let txTypePart = RLPItem(bytes: ExecuteCode.Vote.DataValue.bytes)
        let funcItemPart = RLPItem(bytes: ("VoteTicket".data(using: .utf8)?.bytes)!)
        var items : [RLPItem] = []
        items.append(txTypePart)
        items.append(funcItemPart)
        
        for sdata in params{
            items.append(RLPItem(bytes: sdata!.bytes))
        }
        
        let rlp = RLPItem.array(items)
        let rawRlp = try? RLPEncoder().encode(rlp)
        
        return Data(bytes: rawRlp!)
    }
}
