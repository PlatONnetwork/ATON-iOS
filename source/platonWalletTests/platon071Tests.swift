//
//  platon071Tests.swift
//  platonWalletTests
//
//  Created by Admin on 9/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import XCTest
import BigInt
import platonWeb3
import OHHTTPStubs
import RealmSwift
@testable import platonWallet

extension RLPItem {
    init(epoch: UInt64,
         amount: BigUInt) {
        let epochData = Data.newData(unsignedLong: epoch)
        let epochBytes = epochData.bytes
        self = .array(
            .bytes(epochBytes),
            .bigUInt(amount)
        )
    }
}


class platon071Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetNodePersistence() {
        let expectaion = self.expectation(description: "testGetNodePersistence")
        let nodeId1 = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d9"
        let nodeId2 = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d8"
        let node1 = Node(nodeId: nodeId1, ranking: 1, name: "testNode", deposit: "10000", url: "url", ratePA: "10000", nStatus: .Active, isInit: false, isConsensus: false)
        let node2 = Node(nodeId: nodeId2, ranking: 2, name: "testNode", deposit: "10000", url: "url", ratePA: "10001", nStatus: .Candidate, isInit: false, isConsensus: false)
        NodePersistence.add(nodes: [node1, node2]) {
            expectaion.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
        
        let result1 = NodePersistence.getActiveNode().filter { $0.nodeStatus != NodeStatus.Active.rawValue }
        XCTAssert(result1.count == 0, "get active node status should be active")
        
        let result2 = NodePersistence.getCandiateNode().filter { $0.nodeStatus != NodeStatus.Candidate.rawValue }
        XCTAssert(result2.count == 0, "get active node status should be candiate")
        
    }
    
    func testSaveNodePersistence() {
        let expectaion = self.expectation(description: "testSaveNodePersistence")
        let nodeId = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d1"
        let node = Node(nodeId: nodeId, ranking: 1, name: "testNode", deposit: "10000", url: "url", ratePA: "10000", nStatus: .Active, isInit: false, isConsensus: false)
        
        NodePersistence.add(nodes: [node], {
            expectaion.fulfill()
        })
        
        wait(for: [expectaion], timeout: 5.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = NodePersistence.getAll().filter { $0.nodeId?.lowercased() == nodeId.lowercased() }
            XCTAssert(result.count > 0, "node should be save")
        }
    }

    
    func testSaveTransactionPersistence() {
        let transaction = Transaction()
        transaction.txhash = "0x06961bb2492a0090b7cb177c0f7f401d0d62c2e32550f993a95ae80e44f23691"
        transaction.from = "0xa7074774f4e1e033c6cbd471ec072f7734144a0c"
        transaction.to = "0x1000000000000000000000000000000000000002"
        transaction.value = "12000000000000000000"
        transaction.confirmTimes = 1568277810000
        transaction.actualTxCost = "24264000000000000"
        transaction.nodeName = "节点1"
        transaction.nodeId = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d5"
        transaction.txReceiptStatus = 1
        
        TransferPersistence.add(tx: transaction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let result = TransferPersistence.getByTxhash(transaction.txhash)
            XCTAssertNotNil(result, "not transaction be saved")
        }
    }
    
    func testUpdateTransactionPersistence() {
        let expectaion = self.expectation(description: "testNodeListAPI")
        let txhash = "0x06931bb2492a0090b7cb177c0f7f401d0d62c2e32550f993a95ae80e44f23691"
        
        let transaction = Transaction()
        transaction.txhash = txhash
        transaction.from = "0xa7074774f4e1e033c6cbd471ec072f7734144a0c"
        transaction.to = "0x1000000000000000000000000000000000000002"
        transaction.value = "12000000000000000000"
        transaction.confirmTimes = 1568277810000
        transaction.actualTxCost = "24264000000000000"
        transaction.nodeName = "节点1"
        transaction.nodeId = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e35cd93dc234d5"
        transaction.txReceiptStatus = 1
        TransferPersistence.add(tx: transaction)
        
        Thread.sleep(forTimeInterval: 2)
        
        TransferPersistence.update(txhash: txhash, status: 0, blockNumber: "0x92a2", gasUsed: "0x14000000") {
            expectaion.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }

//        let result = TransferPersistence.getByTxhash(txhash)
//        XCTAssertEqual(result?.txReceiptStatus, 1, "update transaction status failure")
    }
    
