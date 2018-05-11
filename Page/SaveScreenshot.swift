import UIKit

class SaveScreenshot : UIActivity, Sharable {
    func performShare() {
        perform()
    }
    

    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "SaveScreenShot")
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "ScreenCapture")
    }
    
    override var activityTitle: String {
        return "保存到相册"
    }
    
    override class var activityCategory: UIActivityCategory {
        return UIActivityCategory.share
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        ShareHelper.shared.currentWebView?.snapshots(completion: { (image) in
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                Track.event(category: "Share", action: "iOS Screen Shot Save to Photos Album", label: ShareHelper.shared.webPageUrl)
            }
        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let ac: UIAlertController
        if let error = error {
            ac = UIAlertController(title: "无法保存图片", message: error.localizedDescription, preferredStyle: .alert)
        } else {
            ac = UIAlertController(title: "图片已保存", message: "您可以在照片(Photos)应用中查看", preferredStyle: .alert)
        }
        ac.addAction(UIAlertAction(title: "我知道了", style: .default))
        if let topViewController = UIApplication.topViewController() {
            topViewController.present(ac, animated: true, completion: nil)
        }
    }

}
