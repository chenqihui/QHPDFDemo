//
//  QHPDFView+Scroll.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

extension QHPDFView {
    public func addScrollViewIn(rect: CGRect) {
        showType = .scroll
        
        let scrollView = UIScrollView(frame: rect)
        scrollView.maximumZoomScale = 4
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        addSubview(scrollView)
        mainScrollView = scrollView
    }
    
    func scrollViewAt(index: Int) {
        if let docu = document {
            let count = docu.numberOfPages
            currentIndex = min(index, count)
            p_scrollViewAtCurrentIndex()
        }
    }
}

extension QHPDFView {
    
    static let scrollPageIncrementIndex = 8
    static let scrollPageControlIndexCount = 5
    
    func p_reloadScrollView() {
        if let docu = document {
            if let page = docu.page(at: 1) {
                let rect = page.getBoxRect(.cropBox)
                let originScale = bounds.size.width / rect.width
                
                pageHeight = rect.size.height * originScale
                let count = docu.numberOfPages
                let countPagesHeight = pageHeight * CGFloat(count)
                if let mainSV = mainScrollView {
                    var newSize = mainSV.contentSize
                    if countPagesHeight > newSize.height {
                        newSize.height = countPagesHeight
                        mainSV.contentSize = newSize
                    }
                    
                    contentScrollView?.removeFromSuperview()
                    contentScrollView = nil
                    
                    let contentV = UIView(frame: CGRect(origin: CGPoint.zero, size: newSize))
                    contentV.backgroundColor = UIColor.white
                    mainSV.addSubview(contentV)
                    contentScrollView = contentV
                    showIndexsArray.removeAll()
                    
                    if count > QHPDFView.scrollPageIncrementIndex * 2 + QHPDFView.scrollPageControlIndexCount {
                        bJustShowIndexInRange = true
                    }
                }
            }
        }
        if CGFloat(count) * pageHeight <= self.frame.size.height {
            currentIndex = 1
        }
        p_scrollViewAtCurrentIndex()
        p_scrollViewRefresh()
    }
    
    func p_scrollViewRefresh() {
        if let docu = document {
            let count = docu.numberOfPages
            if count > 0 {
                let minIdx = max(1, currentIndex - QHPDFView.scrollPageIncrementIndex)
                let maxIdx = min(currentIndex + QHPDFView.scrollPageIncrementIndex, count)
                p_addPages(minIdx: minIdx, maxIdx: maxIdx)
                p_removePages(minIdx: minIdx, maxIdx: maxIdx)
            }
        }
    }
    
    private func p_addPages(minIdx: Int, maxIdx: Int) {
        if let contenV = contentScrollView {
            if let scrollV = mainScrollView {
                for idx in minIdx...maxIdx {
                    if showIndexsArray.contains(idx) == true {
                        continue
                    }
                    showIndexsArray.append(idx)
                    let rect = CGRect(x: 0, y: pageHeight * CGFloat(idx - 1), width: scrollV.frame.size.width, height: pageHeight)
                    let cellV = QHPDFCellView(frame: rect, index: idx)
                    cellV.delegate = self
                    cellV.tag = idx
                    //                    print("add == \(idx)")
                    contenV.addSubview(cellV)
                }
            }
        }
    }
    
    private func p_removePages(minIdx: Int, maxIdx: Int) {
        if let contenV = contentScrollView {
            if bJustShowIndexInRange == true {
                if currentIndex > QHPDFView.scrollPageIncrementIndex {
                    let removeIndexsArray = showIndexsArray.filter { (idx: Int) -> Bool in
                        if idx > maxIdx || idx < minIdx {
                            return true
                        }
                        return false
                    }
                    if removeIndexsArray.count > QHPDFView.scrollPageControlIndexCount {
                        for idx in removeIndexsArray {
                            if let view = contenV.viewWithTag(idx) {
//                                print("remove == \(idx)")
                                view.removeFromSuperview()
                            }
                            if let index = showIndexsArray.index(of: idx) {
                                showIndexsArray.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func p_scrollViewAtCurrentIndex() {
        if let scrollV = mainScrollView {
            let y = CGFloat(currentIndex - 1) * pageHeight * scrollV.zoomScale
            let p = scrollV.contentOffset
            scrollV.setContentOffset(CGPoint(x: p.x, y: y), animated: false)
            //            scrollV.bounds = scrollV.bounds.offsetBy(dx: p.x, dy: y)
        }
    }
    
    func p_scrollReloadScrollView() {
        p_scrollViewAtCurrentIndex()
        p_scrollViewRefresh()
    }
}
