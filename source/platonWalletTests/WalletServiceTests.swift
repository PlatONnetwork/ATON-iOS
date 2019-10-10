//
//  WalletServiceTests.swift
//  platonWalletTests
//
//  Created by juzix on 2018/10/20.
//  Copyright © 2018 ju. All rights reserved.
//

import XCTest
@testable import platonWallet

class WalletServiceTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGenerateMnemonic() {
        let result = try? WalletUtil.generateMnemonic(strength: 128)
        let arr = result?.split(separator: " ")
        XCTAssertTrue(arr?.count == 12, "mnemonic count should be 12")
    }
    
    func testHdNodeFromSeed() {
        let mnemonic = "focus coconut spray develop coyote puppy dress enjoy bounce fatigue inner grace"
        let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
        XCTAssertNotNil(seed, "seed should not be nil")
        
        let hdNode = WalletUtil.hdNodeFromSeed(seed)
        XCTAssertNotNil(hdNode, "hdNode should not be nil")
    }
    
    func testPrivateKeyFromHDNode() {
        let mnemonic = "focus coconut spray develop coyote puppy dress enjoy bounce fatigue inner grace"
        let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
        var hdNode = WalletUtil.hdNodeFromSeed(seed)
        
        let privateKey = try? WalletUtil.privateKeyFromHDNode(&hdNode, hdPath: HDPATH)
        XCTAssertNotNil(privateKey, "privateKey should not be nil")
        let string = String(data: privateKey!, encoding: .utf8)
        XCTAssertNotNil(string, "privateKey string should not be nil")
        XCTAssertNotNil(string!.count > 0, "privateKey length shoule be > 0")
    }
    
//    func testPublicKeyFromPrivateKey() {
//        let privateKey = "627b3df47efbe6918469af7e55c35ef746ad367d3fded6410e45438bf418e37d"
//        let privateKeyData = privateKey.data(using: .utf8)
//        
//        let publicKeyData = WalletUtil.publicKeyFromPrivateKey(privateKeyData!)
//        XCTAssertNotNil(publicKeyData, "publicKeyData string should not be nil")
//        publicKeyData.
//    }
    
    
    
    func testCreatWallet() {
        let expectaion = self.expectation(description: "testCreatWallet")
        
        WalletService.sharedInstance.createWallet(name: "wallet-create-070", password: "123456", completion: { (wallet, error) in
            expectaion.fulfill()
        })
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
        
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-create-070" })
//        XCTAssertTrue(result != nil, "create wallet should be save to db")
    }
    
    func testImportKeystore() {
        let expectaion = self.expectation(description: "testImportKeystore")
        let keystore = "{\"version\":3,\"id\":\"b5018de2-ace5-4d4a-a93e-300562263d3c\",\"crypto\":{\"ciphertext\":\"f0c7d751ebcc9a08cee73c1f374208b45856c388e6e90bfd3bfbdc89941253f3\",\"cipherparams\":{\"iv\":\"3dbffae8974865298169d1ae4c57c8ad\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"r\":8,\"p\":6,\"n\":4096,\"dklen\":32,\"salt\":\"b48949c48983f9bc8cf020fcf4fd5a50281fdfee922ff8bbfabb6673d0f58426\"},\"mac\":\"1f1fd59fbffc53ae02411443f6e92bae1fdedeef2b5b8f03e8ba118755a8348f\",\"cipher\":\"aes-128-ctr\"},\"address\":\"0x493301712671Ada506ba6Ca7891F436D29185821\"}"
        WalletService.sharedInstance.import(keystore: keystore, walletName: "wallet-import-keystore", password: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-import-keystore" })
//        XCTAssertTrue(result != nil, "import keystore should be save to db")
        
    }
    
    func testImportPrivateKey() {
        let expectaion = self.expectation(description: "testImportPrivateKey")
        let privateKey = "a11859ce23effc663a9460e332ca09bd812acc390497f8dc7542b6938e13f8d7"
        WalletService.sharedInstance.import(privateKey: privateKey, walletName: "wallet-import-privatekey", walletPassword: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-import-privatekey" })
//        XCTAssertTrue(result != nil, "import privatekey should be save to db")
    }
    
    func testImportMnemonic() {
        let expectaion = self.expectation(description: "testImportMnemonic")
        let mnemonic = "magic human crystal broken busy upper jump broccoli fine raccoon chef radar"
        WalletService.sharedInstance.import(mnemonic: mnemonic, walletName: "wallet-import-mnemonic", walletPassword: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
        let wallets = WalletService.sharedInstance.wallets
        let result = wallets.first(where: { $0.name == "wallet-import-mnemonic" })
        XCTAssertTrue(result != nil, "import mnemonic should be save to db")
    }
    
    func testExportKeyStore() {
        let expectaion = self.expectation(description: "testExportKeyStore")
        let keystore = "{\"version\":3,\"id\":\"b5018de2-ace5-4d4a-a93e-300562263d3c\",\"crypto\":{\"ciphertext\":\"f0c7d751ebcc9a08cee73c1f374208b45856c388e6e90bfd3bfbdc89941253f3\",\"cipherparams\":{\"iv\":\"3dbffae8974865298169d1ae4c57c8ad\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"r\":8,\"p\":6,\"n\":4096,\"dklen\":32,\"salt\":\"b48949c48983f9bc8cf020fcf4fd5a50281fdfee922ff8bbfabb6673d0f58426\"},\"mac\":\"1f1fd59fbffc53ae02411443f6e92bae1fdedeef2b5b8f03e8ba118755a8348f\",\"cipher\":\"aes-128-ctr\"},\"address\":\"0x493301712671Ada506ba6Ca7891F436D29185821\"}"
        WalletService.sharedInstance.import(keystore: keystore, walletName: "wallet-import-keystore", password: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-import-keystore" })
////        XCTAssertNotNil(result, "wallet should be not nil")
//        let export = WalletService.sharedInstance.exportKeystore(wallet: result!)
//        XCTAssertEqual(keystore, export.keystore, "keystore should be equal")
    }
    
    func testExportPrivateKey() {
        let expectaion = self.expectation(description: "testExportPrivateKey")
        let privateKey = "a11859ce23effc663a9460e332ca09bd812acc390497f8dc7542b6938e13f8d7"
        WalletService.sharedInstance.import(privateKey: privateKey, walletName: "wallet-import-privatekey", walletPassword: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-import-privatekey" })
////        XCTAssertNotNil(result, "wallet should be not nil")
//        WalletService.sharedInstance.exportPrivateKey(wallet: result!, password: "123456") { (export, _) in
////            XCTAssertEqual(export, privateKey, "privatekey should be equal")
//        }
    }
    
    func testExportMnemonic() {
        let expectaion = self.expectation(description: "testExportMnemonic")
        let mnemonic = "magic human crystal broken busy upper jump broccoli fine raccoon chef radar"
        WalletService.sharedInstance.import(mnemonic: mnemonic, walletName: "wallet-import-mnemonic", walletPassword: "123456") { (_, _) in
            expectaion.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "")
        }
//        let wallets = WalletService.sharedInstance.wallets
//        let result = wallets.first(where: { $0.name == "wallet-import-mnemonic" })
////        XCTAssertNotNil(result, "wallet should be not nil")
    }
    
}
