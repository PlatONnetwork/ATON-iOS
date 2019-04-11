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
    
    mutating func userArrangementSort(){
        self.sort(by: { (obj1, obj2) -> Bool in
            if let obj1 = obj1 as? Wallet, let obj2 = obj2 as? Wallet{
                return obj1.userArrangementIndex < obj2.userArrangementIndex
            }else if let obj1 = obj1 as? SWallet , let obj2 = obj2 as? SWallet{
                return Int(obj1.userArrangementIndex) < obj2.userArrangementIndex
            }else if let obj1 = obj1 as? Wallet , let obj2 = obj2 as? SWallet{
                return obj1.userArrangementIndex < Int(obj2.userArrangementIndex)
            }else if let obj1 = obj1 as? SWallet , let obj2 = obj2 as? Wallet{
                return obj1.userArrangementIndex < obj2.userArrangementIndex
            }
            return false
        })
        
    }
}

extension Array where Element == Any {
    
    var filterClassicWallet : [Wallet]{
        get{
            return filter({ (element) -> Bool in
                if let _ = element as? Wallet{
                    return true
                }
                return false
            }) as! [Wallet]
        }
    }
    
    var filterSharedWallet : [SWallet]{
        get{
            return filter({ (element) -> Bool in
                if let _ = element as? SWallet{
                    return true
                }
                return false
            }) as! [SWallet]
        }
    }
}

extension Array where Element == Ticket {
    
    var validTicketCount : Int{
        get{
            return reduce(0) { (acc, ticket) -> Int in
                ticket.ticketStatus == .normal ? acc + 1 : acc
            }
        }
    }
    
    var invalidTicketCount: Int{
        get{
            return reduce(0) { (acc, ticket) -> Int in
                ticket.ticketStatus != .normal ? acc + 1 : acc
            }
        }
    }

    var lockedAssetSum: BigUInt{
        get{
            return reduce(BigUInt(0)) { (acc, ticket) -> BigUInt in
                
                ticket.ticketStatus == .normal ? acc + (BigUInt(ticket.deposit ?? "") ?? BigUIntZero) : acc
                
            }
        }
    }

    var releasedAssetSum: BigUInt{
        get{
            return reduce(BigUInt(0)) { (acc, ticket) -> BigUInt in
                
                ticket.ticketStatus != .normal ? acc + (BigUInt(ticket.deposit ?? "") ?? BigUIntZero) : acc
                
            }
        }
    }

    var tickets_voteEarnings: String?{
        get{
            return "-"
        }
    }
    
}

extension Array {

    func removeDuplicate<E : Equatable>(_ filter: (Element) -> E) -> [Element] {
        
        var newArr:[Element] = []
        forEach { (item) in
            let e = filter(item)
            if !newArr.map({filter($0)}).contains(e) {
                newArr.append(item)
            }
        }
        return newArr
    }
}
