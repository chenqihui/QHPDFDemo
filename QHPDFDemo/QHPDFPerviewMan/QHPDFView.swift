//
//  QHPDFView.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

protocol QHPDFDataSource: NSObjectProtocol {
    func perviewPDF(view: UIView) -> CFURL?
    
    func showInPDFPage(view: UIView, index: Int)
}

enum QHPDFViewShowType {
    case list
    case page
}

class QHPDFView: UIView, UIScrollViewDelegate, QHPDFCellViewDocumentDelegate {
    
    var pageHeight: CGFloat = 0
    private(set) var document: CGPDFDocument?
    var currentIndex: Int = 0
    
    weak var dataSource: QHPDFDataSource?
    var showType: QHPDFViewShowType = .list
    
    // Page
    var pageViewController: UIPageViewController?
    var pageIsAnimating: Bool = false
    
    // Collection
    var collectionView: UICollectionView?
    var collectionScrollView: UIScrollView?
    var spaceHeight: CGFloat = 0
    
    deinit {
        #if DEBUG
        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        p_setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func p_setup() {
    }
    
    private func p_reload() {
        if let url = dataSource?.perviewPDF(view: self) {
            if let document = CGPDFDocument(url as CFURL) {
                self.document = document
                if showType == .list {
                    p_reloadCollectionView()
                }
                else if showType == .page {
                    p_reloadPageView()
                }
            }
        }
    }
    
    func reload() {
        p_reload()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionScrollView else {
            return
        }
        guard pageHeight > 0 else {
            return
        }
        let y = scrollView.contentOffset.y
        //        // 以页面 bottom 到达屏幕底部为翻页
        //        let currentIndex = ((y + self.frame.size.height) / scrollView.zoomScale) / pdfPageHeight
        // 以页面 top 到达屏幕顶部为翻页
        let cIndex = Int((y / scrollView.zoomScale) / pageHeight) + 1
        
        if let docu = document {
            let count = docu.numberOfPages
            guard currentIndex != cIndex, cIndex > 0, cIndex <= count else {
                return
            }
            currentIndex = cIndex
            dataSource?.showInPDFPage(view: self, index: currentIndex)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == collectionScrollView {
            return collectionView
        }
        return nil
    }
    
    // MARK: - QHPDFCellViewDocumentDelegate
    
    func documentForPDF(cell: QHPDFCellView) -> CGPDFDocument? {
        return document
    }

}
