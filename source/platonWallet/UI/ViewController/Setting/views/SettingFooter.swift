//
//  SettingFooter.swift
//  platonWallet
//
//  Created by matrixelement on 6/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class SettingFooter: UIView {
    @IBOutlet weak var mediumBtn: UIButton!
    @IBOutlet weak var redditBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var githubBtn: UIButton!
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var telegtamBtn: UIButton!
    
    override func awakeFromNib() {
        mediumBtn.tag = 1
        redditBtn.tag = 2
        facebookBtn.tag = 3
        twitterBtn.tag = 4
        githubBtn.tag = 5
        //wechatBtn.tag = 6
        telegtamBtn.tag = 7
    }
    
    @IBAction func onButtonPress(_ sender: Any) {
        let button = sender as! UIButton
        var url : String?
        switch button.tag {
        case 1:
            do {
                url = "https://medium.com/@PlatON_Network/"
            }
        case 2:
            do {
                url = "https://reddit.com/user/PlatON_Network/"
                
            }
        case 3:
            do {
                url = "https://facebook.com/PlatONNetwork/"
                
            }
        case 4:
            do {
                url = "https://twitter.com/PlatON_Network/"
            }
        case 5:
            do {
                url = "https://github.com/PlatONnetwork/"
            }
        case 6:
            do {
                //url = "https://www.wechat.com"
            }
        case 7:
            do {
                url = "https://t.me/PlatONHK/"
                
            }
        default:
            break
        }
        
        UIApplication.shared.openURL(URL(string: url!)!)
    }
    
    
    
}
