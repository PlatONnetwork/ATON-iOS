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

        for wallet in WalletService.sharedInstance.wallets {
            WalletService.sharedInstance.deleteWallet(wallet)
        }
    }

    // 创建普通钱包
    func testCreateNormalWallet() {
        let expectaion = self.expectation(description: "testCreateWallet")
        WalletService.sharedInstance.createWallet(name: "wallet-create-normal-070", password: "123456", physicalType: .normal) { (wallet, error) in
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }

        wait(for: [expectaion], timeout: 30.0)
    }
    
    // 创建HD钱包
    func testCreateAndDeleteHDWallet() {
        let expectaion = self.expectation(description: "testCreateHDWallet")
        WalletService.sharedInstance.createWallet(name: "wallet-create-hd-071", password: "123456", physicalType: .hd) { (wallet, error) in
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 30.0)
    }
    
    func testDeleteWallet() {
        let expectaion = self.expectation(description: "testDeleteWallet")
        if let wallet = WalletService.sharedInstance.wallets.last {
            if wallet.isHD == false {
                // 普通钱包
                WalletService.sharedInstance.deleteWallet(wallet) {
                    expectaion.fulfill()
                }
            } else if wallet.subWallets.count == 0 {
                // 没有子钱包的hd钱包，删除的对象可能是子钱包或母钱包
                WalletService.sharedInstance.deleteWallet(wallet) {
                    expectaion.fulfill()
                }
            }
        }
        wait(for: [expectaion], timeout: 30.0)
    }
    
    func testWalletRename() {
        let expectaion = self.expectation(description: "testRenameWallet")
        if let wallet = WalletService.sharedInstance.wallets.last {
            WalletService.sharedInstance.updateWalletName(wallet, name: "MyNewName")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 30.0)
    }
    
    func testGenerateMnemonic() {
        let result = try? WalletUtil.generateMnemonic(strength: 128)
        let arr = result?.split(separator: " ")
        XCTAssertTrue(arr?.count == 12, "mnemonic count should be 12")
    }
    
    func testHdNodeFromSeed() {
        let mnemonic = "focus coconut spray develop coyote puppy dress enjoy bounce fatigue inner grace"
        XCTAssertTrue(WalletUtil.isValidMnemonic(mnemonic), "the result should be is valid mnemonic")
        
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
        XCTAssertTrue(WalletUtil.isValidPrivateKeyData(privateKey!), "privatekey data should be valid")
    }
    
    func testPublicKeyFromPrivateKey() {
        let originAddress = "0xB6bE423856420a33fc848Bf287e3BFbCb6d6283a"
        XCTAssertTrue(WalletUtil.isValidAddress(originAddress), "the address should be valid")
        
        let privateKey = "627b3df47efbe6918469af7e55c35ef746ad367d3fded6410e45438bf418e37d"
        
        XCTAssertTrue(WalletUtil.isValidPrivateKeyHexStr(privateKey), "the privatekey should be valid")
        
        let privateKeyData = Data(bytes: privateKey.hexToBytes())
        let publicKeyData = WalletUtil.publicKeyFromPrivateKey(privateKeyData)
        XCTAssertNotNil(publicKeyData, "publicKeyData string should not be nil")
        
        let publicKeyString = publicKeyData.toHexString()
        XCTAssertTrue(WalletUtil.isValidPublicKeyHexStr(publicKeyString), "the publickey shoud be valid")
        
        let address = try? WalletUtil.addressFromPublicKey(publicKeyData, eip55: true)
        XCTAssertNotNil(address, "address string should not be nil")
        XCTAssertTrue(originAddress == address, "generate address should be equal")
    }
    
    func testObserverWalletName() {
        let wallets = WallletPersistence.sharedInstance.getAll(detached: true)
        let observeredWallet = wallets.filter { $0.type == .observed }.last
        
        let newName = WalletUtil.generateNewObservedWalletName()
        
        let newIndexStr = String(newName.suffix(from: newName.index(newName.startIndex, offsetBy: 6)))
        let newIndex = Int(newIndexStr)
        
        if let walletName = observeredWallet?.name {
            let lastIndexStr = String(walletName.suffix(from: walletName.index(walletName.startIndex, offsetBy: 6)))
            let lastIndex = Int(lastIndexStr)
            
            XCTAssertTrue(((newIndex ?? 0) - (lastIndex ?? 0)) == 1, "new observer wallet name is not valid")
        } else {
            XCTAssertTrue(newIndex == 1, "new observer wallet name is not valid")
        }
    }
    
    func testKeystoreInitWithPassword() {
        let keystore = try? Keystore(password: "", walletPhysicalType: .normal) // Keystore(password: "")
        XCTAssertNotNil(keystore, "keystore should be not nil")
    }
    
    func testKeystoreInitWithMnemonic() {
        let mnemonic = "focus coconut spray develop coyote puppy dress enjoy bounce fatigue inner grace"
        let keystore = try? Keystore(password: "", mnemonic: mnemonic)
        XCTAssertNotNil(keystore, "keystore should be not nil")
    }
    
    func testKeystoreDecrypt() {
        let mnemonic = "talk offer depend curtain crisp gym cricket excuse jump mimic ask girl"
        let oriPrivatekey = "56c97f05abd5ddcee5dd35ba69bc735e5159abd744e8bf884672e773022a340b"
        let keystore = try? Keystore(password: "", mnemonic: mnemonic)
        XCTAssertNotNil(keystore, "keystore should be not nil")
        
        let privateKeyData = try? keystore!.decrypt(password: "")
        let privateKey = privateKeyData?.toHexString()
        XCTAssertTrue(oriPrivatekey == privateKey, "privatekey value should be equal")
    }
    
    func testCreateObserveWallet() {
        let expectaion = self.expectation(description: "testCreateObserveWallet")
        
        let address = "0xB6bE423856420a33fc848Bf287e3BFbCb6d6283a"
        WalletService.sharedInstance.import(address: address) { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            if let wal = wallet {
                XCTAssertEqual(wal.address, address, "wallet address should be equal")
                WalletService.sharedInstance.deleteWallet(wal)
            }
            expectaion.fulfill()
        }
        
        wait(for: [expectaion], timeout: 5.0)
    }
    
    func testImportKeystore() {
        let expectaion = self.expectation(description: "testImportKeystore")
        let keystore = "{\"version\":3,\"id\":\"2c973aae-cda8-481e-a23c-8d204b0b7917\",\"crypto\":{\"ciphertext\":\"d119415f4c837929c50c68c54d3df842699f3deb75357b70ba2084fdc1969e5e\",\"cipherparams\":{\"iv\":\"0a7c350e485fcdbae950017f981d0d17\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"r\":8,\"p\":6,\"n\":4096,\"dklen\":32,\"salt\":\"59e8392b59b6f2403e692e370d1b2a15594f8f0cb48ee05c96a66ee654e7d905\"},\"mac\":\"812539f92eb932c91d282c562104fe202a745b536fefb6b6169859ef0ce51e25\",\"cipher\":\"aes-128-ctr\"},\"mnemonic\":\"98e5eec0311c87a0c2861f66e87cf5deb17f2865436e13995a90340fae0825813b898bef0162187d76923cf14873aa4d64d1e63f0c6a59884686ffba42e027b4cf9141881de936b1024d57\",\"address\":\"0x8bd932685A4E7eD7c9AB3daf8E33E85fb975e5Fb\"}"
        
        WalletService.sharedInstance.import(keystore: keystore, walletName: "wallet-import-keystore", password: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 10.0)

    }
    
    func testImportPrivateKey() {
        let expectaion = self.expectation(description: "testImportPrivateKey")
        let privateKey = "380d267444b63e4d79a6ea4c266e872ed21ef6470fae0a2c8db01d252b5e0ecc"

        WalletService.sharedInstance.import(privateKey: privateKey, walletName: "wallet-import-privatekey", walletPassword: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 5.0)

    }
    
    
    func testImportMnemonic() {
        let expectaion = self.expectation(description: "testImportMnemonic")
        let mnemonic = "magic human crystal broken busy upper jump broccoli fine raccoon chef radar"

        WalletService.sharedInstance.import(mnemonic: mnemonic, walletName: "wallet-import-mnemonic", walletPassword: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 5.0)
        

    }
    
    func testExportKeyStore() {
        let expectaion = self.expectation(description: "testExportKeyStore")
        let keystore = "{\"version\":3,\"id\":\"b5018de2-ace5-4d4a-a93e-300562263d3c\",\"crypto\":{\"ciphertext\":\"f0c7d751ebcc9a08cee73c1f374208b45856c388e6e90bfd3bfbdc89941253f3\",\"cipherparams\":{\"iv\":\"3dbffae8974865298169d1ae4c57c8ad\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"r\":8,\"p\":6,\"n\":4096,\"dklen\":32,\"salt\":\"b48949c48983f9bc8cf020fcf4fd5a50281fdfee922ff8bbfabb6673d0f58426\"},\"mac\":\"1f1fd59fbffc53ae02411443f6e92bae1fdedeef2b5b8f03e8ba118755a8348f\",\"cipher\":\"aes-128-ctr\"},\"address\":\"0x493301712671Ada506ba6Ca7891F436D29185821\"}"

        WalletService.sharedInstance.import(keystore: keystore, walletName: "wallet-export-keystore", password: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 15.0)
    }
    
    func testExportPrivateKey() {
        let expectaion = self.expectation(description: "testExportPrivateKey")
        let privateKey = "62829e40b6d018693a6a850be3260bb3fda76fa232a75616f65037c9b38b4796"

        WalletService.sharedInstance.import(privateKey: privateKey, walletName: "wallet-export-privatekey", walletPassword: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 5.0)
        

    }
    
    func testExportMnemonic() {
        let expectaion = self.expectation(description: "testExportMnemonic")
        let mnemonic = "magic human crystal broken busy upper jump broccoli fine raccoon chef radar"

        WalletService.sharedInstance.import(mnemonic: mnemonic, walletName: "wallet-export-mnemonic", walletPassword: "123456") { (wallet, error) in
            guard let err = error, err != .walletAlreadyExists else {
                expectaion.fulfill()
                return
            }
            XCTAssertNotNil(wallet, "create wallet shoulde be not nil")
            expectaion.fulfill()
        }
        wait(for: [expectaion], timeout: 15.0)
    }
}
