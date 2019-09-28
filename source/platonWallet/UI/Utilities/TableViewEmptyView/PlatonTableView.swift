//
//  PlatonTableView.swift
//  platonWallet
//
//  Created by matrixelement on 2/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

let emptyViewContainerTag = 999

extension UITableView {
    
    func showEmptyView(description : String?){
        var viewContainer = viewWithTag(emptyViewContainerTag) as? TableViewNoDataPlaceHolder
        if let viewContainer = viewContainer{
            viewContainer.removeFromSuperview()
        }
        
        viewContainer = (UIView.viewFromXib(theClass: TableViewNoDataPlaceHolder.self) as! TableViewNoDataPlaceHolder)
        if (description != nil) && (description?.length)! > 0{
            viewContainer?.descriptionLabel.text = description
        }
        viewContainer?.tag = emptyViewContainerTag
        addSubview(viewContainer!)
        let size = CGSize(width: 200, height: 200)
        viewContainer?.frame = CGRect(x: (self.frame.size.width - size.width) * 0.5, y: (self.frame.size.height - size.height) * 0.5 - 100, width: size.width, height: size.height)
        bringSubviewToFront(viewContainer!)
    }
    
    func removeEmptyView(){
        let viewContainer = viewWithTag(emptyViewContainerTag)
        if let viewContainer = viewContainer{
            viewContainer.removeFromSuperview()
        }
    }
}
