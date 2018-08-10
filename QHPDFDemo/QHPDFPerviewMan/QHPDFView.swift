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
    
    private var scrollView: UIScrollView?
    private var cellView: QHPDFCellView?
    
    var pageViewController: UIPageViewController?
    var document: CGPDFDocument?
    var currentIndex: Int = 0
    
    private var originScale: CGFloat = 0
    
    private var pdfPageHeight: CGFloat = 0
    
    weak var dataSource: QHPDFDataSource?
    /*
     使用 原生的导航顶部 如iPhone X会多出 -88.0 的高度
     建议在 UIViewController 上套一个 UIView 再添加，就可以忽略
     */
    var originOffset: CGFloat = 0
    var spaceHeight: CGFloat = 0
    var showType: QHPDFViewShowType = .list
    
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
    
    private func p_addScrollView() {
        if scrollView == nil {
            scrollView = UIScrollView(frame: self.bounds)
            if let scrollV = scrollView {
                scrollV.delegate = self
                scrollV.maximumZoomScale = 4
                self.addSubview(scrollV)
            }
        }
        if let docu = document {
            if let page = docu.page(at: 1) {
                let rect = page.getBoxRect(.cropBox)
                let count = docu.numberOfPages
                originScale = bounds.size.width / rect.width
                
                if let scrollV = scrollView {
                    pdfPageHeight = rect.size.height * originScale + spaceHeight
                    let height = pdfPageHeight * CGFloat(count)
                    scrollV.contentSize.height = height
                    
                    if let cellV = cellView {
                        cellV.removeFromSuperview();
                    }
                    cellView = nil
                    
                    var frame = scrollV.bounds
                    frame.size.height = height
                    let cellV = QHPDFCellView(frame: frame, scale: originScale, spaceHeight: spaceHeight)
                    cellV.delegate = self
                    scrollV.addSubview(cellV)
                    cellView = cellV
                }
            }
        }
    }
    
    private func p_reload() {
        if let url = dataSource?.perviewPDF(view: self) {
            if let document = CGPDFDocument(url as CFURL) {
                self.document = document
                if showType == .list {
                    p_addScrollView()
                }
                else if showType == .page {
                    addPageVC()
                }
            }
        }
    }
    
    func reload() {
        p_reload()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pdfPageHeight > 0 else {
            return
        }
        let y = scrollView.contentOffset.y + originOffset
//        // 以页面 bottom 到达屏幕底部为翻页
//        let currentIndex = ((y + self.frame.size.height) / scrollView.zoomScale) / pdfPageHeight
        // 以页面 top 到达屏幕顶部为翻页
        let currentIndex = Int((y / scrollView.zoomScale) / pdfPageHeight) + 1
        self.currentIndex = currentIndex
        dataSource?.showInPDFPage(view: self, index: currentIndex)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cellView
    }
    
    // MARK: - QHPDFCellViewDocumentDelegate
    
    func documentForPDF(cell: QHPDFCellView) -> CGPDFDocument? {
        return document
    }

}
