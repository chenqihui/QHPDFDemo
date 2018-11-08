//
//  QHPDFCellView.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/7.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

public protocol QHPDFCellViewDocumentDelegate: NSObjectProtocol {
    func documentForPDF(cell: QHPDFCellView) -> CGPDFDocument?
}

public class QHPDFCellView: UIView {
    
    weak var delegate: QHPDFCellViewDocumentDelegate?
    
    var index: Int = 0
    
    override public class var layerClass: AnyClass {
        get {
            return CATiledLayer.self
        }
    }
    
    deinit {
        #if DEBUG
//        print("[\(type(of: self)) \(#function)]")
        #endif
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tiledlayer = CATiledLayer(layer: self)
        tiledlayer.tileSize = CGSize(width: 100, height: 100)
    }
    
    init(frame: CGRect, index: Int) {
        super.init(frame: frame)
        self.index = index
        let tiledlayer = CATiledLayer(layer: self)
        tiledlayer.tileSize = CGSize(width: 100, height: 100)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override public func draw(_ layer: CALayer, in ctx: CGContext) {
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
