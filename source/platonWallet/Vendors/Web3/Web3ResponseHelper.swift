//
//  Web3ResponseHelper.swift
//  platonWallet
//
//  Created by matrixelement on 7/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

//extension Web3Response{
//    public func getError() -> Web3Response<Result>.Error?{
//        let err = self.error as? Web3Response<Result>.Error
//        if err == nil{
//            let err = self.error as? RPCResponse<Result>.Error
//            return err
//        }
//        return err
//    }
//}

extension Web3Response{
    public func getErrorLocalizedDescription() -> String{
        
        if let err = self.error as? Web3Response<Result>.Error{
            return err.getLocalizedDescription()
        }else if let err = self.error as? RPCResponse<Result>.Error{
            return err.getLocalizedDescription()
        }
        return ""
    }
}

extension RPCResponse.Error{
    public func getLocalizedDescription() -> String{
        let localized = Localized(self.message)
        if localized.length == 0{
            return self.message
        }
        return localized
    }
}

extension Web3Response.Error{
    public func getLocalizedDescription() -> String{
        switch self {
        case .emptyResponse:
            return Localized("RPC_Response_empty")
        case .requestFailed(_):
            return Localized("RPC_Response_requestFailed")
        case .connectionFailed(_):
            return Localized("RPC_Response_connectionFailed")
        case .serverError(_):
            return Localized("RPC_Response_serverError")
        case .decodingError(_):
            return Localized("RPC_Response_decodingError")
        }
    }
}
