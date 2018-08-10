//
//  QHPDFView+Page.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/9.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

extension QHPDFView: UIPageViewControllerDataSource {
    
    private func p_indexOf(viewController: QHPageViewController) -> Int {
        return viewController.index
    }
    
    private func p_goPageViewControllerAt(index: Int) -> UIViewController? {
        print("index1 == \(index)")
        if let vc = p_pageViewControllerAt(index: index) {
            print("index2 == \(index)")
            currentIndex = index
            dataSource?.showInPDFPage(view: self, index: currentIndex)
            return vc
        }
        return nil
    }
    
    private func p_pageViewControllerAt(index: Int) -> UIViewController? {
        if let doc = document {
            let count = doc.numberOfPages
            if index > 0, index <= count {
                let pageVC = QHPageViewController()
                pageVC.index = index
                pageVC.addPDFCellView(delegate: self, rect: self.bounds)
                
                return pageVC
            }
        }
        
        return nil
    }
    
    func addPageViewControllerIn(superViewController: UIViewController, rect: CGRect, transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation) {
        if let pageVC = pageViewController {
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
        }
        pageViewController = nil
        let options = [UIPageViewControllerOptionSpineLocationKey: UIPageViewControllerSpineLocation.min.rawValue]
        pageViewController = UIPageViewController(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        if let pageVC = pageViewController {
            pageVC.view.frame = rect
            pageVC.dataSource = self
            superViewController.addChildViewController(pageVC)
            self.addSubview(pageVC.view)
            pageVC.didMove(toParentViewController: superViewController)
        }
    }
    
    func addPageVC() {
        if let pageVC = pageViewController {
            if let initViewController = p_pageViewControllerAt(index: 1) {
                currentIndex = 1
                pageVC.setViewControllers([initViewController], direction: .reverse, animated: false) { (bResult) in
                }
            }
        }
    }
    
    // MARK - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = p_indexOf(viewController: viewController as! QHPageViewController) - 1
        return p_goPageViewControllerAt(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = p_indexOf(viewController: viewController as! QHPageViewController) + 1
        return p_goPageViewControllerAt(index: index)
    }
    
}

class QHPageViewController: UIViewController {
    var index: Int = 0
    var cellView: QHPDFCellView?
    
    override func viewDidLoad() {
    }
    
    func addPDFCellView(delegate: QHPDFCellViewDocumentDelegate, rect: CGRect) {
        cellView = QHPDFCellView(frame: rect, scale: 1, spaceHeight: 0, index: index)
        cellView?.delegate = delegate
        self.view.addSubview(cellView!)
    }
}
