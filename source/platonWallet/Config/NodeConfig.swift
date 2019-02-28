//
//  NodeConfig.swift
//  platonWallet
//
//  Created by matrixelement on 2/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3_local

let maxRequestContentLength = 1024 * 128

let MinTransactionConfirmations = 1

let DefaultNodeURL = "https://syde.platon.network/test"

//balance query timer
let assetQueryTimerEnable = true

let assetQueryTimerInterval = 3

//tiemr query block number
let blockNumberQueryTimerEnable = true

let blockNumberQueryTimerInterval = 5

//polling all joint walelt's transactions
let allJointWalletPollingTxsTimerEnable = true

let allJointWalletPollingTxsTimerInterval = 5

//polling single joint wallet's transactions in ViewController
let jointWalletUpdateTxListTimerEnable = true

let jointWalletUpdateTxListTimerInterval = 1

//monitor the status of the joint wallet’s creation
let jointWalletCreationTimerEnable = true

let JointWalletCreationTimerInterval = 2

//pending transaction polling
let pendingTransactionPollingTimerEnable = true

let pendingTransactionPollingTimerInterval = 3

let DefaultRPCTimeOut = 30.0

let DefaultChainId = "0"
