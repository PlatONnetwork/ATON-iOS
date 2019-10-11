//
//  commonServiceTests.swift
//  platonWalletTests
//
//  Created by Ned on 2019/10/11.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

import XCTest
import BigInt
import platonWeb3
import OHHTTPStubs
import RealmSwift
@testable import platonWallet

class CommonServicegTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCommonService() {
        CommonService.isValidContractAddress("test")
        CommonService.isValidContractAddress("0x5eBb663FD101b46dBBe6465E72Ed4b2918492011")
        CommonService.isValidWalletName("test")
        CommonService.isValidWalletName("test", checkDuplicate: true)
        CommonService.checkNewAddressName("test")
        CommonService.checkTransferAddress(text: "0x5eBb663FD101b46dBBe6465E72Ed4b2918492011")
        
        CommonService.checkTransferAmoutInput(text: "test", checkBalance: true, minLimit: BigUInt("0"), maxLimit: BigUInt("0"), fee: BigUInt("0"))
        
        let decoder = QRCodeDecoder.init()
        let keystore = """
{"version":3,"id":"a87df8e9-d9d2-4e01-87ca-39108d1c9641","crypto":{"ciphertext":"27652e5d2c7b832e98882bb1a79bd2a26a6a875a8d2ca585969d9917e435d2f9","cipherparams":{"iv":"a59ea0ab8b7262277740d7e39bc42fa1"},"kdf":"scrypt","kdfparams":{"r":8,"p":6,"n":4096,"dklen":32,"salt":"81d94592b42383370f3b8a1e742e29e67fa61b592f9544505c251a6f84652b27"},"mac":"2228e7c58f402347364e09dd78ae2da0427762b9f9133782f6c8afa5976728ff","cipher":"aes-128-ctr"},"address":"0x2e95E3ce0a54951eB9A99152A6d5827872dFB4FD"}
"""
        decoder.decode("0x5eBb663FD101b46dBBe6465E72Ed4b2918492061")
        decoder.decode("c3ab73eb6b0e414f0d8949bd76cb58ab8fd5d348dbb24522bdac5da74b885bac")
        decoder.decode(keystore)
        decoder.decode("a")
        decoder.decode("")
    }
    
    func testAnalysisHelper(){
        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.begin, attributes: nil)
        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.end, attributes: nil)
        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.begin, attributes: nil)
        AnalysisHelper.handleEvent(id: "test", operation: EventOperation.cancel, attributes: nil)
    }
}
    
