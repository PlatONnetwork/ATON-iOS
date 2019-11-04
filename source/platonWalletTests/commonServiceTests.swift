////
////  commonServiceTests.swift
////  platonWalletTests
////
////  Created by Ned on 2019/10/11.
////  Copyright © 2019 ju. All rights reserved.
////
//
//import Foundation
//
//import XCTest
//import BigInt
//import platonWeb3
//import OHHTTPStubs
//import RealmSwift
//@testable import platonWallet
//
//class CommonServicegTest: XCTestCase {
//    
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//    
//    func testCommonService() {
//        XCTAssert(!CommonService.isValidContractAddress("test").0)
//        CommonService.isValidContractAddress("0x5eBb663FD101b46dBBe6465E72Ed4b2918492011")
//        CommonService.isValidWalletName("test")
//        CommonService.isValidWalletName("test", checkDuplicate: true)
//        CommonService.checkNewAddressName("test")
//        CommonService.checkTransferAddress(text: "0x5eBb663FD101b46dBBe6465E72Ed4b2918492011")
//        
//        CommonService.checkTransferAmoutInput(text: "test", checkBalance: true, minLimit: BigUInt("0"), maxLimit: BigUInt("0"), fee: BigUInt("0"))
//        
//        let decoder = QRCodeDecoder.init()
//        let keystore = """
//{"version":3,"id":"a87df8e9-d9d2-4e01-87ca-39108d1c9641","crypto":{"ciphertext":"27652e5d2c7b832e98882bb1a79bd2a26a6a875a8d2ca585969d9917e435d2f9","cipherparams":{"iv":"a59ea0ab8b7262277740d7e39bc42fa1"},"kdf":"scrypt","kdfparams":{"r":8,"p":6,"n":4096,"dklen":32,"salt":"81d94592b42383370f3b8a1e742e29e67fa61b592f9544505c251a6f84652b27"},"mac":"2228e7c58f402347364e09dd78ae2da0427762b9f9133782f6c8afa5976728ff","cipher":"aes-128-ctr"},"address":"0x2e95E3ce0a54951eB9A99152A6d5827872dFB4FD"}
//"""
//        decoder.decode("0x5eBb663FD101b46dBBe6465E72Ed4b2918492061")
//        decoder.decode("c3ab73eb6b0e414f0d8949bd76cb58ab8fd5d348dbb24522bdac5da74b885bac")
//        decoder.decode(keystore)
//        decoder.decode("a")
//        decoder.decode("")
//    }
//    
//    func testAnalysisHelper(){
//        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.begin, attributes: nil)
//        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.end, attributes: nil)
//        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.begin, attributes: nil)
//        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.cancel, attributes: nil)
//    }
//    
//    func testBaseService(){
//        let b = BaseService()
//        
//        var block : platonWallet.PlatonCommonCompletion? = nil
//        b.successCompletionOnMain(obj: nil, completion: &block)
//        b.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &block)
//        b.timeOutCompletionOnMainThread(completion: &block)
//        b.failWithEmptyResponseCompletionOnMainThread(completion: &block)
//        
//        DispatchQueue.global().async {
//            b.successCompletionOnMain(obj: nil, completion: &block)
//            b.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &block)
//            b.timeOutCompletionOnMainThread(completion: &block)
//            b.failWithEmptyResponseCompletionOnMainThread(completion: &block)
//        }
//        
//    }
//    
//    func testTransfer(){
//        TransactionService.service.sendAPTTransfer(from: "0x5eBb663FD101b46dBBe6465E72Ed4b2918492061", to: "0x5eBb663FD101b46dBBe6465E72Ed4b2918492061", amount: "1", InputGasPrice: BigUInt("1"), estimatedGas: "111", memo: "", pri: "c3ab73eb6b0e414f0d8949bd76cb58ab8fd5d348dbb24522bdac5da74b885bac") { (ret, obj) in
//            
//        }
//        
//        
//        TransactionService.service.startGasTimer()
//        TransactionService.service.stopGasTimer()
//        
//        let tx = Transaction()
//        tx.txhash = "0x1111111"
//        tx.transactionType = 0
//        TransferPersistence.add(tx: tx)
//    }
//    
//    func testWeb3Helper(){
//        let correcturl = "https:\\aton.main.platon.network"
//        let errorurl = "https:\\aton.error.platon.network"
//        Web3Helper.switchRpcURL(correcturl) { (result) in
//            
//        }
//        Web3Helper.switchRpcURL(correcturl, succeedCb: { 
//        }) { 
//        }
//        
//        Web3Helper.switchRpcURL(errorurl) { (result) in
//            
//        }
//        Web3Helper.switchRpcURL(errorurl, succeedCb: { 
//        }) { 
//        }
//    }
//    
//    func testByteHelper(){
//        let data = Data(hexStr: "0x0a0b")
//        data?.getByte(at: 0)
//        data?.getUnsignedLong(at: 0)
//        
//        Data.newData(uint32data: 1)
//    }
//    
//    func testAddressBookService(){
//        let addr = AddressInfo()
//        addr.nodeURLStr = "https://aton.main.platon.network"
//        addr.addressType = 0
//        addr.walletAddress = "0xbbbb"
//        addr.walletName = "name1"
//        AddressBookService.service.add(addressInfo: addr)
//        
//        addr.walletAddress = "0xaaa"
//        AddressBookService.service.replaceInto(addrInfo: addr)
//        
//        AddressBookService.service.getAll()
//    }
//    
//    func testTransactionQrcode(){
//        let code0 = TransactionQrcode(amount: "", chainId: "", from: "", to: "", gasLimit: "", gasPrice: "", nonce: "", typ: 0, nodeId: "", nodeName: "", sender: "", stakingBlockNum: "", type: 0)
//        let code1004 = TransactionQrcode(amount: "", chainId: "", from: "", to: "", gasLimit: "", gasPrice: "", nonce: "", typ: 0, nodeId: "", nodeName: "", sender: "", stakingBlockNum: "", type: 1004)
//        let code1005 = TransactionQrcode(amount: "", chainId: "", from: "", to: "", gasLimit: "", gasPrice: "", nonce: "", typ: 0, nodeId: "", nodeName: "", sender: "", stakingBlockNum: "", type: 1005)
//        
//        code0.typeString
//        code0.fromName
//        code0.toName
//        
//        code1004.typeString
//        code1004.fromName
//        code1004.toName
//        
//        code1005.typeString
//        code1005.fromName
//        code1005.toName
//    }
//    
//    func testNode(){
//        
//        let nodeActive = Node(nodeId: "test", ranking: 1, name: "name", deposit: "100", url: "random", ratePA: "1", nStatus: NodeStatus.Active, isInit: true)
//        let nodeCandidate = Node(nodeId: "test", ranking: 1, name: "name", deposit: "100", url: "random", ratePA: "1", nStatus: NodeStatus.Candidate, isInit: true)
//        let nodeExited = Node(nodeId: "test", ranking: 1, name: "name", deposit: "100", url: "random", ratePA: "1", nStatus: NodeStatus.Exited, isInit: true)
//        let nodeExiting = Node(nodeId: "test", ranking: 1, name: "name", deposit: "100", url: "random", ratePA: "1", nStatus: NodeStatus.Exiting, isInit: true)
//        
//        nodeActive.nStatus
//        nodeCandidate.nStatus
//        nodeExited.nStatus
//        nodeExiting.nStatus
//        
//        nodeActive.status
//        nodeCandidate.status
//        nodeExited.status
//        nodeExiting.status
//        
//        nodeActive.rank
//        nodeCandidate.rank
//        nodeExited.rank
//        nodeExiting.rank
//        
//    }
//    
//    func testTransaction(){
//        let tx = Transaction()
//        let typesEnum = [TxType.transfer,
//                         TxType.contractCreate,
//                         TxType.contractExecute,
//                         TxType.otherReceive,
//                         TxType.otherSend,
//                         TxType.MPCtransaction,
//                         TxType.stakingCreate,
//                         TxType.stakingEdit,
//                         TxType.stakingAdd,
//                         TxType.stakingWithdraw,
//                         TxType.delegateCreate,
//                         TxType.delegateWithdraw,
//                         TxType.submitText,
//                         TxType.submitVersion,
//                         TxType.submitParam,
//                         TxType.voteForProposal,
//                         TxType.declareVersion,
//                         TxType.submitCancel,
//                         TxType.reportDuplicateSign,
//                         TxType.createRestrictingPlan,
//                         TxType.unknown]
//        
//        
//        for item in typesEnum{
//            tx.txType = item
//            tx.txType?.localizeTitle
//            tx.toAvatarImage
//            tx.fromAvatarImage
//            tx.toNameString
//            tx.fromNameString
//            tx.toIconImage
//            tx.amountTextString
//            tx.amountTextColor
//            tx.txTypeIcon
//            tx.pipString
//            tx.versionDisplayString
//            tx.recordIconIV
//            tx.recordAmount
//            tx.recordAmountForDisplay
//            tx.recordStatus
//            tx.recordTime
//            tx.recordWalletName
//            
//            
//        }
//         
//    }
//    
//}
//    
