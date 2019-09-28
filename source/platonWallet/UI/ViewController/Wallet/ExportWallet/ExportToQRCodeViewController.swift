//
//  ExportToQRCodeViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class ExportToQRCodeViewController: BaseViewController {

    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var qrCodeImg: UIImageView!
    
    var note: String!
    var plainText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noteLabel.text = note

        qrCodeImg.backgroundColor = UIColor.white
        qrCodeImg.image = UIImage.geneQRCodeImageFor(plainText, size: 230)
        qrCodeImg.contentMode = .center
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
