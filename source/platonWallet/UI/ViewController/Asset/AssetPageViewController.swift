//
//  AssetPageViewController.swift
//  platonWallet
//
//  Created by Ned on 18/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

extension UIPageViewController {

    func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
    }

    func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
    }

}

class AssetPageViewController: UIPageViewController, UIScrollViewDelegate {

    private var pagesScrollviewOffSetX: CGFloat = 0
    private var currentPage: Int = 0

    var mpage: Int = 0

    var didScrolling: ((CGFloat) -> Void)?

    var pagesScrollview: UIScrollView? {
        for subView: UIView in self.view.subviews {
            if subView.isKind(of: UIScrollView.classForCoder()) {
                if let tempScrollView = subView as? UIScrollView {
                    return tempScrollView
                }
            }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagesScrollview?.delegate = self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.pagesScrollview {

            let pageWidth = view.frame.width
            for vc in self.viewControllers! {
                let p = vc.view.convert(CGPoint(), to: view)
                if (p.x) > CGFloat(0.0) && (p.x) < pageWidth {
                    let estimatePage = (self.viewControllers?.index(of: vc))!
                    self.pagesScrollviewOffSetX = CGFloat(estimatePage) * pageWidth - (p.x)
                }
            }
            //若不是循环，最后一个找不到左边距
            if pagesScrollviewOffSetX >= CGFloat((self.viewControllers?.count)!-1)*pageWidth {
                let p = self.viewControllers?[(self.viewControllers?.count)!-1].view.convert(CGPoint(), to: view)
                pagesScrollviewOffSetX = CGFloat((self.viewControllers?.count)!-1) * pageWidth - (p?.x)!
            }
        }

        //print("x offset:\(pagesScrollviewOffSetX)")
        if self.didScrolling != nil {
            self.didScrolling!(pagesScrollviewOffSetX)
        }

    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = view.frame.width
        currentPage = Int(round(pagesScrollviewOffSetX/pageWidth))
        if currentPage < 0 {
            currentPage = (self.viewControllers?.count)! - 1
        }
        pagesScrollviewOffSetX = CGFloat(currentPage)*pageWidth
        //print("x offset:\(pagesScrollviewOffSetX)")
        if self.didScrolling != nil {
            self.didScrolling!(pagesScrollviewOffSetX)
        }
    }

}
