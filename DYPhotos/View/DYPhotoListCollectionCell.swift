//
//  DYPhotoListCollectionCell.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

private let  ITEMWIDTH = 2.0 * (WINDOW_WIDTH - 4*4)/3.0

class DYPhotoListCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var photoModel: DYPhotoModel? {
        didSet{
            if photoModel != nil {
                videoButton.isHidden = !photoModel!.isVideo
                selectImageView.isHidden = !photoModel!.isSelect
                indexLabel.text = String(photoModel!.selectIndex)
                videoButton.setTitle(photoModel!.videoDurationShow(), for: .normal)
//                videoButton.ajustImagePosition(position: .left, offset: 5)
                corverImage.image = photoModel?.thumImage
                
                if photoModel!.isVideo && photoModel?.videoURL == nil {
                    DYPhotosHelper.requestVideoInfo(asset: (photoModel?.asset)!, complete: { (videoUrl) in
                        self.photoModel?.videoURL = videoUrl
                    })
                }
                
                if photoModel?.thumImage == nil {
                    DYPhotosHelper.requestImage(asset: (photoModel?.asset)!, size: CGSize.init(width: SCALE_WIDTH(width: 130), height: SCALE_WIDTH(width: 130)), complete: { (image) in
                        self.corverImage.image = image
                        self.photoModel?.thumImage = image
                    })
                }
            }
        }
    }
    
    //MARK:- animation
    func cellDidClickAnimation(complete:@escaping () -> ()) {
        let duration = 0.1
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }, completion: { (finish) in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                complete()
            })
        })
    }
    
     func createUI() {
        contentView.addSubview(corverImage)
        contentView.addSubview(selectImageView)
        selectImageView.addSubview(indexLabel)
        contentView.addSubview(videoButton)
        
        corverImage.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        selectImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        indexLabel.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview();
            make.size.equalTo(CGSize(width: 25, height: 25));
        }
        
        videoButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(25)
        }
        
        selectImageView.isHidden = true
        videoButton.isHidden = true
    }

    lazy var corverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var selectImageView :UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "ch_selectbg_photo")
        return imageView
    }()
    
    lazy var indexLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.dy_systemFontWithSize(size: 14)
        label.textAlignment = .center
        label.textColor = .black
        
        return label
    }()
    
    lazy var videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isUserInteractionEnabled = false
        button.setImage(#imageLiteral(resourceName: "file_video.png"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
}
