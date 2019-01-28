//
//  Array+sort.swift
//  platonWallet
//
//  Created by Ned on 11/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt

extension Array{
    mutating func txSort(){
        self.sort(by: { (obj1, obj2) -> Bool in
            if let obj1 = obj1 as? Transaction, let obj2 = obj2 as? Transaction{
                return obj1.createTime > obj2.createTime
            }else if let obj1 = obj1 as? STransaction , let obj2 = obj2 as? Transaction{
                return Int(obj1.createTime) > obj2.createTime
            }else if let obj1 = obj1 as? Transaction , let obj2 = obj2 as? STransaction{
                return obj1.createTime > Int(obj2.createTime)
            }else if let obj1 = obj1 as? STransaction , let obj2 = obj2 as? STransaction{
                return obj1.createTime > obj2.createTime
            }
            return false
        })
    }
}

extension Array where Element == Ticket {
    
    var tickets_validCount : Int{
        get{
            return reduce(0) { (acc, ticket) -> Int in
                ticket.ticketStatus == .normal ? acc + 1 : acc
            }
        }
    }
    
    var tickets_invalidCount: Int{
        get{
            return reduce(0) { (acc, ticket) -> Int in
                ticket.ticketStatus != .normal ? acc + 1 : acc
            }
        }
    }

    var tickets_assetOflocked: String?{
        get{
            let assetBI = reduce(BigUInt(0)) { (acc, ticket) -> BigUInt in
                
                ticket.ticketStatus == .normal ? acc + (BigUInt(ticket.deposit ?? "") ?? BigUIntZero) : acc
                
            }
            return String(assetBI)
            
            var asset = BigUInt(0)
            let _ = map { t in
                if t.ticketStatus == TicketStatus.normal && t.deposit != nil && (t.deposit?.length)! > 0{
                    let deposit = BigUInt(t.deposit!)
                    asset.multiplyAndAdd(deposit!, 1)
                }
            }
            return String(asset)
        }
    }

    var tickets_releaseOfVote: String?{
        get{
            let assetBI = reduce(BigUInt(0)) { (acc, ticket) -> BigUInt in
                
                ticket.ticketStatus != .normal ? acc + (BigUInt(ticket.deposit ?? "") ?? BigUIntZero) : acc
                
            }
            return String(assetBI)

            var asset = BigUInt(0)
            let _ = map { t in
                if t.ticketStatus != TicketStatus.normal && t.deposit != nil && (t.deposit?.length)! > 0{
                    let deposit = BigUInt(t.deposit!)
                    asset.multiplyAndAdd(deposit!, 1)
                }
            }
            return String(asset)
        }
    }

    var tickets_voteEarnings: String?{
        get{
            return ""
        }
    }
    
}
