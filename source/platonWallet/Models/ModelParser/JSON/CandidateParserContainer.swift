//
//  CandidateParserContainerMatrix.swift
//  platonWallet
//
//  Created by Ned on 2019/3/26.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

class CandidateParserContainerMatrix : NSObject, Decodable {
    var candidates : Array<Candidate> = []
    required init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        guard container != nil else {
            return
        }
        container = container!
        for _ in 0..<container!.count! {
            var subC = try? container?.nestedUnkeyedContainer()
            guard subC != nil else{
                continue
            }
            for _ in 0..<subC!!.count! {
                let candidate = try? subC!?.decode(Candidate.self)
                if candidate != nil{
                    candidates.append(candidate as! Candidate)
                }
            }
        }
        
    }
}

class CandidateParserContainerArray : NSObject, Decodable {
    var candidates : Array<Candidate> = []
    required init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        guard container != nil else {
            return
        }
        container = container!
        for _ in 0..<container!.count! {
            let candidate = try? container!.decode(Candidate.self)
            if candidate != nil{
                candidates.append(candidate as! Candidate)
            }
        }
        
    }
}