    func testNodeListAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/nodelist")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("nodelist.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testNodeListAPI")
        StakingService.sharedInstance.updateNodeListData { (result, data) in
            switch result {
            case .success:
                
                let result = NodePersistence.getAll()
                XCTAssertTrue(result.count == 2, "get node list success")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get node list failure")
            }
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }

    func testMyDelegateAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/listDelegateGroupByAddr")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("listDelegateGroupByAddr.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testMyDelegateAPI")
        let addresses = ["0x0772fd8e5126C01b98D3a93C64546306149202ED"]

        StakingService.sharedInstance.getMyDelegate(adddresses: addresses) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? [Delegate]) != nil, "response should be decode Delegate Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get my delegate failure")
            }
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }

    }

    func testNodeDetailAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/nodeDetails")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("nodeDetails.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testNodeDetailAPI")
        let nid = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d5"

        StakingService.sharedInstance.getNodeDetail(nodeId: nid) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? NodeDetail) != nil, "response should be decode NodeDetail Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get node detail failure")
            }
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }

    func testDelegateDetailAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/delegateDetails")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("delegateDetails.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testDelegateDetailAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"

        StakingService.sharedInstance.getDelegateDetail(address: walletAddress) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? [DelegateDetail]) != nil, "response should be decode DelegateDetail Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get delegate detail failure")
            }
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }

    func testDelegateValueAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/getDelegationValue")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("delegationValue.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testDelegateValueAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"
        let nid = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d5"
        
        StakingService.sharedInstance.getDelegationValue(addr: walletAddress, nodeId: nid) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? Delegation) != nil, "response should be decode DelegationValue Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get delegate detail failure")
            }
        }

        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testCanDelegateAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/node/canDelegation")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("canDelegation.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testCanDelegateAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"
        let nid = "0x81f4ab0012303bff59c35cead6c2487909cbf59bb0b2b677c2ff36d7009b39a572b2f73214d8590022d20410cbf92631844a7ce8a7d5b840c0e25cd93dc234d5"
        
        StakingService.sharedInstance.getCanDelegation(addr: walletAddress, nodeId: nid) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? CanDelegation) != nil, "response should be decode CanDelegation Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get can delegate failure")
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetBalanceAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/account/getBalance")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("getBalance.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testGetBalanceAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"
        
        AssetService.sharedInstace.getWalletBalances(addrs: [walletAddress]) { (result, data) in
            switch result {
            case .success:
                XCTAssertTrue((data as? [Balance]) != nil, "response should be decode Balance Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get balance failure")
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetTransactionListAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/transaction/list")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("transactionList.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testGetTransactionListAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"
        
        TransactionService.service.getBatchTransaction(addresses: [walletAddress], beginSequence: -1, listSize: 10, direction: "new") { (result, data) in
            
            switch result {
            case .success:
                XCTAssertTrue((data as? [Transaction]) != nil, "response should be decode Transaction Type")
                expectaion.fulfill()
            case .fail(_, _):
                XCTAssert(false, "get transaction list failure")
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetDelegateRecordAPI() {
        stub(condition: isPath(AppConfig.ServerURL.PATH + "/transaction/delegateRecord")) { (request) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("delegateRecord.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectaion = self.expectation(description: "testGetDelegateRecordAPI")
        let walletAddress = "0x0772fd8e5126C01b98D3a93C64546306149202ED"
        
        TransactionService.service.getDelegateRecord(
            addresses: [walletAddress],
            beginSequence: "-1",
            listSize: 20,
            direction: "new",
            type: "all") { (result, data) in
                
                switch result {
                case .success:
                    XCTAssertTrue((data as? [Transaction]) != nil, "response should be decode DelegateRecord Type")
                    expectaion.fulfill()
                case .fail(_, _):
                    XCTAssert(false, "get delegate record failure")
                }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testRestrict(){
        let plan = try? RestrictingPlan(rlp: RLPItem.init(epoch: 1000000, amount: BigUInt("100000000000000000000000")))
        
        web3.restricting.createRestrictingPlan(account: "0x1f9EF81fCdebdef5d6498e69CC46c1e3588dB90D", plans: [plan!], sender: "0x2e95e3ce0a54951eb9a99152a6d5827872dfb4fd", privateKey: "a689f0879f53710e9e0c1025af410a530d6381eebb5916773195326e123b822b", completion: { (ret, data) in
            
        })
    }
}
