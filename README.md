# DYPhotos
## 一款基于photos封装的图片选择框架，以及一个媒体预览的功能
# Sample Code
```
 let photoVC = DYAlbumListViewController()
        let nav = UINavigationController(rootViewController: photoVC)
        photoVC.mediaType = .both
        self.present(nav, animated: true, completion: nil)
        photoVC.selectComplete = {  [weak self] (array) in
            self?.imageArray.append(contentsOf: array)
            self?.collectionView.reloadData()
        }
```
