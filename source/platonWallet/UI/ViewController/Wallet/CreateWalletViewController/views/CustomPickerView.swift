//
//  CustomPickerView.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/14.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class CustomPickerView: UIView {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var onCancelHandler: (() -> Void)?
    var onSubmitHandler: ((String) -> Void)?
    
    var dataSource: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    
    public static func show(inViewController vc: UIViewController, dataSource: [String], curSelected: String?, onSubmitHandler:@escaping (String) -> Void) {
        
        let popVC = PopUpViewController()
        let height:CGFloat = 232
        let view = UIView.viewFromXib(theClass: CustomPickerView.self) as! CustomPickerView
        
        view.dataSource = dataSource
        if curSelected != nil && curSelected!.length > 0 {
            view.pickerView.selectRow(dataSource.firstIndex(of: curSelected!) ?? 0, inComponent: 0, animated: false)
        }
        view.onCancelHandler = {[weak popVC] in
            popVC?.onDismissViewController()
        }
        view.onSubmitHandler = onSubmitHandler
        popVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: height))
        popVC.show(inViewController: vc)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        onCancelHandler?()
    }
    
    @IBAction func submit(_ sender: Any) {
        
        onSubmitHandler?(dataSource[pickerView.selectedRow(inComponent: 0)])
        onCancelHandler?()
    }
    
}

extension CustomPickerView: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}
