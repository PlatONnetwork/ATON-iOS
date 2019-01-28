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

    func updateView(_ detail: Candidate){
        
        name.text = detail.extra?.nodeName
        id.text = detail.candidateId?.add0x()
        
    }

}
