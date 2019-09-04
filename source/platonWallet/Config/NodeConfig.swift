//
//  NodeConfig.swift
//  platonWallet
//
//  Created by matrixelement on 2/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3

let maxRequestContentLength = 1024 * 128

let MinTransactionConfirmations = 1

let DefaultNodeURL_Alpha_deprecated = "https://syde.platon.network/test"

let DefaultNodeURL_Alpha = "https://test-amigo.platon.network/test"

let DefaultNodeURL_Beta = "https://test-beta.platon.network/test"

let DefaultNodeURL_Alpha_V071 = "http://192.168.9.190:1000/rpc"

let assetQueryTimerInterval = 8

//tiemr query block number
let blockNumberQueryTimerEnable = true

let blockNumberQueryTimerInterval = 8

//polling all joint walelt's transactions
let allJointWalletPollingTxsTimerEnable = true

let allJointWalletPollingTxsTimerInterval = 8

//polling single joint wallet's transactions in ViewController
let jointWalletUpdateTxListTimerEnable = true

let jointWalletUpdateTxListTimerInterval = 10

//monitor the status of the joint wallet’s creation
let jointWalletCreationTimerEnable = true

let JointWalletCreationTimerInterval = 8

//pending transaction polling
let pendingTransactionPollingTimerEnable = true

let pendingTransactionPollingTimerInterval = 8

let DefaultRPCTimeOut = 30.0

let DefaultChainId = "0"
