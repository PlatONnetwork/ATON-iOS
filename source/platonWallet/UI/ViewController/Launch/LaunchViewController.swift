//
//  LaunchViewController.swift
//  platonWallet
//
//  Created by matrixelement on 5/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import SVGAPlayer


class LaunchViewController: UIViewController {
    
    var animationFinishedHandle: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = SVGAPlayer(frame: CGRect(x: (view.bounds.width - 300)/2.0, y: 153, width: 300, height: 245))
        player.clearsAfterStop = true
        player.delegate = self
        player.loops = 1
        view.addSubview(player)
        
        let parser = SVGAParser()
        parser.parse(withNamed: "aton-launch-logo", in: Bundle.main, completionBlock: { (entity) in
            player.videoItem = entity
            player.startAnimation()
        }) { (error) in
            
        }
        
        
        
    }

}

extension LaunchViewController: SVGAPlayerDelegate {
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        animationFinishedHandle?()
    }
}
