//
//  web3+completion.swift
//  platonWallet
//
//  Created by Ned on 8/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

enum PlatonCommonResult : Error{
    case success
    case fail(Int?,String?)
}

typealias ContractDeployCompletion = (_ result : PlatonCommonResult, _ address : String?, _ hash: String?) -> ()

typealias ContractCallCompletion = (_ result : PlatonCommonResult, _ data : AnyObject?) -> ()

typealias ContractSendRawCompletion = (_ result : PlatonCommonResult, _ data : Data?) -> ()

extension Web3.Eth{
    
    func timeOutCompletionOnMainThread(completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
            completion = nil
        }
    }
    
    func failCompletionOnMainThread(code: Int, errorMsg: String,completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(code, errorMsg),nil)
            completion = nil
        }
    }
    
    func failWithEmptyResponseCompletionOnMainThread(completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
            completion = nil
        }
    }
    
    func successCompletionOnMain(obj : AnyObject?,completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.success,obj)
            completion = nil
        }
    }

    
}
