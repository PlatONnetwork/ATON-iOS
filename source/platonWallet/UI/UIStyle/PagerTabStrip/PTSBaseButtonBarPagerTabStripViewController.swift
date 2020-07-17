//
//  PTSBaseButtonBarPagerTabStripViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

open class BaseButtonBarPagerTabStripViewController<ButtonBarCellType: UICollectionViewCell>: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    public var settings = ButtonBarPagerTabStripSettings()
    public var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarCellType>!
    public var changeCurrentIndex: ((_ oldCell: ButtonBarCellType?, _ newCell: ButtonBarCellType?, _ animated: Bool) -> Void)?
    public var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarCellType?, _ newCell: ButtonBarCellType?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?

    @IBOutlet public weak var buttonBarView: ButtonBarView!
    /// 是否通过拖拽来切换标签，如果不是，则为点击标签切换的
    var isDragToChangeTag: Bool!

    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
        }()

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        let buttonBarViewAux = buttonBarView ?? {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: settings.style.buttonBarLeftContentInset ?? 35, bottom: 0, right: settings.style.buttonBarRightContentInset ?? 35)
            let buttonBarHeight = settings.style.buttonBarHeight ?? 44
            let buttonBar = ButtonBarView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: buttonBarHeight), collectionViewLayout: flowLayout)
            buttonBar.backgroundColor = .white
            buttonBar.selectedBar.backgroundColor = .black
            buttonBar.autoresizingMask = .flexibleWidth
            var newContainerViewFrame = containerView.frame
            newContainerViewFrame.origin.y = buttonBarHeight
            newContainerViewFrame.size.height = containerView.frame.size.height - (buttonBarHeight - containerView.frame.origin.y)
            containerView.frame = newContainerViewFrame
            return buttonBar
            }()
        buttonBarView = buttonBarViewAux

        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumInteritemSpacing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: settings.style.buttonBarLeftContentInset ?? sectionInset.left, bottom: sectionInset.bottom, right: settings.style.buttonBarRightContentInset ?? sectionInset.right)
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor ?? buttonBarView.backgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor

        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        buttonBarView.selectedBarWidth = settings.style.selectedBarWidth
        // register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .cellClass:
            buttonBarView.register(ButtonBarCellType.self, forCellWithReuseIdentifier:"Cell")
        }
        //-
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
        isViewAppearing = true

        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppearing = false
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard isViewAppearing || isViewRotating else { return }

        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
        // a) The view is appearing.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
        //    when the view is shown and when the view *frame(s)* are actually set
        //    (we need the view frame's to have been set to work out the size's and on the
        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
        //    aren't set correctly)
        // b) The view is rotating.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
        //    *new* frame so that the buttonBarView cell's actually get resized correctly
        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
        // When the view first appears or is rotated we also need to ensure that the barButtonView's
        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
        // tab/cell may end up either skewed or off screen after a rotation otherwise)
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
        buttonBarView.selectItem(at: IndexPath(item: currentIndex, section: 0), animated: false, scrollPosition: [])
    }

    // MARK: - View Rotation

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - Public Methods

    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded else { return }
        buttonBarView.reloadData()
        cachedCellWidths = calculateWidths()
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .yes)
    }

    func updateBarButtonView() {
        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
    }

    open func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0

        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }

        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }

        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let collectionViewAvailiableWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing

        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)

        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveTo(index: toIndex, animated: true, swipeDirection: toIndex < fromIndex ? .right : .left, pagerScroll: .yes)

        if let changeCurrentIndex = changeCurrentIndex {
            let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCellType
            let newCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
            changeCurrentIndex(oldCell, newCell, true)
        }
    }

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        if isDragToChangeTag == true {
            buttonBarView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .yes)
        }
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCellType
            let newCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
            changeCurrentIndexProgressive(oldCell, newCell, progressPercentage, indexWasChanged, true)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayut

    @objc open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != currentIndex else { return }
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        shouldUpdateButtonBarView = true
        isDragToChangeTag = false
// 下列已屏蔽掉，防止切换标签时指示器跳动
//        let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
//        let newCell = buttonBarView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) as? ButtonBarCellType
//        if pagerBehaviour.isProgressiveIndicator {
//            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
//                changeCurrentIndexProgressive(oldCell, newCell, 1, true, true)
//            }
//        } else {
//            if let changeCurrentIndex = changeCurrentIndex {
//                changeCurrentIndex(oldCell, newCell, true)
//            }
//        }
        moveToViewController(at: indexPath.item)

    }

    // MARK: - UICollectionViewDataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarCellType else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
        let indicatorInfo = childController.indicatorInfo(for: self)

        configure(cell: cell, for: indicatorInfo)

        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, 1, true, false)
            }
        } else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, false)
            }
        }

        return cell
    }

    // MARK: - UIScrollViewDelegate
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        guard scrollView == containerView else { return }
               isDragToChangeTag = true
    }
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)

        guard scrollView == containerView else { return }
        shouldUpdateButtonBarView = true
    }

    open func configure(cell: ButtonBarCellType, for indicatorInfo: IndicatorInfo) {
        fatalError("You must override this method to set up ButtonBarView cell accordingly")
    }

    private func calculateWidths() -> [CGFloat] {
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let numberOfCells = viewControllers.count

        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0

        for (index, viewController) in viewControllers.enumerated() {
            let childController = viewController as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            let indicatorInfo = childController.indicatorInfo(for: self)
            switch buttonBarItemSpec! {
            case .cellClass(let widthCallback):

                let cell = buttonBarView.cellForItem(at: IndexPath(item: index, section: 0)) as? StakingLabelViewCell

                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = cell?.label.font
                label.localizedText = indicatorInfo.title
                let labelSize = label.intrinsicContentSize

                let width = labelSize.width
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .nibFile(_, _, let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            }
        }

        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        collectionViewContentWidth += cellSpacingTotal

        let collectionViewAvailableVisibleWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right

        if !settings.style.buttonBarItemsShouldFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        } else {
            let stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchedCellWidthIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()

            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }

            return stretchedCellWidths
        }
    }

    private var shouldUpdateButtonBarView = true
}

class ExampleBaseButtonBarPagerTabStripViewController: BaseButtonBarPagerTabStripViewController<PTSButtonCell> {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    open func initialize() {
        var bundle = Bundle(for: PTSButtonCell.self)
        if let resourcePath = bundle.path(forResource: "XLPagerTabStrip", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }

        buttonBarItemSpec = .nibFile(nibName: "ButtonCell", bundle: bundle, width: { [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont ?? label.font
            label.localizedText = childItemInfo.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + CGFloat(self?.settings.style.buttonBarItemLeftRightMargin ?? 8 * 2)
        })
    }

    open override func configure(cell: PTSButtonCell, for indicatorInfo: IndicatorInfo) {
        cell.label.text = indicatorInfo.title
        cell.accessibilityLabel = indicatorInfo.accessibilityLabel
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
    }
}
