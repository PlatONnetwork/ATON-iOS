//
//  VoteDetailHeader.swift
//  platonWallet
//
//  Created by Ned on 27/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class VoteDetailHeader: UIView {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var id: UILabel!

    func updateView(_ detail: CandidateBasicInfo){
        
        name.text = detail.name
        id.text = detail.id.add0x()
        avatar.image = detail.getAvatar
    }

}
