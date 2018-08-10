//
//  PDFKitViewController.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/10.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

import PDFKit

@available(iOS 11.0, *)
class PDFKitViewController: UIViewController, PDFDocumentDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    var pdfView: PDFView!
    var pdfDocument: PDFDocument!
    var pdfThumbnailView: PDFThumbnailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pdfView = PDFView(frame: self.view.bounds)
        self.contentView.addSubview(pdfView)
        
        
        guard let path = Bundle.main.path(forResource: "mp4", ofType: "pdf") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        pdfDocument = PDFDocument(url: url)
        pdfDocument.delegate = self
        
        pdfView.document = pdfDocument
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func create() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(self).components(separatedBy: ".").last!
        let viewController = storyboard.instantiateViewController(withIdentifier: className)
        
        return viewController
    }
    
    // MARK - PDFDocumentDelegate
    
    func classForPage() -> AnyClass {
        return WatermarkPage.self
    }
    
    // MARK - Action

    @IBAction func showPDFThumbnailViewAction(_ sender: Any) {
        guard pdfThumbnailView == nil else {
            pdfThumbnailView.isHidden = !pdfThumbnailView.isHidden
            return
        }
        pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: 88, width: view.frame.size.width, height: 60))
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.thumbnailSize = CGSize(width: 30, height: 50)
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.backgroundColor = UIColor.lightGray
        self.view.addSubview(pdfThumbnailView)
    }
    
    @IBAction func testAction(_ sender: Any) {
        if let pdfOutline = pdfDocument.outlineRoot {
            print("root = \(String(describing: pdfOutline.label))")
            for index in 1...pdfOutline.numberOfChildren {
                let childOutline = pdfOutline.child(at: index)
                print("\(String(describing: childOutline?.label))")
            }
        }
        
        let radioButton = PDFAnnotation(bounds: CGRect(x: 135, y: 200, width: 24, height: 24), forType: .widget, withProperties: nil)
        radioButton.widgetFieldType = .button
        radioButton.widgetControlType = .radioButtonControl
        radioButton.backgroundColor = UIColor.blue
        pdfView.currentPage?.addAnnotation(radioButton)

    }
}

@available(iOS 11.0, *)
class WatermarkPage: PDFPage {
    
    // 3. Override PDFPage custom draw
    /// - Tag: OverrideDraw
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        // Draw original content
        super.draw(with: box, to: context)
        
        // Draw rotated overlay string
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let pageBounds = self.bounds(for: box)
        context.translateBy(x: 0.0, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat.pi / 4.0)
        
        let string: NSString = "U s e r   3 1 4 1 5 9"
        let attributes = [
            NSAttributedStringKey.foregroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5),
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 64)
        ]
        
        string.draw(at: CGPoint(x:250, y:40), withAttributes: attributes)
        
        context.restoreGState()
        UIGraphicsPopContext()
        
    }
}
