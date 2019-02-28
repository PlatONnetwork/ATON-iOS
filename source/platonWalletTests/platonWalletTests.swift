//
//  platonWalletTests.swift
//  platonWalletTests
//
//  Created by juzix on 2018/10/20.
//  Copyright © 2018 ju. All rights reserved.
//

import XCTest
import BigInt
import platonWeb3_local
@testable import platonWallet

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
}

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt64>.size)
    }
}



class platonWalletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUtil(){
        
        let tmp = BigUInt("0000010")
        let sss = String(tmp!)
        
        XCTAssertTrue("0.11".isValidInputAmoutWith8DecimalPlace())
        XCTAssertFalse("0000.1".isValidInputAmoutWith8DecimalPlace())
        XCTAssertFalse("0.123456789".isValidInputAmoutWith8DecimalPlace())
        
    
        XCTAssertEqual("0.", "0.0".trimDecimalTailingZero())
        XCTAssertEqual("00.", "00.00".trimDecimalTailingZero())
        XCTAssertEqual("10.", "10.000".trimDecimalTailingZero())
        XCTAssertEqual("10.1", "10.100".trimDecimalTailingZero())
        
        XCTAssertEqual("123457000", String((BigUInt("123456789")?.ceilToDecimal(round: 3))!))
        XCTAssertEqual("123456000", String((BigUInt("123456789")?.floorToDecimal(round: 3))!))
        
        
        XCTAssertEqual("111111111111000000010000000000", String((BigUInt("111111111111000000000012345678")?.ceilToDecimal(round: 10))!))
        XCTAssertEqual("11120000000000", String((BigUInt("11110123456789")?.ceilToDecimal(round: 10))!))
        
