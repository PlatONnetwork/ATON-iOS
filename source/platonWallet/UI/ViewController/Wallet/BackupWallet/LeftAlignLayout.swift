//
//  LeftAlignLayout.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/25.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class LeftAlignLayout: UICollectionViewFlowLayout {
    //两个Cell之间的距离
    var betweenOfCell : CGFloat {
        didSet {
            self.minimumInteritemSpacing = betweenOfCell
        }
    }

    //在居中对齐的时候需要知道这行所有cell的宽度总和
    var sumCellWidth : CGFloat = 0.0

    override init() {
        betweenOfCell = 10.0
        super.init()
        scrollDirection = UICollectionView.ScrollDirection.vertical
        minimumLineSpacing = 10

    }

    convenience init(_ betweenOfCell: CGFloat, sectionInset: UIEdgeInsets = .zero) {
        self.init()
        self.betweenOfCell = betweenOfCell
        self.sectionInset = sectionInset
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        let layoutAttributes_super : [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? [UICollectionViewLayoutAttributes]()

        let layoutAttributes:[UICollectionViewLayoutAttributes] = NSArray(array: layoutAttributes_super, copyItems:true)as! [UICollectionViewLayoutAttributes]

        var layoutAttributes_t : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()

        for index in 0..<layoutAttributes.count {

            let currentAttr = layoutAttributes[index]
            let previousAttr = index == 0 ? nil : layoutAttributes[index-1]
            let nextAttr = index + 1 == layoutAttributes.count ?
                nil : layoutAttributes[index+1]

            layoutAttributes_t.append(currentAttr)
            sumCellWidth += currentAttr.frame.size.width

            let previousY :CGFloat = previousAttr == nil ? 0 : previousAttr!.frame.maxY
            let currentY :CGFloat = currentAttr.frame.maxY
            let nextY:CGFloat = nextAttr == nil ? 0 : nextAttr!.frame.maxY

            if currentY != previousY && currentY != nextY {
                if currentAttr.representedElementKind == UICollectionView.elementKindSectionHeader {
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                } else if currentAttr.representedElementKind == UICollectionView.elementKindSectionFooter {
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                } else {
                    self.setCellFrame(with: layoutAttributes_t)
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                }
            } else if currentY != nextY {
                self.setCellFrame(with: layoutAttributes_t)
                layoutAttributes_t.removeAll()
                sumCellWidth = 0.0
            }
        }
        return layoutAttributes
    }

    /// 调整Cell的Frame
    ///
    /// - Parameter layoutAttributes: layoutAttribute 数组
    func setCellFrame(with layoutAttributes : [UICollectionViewLayoutAttributes]) {
        var nowWidth : CGFloat = 0.0

        nowWidth = self.sectionInset.left
        for attributes in layoutAttributes {
            var nowFrame = attributes.frame
            nowFrame.origin.x = nowWidth
            attributes.frame = nowFrame
            nowWidth += nowFrame.size.width + self.betweenOfCell
        }

    }

    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        betweenOfCell = 10.0
        super.init(coder: aDecoder)
    }
}
