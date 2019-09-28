//
//  batchTransferTests.swift
//  platonWalletTests
//
//  Created by Ned on 2019/9/26.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import XCTest
import BigInt
import platonWeb3
import OHHTTPStubs
@testable import platonWallet

let toAddresses =
"""
node_01_staking_account:
6fDXTIlqCv
node_02_staking_account:
Fu4yLVFznd
node_03_staking_account:
PC4JdYTHI1
node_04_staking_account:
ee1CbotF7e
node_05_staking_account:
V5Fzg1yNUC
node_06_staking_account:
jAV8EB7HYA
node_07_staking_account:
diooleFMs4
node_08_staking_account:
h6qd4NmhW5
node_09_staking_account:
lJVQcBL3Xj
node_10_staking_account:
gkVhRxTOsr
node_11_staking_account:
FoYZ3ryWtN
node_12_staking_account:
1IhnAJlkBO
node_13_staking_account:
q3Ovt4qXL2
node_14_staking_account:
4BoRldRdOo
node_15_staking_account:
bqVnBt1Y9M
node_16_staking_account:
JA7U50MKhv
node_17_staking_account:
0aibw6Fy3v
node_18_staking_account:
f8zYrySPVj
node_19_staking_account:
1xZZLYXSPS
node_20_staking_account:
E9f9IM77YD
node_21_staking_account:
gKbq1dcVAy
node_22_staking_account:
Gyv0rk49ZM
node_23_staking_account:
9Loag0pTVR
node_24_staking_account:
1Q6O6QVeXt
node_25_staking_account:
5VjMqDFkI7
node_26_staking_account:
3EB6LXidd6
node_27_staking_account:
vRJ96Av8nq
node_28_staking_account:
Li6yMLfPP4
node_29_staking_account:
IkxsjTzKyj
node_30_staking_account:
Wu6noabb2H
node_31_staking_account:
U54vv1EpTa
node_32_staking_account:
ceWeaZYuf0

"""

class batchTransferTests: XCTestCase {
    
    func testgetstakingAddresstest() -> [String]{
        let lines = toAddresses.components(separatedBy: "\n")
        var addresses : [String] = []
        for line in lines{
            if line.is40ByteAddress(){
                addresses.append(line)
            }
        }
        return addresses
    }
    
    func testbatchTransfertest(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { 
            
            let stakingArr = self.testgetstakingAddresstest()
            print("\(stakingArr):\ncount\(stakingArr.count)")
            
            var address = stakingArr
            
            let pri = "d25a329971e21680a4ed58279fd29e2c0448165cb1d9a5599171e62f81aa75d4"
            let from = "0x0f4fea40f1397d8c087749bfaabd7974f649697e"
            
//            let pri = "e47706d5cfd5d6881da307a37e98e3ce3e9d0000eb8746633ba8cf8ee0b289b3"
//            let from = "0x9bbac0df99f269af1473fd384cb0970b95311001"
            
            var failList = [""]
            let queue = DispatchQueue(label: "ttttt")
            let notifyqueue = DispatchQueue(label: "ttttt111")
            queue.async {
                var semaphore = DispatchSemaphore(value: 0)
                var index = 0
                for addr in address{
                    index = index + 1
                    let _ = TransactionService.service.sendAPTTransfer(from: from, to: addr, amount: "0.1", InputGasPrice: BigUInt("673076775000"), estimatedGas: "210000", memo: "", pri: pri, completion: {[weak self] (result, txHash) in
                        
                        
                        notifyqueue.async {
                            sleep(10)
                            semaphore.signal()
                        }
                        
                        
                        switch result{
                            
                        case .success:
                            print("\(addr) index:\(index) success")
                        case .fail(let code, let des):
                            print("\(addr) index:\(index) error:\(des)")
                            failList.append(addr)
                        }
                    })
                    semaphore.wait()
                }
                
                print("fail:\n \(failList)")
            }
            
            
        }
    }
}
