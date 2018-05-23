//
//  DYPhotoPreviewBaseCell.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/30.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

protocol DYPhotoPreviewCellDelegate: NSObjectProtocol {

    func dYPhotoPreviewCellSingleTap(index: Int)
    func dYPhotoPreviewCellLongPress(photoModel: DYPhotoPreviewModel?)
    
}

class DYPhotoPreviewBaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: DYPhotoPreviewCellDelegate?
    var imageView: UIImageView?
    var indexPath: IndexPath?
    
    func createUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction))
        self.addGestureRecognizer(longPress)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2;
        self.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
    }
    
    var photoModel: DYPhotoPreviewModel? {
        didSet{
            if photoModel != nil {
                setPhotoModel()
            }
        }
    }
    
    public func setPhotoModel() {}
 
    @objc private func tapAction() {
        if self.delegate != nil {
            self.delegate?.dYPhotoPreviewCellSingleTap(index: indexPath?.row ?? 0)
        }
    }
    
    @objc private func longPressAction(longPress: UILongPressGestureRecognizer){
    
        if longPress.state == .began && photoModel?.asset == nil {
            if self.delegate != nil {
                self.delegate?.dYPhotoPreviewCellLongPress(photoModel: self.photoModel)
            }
        }
    }
    
    @objc public func doubleTapAction(doubleTap: UITapGestureRecognizer) {}
}
