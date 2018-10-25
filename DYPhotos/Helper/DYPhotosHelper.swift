//
//  DYPhotosHelper.swift
//  Dayang
//
//  Created by 田向阳 on 2017/8/29.
//  Copyright © 2017年 田向阳. All rights reserved.
//

import UIKit
import Photos

public enum DYCompressType {
    case session
    case timeline
}

class DYPhotosHelper {

    /// 获取包含图片的相册列表
    ///
    /// - Parameter complete: 回调
    public class func getAllAlbumList(mediaType: DYPhotoMediaType, complete:(( _ array: [DYAlbumModel])->())?) {

        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                // 获取自定义相册
                let otherOptions = PHFetchOptions()
                otherOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
                var otherSort = [NSSortDescriptor]()
                otherSort.append(NSSortDescriptor(key: "startDate", ascending: true))
                otherOptions.sortDescriptors = otherSort
                let otherPhotos = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: otherOptions)
                
                // get all asset
                var allSort = [NSSortDescriptor]()
                let allPhotoOptions = PHFetchOptions()
                allSort.append(NSSortDescriptor(key: "creationDate", ascending: false))
                allPhotoOptions.sortDescriptors = allSort
                let allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
                
                var albumListArray = [DYAlbumModel]()
                
                let albumModel = DYAlbumModel()
                albumModel.albumName = "相机胶卷"
                albumModel.mediaType = mediaType
                albumModel.fetchAssets = allPhotos;
                if albumModel.assetList.count > 0 {
                    albumListArray.append(albumModel)
                }
                
