//
//  QHPDFView+Page.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/9.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

// MARK - Public

extension QHPDFView {    
    public func addPageViewIn(superViewController: UIViewController, rect: CGRect, config: (() -> UIPageViewController)) {
        showType = .page
        
        if let pageVC = pageViewController {
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
        }
        pageViewController = config()
        if let pageVC = pageViewController {
            pageVC.view.frame = rect
            pageVC.dataSource = self
            pageVC.delegate = self
            superViewController.addChildViewController(pageVC)
            self.addSubview(pageVC.view)
            pageVC.didMove(toParentViewController: superViewController)
        }
    }
}

extension QHPDFView: UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    
    private func p_indexOf(viewController: QHPageViewController) -> Int {
        return viewController.index
    }
    
    private func p_goPageViewControllerAt(index: Int) -> QHPageViewController? {
        if let vc = p_pageViewControllerAt(index: index) {
            currentIndex = index
            dataSource?.showInPDFPage(view: self, index: currentIndex)
            return vc
        }
        return nil
    }
    
    private func p_goPage(currentViewController: QHPageViewController, incrementIndex: Int) -> QHPageViewController? {
        if pageIsAnimating == true {
            return nil
        }
        let index = p_indexOf(viewController: currentViewController) + incrementIndex
        let vc = p_goPageViewControllerAt(index: index)
        return vc
    }
    
    private func p_pageViewControllerAt(index: Int) -> QHPageViewController? {
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
    
    func p_reloadPageView() {
        if let pageVC = pageViewController {
            if let initViewController = p_pageViewControllerAt(index: 1) {
                currentIndex = 1
                pageVC.setViewControllers([initViewController], direction: .reverse, animated: false) { (bResult) in
                    if bResult == true {
                        self.dataSource?.showInPDFPage(view: self, index: self.currentIndex)
                    }
                }
            }
        }
    }
    
    // MARK - UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return p_goPage(currentViewController: viewController as! QHPageViewController, incrementIndex: -1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return p_goPage(currentViewController: viewController as! QHPageViewController, incrementIndex: 1)
    }
    
    // MARK - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageIsAnimating = true
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if finished == true, completed == true {
            pageIsAnimating = false
//        }
    }
    
}

class QHPageViewController: UIViewController {
    private(set) var cellView: QHPDFCellView?
    
    var index: Int = 0
    
    override func viewDidLoad() {
    }
    
    func addPDFCellView(delegate: QHPDFCellViewDocumentDelegate, rect: CGRect) {
        let cellV = QHPDFCellView(frame: rect, index: index)
        cellV.delegate = delegate
        view.addSubview(cellV)
        cellView = cellV
    }
}
