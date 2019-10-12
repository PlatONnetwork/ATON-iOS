//
//  AssetPersistenceTests.swift
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

class PersistenceTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func generateRandomBytes() -> Data? {
        
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    func testAddressInfoPersistence(){
        let addr = AddressInfo()
        addr.walletAddress = self.generateRandomBytes()?.toHexString()
        addr.nodeURLStr = "https:\\aton.main.platon.network"
        AddressInfoPersistence.add(addrInfo: addr)
        AddressInfoPersistence.getAll()
        AddressInfoPersistence.replaceInto(addrInfo: addr)
        AddressInfoPersistence.delete(addrInfo: addr)
        

    }
    
    func testBalance(){
        let b = Balance(addr: "0x5eBb663FD101b46dBBe6465E72Ed4b2918492061", free: "123", lock: "234")
        print("\(b.lockedBalanceValue)")
    }
    
    func testAssetPersistence(){
        
        AssetPersistence.getAll()
        
        let addressInfo = AddressInfo()
        addressInfo.walletName = "testwalletName"
        addressInfo.nodeURLStr = "https:\\aton.main.platon.network"
        addressInfo.walletAddress = "0x5eBb663FD101b46dBBe6465E72Ed4b2918492061"
        AssetPersistence.add(addrInfo: addressInfo)
        
        AssetPersistence.getAll()
        
    }
    
    func testWallletPersistence(){
       
    }
}
