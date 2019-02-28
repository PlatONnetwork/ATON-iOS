//
//  Ticket.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import platonWeb3
import CryptoSwift

enum TicketStatus: Int{
    case none = 0
    case normal = 1
    case selected = 2
    case expired = 3
    case dropout = 4
}



class Ticket: Object, Codable{
    //ticket id
    @objc dynamic var ticketId : String? = ""
    
    //ticket owner
    @objc dynamic var owner : String? = ""
    
    //ticket price
    @objc dynamic var deposit : String? = ""
    
    //candidate id
    @objc dynamic var candidateId : String? = ""
    
    //block number when buy votes
    @objc dynamic var blockNumber : String? = ""
    
    //ticket status
    @objc dynamic var state: Int = 0
    
    var ticketStatus: TicketStatus{
        get{
            return TicketStatus(rawValue: state)!
        }
    }
    
    override public static func primaryKey() -> String? {
        return "ticketId"
    }
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "TicketId"
        case owner = "Owner"
        case deposit = "Deposit"
        case candidateId = "CandidateId"
        case blockNumber = "BlockNumber"
        case state = "State"
    }
    
    required public init(from decoder: Decoder) throws {
        
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticketId = try container.decode(String.self, forKey: .ticketId)
        owner = try container.decode(String.self, forKey: .owner)
        let depositDecimal = try? container.decode(Decimal.self, forKey: .deposit)
        deposit = depositDecimal?.description
        candidateId = try container.decode(String.self, forKey: .candidateId)
        let blockNumberDecimal = try? container.decode(Decimal.self, forKey: .blockNumber)
        blockNumber = blockNumberDecimal?.description
        state = try container.decode(Int.self, forKey: .state)
    }
    
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
        
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
        
    }
    
    public static func generateTickets(txHash: Data, count: UInt32, owner: String, candidateId: String, price: String) -> [Ticket]{
        
        var tickets = [Ticket]()
        
        for i in 0..<count {
            
            let t = Ticket()
            let ticketId = generateTicketId(txHash: txHash, index: i)
            t.ticketId = ticketId
            t.owner = owner
            t.candidateId = candidateId
            t.deposit = price
            
            tickets.append(t)

        }
        return tickets
    }
    
    static func generateTicketId(txHash: Data, index: UInt32) -> String {
        var data = txHash
        for c in String(index).unicodeScalars {
            data.append(UInt8(c.value))
        }
        return "0x\(data.sha3(.sha256).toHexString())"
    }

}

