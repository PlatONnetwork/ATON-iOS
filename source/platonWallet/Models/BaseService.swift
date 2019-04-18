//
//  BaseService.swift
//  platonWallet
//
//  Created by matrixelement on 7/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import platonWeb3



enum PlatonCommonResult : Error{
    case success
    case fail(Int?,String?)
}

let onMainPerformTimeout = 2.0

let serviceQueue = DispatchQueue(label: "com.service.base", qos: .userInitiated, attributes: .concurrent)

typealias PlatonCommonCompletion = (_ result : PlatonCommonResult, _ obj : AnyObject?) -> ()

class BaseService {
    
    func timeOutCompletionOnMainThread(completion: inout PlatonCommonCompletion?){
        if Thread.current.isMainThread {
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }

    }
    
    func failCompletionOnMainThread(code: Int, errorMsg: String, completion: inout PlatonCommonCompletion?){
        if Thread.current.isMainThread {
            completion?(PlatonCommonResult.fail(code, errorMsg),nil)
            completion = nil
        }else{
            
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(code, errorMsg),nil)
                mc = nil
                semaphore.signal()
            }
            
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }

    }
    
    
    func failWithEmptyResponseCompletionOnMainThread(completion: inout PlatonCommonCompletion?){
        if Thread.current.isMainThread {
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }

    }
    
    func successCompletionOnMain(obj : AnyObject?,completion: inout PlatonCommonCompletion?){
        if Thread.current.isMainThread {
            completion?(PlatonCommonResult.success,obj)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.success,obj)
                mc = nil
                semaphore.signal()
                
            }
            
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            
            completion = nil
        }

    }

    
}
