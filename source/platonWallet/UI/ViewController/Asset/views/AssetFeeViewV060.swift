//
//  AssetFeeView060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/7.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class AssetFeeViewV060: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var fee: UILabel!
    
    @IBOutlet weak var centerView: UIView!
    
    lazy var levelView = { () -> PLevelSlider in 
        let levelView = PLevelSlider.create(levelChanged: { (level) in
            print("level:\(level)")
        })
        return levelView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    func initSubviews() {
        let view = Bundle.main.loadNibNamed("AssetFeeViewV060", owner: self, options: nil)?.first as! UIView
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        levelView = PLevelSlider.create(levelChanged: { (level) in
            print("level\(level)")
        })
        centerView.addSubview(levelView)
        levelView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
