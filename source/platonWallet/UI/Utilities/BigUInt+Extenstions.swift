//
//  BigUInt+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import platonWeb3

extension BigUInt {

    static func safeInit(str: String?) -> BigUInt {
        guard str != nil else {
            return BigUInt("0")
        }

        var conditionVar = str
        for _ in 0...100 {
            if let index = conditionVar!.lastIndex(of: ".") {
                conditionVar = String(conditionVar![..<index])
            } else {
                return BigUInt(conditionVar ?? "0") ?? BigUInt("0")
            }
        }

        return BigUInt("0")
    }

    static func mutiply(a : String, by : String) -> BigUInt? {

        if !a.isPureFloat() {
            return nil
        }

        let regex = "10*" //
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: by)
        if !isValid {
            assert(false, "by param is invalid")
            return nil
        }

        var result : String = a

        if ((a.range(of: ".")?.lowerBound) != nil) {
            var nonZeroIndex = -1
            for i in (0...(a.length - 1)).reversed() {
                if a.substr(i, 1) != "0"{
                    nonZeroIndex = i
                    //NSLog("i:\(i)  \(ret?.substr(i, 1))")
                    break
                }
            }

            if nonZeroIndex != -1 {
                result = a.substr(0, nonZeroIndex + 1)!
                let seps = result.components(separatedBy: ".")
                if (seps.count) > 1 {
                    let suf = seps[1]
                    let diff = (by.length - 1) - suf.length
                    assert(diff >= 0, "a*by have numbers after a decimal place")
                    result = result.replacingOccurrences(of: ".", with: "")

                    if diff > 0 {
                        for _ in 0...(diff - 1) {
                            result.append("0")
                        }
                    }

                }
            }
        } else {
            let br = BigUInt(result)?.multiplied(by: BigUInt(by)!)
            result = String(br!)

        }

        return BigUInt(result)
    }

    func floorToDecimal(round : Int) -> BigUInt {
        if round <= 1 {
            return self
        }
        var mutiplier = "1"
        for _ in 0...(round - 1) {
            mutiplier.append("0")
        }

        let (q,_) = (self.quotientAndRemainder(dividingBy: BigUInt(mutiplier)!))
        let result = BigUInt.mutiply(a: String(q), by: mutiplier)
        return result!
    }

    func ceilToDecimal(round : Int) -> BigUInt {
        if round <= 1 {
            return self
        }
        var mutiplier = "1"
        for _ in 0...(round - 1) {
            mutiplier.append("0")
        }
        let (q,r) = (self.quotientAndRemainder(dividingBy: BigUInt(mutiplier)!))
        let result = BigUInt.mutiply(a: String(q), by: mutiplier)
        if String(r) != "0"{
            var ceil = BigUInt(String(result!))
            ceil?.multiplyAndAdd(BigUInt(mutiplier)!, 1)
            return ceil!
        }
        return result!
    }

    func divide(by: String, round : Int) -> String {

        let regex = "10*" //
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: by)
        if !isValid {
            assert(false, "by param is invalid")
            return ""
        }

        let (q, r) = self.quotientAndRemainder(dividingBy: BigUInt(by)!)
        var ret : String?
        let remains = String(r)

        if remains != "0"{
            if round == 0 {
                return String(q)
            }
            let left = by.length - remains.length - 1
            var appends : String? = "."
            if left > 0 {
                for _ in 0...left - 1 {
                    appends?.append("0")
                }
            }
            ret = String(q) + appends! + String(r)
        } else {
            ret = String(q)
        }

        //NSLog("after divide befor trim suffix zero: \(ret)")

        //trim suffix zero e.g. 1.990000 -> 1.990 when round is 3
        if ((ret?.range(of: ".")?.lowerBound) != nil) {
            var nonZeroIndex = -1
            if let end = ret?.length {
                for i in (0...end - 1).reversed() {
                    if ret?.substr(i, 1) != "0"{
                        nonZeroIndex = i
                        //NSLog("i:\(i)  \(ret?.substr(i, 1))")
                        break
                    }
                }
            }

            if nonZeroIndex != -1 {
                ret = ret?.substr(0, nonZeroIndex + 1)
                let seps = ret?.components(separatedBy: ".")
                if (seps?.count)! > 1 {
                    let suf = seps![1]
                    if (suf.length) - round > 0 {
                        ret = seps![0] + "." + suf.prefix(round)
                        //NSLog("----->after round:\(ret) nonZeroIndex:\(nonZeroIndex)")
                    }

                }
            }
        }

        //NSLog("----->ret:\(ret)")
        return ret!
    }

    static func safeSubStractToUInt64(a : BigUInt,b : BigUInt) -> UInt64 {
        var subtractor = BigUInt(String(a))
        let overflow = subtractor?.subtractReportingOverflow(b, shiftedBy: 0)
        if !overflow! {
            return UInt64(String(subtractor!))!
        }
        return 0
    }

    func overflowWhenSubtract(comparison: BigUInt) -> Bool {

        var subtractor = BigUInt(String(self))
        let overflow = subtractor?.subtractReportingOverflow(comparison, shiftedBy: 0)
        return overflow!
    }

    func fixIntrinsicGasLow() -> BigUInt {
        var fixed = self
        let (q,_) = self.quotientAndRemainder(dividingBy: BigUInt(10))
        fixed.multiplyAndAdd(q, 1)
        return fixed
    }

    func fixIntrinsicGasLowWithDouble() -> BigUInt {
        return self.multiplied(by: BigUInt("4"))
    }

    func gasMutiply(_ times: Int) -> BigUInt {
        return self.multiplied(by: BigUInt(String(times))!)
    }

    func convertToEnergon(round:Int) -> String {
        return self.divide(by: ETHToWeiMultiplier, round: round)
    }

    func convertBalanceDecimalPlaceToZero() -> BigUInt {
        return convertDecimalPlaceToZero(round: 10, isCeil: false)
    }

    func convertLastTenDecimalPlaceToZero() -> BigUInt {
        return convertDecimalPlaceToZero(round: 10, isCeil: true)
    }

    func convertDecimalPlaceToZero(round: Int, isCeil: Bool = true) -> BigUInt {
        let vonValue = self
        let tenPowerValue = BigUInt(10).power(round)
        let tenAddOnePowerValue = BigUInt(10).power(round-1)

        let (quotient1, _) = vonValue.quotientAndRemainder(dividingBy: tenPowerValue)
        let (quotient2, _) = vonValue.quotientAndRemainder(dividingBy: tenAddOnePowerValue)

        guard isCeil == true else {
            return quotient1*tenPowerValue
        }

        let subQuotient = quotient2 - quotient1*BigUInt(10)
        guard subQuotient >= BigUInt(5) else {
            return quotient1*tenPowerValue
        }

        let newQuotient = (quotient1+BigUInt(1))*tenPowerValue
        return newQuotient
    }
}
