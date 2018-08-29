//
//  QHPDFView+Collection.swift
//  QHPDFDemo
//
//  Created by Anakin chen on 2018/8/14.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import UIKit

// MARK - Public

extension QHPDFView {
    public func addCollectionViewIn(rect: CGRect, config: ((CGRect) -> UICollectionView?)) {
        showType = .collect
        
        let scrollV = UIScrollView(frame: rect)
        scrollV.contentSize = CGSize(width: rect.width, height: 0)
        scrollV.bouncesZoom = false
        scrollV.maximumZoomScale = 4
        scrollV.delegate = self
        addSubview(scrollV)
        collectionScrollView = scrollV
        
        var collectionV = config(scrollV.bounds)
        if collectionV == nil {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
            collectionV = UICollectionView(frame: scrollV.bounds, collectionViewLayout: layout)
            collectionV!.backgroundColor = UIColor.white
        }
        
        if let cv = collectionV {
            cv.dataSource = self
            cv.delegate = self
            cv.register(QHPDFCollectionViewCell.self, forCellWithReuseIdentifier: QHPDFView.CollectionViewCellIdentifier)
            scrollV.addSubview(cv)
            collectionView = cv
            
            if let gesture = cv.pinchGestureRecognizer {
                cv.removeGestureRecognizer(gesture)
            }
        }
    }
}

extension QHPDFView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let CollectionViewCellIdentifier = "QHCollectionViewCell"
    
    func p_reloadCollectionView() {
        if let docu = document {
            if let page = docu.page(at: 1) {
                let rect = page.getBoxRect(.cropBox)
                let originScale = bounds.size.width / rect.width
                
                pageHeight = rect.size.height * originScale
                
                collectionView?.reloadData()
                
                if currentIndex > 1 {
                    if let collectionV = collectionView {
                        let y = CGFloat(currentIndex - 1) * pageHeight * collectionV.zoomScale
                        let p = collectionV.contentOffset
                        collectionV.setContentOffset(CGPoint(x: p.x, y: y), animated: false)
                    }
                }
            }
        }
    }
    
    func p_scrollReloadCollectionView() {
    }
    
    // MARK - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let docu = document {
            let count = docu.numberOfPages
            return count
        }
        return 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QHPDFView.CollectionViewCellIdentifier, for: indexPath) as! QHPDFCollectionViewCell
        cell.pdfCellView.delegate = self
        cell.refreshAt(index: (indexPath.row + 1))
        return cell
    }
    
    // MARK - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: pageHeight)
    }
    
    // MARK - UICollectionViewDelegate
}

class QHPDFCollectionViewCell: UICollectionViewCell {
    private(set) var pdfCellView: QHPDFCellView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pdfCellView = QHPDFCellView(frame: bounds)
        addSubview(pdfCellView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Public
    
    func refreshAt(index: Int) {
        pdfCellView.index = index
        pdfCellView.refresh()
    }
}
