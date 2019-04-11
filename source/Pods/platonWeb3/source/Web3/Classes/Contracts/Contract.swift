//
//  Contract.swift
//  platonWeb3Demo
//
//  Created by Ned on 10/1/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Localize_Swift

class Contract {
    
    func timeOutCompletionOnMainThread(completion: inout PlatonCommonCompletion?){
        if Thread.current == Thread.main{
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
        if Thread.current == Thread.main{
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
        if Thread.current == Thread.main{
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
        if Thread.current == Thread.main{
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
