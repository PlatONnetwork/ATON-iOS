//
//  CommunityCellStyle.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

public struct CommunityContactStyle {
    var contact: String
    var qrcodeImage: UIImage?
    var action: CommunityAction
    var isSelected: Bool = false

    public enum CommunityAction {
        case scan
        case link
    }
}

public struct CommunityCellStyle {
    var avatar: String
    var name: String
    var contacts: [CommunityContactStyle]
}
