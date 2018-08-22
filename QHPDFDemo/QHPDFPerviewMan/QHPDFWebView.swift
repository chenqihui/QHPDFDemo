//
//  QHPDFWebView.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/8.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

class QHPDFWebView: UIView, UIWebViewDelegate, UIScrollViewDelegate {

    private var webView: UIWebView?
    private var pdfPageHeight: CGFloat = 0
    private var count: Int = 0
    
    weak var dataSource: QHPDFDataSource?
    
    deinit {
        #if DEBUG
        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        p_setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func p_setup() {
        webView = UIWebView(frame: self.bounds)
        if let webV = webView {
            webV.scalesPageToFit = true
            webV.delegate = self
            webV.scrollView.delegate = self
            self.addSubview(webV)
        }
    }
    
    public func reload() {
        if let url = dataSource?.perviewPDF(view: self) {
            if let document = CGPDFDocument(url as CFURL) {
                count = document.numberOfPages
                
                let requset = URLRequest(url: url as URL)
                webView?.loadRequest(requset)
            }
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        pdfPageHeight = webView.scrollView.contentSize.height / CGFloat(count)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pdfPageHeight > 0 else {
            return
        }
        let y = scrollView.contentOffset.y
        //        // 以页面 bottom 到达屏幕底部为翻页
        //        let currentIndex = ((y + self.frame.size.height) / scrollView.zoomScale) / pdfPageHeight
        // 以页面 top 到达屏幕顶部为翻页
        let currentIndex = Int((y / scrollView.zoomScale) / pdfPageHeight) + 1
        
        dataSource?.showInPDFPage(view: self, index: currentIndex)
    }

}
