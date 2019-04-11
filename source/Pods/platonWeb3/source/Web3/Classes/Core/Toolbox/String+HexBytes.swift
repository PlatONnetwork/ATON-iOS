//
//  String+HexBytes.swift
//  Web3
//
//  Created by Koray Koska on 10.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

extension String {
    
    /// Convert a hex string "0xFF" or "FF" to Bytes
    func hexBytes() throws -> Bytes {
        var string = self
        // Check if we have a complete byte
        guard !string.isEmpty else {
            return Bytes()
        }
        
        if string.count >= 2 {
            let pre = string.startIndex
            let post = string.index(string.startIndex, offsetBy: 2)
            if String(string[pre..<post]) == "0x" {
                // Remove prefix
                string = String(string[post...])
            }
        }
        
        //normalize string, since hex strings can omit leading 0
        string = string.count % 2 == 0 ? string : "0" + string

        return try string.rawHex()
    }

    func quantityHexBytes() throws -> Bytes {
        var bytes = Bytes()

        var string = self

        guard string.count >= 2 else {
            if string == "0" {
                return bytes
            }

            throw StringHexBytesError.hexStringMalformed
        }

        let pre = string.startIndex
        let post = string.index(string.startIndex, offsetBy: 2)
        if String(string[pre..<post]) == "0x" {
            // Remove prefix
            string = String(string[post...])
        }

        if string.count % 2 != 0 {
            let newStart = string.index(after: string.startIndex)

            guard let byte = Byte(String(string[string.startIndex]), radix: 16) else {
                throw StringHexBytesError.hexStringMalformed
            }
            bytes.append(byte)

            // Remove already appended byte so we have an even number of characters for the next step
            string = String(string[newStart...])
        }

        try bytes.append(contentsOf: string.rawHex())

        return bytes
    }

    private func rawHex() throws -> Bytes {
        return try self.optimizeRawHex()
        /*
        var bytes = Bytes()
        for i in stride(from: 0, to: self.count, by: 2) {
            let start = self.index(self.startIndex, offsetBy: i)
            let end = self.index(self.startIndex, offsetBy: i + 2)

            guard let byte = Byte(String(self[start..<end]), radix: 16) else {
                throw StringHexBytesError.hexStringMalformed
            }
            bytes.append(byte)
        }

        return bytes
         */
    }
    
    func optimizeRawHex() throws -> [UInt8] {
        let length = self.count
        if length & 1 != 0 {
            throw StringHexBytesError.hexStringMalformed
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = self.startIndex
        for _ in 0..<length/2 {
            let nextIndex = self.index(index, offsetBy: 2)
            if let b = UInt8(self[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                throw StringHexBytesError.hexStringMalformed
            }
            index = nextIndex
        }
        return bytes
    }
}

public enum StringHexBytesError: Error {

    case hexStringMalformed
}
