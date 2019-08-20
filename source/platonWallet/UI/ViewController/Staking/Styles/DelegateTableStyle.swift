//
//  DelegateTableStyle.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import BigInt

// uitableview 不同cell获取的样式通过枚举获取
enum DelegateTableViewCellStyle {
    case nodeInfo(node: Node)
    case wallets(walletStyle: WalletsCellStyle)
    case walletBalances(balanceStyle: BalancesCellStyle)
    case inputAmount
    case feeUsed(fee: String)
    case singleButton(title: String)
    case doubt(contents: [(title: String, content: String)])
}

// 可展开绑定的样式数据
struct BalancesCellStyle {
    var balances: [(String, String)]
    var selectedIndex: Int = 0
    var isExpand: Bool = false
    
    var cellCount: Int {
        return isExpand ? balances.count + 1 : 1
    }
    
    var currentBalance: (String, String) {
        return balances[selectedIndex]
    }
    
    func balance(for index: Int) -> (String, String) {
        if isExpand {
            return index == 0 ? balances[selectedIndex] : balances[index - 1]
        } else {
            return balances[selectedIndex]
        }
    }
}

// 可展开绑定的样式数据
struct WalletsCellStyle {
    var wallets: [Wallet]
    var selectedIndex: Int = 0
    var isExpand: Bool = false
    
    var cellCount: Int {
        return isExpand ? wallets.count + 1 : 1
    }
    
    var currentWallet: Wallet {
        return wallets[selectedIndex]
    }
    
    func getWallet(for index: Int) -> Wallet {
        if isExpand {
            return index == 0 ? wallets[selectedIndex] : wallets[index - 1]
        } else {
            return wallets[selectedIndex]
        }
    }
}