                if otherPhotos.count > 0{
                    if otherPhotos.count == 1 {
                        let albumModel = DYAlbumModel()
                        let collection = otherPhotos[0]
                        albumModel.albumName = collection.localizedTitle
                        let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                        albumModel.mediaType = mediaType
                        albumModel.fetchAssets = assetsFetchResult
                        if albumModel.assetList.count > 0 {
                            albumListArray.append(albumModel)
                        }
                    }else{
                        for index  in 0...otherPhotos.count - 1 {
                            let albumModel = DYAlbumModel()
                            let collection = otherPhotos[index]
                            albumModel.albumName = collection.localizedTitle
                            let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                            albumModel.mediaType = mediaType
                            albumModel.fetchAssets = assetsFetchResult
                            if albumModel.assetList.count > 0 {
                                albumListArray.append(albumModel)
                            }
                        }
                    }
                }
                if complete != nil {
                    DispatchQueue.main.async {
                        complete!(albumListArray)
                    }
                }

            }
        }
        
    }
    
    /// 整理所有图片视频资源
    ///
    /// - Parameters:
    ///   - fetchAssets: 资源得集合
    ///   - complete: 回调
    public class func prepareAssetList(fetchAssets: PHFetchResult<PHAsset>, complete:((_ assetList: Array<DYPhotoModel>)->())?) {
        var assetListArray = [DYPhotoModel]()
        for index in 0...fetchAssets.count - 1 {
            let asset = fetchAssets[index]
            let photoModel = DYPhotoModel()
            photoModel.asset = asset;
            assetListArray.append(photoModel)
        }
        
        if complete != nil {
            complete!(assetListArray)
        }
    }
    
    /// 获取列表的缩略图
    ///
    /// - Parameters:
    ///   - asset: asset
    ///   - size: 大小
    ///   - complete: 回调
    public class func requestImage(asset: PHAsset,size: CGSize ,complete:dyRequestImageComplete?) {
        autoreleasepool { () in
            let imageManager = PHImageManager.default()
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: {(image, info)  in
                if complete != nil {
                    DispatchQueue.main.async {
                        complete!(image)
                    }
                }
            })
        }
    }
    
    /// 获取相册图片
    ///
    /// - Parameters:
    ///   - asset: asset
    ///   - isOrigin: 是否是原图
    ///   - complete: 回调 image对象
    public class func requestImage(asset: PHAsset?, isOrigin: Bool, complete:dyRequestImageComplete?) {
    
        guard let `asset` = asset else {
            complete?(nil)
            return }
        let options = PHImageRequestOptions()
        //        let size = PHImageManagerMaximumSize
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, string, orienttation, info) in
            guard let `data` = data else {
                complete?(nil)
                return
            }
            autoreleasepool{
                let originImage = UIImage(data: data)
                if !isOrigin {
                    let resultImage = originImage?.dyCompress(type: .session)
                    complete?(resultImage);
                    dy_Print(Double(resultImage?.imageData()?.count ?? 0)/1024.0)
                }else{
                    complete?(originImage);
                }
            }
        }
    }
    
    /// 获取视频资源的信息
    ///
    /// - Parameters:
    ///   - asset: asset
    ///   - complete: 回调
    public class func requestVideoInfo(asset: PHAsset ,complete:((_ videoURL: URL)->())?) {
        let imageManager = PHImageManager.default()        
        imageManager.requestAVAsset(forVideo: asset, options: nil) { (avAsset, audioMix, info) in
            let  infoString = info?["PHImageFileSandboxExtensionTokenKey"]
            if infoString != nil && complete != nil {
                DispatchQueue.main.async {
                let url = URL(fileURLWithPath: (infoString as! NSString).components(separatedBy: ";").last!)
                    complete!(url)
                }
            }
        }
    }
    
    public class func getVideoDefaultImage(url: URL,duration: TimeInterval, complete: dyRequestImageComplete?) {
        if complete == nil {
            return
        }
        let imageCache = ImageCache.default
        let cacheKey = url.absoluteString
        if let cacheImage = imageCache.retrieveImageInDiskCache(forKey: cacheKey) {
            complete!(cacheImage)
            return
        }
        DispatchQueue.global().async {
            let avAsset = AVURLAsset.init(url: url)
            let assetImageGenerator = AVAssetImageGenerator.init(asset: avAsset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureMode.encodedPixels
            
            var cmTime = CMTimeMakeWithSeconds(duration, 30)
            if duration == 0 {
                cmTime = CMTimeMakeWithSeconds(duration, 1);
            }
            do {
                let thumbImageRef =  try assetImageGenerator.copyCGImage(at: cmTime, actualTime: nil)
                let image = UIImage.init(cgImage: thumbImageRef)
                imageCache.store(image, forKey: imageCache.cachePath(forKey: cacheKey))
                dy_safeAsync {
                    complete!(image)
                }
            } catch _ {
                dy_safeAsync {
                    complete!(nil)
                }
            }
        }
    }
    
    // 根据地质类型生成URL
    public class func getURL(url: String) -> URL {
        if url.isNetUrl() {
            return URL.init(string: url)!
        }else{
            return URL.init(fileURLWithPath:url)
        }
    }
    
    /// 保存图片到相册
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - complete: 回调 是否保存成功
    public class func saveImageToAlbum(image: UIImage, complete:dyBoolComplete?) {
        getAuthorizationStatus { (status) -> (Void) in
            if status == .authorized {
                getCollection(complete: { (collection) -> (Void) in
                    PHPhotoLibrary.shared().performChanges({
                        if #available(iOS 9.0, *) {
                            let newAsset = PHAssetCreationRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset
                            if newAsset == nil {
                                DispatchQueue.main.async {
                                    if complete != nil{
                                        complete!(false)
                                    }
                                }
                                return
                            }
                            let array = NSMutableArray()
                            array.add(newAsset!)
                            let request = PHAssetCollectionChangeRequest.init(for: collection!)
                            request?.insertAssets(array, at: IndexSet.init(integer: 0))
                        } else {
                            UIImageWriteToSavedPhotosAlbum(image, DYPhotosHelper(), nil , nil)
                            if complete != nil{
                                complete!(true)
                            }
                        }
                    }, completionHandler: { (finish, error) in
                        DispatchQueue.main.async {
                            if complete != nil{
                                complete!(finish)
                            }
                        }
                    })
                })
            }else{
                if complete != nil {
                    complete!(false)
                }
            }
        }
    }
    
    /// 保存视频到相册
    ///
    /// - Parameters:
    ///   - videoURL: 视频的本地路径
    ///   - complete: 回调
    public class func saveVideoToAlbum(videoPath: String, complete:dyBoolComplete?) {
        
        if !FileManager.default.fileExists(atPath: videoPath) {
            if complete != nil{
                complete!(false)
            }
            return
        }
        let videoURL = URL(fileURLWithPath: videoPath)
       
        getAuthorizationStatus { (status) -> (Void) in
            if status == .authorized {
                getCollection(complete: { (collection) -> (Void) in
                    if collection == nil {
                        complete!(false)
                    }else{
                        PHPhotoLibrary.shared().performChanges({
                            if #available(iOS 9.0, *) {
                                let newAsset = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)?.placeholderForCreatedAsset
                                if newAsset == nil {
                                    DispatchQueue.main.async {
                                        if complete != nil{
                                            complete!(false)
                                        }
                                    }
                                    return
                                }
                                
                                let array = NSMutableArray()
                                array.add(newAsset!)
                                let request = PHAssetCollectionChangeRequest.init(for: collection!)
                                request?.insertAssets(array, at: IndexSet.init(integer: 0))
                            } else {
                                UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self,nil, nil)
                                DispatchQueue.main.async {
                                    if complete != nil{
                                        complete!(true)
                                    }
                                }
                            }
                        }, completionHandler: { (finish, error) in
                            DispatchQueue.main.async {
                                if complete != nil{
                                    complete!(finish)
                                }
                            }
                        })
                    }
                })
            }else{
                complete!(false)
            }
        }
    }
    
    /// 获取项目的相册
    ///
    /// - Returns: 相册对象
    private class func getCollection(complete: ((_ collection: PHAssetCollection?)->(Void))?) {
        
        if complete == nil {
            return;
        }
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
        if collections.count > 0 {
            if collections.count == 1 {
                let collection = collections[0]
                if appName == collection.localizedTitle {
                    complete!(collection)
                    return
                }
            }else{
                for index in 0...collections.count - 1 {
                    let collection = collections[index]
                    if appName == collection.localizedTitle {
                        complete!(collection)
                        return
                    }
                }
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            let collectionId = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: appName).placeholderForCreatedAssetCollection.localIdentifier
            PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionId], options: nil)
        }) { (finish, error) in
            if finish {
                let reslutCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                complete!(reslutCollections.lastObject!)
            }else{
                complete!(nil)
            }
        }
    }
    
   ///  get authorizationStatus
   ///
   /// - Returns: 返回是不授权
   public class func isOpenAuthority() -> Bool {
        return PHPhotoLibrary.authorizationStatus() != .denied
    }
    
    // jumpToSetting handle  privacyAuth
   public class func jumpToSetting(){
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }

    public class func getAuthorizationStatus(complete: ((_ status: PHAuthorizationStatus)->(Void))?){
        PHPhotoLibrary.requestAuthorization { (status) in
            if complete != nil {
                dy_safeAsync {
                    complete!(status)
                }
            }
        }
    }
}

