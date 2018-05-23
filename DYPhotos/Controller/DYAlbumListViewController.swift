//
//  DYAlbumListViewController.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit

class DYAlbumListViewController: DYBaseTableViewController {

    var selectComplete: dySelectImagesComplete?
    var maxSelectCount: Int = 9 //做多选择的个数
    var mediaType: DYPhotoMediaType = .both //默认展示的资源类型
    //MARK: ControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initControllerFirstData()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: LoadData
    @objc private func loadData() {
        
        if !DYPhotosHelper.isOpenAuthority() {
            
            DYAlertViewHelper .showAlertWithCancel(title: "温馨提示", message: "您还没有开启相册权限，是否设置", controller: self, complete: { (index) in
                if index == 1 {
                    DYPhotosHelper.jumpToSetting()
                }else{
                    self.didClickNavigationBarLeftButton()
                }
            })
            return
        }
        
        DYPhotosHelper.getAllAlbumList(mediaType: self.mediaType) { (listArray) in
            self.dataArray?.removeAll()
            self.dataArray?.append(listArray)
            self.tableView.reloadData()
        }
    }
    
    private func initControllerFirstData() {
        self.title = "相册"
        cellHeight = 90
        self.setLeftButtonItemWithTitle(title: "取消")
    }

    private func registNotification() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func didClickNavigationBarLeftButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: tableViewDataSource & delegate
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "DYAlbumListTableViewCell"
    var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
    if cell == nil {
        cell = DYAlbumListTableViewCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    let albumListCell = cell as! DYAlbumListTableViewCell
    if let model = self.dataArray?.dy_objectAtIndex(index: indexPath.section)?.dy_objectAtIndex(index: indexPath.row){
        albumListCell.albumModel = model as? DYAlbumModel
    }
    return cell!
    
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let model = self.dataArray?.dy_objectAtIndex(index: indexPath.section)?.dy_objectAtIndex(index: indexPath.row){
            let photoListVC = DYPhotoListViewController()
            photoListVC.albumModel = model as? DYAlbumModel
            photoListVC.title = (model as? DYAlbumModel)?.albumName
            photoListVC.selectComplete = self.selectComplete
            photoListVC.maxSelectCount = self.maxSelectCount
            self.navigationController?.pushViewController(photoListVC, animated: true)
        }
    }
    
}

class DYBaseTableViewController: DYBaseViewController {
    
    public var cellHeight: CGFloat = 44;// 行高
    
    //MARK: ControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initControllerFirstData();
        createUI()
        loadData()
        registNotification()
    }
    //MARK: LoadData
    private func loadData() {
        
    }
    
    private func initControllerFirstData() {
        dataArray = [Array<Any>]()
    }
    //MARK: Action
    
    //MARK: AddNotificatoin
    private func registNotification() {
        
    }
    //MARK: CreateUI
    private func createUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    //MARK: Helper
    //MARK: lazy
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame:self.view.bounds,style:.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var dataArray: [Array<Any>]? {
        didSet{
            tableView.reloadData()
        }
    }
}

extension DYBaseTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.dataArray?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray?[section].count ?? 0
    }
    
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdextifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

class DYBaseViewController: UIViewController {
    
    //MARK: ControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dy_Print("init:\(self)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        dy_Print("dealloc:\(self)")
    }
    
    private func initControllerFirstData() {
        
    }
    //MARK: Action
    @objc public func didClickNavigationBarRightButton() {
        
    }
    
    @objc public func didClickNavigationBarLeftButton() {
        
    }
    
    /// 设置带有标题的 rightItem
    ///
    /// - Parameter title: 标题
    public func setRightButtonItemWithTitle(title: String) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(didClickNavigationBarRightButton))
    }
    
    /// 带有图片的 rightItem
    ///
    /// - Parameter image: 图片
    public func setRightButtonItemWithImage(image: UIImage) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickNavigationBarRightButton))
    }
    
    /// 设置带有标题的 leftItem
    ///
    /// - Parameter title: 标题
    public func setLeftButtonItemWithTitle(title: String) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(didClickNavigationBarLeftButton))
    }
    
    /// 带有图片的 leftItem
    ///
    /// - Parameter image: 图片
    public func setLeftButtonItemWithImage(image: UIImage) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickNavigationBarLeftButton))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.presentedViewController != nil && !(self.presentedViewController?.isBeingDismissed)! {
            return (self.presentedViewController?.preferredStatusBarStyle)!
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if self.presentedViewController != nil && !(self.presentedViewController?.isBeingDismissed)! {
            return (self.presentedViewController?.prefersStatusBarHidden)!
        }
        return false
    }
}
