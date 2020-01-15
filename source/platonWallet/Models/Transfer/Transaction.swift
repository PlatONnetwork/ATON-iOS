//
//  Transaction.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import Realm
import RealmSwift
import Localize_Swift

let oneMultiplier = "1"
let ETHToWeiMultiplier = "1000000000000000000"
let GMultiplier = "1000000000"

let THE8powerof10 = "100000000"
let THE9powerof10 = "1000000000"
let THE18powerof10 = "1000000000000000000"

enum TxType: String, Decodable {
    case transfer = "0"
    case contractCreate = "1"
    case contractExecute = "2"
    case otherReceive = "3"
    case otherSend = "4"
    case MPCtransaction = "5"
    case stakingCreate = "1000"
    case stakingEdit = "1001"
    case stakingAdd = "1002"
    case stakingWithdraw = "1003"
    case delegateCreate = "1004"
    case delegateWithdraw = "1005"
    case submitText = "2000"
    case submitVersion = "2001"
    case submitParam = "2002"
    case voteForProposal = "2003"
    case declareVersion = "2004"
    case submitCancel = "2005"
    case reportDuplicateSign = "3000"
    case createRestrictingPlan = "4000"
    case claimReward = "5000"
    case unknown = "-1"

    var localizeTitle: String {
        switch self {
        case .transfer:
            return Localized("TransactionStatus_transfer_title")
        case .contractCreate:
            return Localized("TransactionStatus_contractCreate_title")
        case .contractExecute:
            return Localized("TransactionStatus_contractExecute_title")
        case .otherReceive:
            return Localized("TransactionStatus_otherReceive_title")
        case .otherSend:
            return Localized("TransactionStatus_otherSend_title")
        case .MPCtransaction:
            return Localized("TransactionStatus_MPCtransaction_title")
        case .stakingCreate:
            return Localized("TransactionStatus_stakingCreate_title")
        case .stakingEdit:
            return Localized("TransactionStatus_stakingEdit_title")
        case .stakingAdd:
            return Localized("TransactionStatus_stakingAdd_title")
        case .stakingWithdraw:
            return Localized("TransactionStatus_stakingWithdraw_title")
        case .delegateCreate:
            return Localized("TransactionStatus_delegateCreate_title")
        case .delegateWithdraw:
            return Localized("TransactionStatus_delegateWithdraw_title")
        case .submitText:
            return Localized("TransactionStatus_submitText_title")
        case .submitVersion:
            return Localized("TransactionStatus_submitVersion_title")
        case .submitParam:
            return Localized("TransactionStatus_submitParam_title")
        case .voteForProposal:
            return Localized("TransactionStatus_voteForProposal_title")
        case .declareVersion:
            return Localized("TransactionStatus_declareVersion_title")
        case .reportDuplicateSign:
            return Localized("TransactionStatus_reportDuplicateSign_title")
        case .createRestrictingPlan:
            return Localized("TransactionStatus_createRestrictingPlan_title")
        case .submitCancel:
            return Localized("TransactionStatus_submitCancel_title")
        case .claimReward:
            return Localized("TransactionStatus_claimReward_title")
        case .unknown:
            return Localized("TransactionStatus_unknown_title")
        }
    }
}

enum TransanctionType: Int {
    case Send
    case Receive
    case Vote

    public var localizedDesciption: String? {
        switch self {
        case .Send:
            return Localized("walletDetailVC_tx_type_send")
        case .Receive:
            return Localized("walletDetailVC_tx_type_receive")
        case .Vote:
            return Localized("walletDetailVC_tx_type_vote")
        }
    }
}

enum TransferStatus {
    case pending
    case confiming
    case success
    case fail
}

enum TransactionStatus {
    case sending
    case sendSucceed
    case sendFailed
    case receiving
    case receiveSucceed
    case receiveFailed
    case voting
    case voteSucceed
    case voteFailed