        XCTAssertEqual("111111111111000000000000000000", String((BigUInt("111111111111000000000012345678")?.floorToDecimal(round: 10))!))
        XCTAssertEqual("11110000000000", String((BigUInt("11110123456789")?.floorToDecimal(round: 10))!))

        
    }
    
    func testRlpDecode(){
        
        let rlpItem = try? RLPDecoder().decode([0xc1,0x80])
        var transactionId = Data(bytes: rlpItem!.array![0].bytes!).safeGetUnsignedLong(at: 0, bigEndian: true)
        print("d")
        
    }
    
    func testSendAmoutInput(){
        
        assert(!".0...1".isValidInputAmoutWith8DecimalPlace())
        assert(!"..1".isValidInputAmoutWith8DecimalPlace())
        assert(!"9.111.".isValidInputAmoutWith8DecimalPlace())
        assert(!"9.123456789".isValidInputAmoutWith8DecimalPlace())
        assert(!".111".isValidInputAmoutWith8DecimalPlace())
        assert("0.111".isValidInputAmoutWith8DecimalPlace())
    
    }
    
    func testUIntUtilTest(){
        let intdata16 : UInt16 = 1
        let data16 = intdata16.data
        let data16Hex = data16.hexString
        print("")
        
        let intdata32 : UInt32 = 1
        let data32 = intdata32.littleEndian.data
        let data32Hex = data32.hexString
        print("")
        
        let intdata64 : UInt64 = 1
        let data64 = intdata64.data
        let thebytes = data64.bytes
        let data64Hex = data64.hexString
        print("")
        
    }

    func testBigUintExtensionTest() {
        
        let ret1 = BigUInt("1234567893333")?.divide(by: "10000000000", round: 8)
        XCTAssertEqual(ret1, "123.45678933")
        
        let ret2 = BigUInt("1234567893333")?.divide(by: "10000000000", round: 1)
        XCTAssertEqual(ret2, "123.4")
        
        let ret3 = BigUInt("1234567893333000000000000000000000000000000")?.divide(by: "10000000000", round: 1)
        XCTAssertEqual(ret3, "123456789333300000000000000000000")
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let divideret1 = BigUInt("21000")?.divide(by: "10000", round: 4)
        XCTAssertEqual(divideret1, "2.1")
        
        let divideret2 = BigUInt("21000")?.divide(by: "100000", round: 4)
        XCTAssertEqual(divideret2, "0.21")
        
        let divideret3 = BigUInt("21000000000000")?.divide(by: "1000000000000000000", round: 100)
        XCTAssertEqual(divideret3, "0.000021")
    }
    
    func testPlatonContranctDeploy(){
        
        let web3 = Web3(rpcURL: "http://192.168.7.184:8545")
        
        let abi = "{\"version\":\"0.01\",\"abi\":[{\"method\":\"transfer\",\"args\":[{\"name\":\"from\",\"typeName\":\"\",\"realTypeName\":\"string\"},{\"name\":\"to\",\"typeName\":\"\",\"realTypeName\":\"string\"},{\"name\":\"balance\",\"typeName\":\"\",\"realTypeName\":\"int32\"}],\"return\":\"void\",\"funcType\":\"\"},{\"method\":\"transfer02\",\"args\":[{\"name\":\"from\",\"typeName\":\"\",\"realTypeName\":\"string\"},{\"name\":\"to\",\"typeName\":\"\",\"realTypeName\":\"string\"},{\"name\":\"balance\",\"typeName\":\"\",\"realTypeName\":\"int32\"}],\"return\":\"void\",\"funcType\":\"\"},{\"method\":\"getBalance\",\"args\":[{\"name\":\"from\",\"typeName\":\"\",\"realTypeName\":\"string\"}],\"return\":\"string\",\"funcType\":\"const\"}],\"event\":[{\"name\":\"Notify\",\"args\":[{\"typeName\":\"string\"}]},{\"name\":\"NotifyWithCode\",\"args\":[{\"typeName\":\"int32\"},{\"typeName\":\"string\"}]}]}"
        let path = Bundle.main.path(forResource: "PlatonAssets/demo01", ofType: "wasm")
        let bin = try? Data(contentsOf: URL(fileURLWithPath: path!))
        
        let txTypePart = RLPItem(bytes: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01])
        let binPart = RLPItem(bytes: (bin?.bytes)!)
        let abiPart = RLPItem(bytes: (abi.data(using: .utf8)?.bytes)!)

        let rlp = RLPItem(arrayLiteral: txTypePart,binPart,abiPart)
        
        let rawRlp = try? RLPEncoder().encode(rlp)
        let rlpHex = rawRlp?.toHexString()
        
        let tmpAddr = EthereumAddress(hexString: "0xAa9afdCf179EBd392767F4113eF02B018D937488")
        let tmpQuan = EthereumQuantity(quantity: BigUInt("0")!)
        let call = EthereumCall(from: tmpAddr, to: tmpAddr!, gas: tmpQuan, gasPrice: tmpQuan, value: tmpQuan, data: EthereumData(bytes: rawRlp!))
        
        web3.eth.estimateGas(call: call) { (resp) in
            print("\(resp)")
            print("\(String((resp.result?.quantity)!))")
            print("\(self)")
        }
        
        
        print("bin length")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func testIPQuery(){
        var list : [String] = []
        
        list.append("59.125.205.87")
        list.append("61.244.148.166")
        for i in 1...250{
            let n:Int = Int(arc4random() % 250) + 1
            let j:Int = Int(arc4random() % 250) + 1
            let k:Int = Int(arc4random() % 250) + 1
            let l:Int = Int(arc4random() % 250) + 1
            list.append(String(format: "%d.%d.%d.%d", n,j,k,l))
        }
        
        IPQuery.sharedInstance.batchQueryIPs(ipList: list) { (result, data) in
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            VoteManager.sharedInstance.CandidateList { (result, data) in
                
            }
            
//            self.window?.rootViewController = MyVoteListVC()
        }
    }
    
    func testJsonwithbn(){
        
        
        let data = Data(hex: "5b7b224465706f736974223a36303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030302c22426c6f636b4e756d626572223a3236302c225478496e646578223a302c2243616e6469646174654964223a223266336138363732333438666636623738396534313637363261643533653639303633313338623865623464383738303130313635386632346232333639663161386530393439393232366234363764386263306334653033653164633930336466383537656562336336373733336432316236616165653238343065343239222c22486f7374223a22302e302e302e31222c22506f7274223a223330333033222c224f776e6572223a22307835613563343336386532363932373436623238366365653336616230373130616633656661366366222c2246726f6d223a22307835613563343336386532363932373436623238366365653336616230373130616633656661366366222c224578747261223a2265787472612064617461222c22466565223a3530302c225469636b65744964223a22307830303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030227d2c7b224465706f736974223a353030303030303030303030303030303030302c22426c6f636b4e756d626572223a3235342c225478496e646578223a302c2243616e6469646174654964223a223166336138363732333438666636623738396534313637363261643533653639303633313338623865623464383738303130313635386632346232333639663161386530393439393232366234363764386263306334653033653164633930336466383537656562336336373733336432316236616165653238343065343239222c22486f7374223a22302e302e302e30222c22506f7274223a223330333033222c224f776e6572223a22307837343063653331623366616332306461633337396462323433303231613531653830616430306437222c2246726f6d223a22307837343063653331623366616332306461633337396462323433303231613531653830616430306437222c224578747261223a2265787472612064617461222c22466565223a3530302c225469636b65744964223a22307830303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030227d2c7b224465706f736974223a343030303030303030303030303030303030302c22426c6f636b4e756d626572223a3236342c225478496e646578223a302c2243616e6469646174654964223a223366336138363732333438666636623738396534313637363261643533653639303633313338623865623464383738303130313635386632346232333639663161386530393439393232366234363764386263306334653033653164633930336466383537656562336336373733336432316236616165653238343065343239222c22486f7374223a22302e302e302e32222c22506f7274223a223330333033222c224f776e6572223a22307834393333303137313236373161646135303662613663613738393166343336643239313835383231222c2246726f6d223a22307834393333303137313236373161646135303662613663613738393166343336643239313835383231222c224578747261223a2265787472612064617461222c22466565223a3530302c225469636b65744964223a22307830303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030227d5d")
        
        let darray = try? JSONSerialization.jsonObject(with: data, options: []) as! Array<Dictionary<String, Any>>
        let tmpdic = darray![0]
        
        let value = tmpdic["Deposit"] as! Decimal
        let stringvalue = value.description
        
    }
    
    func testVoteTicket() {
        
        let expectaion = self.expectation(description: "voteTicket.test")
        
        VoteManager.sharedInstance.VoteTicket(count: 100, price: BigUInt("1")!, nodeId: "0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e429", sender: "0x493301712671Ada506ba6Ca7891F436D29185821", privateKey: "a11859ce23effc663a9460e332ca09bd812acc390497f8dc7542b6938e13f8d7", gasPrice: BigUInt("1000000000")!, gas: deploy_UseStipulatedGas, completion: { (res, data) in
            expectaion.fulfill()
            XCTAssert(true)
        })
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
        
    }
    
    func testGetCandidateEpoch() {
        
        let expectaion = self.expectation(description: "GetCandidateEpoch.test")
        
        VoteManager.sharedInstance.GetCandidateEpoch(candidateId: "0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e429") { (res, data) in
            expectaion.fulfill()
            XCTAssert(true)
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetTicketDetail() {
        
        let expectaion = self.expectation(description: "GetTicketDetail.test")
        
        VoteManager.sharedInstance.GetTicketDetail(ticketId: "0x34bdecd0fa6b8d85b1fa436eac6066aca2f51cc5e84fec278bff7df781310982") { (res, data) in
            expectaion.fulfill()
            print(res, data)
            XCTAssert(true)
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetBatchTicketDetail() {
        
        let expectaion = self.expectation(description: "GetBatchTicketDetail.test")
        
        VoteManager.sharedInstance.GetBatchTicketDetail(ticketIds: ["0x34bdecd0fa6b8d85b1fa436eac6066aca2f51cc5e84fec278bff7df781310982","0x34bdecd0fa6b8d85b1fa436eac6066aca2f51cc5e84fec278bff7df781310983"]) { (res, data) in
            expectaion.fulfill()
            print(res, data as Any)
            XCTAssert(true)
        }

        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testGetCandidateDetails() {
        
        let expectaion = self.expectation(description: "CandidateDetails.test")
        
        VoteManager.sharedInstance.CandidateDetails(candidateId: "0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e429", completion: { (res, data) in
            expectaion.fulfill()
            print(res, data as Any)
            XCTAssert(true)
        })
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    
    func testGetBatchCandidateDetail() {
        
        let expectaion = self.expectation(description: "GetBatchCandidateDetail.test")
        
        VoteManager.sharedInstance.GetBatchCandidateDetail(ids: ["0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e420"], completion: { (res, data) in
            expectaion.fulfill()
            print(res, data as Any)
            XCTAssert(true)
        })
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }

    func testGetBatchCandidateTicketIds() {
        
        let expectaion = self.expectation(description: "GetBatchCandidateTicketIds.test")
        
        VoteManager.sharedInstance.GetBatchCandidateTicketIds(candidateIds: ["0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e420","0x1f3a8672348ff6b789e416762ad53e69063138b8eb4d8780101658f24b2369f1a8e09499226b467d8bc0c4e03e1dc903df857eeb3c67733d21b6aaee2840e429"], completion: { (res, data) in
            expectaion.fulfill()
            print(res, data as Any)
            XCTAssert(true)
        })
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
}
