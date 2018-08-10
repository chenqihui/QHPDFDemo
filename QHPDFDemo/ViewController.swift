//
//  ViewController.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPDFWebViewAction(_ sender: Any) {
        let vc = PDFViewController.create(type: .webView)
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func showPDFViewAction(_ sender: Any) {
        let vc = PDFViewController.create(type: .pdfViewList)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPDFViewPageCurlAction(_ sender: Any) {
        let vc = PDFViewController.create(type: .pdfViewPageCurl)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPDFViewPageScrollAction(_ sender: Any) {
        let vc = PDFViewController.create(type: .pdfViewPageScroll)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @available(iOS 11.0, *)
    @IBAction func showPDFKitAction(_ sender: Any) {
        let vc = PDFKitViewController.create()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