    var localizeTitle : String {
        switch self {
        case .sending:
            return Localized("TransactionStatus_sending_title")
        case .sendSucceed:
            return Localized("TransactionStatus_sendSucceed_title")
        case .sendFailed:
            return Localized("TransactionStatus_sendFailed_title")
        case .receiving:
            return Localized("TransactionStatus_receiving_title")
        case .receiveSucceed:
            return Localized("TransactionStatus_receiveSucceed_title")
        case .receiveFailed:
            return Localized("TransactionStatus_receiveFailed_title")
        case .voting:
            return Localized("TransactionStatus_voting_title")
        case .voteSucceed:
            return Localized("TransactionStatus_voteSucceed_title")
        case .voteFailed:
            return Localized("TransactionStatus_voteFailed_title")
        }
    }

    var localizeDescAndColor : (String, UIColor) {

        let succeedColor = cell_Transaction_success_color
        let pendingColor = cell_Transaction_pending_color
        let failedColor  = cell_Transaction_fail_color

        let pendingDesc = Localized("TransactionStatus_pending_desc")
        let succeedDesc = Localized("TransactionStatus_succeed_desc")
        let failedDesc = Localized("TransactionStatus_failed_desc")

        switch self {
        case .sending, .receiving, .voting:
            return (pendingDesc, pendingColor)
        case .sendSucceed, .receiveSucceed, .voteSucceed:
            return (succeedDesc, succeedColor)
        case .sendFailed, .receiveFailed, .voteFailed:
            return (failedDesc, failedColor)
        }
    }
}

//-1为处理中，兼容本地缓存的数据，后台只返回1：成功 0：失败
enum TransactionReceiptStatus: Int {
    case timeout = -2           //超过24小时，仍然没有回执返回
    case pending = -1           //处理中
    case sucess = 1             //转账成功或合约业务成功
    case businessCodeError = 0 //合约业务错误
}

class Transaction : Object, Decodable {

    @objc dynamic var txhash : String? = ""

    var nonce : CLongLong? = 0

    @objc dynamic var blockHash : String?  = ""

    @objc dynamic var blockNumber : String?  = ""

    @objc dynamic var from : String? = ""

    @objc dynamic var to : String?  = ""

    @objc dynamic var value : String? = ""

    @objc dynamic var gasPrice : String? = ""

    @objc dynamic var gas : String? = ""

    @objc dynamic var gasUsed : String? = ""

    @objc dynamic var memo : String? = ""

    @objc dynamic var input : String? = ""

    @objc dynamic var confirmTimes = 0

    @objc dynamic var createTime = 0

    @objc dynamic var transactionType = 0 //0.7版本之前的字段，延用。等txtype

    @objc dynamic var extra: String?

    @objc dynamic var chainId: String = ""

    var totalReward: String?

    var sequence: Int64?

    var txType: TxType? {
        get {
            return TxType(rawValue: String(transactionType))
        }
        set {
            transactionType = Int(newValue?.rawValue ?? "0") ?? 0
        }
    }

    var actualTxCost: String? = ""

    var transactionIndex: Int = 0

    @objc dynamic var txReceiptStatus: Int = TransactionReceiptStatus.pending.rawValue

    //to confirm send or receive
    var senderAddress: String?

    var toType: TransactionToType = .address
    var direction: TransactionDirection = .unknown

    @objc dynamic var nodeName: String? = ""
    @objc dynamic var nodeId: String? = ""
    var lockAddress: String?
    var reportType: ReportType?
    var version: String?
    var piDID: String?
    var proposalType: ProposalType?
    var proposalId: String?
    var vote: VoteResultType?
    var unDelegation: String?

    override public static func ignoredProperties() -> [String] {
        return ["sharedWalletOwners",
                "sharedWalletConOwners",
                "sharedWalletRejectOwners",
                "valueDescription",
                "senderAddress",
                "sequence",
                "actualTxCost",
                "lockAddress",
                "reportType",
                "version",
                "piDID",
                "proposalType",
                "proposalId",
                "vote",
                "unDelegation",
                "totalReward"
        ]
    }

    override public static func primaryKey() -> String? {
        return "txhash"
    }

