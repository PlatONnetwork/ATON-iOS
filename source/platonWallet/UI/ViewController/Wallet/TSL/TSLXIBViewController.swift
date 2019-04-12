//
//  TSLXIBViewController.swift
//  platonWallet
//
//  Created by Ned on 11/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class TSLXIBViewController: UIViewController {
    @IBOutlet weak var onNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onNext(_ sender: Any) {
        self.navigationController?.pushViewController(TSLViewControllerTwo(), animated: false)
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
