//
//  NodeModel.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import RealmSwift
import Realm

enum NodeStatus: String, Decodable {
    case Active
    case Candidate
    case Exiting
    case Exited

    var description: String {
        switch self {
        case .Active:
            return Localized("node_status_active")
        case .Candidate:
            return Localized("node_status_candidate")
        case .Exiting:
            return Localized("node_status_exiting")
        case .Exited:
            return Localized("node_status_exited")
        }
    }
}

class Node: Object, Decodable {
    @objc dynamic var nodeId: String? = ""
    @objc dynamic var ranking: Int = 0
    @objc dynamic var name: String? = ""
    @objc dynamic var deposit: String? = ""
    @objc dynamic var url: String? = ""
    @objc dynamic var ratePA: String? = ""
    @objc dynamic var nodeStatus: String = NodeStatus.Active.rawValue
    @objc dynamic var isInit: Bool = false
    // 不同的链
    @objc dynamic var chainUrl: String? = ""

    required init() {
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    override static func primaryKey() -> String? {
        return "nodeId"
    }

    convenience init(
        nodeId: String?,
        ranking: Int?,
        name: String?,
        deposit: String?,
        url: String?,
        ratePA: String?,
        nStatus: NodeStatus,
        isInit: Bool
        ) {
        self.init()
        self.nodeId = nodeId
        self.ranking = ranking ?? 0
        self.name = name
        self.deposit = deposit
        self.url = url
        self.ratePA = ratePA
        self.nodeStatus = nStatus.rawValue
        self.isInit = isInit
    }
}

struct NodeDetail: Decodable {
    var node: Node
    var website: String?
    var intro: String?
    var punishNumber: Int?
    var delegateSum: String?
    var delegate: String?
    var blockOutNumber: Int?
    var blockRate: String?

    enum NodeCodingKeys: String, CodingKey {
        case nodeId
        case ranking
        case name
        case deposit
        case url
        case ratePA
        case nodeStatus
        case isInit
    }

    enum CodingKeys: String, CodingKey {
        case website
        case intro
        case punishNumber
        case delegateSum
        case delegate
        case blockOutNumber
        case blockRate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let nodeContainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let nodeId = try nodeContainer.decode(String.self, forKey: .nodeId)
        let ranking = try nodeContainer.decodeIfPresent(Int.self, forKey: .ranking)
        let name = try nodeContainer.decode(String.self, forKey: .name)
        let deposit = try nodeContainer.decodeIfPresent(String.self, forKey: .deposit)
        let url = try nodeContainer.decodeIfPresent(String.self, forKey: .url)
        let ratePA = try nodeContainer.decodeIfPresent(String.self, forKey: .ratePA)
        let nodeStatus = try nodeContainer.decode(NodeStatus.self, forKey: .nodeStatus)
        let isInit = try nodeContainer.decode(Bool.self, forKey: .isInit)

        website = try container.decodeIfPresent(String.self, forKey: .website)
        intro = try container.decodeIfPresent(String.self, forKey: .intro)
        punishNumber = try container.decodeIfPresent(Int.self, forKey: .punishNumber)
        delegateSum = try container.decodeIfPresent(String.self, forKey: .delegateSum)
        delegate = try container.decodeIfPresent(String.self, forKey: .delegate)
        blockOutNumber = try container.decodeIfPresent(Int.self, forKey: .blockOutNumber)
        blockRate = try container.decodeIfPresent(String.self, forKey: .blockRate)

        node = Node(nodeId: nodeId, ranking: ranking, name: name, deposit: deposit, url: url, ratePA: ratePA, nStatus: nodeStatus, isInit: isInit)
    }
}
