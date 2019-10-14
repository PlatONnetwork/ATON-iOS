//
//  VoteManager.swift
//  platonWallet
//
//  Created by Ned on 24/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

let reservePoolingContract = "0x1000000000000000000000000000000000000000"
let candidateContract = "0x1000000000000000000000000000000000000001"
let votePoolingContract = "0x1000000000000000000000000000000000000002"

class VoteManager: BaseService {

    func CandidateList(completion: PlatonCommonCompletion) {

        web3.eth.platonCall(contractAddress: candidateContract, functionName: "CandidateList", from: nil, [], outputs: []) { (result, _) in
            switch result {

            case .success:
                do {}
            case .fail:
                do {}
            }
        }

    }

}
