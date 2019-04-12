//
//  String+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt


let dateFormatter = DateFormatter()

extension String{
    
    func is40ByteAddress() -> Bool{
        let regex = "(0x)?[A-Fa-f0-9]{40}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
    
    func is128BytePrivateKey() -> Bool{
        let regex = "(0x)?[A-Fa-f0-9]{64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
    
    func isKeyStoreString() -> Bool{
        return self.contains("ciphertext") && self.contains("crypto") && self.contains("address")
    }
    
    func isHexString() -> Bool{
        let regex = "(0x)?[A-Fa-f0-9]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
     
    func ishexStringEqual(other: String?) -> Bool{
        if other == nil || other?.length == 0{
            return self == other
        }
        var newString = self
        if newString.hasPrefix("0x"){
            newString = newString.replacingOccurrences(of: "0x", with: "")
        }
        var newOther = other
        if (newOther?.hasPrefix("0x"))!{
            newOther = newOther!.replacingOccurrences(of: "0x", with: "")
        }
        return newString.lowercased() == newOther?.lowercased()
    }
    
    func isValidInputAmoutWith8DecimalPlaceAndNonZero() -> Bool{
        let regex = "^(([1-9]{1}\\d*)|(0{1}))(.{1}\\d{0,8}){0,1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        
        if isValid && Float(self) != nil && Float(self) != 0.0{
            return true
        }
        
        return false
    }
    
    func ispureUint() -> Bool{
        let regex = "([1-9]{1}\\d*)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
    
    func reachMaxVoteTicketsNumber(remained: UInt64) -> Bool{
        if !self.ispureUint(){
//            assert(false, "invlid format string")
            return true
        }
        if UInt64(self)! > remained{
            return true
        }
        return false
    }
    
    func isValidInputAmoutWith8DecimalPlace() -> Bool{
        let regex = "^(([1-9]{1}\\d*)|(0{1}))(.{1}\\d{0,8}){0,1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
    
    func isValidAddress() -> Bool {
        return self.is40ByteAddress()
        
        //0x5eBb663FD101b46dBBe6465E72Ed4b291849111 -> true (wrong logic)
        //0x5eBb663FD101b46dBBe6465E72Ed4b2918491111 -> true
        guard self.isHexString() else {
            return false
        }
        return drop0x().hexToBytes().count == 20
    }
    
    func isValidPrivateKey() -> Bool {
        guard self.isHexString() else {
            return false
        }
        return drop0x().hexToBytes().count == 32
    }
    
    func trim0x() -> String{
        if self == "0x"{
            return ""
        }
        if self.hasPrefix("0x"){
            return self.substr(2, self.count - 2)!
        }
        return self
    }
    
    func isValidKeystore() -> Bool {
        
        do {
            let _ = try JSONDecoder().decode(Keystore.self, from: data(using: .utf8)!)
            return true
        } catch  {
            return false
        } 
    }
    
    func drop0x() -> String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }
    
    func add0x() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    /// fix number to display
    ///
    /// - Parameter maxRound: max round
    /// - Returns:
    /*
     e.g.
     
     self = "0.000000091" maxRound = 8 will return "0.00000009"
     self = "0.000000090000" maxRound = 8 will return "0.00000009"
     self = "10" maxRound = 4 will return "10.00"
     self = "10.0" maxRound = 4 will return "10.00"
     self = "10.12345" maxRound = 4 will return "10.1234"
     
     */
    func balanceFixToDisplay(maxRound : Int) -> String{
        if  ((self.range(of: ".")?.lowerBound) != nil) {
            
            var key = "."
            for _ in 0...(maxRound-1) {
                key.append("0")
            }
            
            let components = self.components(separatedBy: ".")
            if components.count > 1{
                if self.range(of: key)?.lowerBound != nil {
                    return components[0] + ".00"
                }else{
                    return self.trimDecimalTailingZero()
                }
            }
            
            return self
        }
        return self + ".00"
    }
    
    func trimDecimalTailingZero() -> String{
        
        if ((self.range(of: ".")?.lowerBound) != nil) {
            var nonZeroIndex = -1
            for i in (0...self.length - 1).reversed() {
                if self.substr(i, 1) != "0"{
                    nonZeroIndex = i
                    break
                }
            }
            
            if nonZeroIndex != -1{
                return self.substr(0, nonZeroIndex + 1)!
            }
        }
        return self
    }
    
    func trimNumberLeadingZero() -> String {
        let c = self.components(separatedBy: ".")
        if c.count == 2 && c[0].length > 0{
            let firstCom = BigUInt(c[0])
            return String(firstCom!) + "." + c[1]
        }
        return self
    }
    
    func validFloatNumber() -> Bool {
        if self == "" || self == "."{
            return true
        }
        let regex = "[0-9]"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }
    
    
    func ATPSuffix() -> String {
        return self + " Energon"
    }
    
    func addressForDisplay() -> String{
        guard self.is40ByteAddress() else {
            return self
        }
        if !self.hasPrefix("0x"){
            return "0x" + self.substr(0, 8)! + "......" + self.substr(30, 10)! 
        }
        return self.substr(0, 10)! + "......" + self.substr(32, 10)!
    }
    
    func EnergonSuffix() -> String {
        return self + " Energon"
    }
    
    func walletAddressLastCharacterAvatar() -> String{
        if self.length == 0{
            return "walletAvatar_1"
        }
    
        let remain = (self.unicodeScalars.last?.value ?? 0) % 15
        return "walletAvatar_\(remain + 1)"
    }
    
    func GreenwichTime() -> Date{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
    
    func GreenwichTimeStamp() -> UInt64{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: self)
        return UInt64((date?.timeIntervalSince1970)!)
    }
    
    static func walletRandomAvatar() -> String{
        return "walletAvatar_\(arc4random_uniform(14) + 1)"
    }
}
