//
//  ImportWalletHeaderView.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit

protocol ImportWalletHeaderViewDelegate: AnyObject {
    func didClickTabIndex(_ index:Int)
}

class ImportWalletHeaderView: UIView {
    
    var tabLists: [String] = []
    var curIndex: Int = 0 {
        didSet {
            
            if oldValue == curIndex {
                return
            }
            
            tabBtns[oldValue].isSelected = false
            
            tabBtns[curIndex].isSelected = true
            
            slider.snp.remakeConstraints { (maker) in
                maker.bottom.equalToSuperview()
                maker.height.equalTo(2)
                
                maker.left.width.equalTo(tabBtns[curIndex])
            }
            UIView.animate(withDuration: 0.25) { 
                self.layoutIfNeeded()
            }
        }
    }
    
    weak var delegate: ImportWalletHeaderViewDelegate?
    
    lazy var tabBtns: [UIButton] = {
        
        var arr:[UIButton] = []
        for i in 0..<tabLists.count {
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            btn.setTitle(tabLists[i], for: .normal)
            btn.tag = 100 + i
            btn.setTitleColor(UIColor(rgb: 0xCDCDCD), for: .normal)
            btn.setTitleColor(UIColor(rgb: 0xFFED54), for: .selected)
            btn.backgroundColor = UIColor.clear
            btn.addTarget(self, action: #selector(onTabBtnClick(_:)), for: .touchUpInside)
            arr.append(btn)
        }
        return arr
        
    }()
    
    lazy var slider: UIView = {
        
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor(rgb: 0xFFED54)
        return line
        
    }()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    convenience init(tabLists:[String], currentIndex:Int = 0) {
        self.init()
        self.tabLists = tabLists
        curIndex = currentIndex
        setupUI()
    }
    
    func setupUI() {
        
        backgroundColor = UIColor(rgb: 0x1B2137)
        
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor(rgb: 0x32394E)
        addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(1.0)
        }
        
        for index in 0..<tabBtns.count {
            
            let btn = tabBtns[index]
            addSubview(btn)
            btn.snp.makeConstraints { (maker) in
                maker.top.bottom.equalToSuperview()
                
                if index == 0 {
                    maker.width.equalToSuperview().dividedBy(tabBtns.count)
                    maker.left.equalToSuperview()
                }else if index == tabBtns.count - 1 {
                    maker.left.equalTo(tabBtns[index - 1].snp.right)
                    maker.right.equalToSuperview()
                }else {
                    maker.width.equalToSuperview().dividedBy(tabBtns.count)
                    maker.left.equalTo(tabBtns[index - 1].snp.right)
                }
                
            }
            
        }
        
        addSubview(slider)
        slider.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview()
            maker.height.equalTo(2)
            maker.left.width.equalTo(tabBtns[curIndex])
        }
        
    }
    
    @objc func onTabBtnClick(_ sender:Any) {
        
        guard let btn = sender as? UIButton else { return }
        
        if btn.tag - 100 == curIndex {
            return
        }
        
        curIndex = btn.tag - 100
        delegate?.didClickTabIndex(curIndex)
    }

}

