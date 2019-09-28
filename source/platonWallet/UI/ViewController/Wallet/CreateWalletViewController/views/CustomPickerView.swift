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
    
    @IBOutlet weak var submitButton: PButton!
    
    @IBOutlet weak var title: UILabel!
    var onCancelHandler: (() -> Void)?
    var onSubmitHandler: ((String) -> Void)?
    
    var dataSource: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.dataSource = self
        submitButton.style = .blue
    }
    
    public static func show(inViewController vc: UIViewController, dataSource: [String], curSelected: String?,title : String = "", onSubmitHandler:@escaping (String) -> Void) {
        
        let popVC = PopUpViewController()
        let height:CGFloat = 330
        let view = UIView.viewFromXib(theClass: CustomPickerView.self) as! CustomPickerView
        
        view.dataSource = dataSource
        if curSelected != nil && curSelected!.length > 0 {
            view.pickerView.selectRow(dataSource.firstIndex(of: curSelected!) ?? 0, inComponent: 0, animated: false)
        }
        view.onCancelHandler = {[weak popVC] in
            popVC?.onDismissViewController()
        }
        view.onSubmitHandler = onSubmitHandler
        popVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: height))
        popVC.show(inViewController: vc)
        view.title.text = title
        
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
        return 34
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        for view in pickerView.subviews {
            if view.frame.size.height < 1 {
                var frame = view.frame
                frame.size.height = 1
                view.frame = frame
                view.backgroundColor = UIColor(rgb: 0xE4E7F3)
            }
        }
        
        let label = UILabel()
        label.text = dataSource[row]
        label.textAlignment = NSTextAlignment.center
        return label
    }
}
