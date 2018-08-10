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
    
    private var spaceHeight: CGFloat = 0
    
    weak var delegate: QHPDFCellViewDocumentDelegate?
    
    var scale: CGFloat = 1
    var index: Int = 0
    
    deinit {
        #if DEBUG
//        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    init(frame: CGRect, scale: CGFloat, spaceHeight: CGFloat) {
        super.init(frame: frame)
        self.scale = scale
        self.spaceHeight = spaceHeight
    }
    
    init(frame: CGRect, scale: CGFloat, spaceHeight: CGFloat, index: Int) {
        super.init(frame: frame)
        self.scale = scale
        self.spaceHeight = spaceHeight
        self.index = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    /*
     可修改为绘制前后几页的优化，当总页数过多的时候
     */
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(bounds)
        if let document = delegate?.documentForPDF(cell: self) {
            let count = document.numberOfPages
            if index == 0 {
                for index in 1...count {
                    if let page = document.page(at: index) {
                        let rect = page.getBoxRect(.cropBox)
                        ctx.saveGState()
                        ctx.translateBy(x: 0, y: rect.height * CGFloat(index) * scale + spaceHeight * CGFloat(index - 1))
                        ctx.scaleBy(x: 1, y: -1)
//                        ctx.scaleBy(x: scale, y: scale)
                        ctx.drawPDFPage(page)
                        
                        ctx.addRect(CGRect(x: 0, y: rect.height, width: rect.width, height: spaceHeight))
                        ctx.setFillColor(UIColor.lightGray.cgColor)
                        ctx.fillPath()
                        
                        ctx.restoreGState()
                    }
                }
            }
            else if index > 0, index <= count {
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

}
