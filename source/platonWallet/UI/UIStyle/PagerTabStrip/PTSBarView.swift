//
//  PTSBarView.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

open class BarView: UIView {
    
    open lazy var selectedBar: UIView = { [unowned self] in
        let selectedBar = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        return selectedBar
        }()
    
    var optionsCount = 1 {
        willSet(newOptionsCount) {
            if newOptionsCount <= selectedIndex {
                selectedIndex = optionsCount - 1
            }
        }
    }
    var selectedIndex = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(selectedBar)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectedBar)
    }
    
    // MARK: - Helpers
    
    private func updateSelectedBarPosition(with animation: Bool) {
        var frame = selectedBar.frame
        frame.size.width = self.frame.size.width / CGFloat(optionsCount)
        frame.origin.x = frame.size.width * CGFloat(selectedIndex)
        if animation {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = frame
            })
        } else {
            selectedBar.frame = frame
        }
    }
    
    open func moveTo(index: Int, animated: Bool) {
        selectedIndex = index
        updateSelectedBarPosition(with: animated)
    }
    
    open func move(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat) {
        selectedIndex = (progressPercentage > 0.5) ? toIndex : fromIndex
        
        var newFrame = selectedBar.frame
        newFrame.size.width = frame.size.width / CGFloat(optionsCount)
        var fromFrame = newFrame
        fromFrame.origin.x = newFrame.size.width * CGFloat(fromIndex)
        var toFrame = newFrame
        toFrame.origin.x = toFrame.size.width * CGFloat(toIndex)
        var targetFrame = fromFrame
        targetFrame.origin.x += (toFrame.origin.x - targetFrame.origin.x) * CGFloat(progressPercentage)
        selectedBar.frame = targetFrame
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectedBarPosition(with: false)
    }
}
