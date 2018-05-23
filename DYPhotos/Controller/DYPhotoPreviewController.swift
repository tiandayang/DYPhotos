//
//  DYPhotoPreviewController.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

protocol DYPhotoPreviewControllerDelegate: NSObjectProtocol {
    func dyPhotoDismissTargetView(indexPath: IndexPath) -> UIImageView?
}
class DYPhotoPreviewController: DYBaseViewController {
    
    open var thumbTapView: UIImageView?// 点击的view
    open var tapSuperView: UIScrollView? // imageView的滚动父视图  collectionView 或者 tableView
    open var selectIndex: Int = 0 //当前展示的索引
    
    //手势
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var originCenter: CGPoint!
    fileprivate var isTap: Bool = false //是否是点击取消
    weak var delegate: DYPhotoPreviewControllerDelegate?
    
    open var dataArray: Array<DYPhotoPreviewModel>?{
        didSet{
            loadData()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: ControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initControllerFirstData()
        createUI()
        loadData()
        registNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configVideo(isDisAppear: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configVideo(isDisAppear: true)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    //MARK: LoadData
    private func loadData() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: WINDOW_WIDTH * CGFloat(selectIndex), y: 0), animated: false)
    }
    
    private func initControllerFirstData() {
        view.backgroundColor = .black
    }
    //MARK: Action
    private func configVideo(isDisAppear: Bool) {
        let cell = collectionView.visibleCells.first
        if cell != nil && (cell?.isKind(of: DYPhotoPreviewVideoCell.classForCoder()))!{
            let videoCell = cell as! DYPhotoPreviewVideoCell
            videoCell.isDisplay = !isDisAppear
        }
    }
    
    
    @objc private func panGestureAction(sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: sender.view)
//        var scale = 1 - (translation.y / view.frame.size.height)
//        scale = scale < 0 ? 0 : scale
//        scale = scale > 1 ? 1 : scale
        switch sender.state {
        case .possible:
            break
        case .began:
            dismiss(animated: true, completion: nil)
            break
        case .changed:
//            self.collectionView.center = CGPoint.init(x: self.originCenter.x + translation.x * scale, y: self.originCenter.y + translation.y);
//            self.collectionView.transform = CGAffineTransform.init(scaleX: scale, y: scale);
            break
        default:
//        .failed:
//        .cancelled:
//        .ended:
//            if scale > 0.8 {
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.collectionView.center = self.originCenter;
//                    self.collectionView.transform = CGAffineTransform.identity
//                })
//            }
            break
        }
    }
    
    //MARK: AddNotificatoin
    private func registNotification() {
        
    }
    //MARK: CreateUI
    private func createUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
        originCenter = collectionView.center
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureAction))
        self.view.addGestureRecognizer(panGesture)
    }
 
    lazy var collectionView: UICollectionView = {
        let layout = DYPhotoPreViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 30
        layout.itemSize = CGSize(width: WINDOW_WIDTH, height: WINDOW_HEIGHT)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(DYPhotoPreViewImageCell.self, forCellWithReuseIdentifier: "DYPhotoPreViewImageCell")
        collectionView.register(DYPhotoPreviewVideoCell.self, forCellWithReuseIdentifier: "DYPhotoPreviewVideoCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .fade
    }
}

extension DYPhotoPreviewController: UICollectionViewDelegate, UICollectionViewDataSource, DYPhotoPreviewCellDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataArray?[indexPath.item]
        if !(model?.isVideo)! {
            let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DYPhotoPreViewImageCell", for: indexPath) as! DYPhotoPreViewImageCell
            imageCell.photoModel = model
            imageCell.delegate = self
            return imageCell
        }else{
            let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DYPhotoPreviewVideoCell", for: indexPath) as! DYPhotoPreviewVideoCell
            videoCell.photoModel = model
            videoCell.delegate = self
            return videoCell;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.isKind(of: DYPhotoPreviewVideoCell.self) {
            (cell as! DYPhotoPreviewVideoCell).isDisplay = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.isKind(of: DYPhotoPreviewVideoCell.self) {
            (cell as! DYPhotoPreviewVideoCell).isDisplay = false
        }
    }
    
    func dYPhotoPreviewCellSingleTap(index: Int) {
        isTap = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func dYPhotoPreviewCellLongPress(photoModel: DYPhotoPreviewModel?) {
        
        if photoModel == nil {
            return
        }
        DYActionSheetHelper.showActionSheet(title: nil, items: ["保存到相册"], cancelTitle: "取消", controller: self) { (index) in
            if index == 1 {
                if !(photoModel?.isVideo)! {
                    DYPhotosHelper.saveImageToAlbum(image: (photoModel?.image)!, complete: { (finish) in
                        let title = finish ? "保存成功" : "保存失败"
                        dy_Print(title)
                        DYAlertViewHelper.showAlert(title: title, controller: self, complete: nil)
                    })
                }else{
                    if photoModel?.videoPath != nil {
                        DYPhotosHelper.saveVideoToAlbum(videoPath:(photoModel?.videoPath)!, complete: { (finish) in
                            let title = finish ? "保存成功" : "保存失败"
                            dy_Print(title)
                            DYAlertViewHelper.showAlert(title: title, controller: self, complete: nil)
                        })
                    }
                }
            }
        }
        
    }
}

//动画的代理
extension DYPhotoPreviewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DYPhotoPreviewAnimation.init(thumbTapView: self.thumbTapView)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.delegate != nil {
            if let indexPAth = collectionView.indexPathsForVisibleItems.last {
                self.thumbTapView = self.delegate?.dyPhotoDismissTargetView(indexPath: indexPAth)
            }
        }
        return DYPhotoPreviewAnimation.init(thumbTapView: self.thumbTapView)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !isTap {
            return DYPhotoPercentInteractive.init(gesture: self.panGesture)
        }
        return nil
    }
}