    enum CodingKeys: String, CodingKey {
        case actualTxCost
        case txhash = "hash"
        case from
        case to
        case blockHash
        case blockNumber
        case value
        case gasUsed = "energonUsed"
        case gasPrice = "energonPrice"
        case sequence
        case txType
        case confirmTimes = "timestamp"
        case transactionIndex
        case txReceiptStatus
        case extra = "txInfo"
        case unDelegation
        case nodeName
        case nodeId
        case toType
        case lockAddress
        case proposalType
        case proposalId
        case piDID
        case vote
        case version
        case reportType
        case totalReward
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        blockNumber = try? container.decode(String.self, forKey: .blockNumber)
        txhash = try? container.decode(String.self, forKey: .txhash)
        from = try? container.decode(String.self, forKey: .from)
        to = try? container.decode(String.self, forKey: .to)
        blockHash = try? container.decode(String.self, forKey: .blockHash)
        value = try? container.decode(String.self, forKey: .value)
        gasUsed = try? container.decode(String.self, forKey: .gasUsed)
        gasPrice = try? container.decode(String.self, forKey: .gasPrice)
        sequence = try? container.decode(Int64.self, forKey: .sequence)
        txType = (try? container.decode(TxType.self, forKey: .txType)) ?? .unknown
        let timeStampString = try? container.decode(String.self, forKey: .confirmTimes)
        if let ts = Int(timeStampString ?? "0") {
            confirmTimes = ts
        }
        actualTxCost = try? container.decode(String.self, forKey: .actualTxCost)
        let indexString = try? container.decode(String.self, forKey: .transactionIndex)
        if let index = Int(indexString ?? "0") {
            transactionIndex = index
        }

        txReceiptStatus = (try? container.decode(Int.self, forKey: .txReceiptStatus)) ?? -1
        extra = try? container.decode(String.self, forKey: .extra)
        unDelegation = try? container.decode(String.self, forKey: .unDelegation)
        nodeName = try? container.decode(String.self, forKey: .nodeName)
        nodeId = try? container.decode(String.self, forKey: .nodeId)
        toType = (try? container.decode(TransactionToType.self, forKey: .toType)) ?? .address
        lockAddress = try? container.decode(String.self, forKey: .lockAddress)
        proposalType = try? container.decode(ProposalType.self, forKey: .proposalType)
        piDID = try? container.decode(String.self, forKey: .piDID)
        vote = try? container.decode(VoteResultType.self, forKey: .vote)
        proposalId = try? container.decode(String.self, forKey: .proposalId)
        version = try? container.decode(String.self, forKey: .version)
        reportType = try? container.decode(ReportType.self, forKey: .reportType)
        totalReward = try? container.decode(String.self, forKey: .totalReward)
    }
}

extension Transaction {

    var actualTxCostDescription: String? {
        get {
            guard let atcost = actualTxCost, atcost.count > 0 else {
                return BigUInt.safeInit(str: gasUsed).divide(by: ETHToWeiMultiplier, round: 8)
            }

            let cost = BigUInt.safeInit(str: atcost).divide(by: ETHToWeiMultiplier, round: 8)
            return cost
        }
    }

    var feeDescription : String? {
        get {
            var feeB : BigUInt?
            guard gasUsed != nil, gasUsed != "" ,gasPrice != nil, gasPrice != "" else {
                return "0.00"
            }

            feeB = BigUInt(gasUsed!)?.multiplied(by: BigUInt(gasPrice!)!)
            guard feeB != nil else {
                return "0.00"
            }
            return feeB!.divide(by: ETHToWeiMultiplier, round: 8)
        }
    }

    var topValueDescription : String? {
        get {
            if let type = txType, type == .claimReward {
                return BigUInt(totalReward ?? "0")?.divide(by: ETHToWeiMultiplier, round: 8).displayForMicrometerLevel(maxRound: 8)
            } else if let type = txType, type == .delegateWithdraw {
                return ((BigUInt(value ?? "0") ?? BigUInt.zero) + (BigUInt(totalReward ?? "0") ?? BigUInt.zero)) .divide(by: ETHToWeiMultiplier, round: 8).displayForMicrometerLevel(maxRound: 8)
            } else {
                guard value != nil else {
                    return "0.00"
                }
                return BigUInt(value!)?.divide(by: ETHToWeiMultiplier, round: 8).displayForMicrometerLevel(maxRound: 8)
            }
        }
    }

