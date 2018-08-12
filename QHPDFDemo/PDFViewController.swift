//
//  PDFViewController.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit
import PDFKit

enum PDFViewType {
    case webView
    case pdfViewList
    case pdfViewPageCurl
    case pdfViewPageScroll
}

class PDFViewController: UIViewController, QHPDFDataSource {

    @IBOutlet weak var contentView: UIView!
    private var type = PDFViewType.pdfViewList
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        switch type {
        case .webView:
            p_addPDFWebView()
        case .pdfViewList:
            p_addPDFView(transitionStyle: nil)
        case .pdfViewPageCurl:
            p_addPDFView(transitionStyle: .pageCurl)
        case .pdfViewPageScroll:
            p_addPDFView(transitionStyle: .scroll)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func p_addPDFView(transitionStyle style: UIPageViewControllerTransitionStyle?) {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - contentView.frame.origin.y)
        let pdfView = QHPDFView(frame: rect)
//        pdfView.originOffset = 88
        pdfView.dataSource = self
        if let s = style {
            pdfView.showType = .page
            pdfView.addPageViewControllerIn(superViewController: self, rect: rect, transitionStyle: s, navigationOrientation: .horizontal)
        }
        else {
            pdfView.spaceHeight = 10
            pdfView.showType = .list
        }
        contentView.addSubview(pdfView)
        pdfView.reload()
    }
    
    private func p_addPDFWebView() {
        let webView = QHPDFWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - contentView.frame.origin.y))
        webView.dataSource = self
        contentView.addSubview(webView)
        webView.reload()
    }
    
    // MARK - Action
    
    class func create(type: PDFViewType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(self).components(separatedBy: ".").last!
        let viewController = storyboard.instantiateViewController(withIdentifier: className)
        if let vc = viewController as? PDFViewController {
            vc.type = type
        }
        
        return viewController
    }
    
    // MARK - QHPDFDataSource
    
    func perviewPDF(view: UIView) -> CFURL? {
        guard let path = Bundle.main.path(forResource: "PDF32000_2008", ofType: "pdf") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        return url as CFURL
    }
    
    func showInPDFPage(view: UIView, index: Int) {
        print("当前页码：\(index)")
    }

}
