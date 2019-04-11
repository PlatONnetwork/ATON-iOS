//
//  SWallet.swift
//  platonWallet
//
//  Created by matrixelement on 14/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import Localize_Swift
import platonWeb3

enum ECreationStatus : Int{
    case deploy_begin = 0
    case deploy_HashGenerated = 25
    case deploy_ReceiptGenerated = 50
    case initWallet_HashGenerated = 75
    case initWallet_ReceiptGenerated = 100
}


class SWallet: Object {
    
    @objc dynamic var uuid: String = NSUUID().uuidString
    
    @objc dynamic var name: String = ""
    
    //owner Address
    @objc dynamic var walletAddress: String = ""
    
    @objc dynamic var contractAddress: String = ""
    
    @objc dynamic var createTime = Date().millisecondsSince1970
    
    @objc dynamic var updateTime = Date().millisecondsSince1970
    
    @objc dynamic var required = 0
    
    //Int 0 ~ 100 must be in {25,50,75,100}
    @objc dynamic var creationStatus = 0
    
    var owners = List<AddressInfo>()
    
    //joint wallet contract deploy hash
    @objc dynamic var deployHash: String = ""
    
    @objc dynamic var initWalletHash: String = ""
    
    @objc dynamic var deployReceptionLooptime = 0
    
    @objc dynamic var initWalletReceptionLooptime = 0
    
    @objc dynamic var userArrangementIndex = -1
    
    override public static func primaryKey() -> String? {
        return "uuid"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["privateKey", "initWalletCall"]
    }
    
    var initWalletCall : EthereumCall?
    
    var privateKey : String? = ""
    
    var isOwner : Bool{
        get{
            for item in owners{
                if (item.walletAddress?.ishexStringEqual(other: walletAddress))!{
                    return true
                }
            }
            return false
        }
    }
    
    //if owner Wallet been delete,return false
    var isWatchAccount : Bool{
        get{
            let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: self.walletAddress)
            if wallet != nil{
                return false
            }
            return true
        }
    }
    
    convenience init(tx: STransaction) {
        self.init()
        self.required = tx.required
        self.contractAddress = tx.contractAddress
        self.walletAddress = tx.ownerWalletAddress
        
        var ownerAddrInfos : [AddressInfo] = []
        var index = 1
        for element in tx.determinedResult{
            let addr = AddressInfo()
            addr.walletAddress = element.walletAddress
            addr.addressType = AddressType_SharedWallet
            addr.walletName = Localized("sharedWalletDefaltMemberName") + String(index)
            index = index + 1
            ownerAddrInfos.append(addr)
        }
        
        self.owners.append(objectsIn: ownerAddrInfos)
    }
    
    //0~100
    var progress: Int{
        get{
            if self.creationStatus == ECreationStatus.deploy_HashGenerated.rawValue{
                var percentage = self.creationStatus + self.deployReceptionLooptime * 2
                if percentage >= 45{
                    percentage = 45
                }
                return percentage
            }else if self.creationStatus == ECreationStatus.deploy_ReceiptGenerated.rawValue{
                return self.creationStatus
            }else if self.creationStatus == ECreationStatus.initWallet_HashGenerated.rawValue{
                var percentage = self.creationStatus + self.initWalletReceptionLooptime * 2
                if percentage >= 95{
                    percentage = 95
                }
                return percentage
            }
            return 100
        }
    }
}


