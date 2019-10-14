//
//  PasswordStrengthView.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/30.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class PasswordStrengthView: UIView {

    enum StrengthLevel: Int {
        case none = 0, weak, soso, good, strong

        func desc() -> String {
            return Localized("password_strength_level_\(self.rawValue)")
        }
    }

    @IBOutlet weak var descLabel: UILabel!

    @IBOutlet var levelViews: [UIView]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }

    func initSubView() {
        guard let subView = Bundle.main.loadNibNamed("PasswordStrengthView", owner: self, options: nil)?.first as? UIView else {
            return
        }

        self.addSubview(subView)
        subView.snp.makeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
        for i in 0..<levelViews.count {
            levelViews[i].layer.cornerRadius = 1.0
            levelViews[i].layer.masksToBounds = true
            levelViews[i].tag = 101 + i
            levelViews[i].isHidden = true
        }
    }

    func updateFor(password: String) {

//        let lev = arc4random_uniform(5)
        let lev = strengthLevelFor(password)

        for view in levelViews {

            if view.tag - 100 <= lev.rawValue {
                view.isHidden = false
            } else {
                view.isHidden = true
            }

            switch lev {

            case .none:
                view.backgroundColor = UIColor(red: 22, green: 30, blue: 51, alpha: 1)
            case .weak:
                view.backgroundColor = UIColor(rgb: 0xF5302C )
            case .soso:
                view.backgroundColor = UIColor(rgb: 0xFF9000 )
            case .good:
                view.backgroundColor = UIColor(rgb: 0x58B8FF )
            case .strong:
                view.backgroundColor = UIColor(rgb: 0x19A20E)
            }
            descLabel.textColor = view.backgroundColor
        }
        descLabel.text = lev.desc()

    }

}

extension PasswordStrengthView {

    func strengthLevelFor(_ password: String) -> StrengthLevel {
//        要求不少于6位
//        四种：大写字母、小写字母、数字、常用符号
//        弱：6位以下
//        一般： 单一+6位以上 或 两种+6位以上但不包含大写字母或符合
//        强：  2种（至少包含大写字母或符合）+6位以上 或 3种（6位以上）
//        很好：3种（12位以上） 或4种（6位以上）
        //

        //数字
        let containNums = NSPredicate(format: "SELF MATCHES %@", "(.*?)\\d+(.*?)").evaluate(with: password)

        let containlowerLetter = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(.*)$").evaluate(with: password)

        let containUpperLetter = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(.*)$").evaluate(with: password)

        let noSpecialCharacter = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$").evaluate(with: password)

        if password.length == 0 {
            return .none
        } else if password.length > 0 && password.length < 6 {
            return .weak
        } else {

            var count = 0
            count = containNums ? count + 1 : count
            count = containlowerLetter ? count + 1 : count
            count = containUpperLetter ? count + 1 : count
            count = !noSpecialCharacter ? count + 1 : count

            switch count {
            case 1:
                return .soso
            case 2:
                if containUpperLetter || !noSpecialCharacter {
                    return .good
                } else {
                    return .soso
                }
            case 3:
                if password.length < 12 {
                    return .good
                } else {
                    return .strong
                }
            case 4: return .strong
            default:
                return .none
            }

        }

    }

}
