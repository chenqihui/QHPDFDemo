//
//  QHPDFView.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

public protocol QHPDFDataSource: NSObjectProtocol {
    func perviewPDF(view: UIView) -> CFURL?
}

public protocol QHPDFDelegate: NSObjectProtocol {
    // 当前页改变，当前页是 1 的时候（即首页），是不会回调，计算页面改变是根据当前页到达顶部才算，可能对于由于PDF的高小于屏幕，即浏览到，可是不会d到顶部，即不会回调。
    func showInPDFPage(view: UIView, index: Int)
    // 滑到底部的回调，不论多少页，这样滑到底部就回调，如果pdf总高度小于屏幕，也会b回调，即可以通过此判断是否浏览完c整个PDF
    func scrollBottomPDFPage(view: UIView)
}

enum QHPDFViewShowType {
    case none
    case scroll
    case page
    case collect
}

public class QHPDFView: UIView, UIScrollViewDelegate, QHPDFCellViewDocumentDelegate {
    
    var pageHeight: CGFloat = 0
    private(set) var document: CGPDFDocument?
    private(set) var pdfURL: CFURL?
    var currentIndex: Int = 0
    
    public weak var dataSource: QHPDFDataSource?
    public weak var delegate: QHPDFDelegate?
    var showType: QHPDFViewShowType = .none
    private(set) var count: Int = 0
    
    // Page
    var pageViewController: UIPageViewController?
    var pageIsAnimating: Bool = false
    
    // Collection
    var collectionView: UICollectionView?
    var collectionScrollView: UIScrollView?
    var spaceHeight: CGFloat = 0
    
    // Scroll
    var mainScrollView: UIScrollView?
    var contentScrollView: UIView?
    lazy var showIndexsArray = [Int]()
    var bJustShowIndexInRange = false
    
    deinit {
        dataSource = nil
        delegate = nil
        #if DEBUG
        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        p_setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func p_setup() {
    }
    
    private func p_reloadAt(index: Int) {
        if let url = dataSource?.perviewPDF(view: self) {
            if let pdfUrl = pdfURL, document != nil {
                if url == pdfUrl {
                    currentIndex = min(index, count)
                    switch showType {
                    case .scroll:
                        p_scrollReloadScrollView()
                    case .page:
                        p_scrollReloadPageView()
                    case .collect:
                        p_scrollReloadCollectionView()
                    case .none:
                        print("not show")
                    }
                    return
                }
            }
            if let document = CGPDFDocument(url as CFURL) {
                self.document = document
                pdfURL = url
                count = document.numberOfPages
                currentIndex = min(index, count)
                switch showType {
                case .scroll:
                    p_reloadScrollView()
                case .page:
                    p_reloadPageView()
                case .collect:
                    p_reloadCollectionView()
                case .none:
                    print("not show")
                }
            }
        }
    }
    
    private func p_endPage(in scrollV: UIScrollView) -> Bool {
        if scrollV.contentSize.height <= scrollV.contentOffset.y + scrollV.frame.size.height {
            return true
        }
        return false
    }
    
    // MARK - Public
    
    public func reload(_ index: Int = 1) {
        p_reloadAt(index: index)
    }
    
    public func pdfCount() -> Int {
        return count
    }
    
    // MARK - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pageHeight > 0 else {
            return
        }
        if scrollView == collectionView || scrollView == mainScrollView {
            let y = scrollView.contentOffset.y
            // 以页面 bottom 到达屏幕底部为翻页
//            let cIndex = Int(((y + self.frame.size.height) / scrollView.zoomScale) / pageHeight)
            // 以页面 top 到达屏幕顶部为翻页
            
            var cIndex = 0
            if p_endPage(in: scrollView) {
                cIndex = count
            }
            else {
                cIndex = Int((y / scrollView.zoomScale) / pageHeight) + 1
            }
            if y + scrollView.frame.size.height >= scrollView.contentSize.height {
                delegate?.scrollBottomPDFPage(view: self)
            }
            
            guard currentIndex != cIndex, cIndex > 0, cIndex <= count else {
                return
            }
            currentIndex = cIndex
            if scrollView == mainScrollView {
                   p_scrollViewRefresh()
            }
            delegate?.showInPDFPage(view: self, index: currentIndex)
        }
    }
    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        if scrollView == collectionScrollView {
//            var size = scrollView.contentSize
//            size.height = 0
//            scrollView.contentSize = size
//        }
//    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == collectionScrollView {
            return collectionView
        }
        else if scrollView == mainScrollView {
            return contentScrollView
        }
        return nil
    }
    
    // MARK - QHPDFCellViewDocumentDelegate
    
    public func documentForPDF(cell: QHPDFCellView) -> CGPDFDocument? {
        return document
    }

}
