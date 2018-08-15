//
//  QHPDFCellView.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

protocol QHPDFCellViewDocumentDelegate: NSObjectProtocol {
    func documentForPDF(cell: QHPDFCellView) -> CGPDFDocument?
}

class QHPDFCellView: UIView {
    
    weak var delegate: QHPDFCellViewDocumentDelegate?
    
    var index: Int = 0
    
    deinit {
        #if DEBUG
        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, index: Int) {
        super.init(frame: frame)
        self.index = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(bounds)
        if index <= 0 {
            return
        }
        if let document = delegate?.documentForPDF(cell: self) {
            let count = document.numberOfPages
            if index > 0, index <= count {
                if let page = document.page(at: index) {
                    ctx.translateBy(x: 0, y: bounds.size.height)
                    ctx.scaleBy(x: 1, y: -1)
                    
                    ctx.saveGState()
                    let transform = page.getDrawingTransform(.cropBox, rect: bounds, rotate: 0, preserveAspectRatio: true)
                    ctx.concatenate(transform)
                    ctx.drawPDFPage(page)
                    ctx.restoreGState()
                }
            }
        }
    }
    
    func refresh() {
        setNeedsDisplay()
    }

}