    var valueDescription : String? {
        get {
            if let type = txType, type == .claimReward {
                return BigUInt(totalReward ?? "0")?.divide(by: ETHToWeiMultiplier, round: 8).displayForMicrometerLevel(maxRound: 8)
            } else {
                guard value != nil else {
                    return "0.00"
                }
                return BigUInt(value!)?.divide(by: ETHToWeiMultiplier, round: 8).displayForMicrometerLevel(maxRound: 8)
            }
        }
    }

    var transactionStauts: TransactionStatus {
        get {
            switch transanctionTypeLazy {
            case .Send:
                if txReceiptStatus == 0 {
                    return .sendFailed
                } else if txReceiptStatus == 1 {
                    return .sendSucceed
                } else {
                    return .sending
                }
            case .Receive:
                if txReceiptStatus == 0 {
                    return .receiveFailed
                } else if txReceiptStatus == 1 {
                    return .receiveSucceed
                } else {
                    return .receiving
                }
            case .Vote:
                if txReceiptStatus == 0 {
                    return .voteFailed
                } else if txReceiptStatus == 1 {
                    return .voteSucceed
                } else {
                    return .voting
                }
            }
        }
    }

    var transanctionTypeLazy : TransanctionType {
        get {
            switch txType! {
            case .transfer:
                if senderAddress != nil && (senderAddress?.ishexStringEqual(other: from))! {
                    return .Send
                } else {
                    return .Receive
                }
            case .otherReceive:
                return .Receive
            case .contractCreate,
                 .contractExecute,
                 .MPCtransaction,
                 .otherSend,
                 .stakingCreate,
                 .stakingAdd,
                 .stakingEdit,
                 .stakingWithdraw,
                 .delegateCreate,
                 .delegateWithdraw,
                 .submitText,
                 .submitVersion,
                 .submitParam,
                 .submitCancel,
                 .voteForProposal,
                 .reportDuplicateSign,
                 .declareVersion,
                 .createRestrictingPlan:
                return .Send
            default:
                let type = TransanctionType(rawValue: transactionType) ?? .Send
                if type == .Send {
                    if senderAddress != nil && (senderAddress?.ishexStringEqual(other: from))! {
                        return .Send
                    } else {
                        return .Receive
                    }
                } else {
                    return type
                }
            }
        }
    }
}

enum ProposalType: Int, Decodable {
    case text = 1
    case version = 2
    case parameter = 3
    case cancel = 4

    public var localizedDesciption: String? {
        switch self {
        case .text:
            return Localized("TransactionDetailVC_proposal_text")
        case .version:
            return Localized("TransactionDetailVC_proposal_upgrade")
        case .parameter:
            return Localized("TransactionDetailVC_proposal_parameter")
        case .cancel:
            return Localized("TransactionDetailVC_proposal_cancel")
        }
    }
}

enum ReportType: String, Decodable {
    case DoubleSign = "1"

    public var localizedDesciption: String? {
        switch self {
        case .DoubleSign:
            return Localized("TransactionDetailVC_doublesign")
        }
    }
}

enum VoteResultType: String, Decodable {
    case VoteYes = "1"
    case VoteNo = "2"
    case VoteAbstain = "3"

    public var localizedDesciption: String? {
        switch self {
        case .VoteYes:
            return Localized("TransactionDetailVC_proposal_voteyes")
        case .VoteNo:
            return Localized("TransactionDetailVC_proposal_voteno")
        case .VoteAbstain:
            return Localized("TransactionDetailVC_proposal_voteabstain")
        }
    }
}

enum TransactionToType: String, Decodable {
    case contract
    case address
}

enum TransactionDirection: String, Decodable {
    case unknown
    case Sent
    case Receive

    public var localizedDesciption: String? {
        switch self {
        case .Sent:
            return Localized("walletDetailVC_tx_type_send")
        case .Receive:
            return Localized("walletDetailVC_tx_type_receive")
        case .unknown:
            return Localized("TransactionStatus_unknown_title")
        }
    }
}

struct TransactionsStatusByHash: Decodable {
    var hash: String?
    var status: Int?
}

extension TransactionsStatusByHash {
    var localStatus: TransactionReceiptStatus? {
        guard let st = status else { return nil }
        switch st {
        case 0:
            return .businessCodeError
        case 1:
            return .sucess
        case 2:
            return .pending
        default:
            return nil
        }
    }
}
