//
//  String+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import Localize_Swift

let dateFormatter = DateFormatter()
let dateFormatter_greenwich = DateFormatter()

extension String {
    var vonToLATString: String? {
        guard let von = BigUInt(self) else { return nil }
        let valueLAT = von.divide(by: ETHToWeiMultiplier, round: 8)
        return valueLAT.displayForMicrometerLevel(maxRound: 8)
    }

    var LATToVon: BigUInt {
        let lat = BigUInt.safeInit(str: self)
        return lat.multiplied(by: BigUInt(ETHToWeiMultiplier)!)
    }

    var vonToLAT: BigUInt {
        guard let von = BigUInt(self) else { return BigUInt.zero }
        return BigUInt.safeInit(str: von.divide(by: ETHToWeiMultiplier, round: 8))
    }

    var displayFeeString: String {
        return Localized("VoteConfirm_fee_colon") + self.ATPSuffix()
    }
}

extension String {

    func is40ByteAddress() -> Bool {
        let regex = "(0x)?[A-Fa-f0-9]{40}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }

    func is128BytePrivateKey() -> Bool {
        let regex = "(0x)?[A-Fa-f0-9]{64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }

    func isKeyStoreString() -> Bool {
        return self.contains("ciphertext") && self.contains("crypto") && self.contains("address")
    }

    func isHexString() -> Bool {
        let regex = "(0x)?[A-Fa-f0-9]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }

    func ishexStringEqual(other: String?) -> Bool {
        if other == nil || other?.length == 0 {
            return self == other
        }
        var newString = self
        if newString.hasPrefix("0x") {
            newString = newString.replacingOccurrences(of: "0x", with: "")
        }
        var newOther = other
        if (newOther?.hasPrefix("0x"))! {
            newOther = newOther!.replacingOccurrences(of: "0x", with: "")
        }
        return newString.lowercased() == newOther?.lowercased()
    }

    func isValidInputAmoutWith8DecimalPlaceAndNonZero() -> Bool {
        let regex = "^(([1-9]{1}\\d*)|(0{1}))(.{1}\\d{0,8}){0,1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)

        if isValid && Float(self) != nil && Float(self) != 0.0 {
            return true
        }

        return false
    }

    func isPureFloat() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }

    func ispureUint() -> Bool {
        let regex = "([1-9]{1}\\d*)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }

    func reachMaxVoteTicketsNumber(remained: UInt64) -> Bool {
        if !self.ispureUint() {
//            assert(false, "invlid format string")
            return true
        }
        if UInt64(self)! > remained {
            return true
        }
        return false
    }

    func isValidInputAmoutWith8DecimalPlace() -> Bool {
        let regex = "^(([1-9]{1}\\d*)|(0{1}))(.{1}\\d{0,8}){0,1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: self)
        return isValid
    }

    func isValidAddress() -> Bool {
        return self.is40ByteAddress()

        //0x5eBb663FD101b46dBBe6465E72Ed4b291849111 -> true (wrong logic)
        //0x5eBb663FD101b46dBBe6465E72Ed4b2918491111 -> true
//        guard self.isHexString() else {
//            return false
//        }
//        return drop0x().hexToBytes().count == 20
    }

    func isValidPrivateKey() -> Bool {
        guard self.isHexString() else {
            return false
        }
        return drop0x().hexToBytes().count == 32
    }

    func trim0x() -> String {
        if self == "0x"{
            return ""
        }
        if self.hasPrefix("0x") {
            return self.substr(2, self.count - 2)!
        }
        return self
    }

    func isValidKeystore() -> Bool {

        do {
            _ = try JSONDecoder().decode(Keystore.self, from: data(using: .utf8)!)
            return true
        } catch {
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
    func balanceFixToDisplay(maxRound : Int) -> String {
//        if  ((self.range(of: ".")?.lowerBound) != nil) {
//
//            var key = "."
//            for _ in 0...(maxRound-1) {
//                key.append("0")
//            }
//
//            let components = self.components(separatedBy: ".")
//            if components.count > 1{
//                if self.range(of: key)?.lowerBound != nil {
//                    return components[0] + ".00"
//                }else{
//                    return self.trimDecimalTailingZero()
//                }
//            }
//
//            return self
//        }

        return self.displayForMicrometerLevel(maxRound: maxRound)
    }

    func displayForMicrometerLevel(maxRound : Int) -> String {
        guard self.isValidInputAmoutWith8DecimalPlace() else {
            return self
        }

        if self.count != 0 {
            var integerPart:String?
            var decimalPart = String()

            // 先将传入的参数整体赋值给整数部分
            integerPart = self
            // 然后再判断是否含有小数点(分割出整数和小数部分)
            if self.contains(".") {
                let segmentationArray = self.components(separatedBy: ".")
                integerPart = segmentationArray.first
                decimalPart = segmentationArray.last!
            }

            /**
             创建临时存放余数的可变数组
             */
            let remainderMutableArray = NSMutableArray.init(capacity: 0)

            /**
             对传入参数的整数部分进行千分拆分
             */

            var tempValue = integerPart!
            var start = tempValue.index(tempValue.endIndex, offsetBy: -min(3, tempValue.count))
            var end = tempValue.index(tempValue.endIndex, offsetBy: 0)

            while tempValue.count > 0 {
                let remainderStr = String(tempValue[start..<end])
                remainderMutableArray.insert(remainderStr, at: 0)
                tempValue = String(tempValue[..<start])
                end = tempValue.index(start, offsetBy: 0)
                start = tempValue.index(start, offsetBy: -min(3, tempValue.count))
            }

            // 创建一个临时存储余数数组里的对象拼接起来的对象
            var tempString = String()

            if decimalPart.count > 0 {
                var nonZeroIndex = -1
                for i in (0...decimalPart.length - 1).reversed() {
                    if decimalPart.substr(i, 1) != "0"{
                        nonZeroIndex = i
                        break
                    }
                }

                decimalPart = decimalPart.substr(0, nonZeroIndex + 1)!
            }

            if decimalPart.count > maxRound {
                decimalPart = String(decimalPart.prefix(maxRound))
            } else if decimalPart.count < 2 {
                decimalPart = String(format: "%d", Int(decimalPart) ?? 0)
                if decimalPart.count < 2 {
                    decimalPart.append("0")
                } else {
                    decimalPart.append("00")
                }
            }

            /**
             获取余数组里的余数
             */
            for i in 0..<remainderMutableArray.count {
                // 判断余数数组是否遍历到最后一位
                let param = (i != remainderMutableArray.count-1 ? "," : ".")
                tempString += String(format: "%@%@", remainderMutableArray[i] as! String, param)
            }
            //  清楚一些数据
            integerPart = nil
            remainderMutableArray.removeAllObjects()
            // 最后返回整数和小数的合并
            return tempString as String + decimalPart
        }

        return self
    }

    func trimDecimalTailingZero() -> String {

        if ((self.range(of: ".")?.lowerBound) != nil) {
            var nonZeroIndex = -1
            for i in (0...self.length - 1).reversed() {
                if self.substr(i, 1) != "0"{
                    nonZeroIndex = i
                    break
                }
            }

            if nonZeroIndex != -1 {
                return self.substr(0, nonZeroIndex + 1)!
            }
        }
        return self
    }

    func trimNumberLeadingZero() -> String {
        let c = self.components(separatedBy: ".")
        if c.count == 2 && c[0].length > 0 {
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
        return self + " LAT"
    }

    func nodeIdForDisplayShort() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self.substr(0, 2)! + "...." + self.substr(124, 4)!
        }
        return self.substr(0, 4)! + "...." + self.substr(126, 4)!
    }

    func nodeIdForDisplay() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self.substr(0, 8)! + "......" + self.substr(118, 10)!
        }
        return self.substr(0, 10)! + "......" + self.substr(120, 10)!
    }

    func addressForDisplayShort() -> String {
        guard self.is40ByteAddress() else {
            return self
        }
        if !self.hasPrefix("0x") {
            return "0x" + self.substr(0, 2)! + "...." + self.substr(36, 4)!
        }
        return self.substr(0, 4)! + "...." + self.substr(38, 4)!
    }

    func addressForDisplay() -> String {
        guard self.is40ByteAddress() else {
            return self
        }
        if !self.hasPrefix("0x") {
            return "0x" + self.substr(0, 8)! + "......" + self.substr(30, 10)!
        }
        return self.substr(0, 10)! + "......" + self.substr(32, 10)!
    }

    func EnergonSuffix() -> String {
        return self + " LAT"
    }

    func walletAddressLastCharacterAvatar() -> String {
        if self.length == 0 {
            return "walletAvatar_1"
        }

        let remain = (self.unicodeScalars.last?.value ?? 0) % 15
        return "walletAvatar_\(remain + 1)"
    }

    func GreenwichTime() -> Date {

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }

    func GreenwichTimeStamp() -> UInt64 {

        dateFormatter_greenwich.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter_greenwich.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter_greenwich.date(from: self)
        return UInt64((date?.timeIntervalSince1970)!)
    }

    static func walletRandomAvatar() -> String {
        return "walletAvatar_\(arc4random_uniform(14) + 1)"
    }

    func inputAmountForMagnitude() -> String? {
        if !isValidInputAmoutWith8DecimalPlace() && self.count == 0 {
            return nil
        }

        var integerPart: String?
        integerPart = self
        if self.contains(".") {
            let segmentationArray = self.components(separatedBy: ".")
            integerPart = segmentationArray.first
        }

        guard let inte = integerPart, inte.count > 2 else {
            return nil
        }

        if integerPart?.count == 3 {
            return Localized("input_amount_hundred")
        } else if integerPart?.count == 4 {
            return Localized("input_amount_thousand")
        } else if integerPart?.count == 5 {
            return Localized("input_amount_ten_thousand")
        } else if integerPart?.count == 6 {
            return Localized("input_amount_hundred_thousand")
        } else if integerPart?.count == 7 {
            return Localized("input_amount_million")
        } else if integerPart?.count == 8 {
            return Localized("input_amount_ten_million")
        } else if integerPart?.count == 9 {
            return Localized("input_amount_hundred_million")
        } else if integerPart?.count == 10 {
            return Localized("input_amount_billion")
        } else if integerPart?.count == 11 {
            return Localized("input_amount_ten_billion")
        } else if integerPart?.count == 12 {
            return Localized("input_amount_hundred_billion")
        } else {
            return Localized("input_amount_trillion")
        }
    }

    func addressDisplayInLocal() -> String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == self.lowercased() }.first
        if let wallet = localWallet {
            return wallet.name + "(\(self.addressForDisplayShort()))"
        } else {
            let addressInfo = AddressBookService.service.getAll().filter { $0.walletAddress?.lowercased() == self.lowercased() }.first
            guard let addressName = addressInfo?.walletName else { return self }
            return addressName + "(\(self.addressForDisplayShort()))"
        }
    }

}
