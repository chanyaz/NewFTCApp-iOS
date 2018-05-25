//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
    
    convenience init(hex: (day: String, night: String)) {
        let isNightMode = Setting.isSwitchOn("night-reading-mode")
        let hexString: String
        if isNightMode {
            hexString = hex.night.replacingOccurrences(of: "#", with: "")
        } else {
            hexString = hex.day.replacingOccurrences(of: "#", with: "")
        }
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
    
    convenience init(hex: (day: String, night: String), alpha: CGFloat) {
        let isNightMode = Setting.isSwitchOn("night-reading-mode")
        let hexString: String
        if isNightMode {
            hexString = hex.night.replacingOccurrences(of: "#", with: "")
        } else {
            hexString = hex.day.replacingOccurrences(of: "#", with: "")
        }
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
    }
    
    public convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
}

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!;
    }
}

extension UIViewController {
    
    func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }
    
    func layoutType() -> String {
        let type: String
        if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
            type = "regularLayout"
        } else {
            type = "compactLayout"
        }
        return type
    }
    
    
    
    
    public func showLaunchScreen() {
        // MARK: You can't insert a view controller into a navigation controller
        if self is UINavigationController {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "LaunchScreen") as? LaunchScreen {
            let fullScreenView = UIView()
            fullScreenView.frame = UIScreen.main.bounds
            fullScreenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // MARK: add as a childviewcontroller
            addChildViewController(controller)
            // MARK: Add the child's View as a subview
            fullScreenView.addSubview(controller.view)
            controller.view.frame = fullScreenView.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // MARK: tell the childviewcontroller it's contained in it's parent
            controller.didMove(toParentViewController: self)
            //view.insertSubview(fullScreenView, aboveSubview: self.tabBar)
            if let tabBarViewController = self as? UITabBarController {
                view.insertSubview(fullScreenView, aboveSubview: tabBarViewController.tabBar)
            } else {
                let lastViewIndex = view.subviews.count - 1
                view.insertSubview(fullScreenView, at: lastViewIndex)
            }
        }
    }
}


extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    
    
}

extension UIFont{
    var isBold: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func setBold() -> UIFont
    {
        if(isBold)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.insert([.traitBold])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    
    func setItalic()-> UIFont
    {
        if(isItalic)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.insert([.traitItalic])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    func desetBold() -> UIFont
    {
        if(!isBold)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.remove([.traitBold])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    
    func desetItalic()-> UIFont
    {
        if(!isItalic)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.remove([.traitItalic])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
}

extension TimeInterval{
    func unixToTimeStamp() -> String {
        let time = Date(timeIntervalSince1970: self)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "YYYY年MM月dd日 hh:mm"
        let timeString = dayTimePeriodFormatter.string(from: time)
        return timeString
    }
}

extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    func downHide(duration: TimeInterval = 1.0,delay: TimeInterval = 0,deltaY:CGFloat, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.transform = CGAffineTransform(translationX: 0,y: deltaY)
            self.setNeedsUpdateConstraints()
        },  completion: completion)
    }
    func upShow(duration: TimeInterval = 1.0,delay: TimeInterval = 0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.transform = CGAffineTransform.identity
            self.setNeedsUpdateConstraints()
        },  completion: completion)
    }
    
    //    func addOverlay(_ image: UIImage, to background: UIImageView, of size: CGFloat) {
    //        let overlayHeight = background.frame.height * size
    //        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: overlayHeight, height: overlayHeight))
    //        imageView.image = image
    //        if let containerView = background.superview {
    //        containerView.insertSubview(imageView, aboveSubview: background)
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: background, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
    //        containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: background, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
    //        containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayHeight))
    //        containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayHeight))
    //        }
    //    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x:0,y:0,width:self.frame.width,height:thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0,y:self.frame.height - thickness,width:self.frame.width,height:thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x:0,y:0,width:thickness,height:self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x:self.frame.width - thickness,y:0,width:thickness,height:self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}

extension UILabel {
    func addTextSpacing(value: Any) {
        if let textString = text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: value, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
// MARK: Set background color for UIButton
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension String {
    func removeHTMLTags() -> String {
        let newString = self.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)
        return newString
    }
    
    func cleanHTMLTags() -> String {
        let newString = self.replacingOccurrences(of: "[\r\n]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "'", with: "{singlequote}")
            .replacingOccurrences(of: "<div [classid]+=story_main_mpu.*</div>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<script type=\"text/javascript\">", with: "{JSScriptTagStart}")
            .replacingOccurrences(of: "</script>", with: "{JSScriptTagEnd}")
            .replacingOccurrences(of: "<script>", with: "{JSScriptTagStart}")
        return newString
    }
    
    func getFirstTag(_ blackList: [String]) -> String? {
        let cleanedString = self.replacingOccurrences(
            of: "[,，]+",
            with: ",",
            options: .regularExpression
        )
        let newArray = cleanedString.components(separatedBy: ",")
        let newArrayCleaned = newArray.filter{
            !blackList.contains($0)
        }
        if newArrayCleaned.count > 0 {
            let firstTag = newArrayCleaned[0]
            if firstTag != "" {
                return firstTag
            }
            return nil
        } else {
            return nil
        }
    }
    
    func checkAPIForLanguage() -> String {
        if LanguageSetting.shared.currentPrefence == 0 {
            return self
        } else {
            return self
        }
    }
    
    func addUrlEncoding() -> String {
        return self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }

    
    func md5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        //context.deallocate(capacity: 1)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
    func matchingFirstString(regex: String) -> String? {
        let matches = self.matchingArrays(regex: regex)
        if let matches = matches {
            if matches.count > 0 {
                let firstMatch = matches[0]
                let firstMatchCount = firstMatch.count
                if firstMatchCount > 0 {
                    return firstMatch[firstMatchCount-1]
                }
            }
        }
        return nil
    }
    
    func matchingArrays(regex: String) -> [[String]]? {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return nil }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        let matches = results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
        return matches
    }
    
    func matchingStrings(regexes: [String]) -> String? {
        for regex in regexes {
            if let matchString = self.matchingFirstString(regex: regex) {
                return matchString
            }
        }
        return nil
    }
}


// MARK: Shuffle and Array
extension Array {
    
    func shuffled() -> [Element] {
        var results = [Element]()
        var indexes = (0 ..< count).map { $0 }
        while indexes.count > 0 {
            let indexOfIndexes = Int(arc4random_uniform(UInt32(indexes.count)))
            let index = indexes[indexOfIndexes]
            results.append(self[index])
            indexes.remove(at: indexOfIndexes)
        }
        return results
    }
    
}


extension UIView {
    //MARK:计算属性parentViewController获取本view所在的controller
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


class UIButtonWithSpacing: UIButton {
    override func setTitle(_ title: String?, for state: UIControlState) {
        if let title = title, spacing != 0 {
            let color = super.titleColor(for: state) ?? UIColor.black
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [NSAttributedStringKey.kern: spacing,
                             NSAttributedStringKey.foregroundColor: color])
            super.setAttributedTitle(attributedTitle, for: state)
        } else {
            super.setTitle(title, for: state)
        }
    }
    
    fileprivate func updateTitleLabel_() {
        let states:[UIControlState] = [.normal, .highlighted, .selected, .disabled]
        for state in states {
            let currentText = super.title(for: state)
            self.setTitle(currentText, for: state)
        }
    }
    
    @IBInspectable var spacing:CGFloat = 0 {
        didSet {
            updateTitleLabel_()
        }
    }
}
