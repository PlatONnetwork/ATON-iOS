//
//  CandidateResponse.swift
//  platonWallet
//
//  Created by Admin on 20/5/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

class CandidateResponse: Decodable {
    var errMsg: String = ""
    var code: Int = 0
    var voteCount: Int
    var totalCount: Int
    var ticketPrice: String?
    var list: [Candidate] = []
    
    enum CodingKeys: String, CodingKey {
        case errMsg
        case code
        case data
    }
    
    enum DataCodingKeys: String, CodingKey {
        case voteCount
        case totalCount
        case ticketPrice
        case list
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        errMsg = try container.decode(String.self, forKey: .errMsg)
        code = try container.decode(Int.self, forKey: .code)
        
        let keyedContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        voteCount = try keyedContainer.decode(Int.self, forKey: .voteCount)
        totalCount = try keyedContainer.decode(Int.self, forKey: .totalCount)
        ticketPrice = try keyedContainer.decode(String.self, forKey: .ticketPrice)
        list = try keyedContainer.decode([Candidate].self, forKey: .list)
    }
}
