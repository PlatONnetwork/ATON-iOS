//
//  CreateAndInputWalletCollectionViewCell.swift
//  platonWallet
//
//  Created by Ned on 2019/3/29.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

extension UIView {
    func addDashedBorder() {
        
        let color = UIColor(rgb: 0xE4E7F3).cgColor
//        let shapeLayer:CAShapeLayer = CAShapeLayer()
//        let frameSize = self.frame.size
//        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width - 1, height: frameSize.height -  1)
//        
//        shapeLayer.bounds = shapeRect
//        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = color
//        shapeLayer.lineWidth = 1
//        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
//        shapeLayer.lineDashPattern = [6,3]
//        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
//        self.layer.addSublayer(shapeLayer)
        
        
        var yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color
        yourViewBorder.lineDashPattern = [6, 3]
        yourViewBorder.lineWidth = 1.0
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.lineJoin = CAShapeLayerLineJoin.round
        yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
        self.layer.addSublayer(yourViewBorder)

    }
}

class CreateAndInputWalletCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var functionIcon: UIImageView!
    
    @IBOutlet weak var functionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.addDashedBorder()
    }
    
    func updateCell(index: Int){
        if index == 0{
            self.functionIcon.image = UIImage(named: "cellItemCreate")
            self.functionLabel.localizedText = "AddWalletMenuVC_createIndividualWallet_title"
        }else{
            self.functionIcon.image = UIImage(named: "cellItemImport")
            self.functionLabel.localizedText = "AddWalletMenuVC_importIndividualWallet_title"
        }
    }

}

