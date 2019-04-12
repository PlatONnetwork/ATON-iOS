//
//  CandidateScrollContainer.swift
//  platonWallet
//
//  Created by Ned on 20/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class CandidateScrollContainer: UIScrollView {

    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            super.setContentOffset(contentOffset, animated: animated)
        }
        
    }

}
