import UIKit

class SaveScreenShot : UIActivity {

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
        if let url = URL(string: ShareHelper.shared.webPageUrl) {
            UIApplication.shared.openURL(url)
        }
    }
    
}
