import UIKit

class OpenInSafari : UIActivity, Sharable {
    func performShare() {
        perform()
    }
    
    
    init(to: String) {
        self.to = to
        self.text = ""
    }
    
    var to: String
    var text:String?

    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "openInSafari")
    }
    
    override var activityImage: UIImage? {
        if to == "safari-custom" {
            return UIImage(named: "SafariCustom")
        } else {
            return UIImage(named: "Safari")
        }
    }
    
    override var activityTitle: String {
        return "打开链接"
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
