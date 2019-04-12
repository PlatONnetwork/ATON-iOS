//
//  PLevelBar.swift
//  platonWallet
//
//  Created by juzix on 2019/3/6.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class PLevelSlider: UIView {
    
    let margin: CGFloat = 12.0
    let radius_s: CGFloat = 3.0
    let radius_l: CGFloat = 7.0
    let line_w: CGFloat = 2.0
    let line_margin: CGFloat = 16.0

    @IBOutlet weak var slider: UISlider!
    
    var glayer: CAGradientLayer!
    var lLayer: CAShapeLayer!
    
    private var level: Int = 0
    private var curLevel: Int = 0 {
        didSet{
            if oldValue != curLevel {
                levelChanged?(curLevel)
            }
        }
    }
    
    var levelChanged: ((Int)->Void)?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        drawGradientLayer()
        drawlineLayer() 
        
        updateSliderValue(value: Float(curLevel - 1)/Float(level - 1), animated: false)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initSubViews()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initSubViews()
//    }
//    
//    func initSubViews() {
//        let slider = Bundle.main.loadNibNamed("PLevelSlider", owner: self, options: nil)?.first as! UIView
//        addSubview(slider)
//    }
    
    public class func create(level:Int = 4, initLevel:Int = 1, levelChanged:@escaping ((_ level:Int)->Void)) -> PLevelSlider {
        
        let view = UIView.viewFromXib(theClass: PLevelSlider.self) as! PLevelSlider
        view.level = level
        view.curLevel = initLevel
        view.levelChanged = levelChanged
        let image = UIImage.gradientImage(colors: [UIColor(rgb: 0x427FFF),UIColor(rgb: 0x105CFE)], size: CGSize(width: 14, height: 14))
        view.slider.setThumbImage(image?.circleImage(), for: .normal)
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(tap(_:))))
        return view
    }
    
    private func drawGradientLayer() {
        
        if glayer != nil {
            return
        }
        glayer = CAGradientLayer()
        glayer.frame = CGRect(x: line_margin, y: 0, width: bounds.width - 2 * line_margin, height: bounds.height)
        glayer.colors = [UIColor(rgb: 0x28ADFF).cgColor, 
                         UIColor(rgb: 0x105CFE).cgColor,
                         UIColor(rgb: 0xD5D8DF).cgColor,
                         UIColor(rgb: 0xD5D8DF).cgColor]
        glayer.startPoint = CGPoint(x: 0, y: 0.5)
        glayer.endPoint = CGPoint(x: 1, y: 0.5)
        glayer.locations = [0,0.33,0.33,1]
        layer.insertSublayer(glayer, at: 0)
    }
    
    private func drawlineLayer() {
        
        if lLayer != nil {
            return
        }
        
        lLayer = CAShapeLayer()
        
        lLayer.frame = CGRect(x: 1, y: 0, width: glayer.bounds.width - 2, height: glayer.bounds.height)
        
        lLayer.fillColor = UIColor.red.cgColor
        lLayer.strokeColor = UIColor.red.cgColor
        
        let path = UIBezierPath()
        path.lineWidth = line_w
        
        let center_y = bounds.height/2
        //draw line
        path.move(to: CGPoint(x: radius_s, y: center_y))
        path.addLine(to: CGPoint(x: lLayer.bounds.width - (radius_s), y: center_y))
        
        //draw circle
        let w = (lLayer.frame.width - 2 * radius_s) / CGFloat(level-1)
        
        for i in 0..<level {
            
            path.addArc(withCenter: CGPoint(x: radius_s + (CGFloat(i) * w), y: center_y), radius: radius_s, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
            
        }
        
        lLayer.path = path.cgPath
        glayer.mask = lLayer
    }
    
    @IBAction func end(_ sender: Any) {
        let s = sender as! UISlider
        updateSliderValue(value: s.value)
        
    }
    
    @IBAction func sliderChange(_ sender: Any) {
        let s = sender as! UISlider
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glayer.locations = [0,NSNumber(value: s.value),NSNumber(value: s.value),1]
        CATransaction.commit()
    }
    
    @objc func tap(_ gesture: UIGestureRecognizer) {
        let point = gesture.location(in: self)
        let realPoint = self.convert(point, to: slider)
        let value = Float(realPoint.x) / Float(slider.bounds.width)
        updateSliderValue(value: value)
    }
    
    private func updateSliderValue(value: Float, animated: Bool = true) {
        
        let ava = 1.0 / Float(level-1)
        let half = ava / 2
        let targetValue:Float
        if value.truncatingRemainder(dividingBy: ava) < half {
            curLevel = Int(value / ava) + 1
            targetValue = Float(Int(value / ava)) * ava
        }else {
            curLevel = Int(value / ava) + 1 + 1
            targetValue = Float(Int(value / ava) + 1) * ava
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glayer.locations = [0,NSNumber(value: targetValue),NSNumber(value: targetValue),1]
        CATransaction.commit()
        CATransaction.setCompletionBlock { 
            self.slider.setValue(targetValue, animated: animated)
        }
        

    }
}
