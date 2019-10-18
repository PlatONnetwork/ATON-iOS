//
//  PTSBarPagerTabStripViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

public struct BarPagerTabStripSettings {

    public struct Style {
        public var barBackgroundColor: UIColor?
        public var selectedBarBackgroundColor: UIColor?
        public var barHeight: CGFloat = 5 // barHeight is ony set up when the bar is created programatically and not using storyboards or xib files.
    }

    public var style = Style()
}

open class BarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {

    public var settings = BarPagerTabStripSettings()

    @IBOutlet weak public var barView: BarView!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        barView = barView ?? {
            let barView = BarView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: settings.style.barHeight))
            barView.autoresizingMask = .flexibleWidth
            barView.backgroundColor = .black
            barView.selectedBar.backgroundColor = .white
            return barView
            }()

        barView.backgroundColor = settings.style.barBackgroundColor ?? barView.backgroundColor
        barView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor ?? barView.selectedBar.backgroundColor
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if barView.superview == nil {
            view.addSubview(barView)
        }
        barView.optionsCount = viewControllers.count
        barView.moveTo(index: currentIndex, animated: false)
    }

    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        barView.optionsCount = viewControllers.count
        if isViewLoaded {
            barView.moveTo(index: currentIndex, animated: false)
        }
    }

    // MARK: - PagerTabStripDelegate

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {

        barView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage)
    }

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        barView.moveTo(index: toIndex, animated: true)
    }
}