extension Array {
    
    public func dy_objectAtIndex(index: Int) -> Element? {
        
        if index < self.count {
            return self[index]
        }
        return nil
    }
    
}

extension UIFont {
    
    public class func dy_systemFontWithSize(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size + self.dy_fontScaleSize())
    }
    
    public class func dy_boldSystemFontWithSize(size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size + self.dy_fontScaleSize())
    }
    
    
    private class func dy_fontScaleSize() -> CGFloat {
        if WINDOW_HEIGHT <= 568 {
            return -1
        }else if WINDOW_HEIGHT == 736{
            return 1
        }
        return 0
    }
    
}

extension UIImage {
    
    public class func  scaleImageFrame(image: UIImage?) -> CGRect {
        if image == nil || image?.size ==  CGSize.zero {
            return CGRect.zero
        }
        let screenSize = UIScreen.main.bounds.size
        let screenScale = screenSize.width / screenSize.height
        let imageScale = (image?.size.width)! / (image?.size.height)!
        
        let x = CGFloat(0)
        var y = CGFloat(0)
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        if imageScale > screenScale {
            width = screenSize.width
            height = width / imageScale
            y = (screenSize.height - height) / 2
        }else{
            width = screenSize.width
            height = width / imageScale
            y = 0
//            height = screenSize.height
//            width = height * imageScale
//            x = (screenSize.width - width) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public func imageData() -> Data? {
        return UIImageJPEGRepresentation(self, 1)
    }
    
    public func compressImage(toSize: CGSize) -> UIImage? {
        var newImage: UIImage? = nil
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height
        var scaleFactor = CGFloat(0)
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x:0.0,y: 0.0)
        if !imageSize.equalTo(size) {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if(widthFactor > heightFactor){
                scaleFactor = CGFloat(widthFactor)
            }
            else{
                scaleFactor = CGFloat(heightFactor)
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            if(widthFactor > heightFactor){
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }else if(widthFactor < heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = floor(scaledWidth)
        thumbnailRect.size.height = floor(scaledHeight)
        UIGraphicsBeginImageContext(thumbnailRect.size)
        self .draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func dyCompress(type: DYCompressType = .timeline) -> UIImage {
        let size = self.dyImageSize(type: type)
        let reImage = resizedImage(size: size)
        let data = UIImageJPEGRepresentation(reImage, 0.5)!
        return UIImage.init(data: data)!
    }
    
    private func dyImageSize(type: DYCompressType) -> CGSize {
        var width = self.size.width
        var height = self.size.height
        
        var boundary: CGFloat = 1280
        
        // width, height <= 1280, Size remains the same
        guard width > boundary || height > boundary else {
            return CGSize(width: width, height: height)
        }
        
        // aspect ratio
        let s = max(width, height) / min(width, height)
        if s <= 2 {
            // Set the larger value to the boundary, the smaller the value of the compression
            let x = max(width, height) / boundary
            if width > height {
                width = boundary
                height = height / x
            } else {
                height = boundary
                width = width / x
            }
        } else {
            // width, height > 1280
            if min(width, height) >= boundary {
                boundary = type == .session ? 800 : 1280
                // Set the smaller value to the boundary, and the larger value is compressed
                let x = min(width, height) / boundary
                if width < height {
                    width = boundary
                    height = height / x
                } else {
                    height = boundary
                    width = width / x
                }
            }
        }
        return CGSize(width: width, height: height)
    }
    
    private func resizedImage(size: CGSize) -> UIImage {
        let newRect = CGRect(x: 0, y: 0, width: ceil(size.width), height: ceil(size.height))
        var newImage: UIImage!
        UIGraphicsBeginImageContext(newRect.size)
        newImage = UIImage(cgImage: self.cgImage!, scale: 1, orientation: self.imageOrientation)
        newImage.draw(in: newRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

extension String {
    
    public func isNetUrl() ->Bool {
        if self.count > 0 {
            return self.hasPrefix("http://") || self.hasPrefix("https://")
        }
        return false
    }
    
    /// MD5
    ///
    /// - Returns: MD5
//    func md5() -> String {
//
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//
//        result.deallocate(capacity: digestLen)
//
//        return String(format: hash as String)
//    }
}

