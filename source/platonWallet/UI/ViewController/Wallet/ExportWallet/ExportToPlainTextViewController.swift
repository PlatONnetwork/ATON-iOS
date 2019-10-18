//
//  ExportToPlainTextViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class ExportToPlainTextViewController: BaseViewController {

    @IBOutlet weak var noteLabel: UILabel!

    @IBOutlet weak var plainTextLabel: UILabel!

    @IBOutlet weak var copyButton: PButton!

    var note: String!
    var plainText: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noteLabel.text = note
        plainTextLabel.text = plainText
        copyButton.style = .blue
    }

    @IBAction func copyText(_ sender: Any) {

        let pasteb = UIPasteboard.general
        pasteb.string = plainText
        showMessage(text: Localized("ExportVC_copy_success"))
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
