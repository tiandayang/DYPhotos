//
//  ViewController.swift
//  DYPhotos
//
//  Created by 田向阳 on 2018/5/17.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit

private let  kItemsOfRow = 3
private let  kItemsSpace = 4.0
private let  ITEMWIDTH = 2.0 * (WINDOW_WIDTH - 4*4)/3.0

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    @IBAction func openAlbum(_ sender: Any) {
        let photoVC = DYAlbumListViewController()
        let nav = UINavigationController(rootViewController: photoVC)
        photoVC.mediaType = .both
        self.present(nav, animated: true, completion: nil)
        photoVC.selectComplete = {  [weak self] (array) in
            self?.imageArray.append(contentsOf: array)
            self?.collectionView.reloadData()
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        
        self.imageArray.removeAll()
        self.collectionView.reloadData()
        
    }
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = CGFloat(kItemsSpace);
        layout.minimumInteritemSpacing = CGFloat(kItemsSpace);
        layout.itemSize = CGSize(width: ITEMWIDTH/2.0, height: ITEMWIDTH/2.0)
        layout.sectionInset = UIEdgeInsets(top: CGFloat(0), left: CGFloat(kItemsSpace), bottom: CGFloat(kItemsSpace), right: CGFloat(kItemsSpace))
        let collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.delegate = self;
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        collection.isPagingEnabled = true
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    lazy var imageArray:Array<DYPhotoModel> = {
        return [DYPhotoModel]()
    }()
}

extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate,DYPhotoPreviewControllerDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.backgroundView = imageView
        let model = imageArray[indexPath.row]
        model.getCachedImage(complete: { (image) in
            imageView.image = image
        })
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var previewModels = [DYPhotoPreviewModel]()
        for model in imageArray {
            let previewModel = DYPhotoPreviewModel()
            previewModel.image = model.cacheImage
            if model.isVideo {
                previewModel.isVideo = true
                previewModel.videoURL = model.videoURL?.path //本地路径转成path 网络路径转成string
            }
            previewModels.append(previewModel)
        }
        
        let previewModel = DYPhotoPreviewModel()
        previewModel.isVideo = true
        previewModel.videoURL = "http://sunmu-bucket.oss-cn-hangzhou.aliyuncs.com/1530004410_ios.mp4?Expires=1530050892&OSSAccessKeyId=LTAIz9H8q2V1Eatn&Signature=VZ49Nc1W%2BSg53pDS4fuFa6loK9E%3D"
        previewModels.append(previewModel)
        let previewVC = DYPhotoPreviewController()
        previewVC.dataArray = previewModels
        previewVC.selectIndex = indexPath.row
        let cell = collectionView.cellForItem(at: indexPath)
        previewVC.thumbTapView = cell?.backgroundView as? UIImageView
        previewVC.tapSuperView = collectionView
        previewVC.delegate = self
        self.present(previewVC, animated: true, completion: nil)
    }
    
    func dyPhotoDismissTargetView(indexPath: IndexPath) -> UIImageView? {
       let cell = collectionView.cellForItem(at: indexPath)
        return cell?.backgroundView as? UIImageView
    }
}

