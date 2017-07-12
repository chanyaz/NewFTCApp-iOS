//
//  HotArticleCellRegular.swift
//  Page
//
//  Created by huiyun.he on 12/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import QuartzCore

class HotArticleCellRegular: UICollectionViewCell {

    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var hotTitle: UILabel!
    @IBOutlet weak var hotContent1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let shapeLayer = CAShapeLayer()
//        let path = CGMutablePath()
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        shapeLayer.lineWidth = 1.0
//        shapeLayer.lineDashPattern = [2, 5] //右边是间距，左边是每段长度
//        path.move(to: CGPoint(x:14.0,y:20+hotTitle.bounds.size.height))
//        path.addLine(to: CGPoint(x:self.bounds.size.width,y:20+hotTitle.bounds.size.height))
//        shapeLayer.path=path
//        shapeLayer.fillColor = UIColor.yellow.cgColor
//        self.layer.addSublayer(shapeLayer)
        
        
        containerView.backgroundColor = UIColor(hex: "#fff1e0")
        view.backgroundColor = UIColor(hex: "#f6e9d8")
        border.backgroundColor = UIColor(hex: Color.Content.border)
        hotTitle.backgroundColor = UIColor(hex: "#e9decf")
        hotTitle.addDashBorder(color:UIColor.blue , thickness: CGFloat(2))
        hotContent1.addDashBorder(color: UIColor.black, thickness: CGFloat(1))
    }
    
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    func updateUI() {
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
     
    }

}

extension UILabel {
    func addDashBorder(color: UIColor, thickness: CGFloat) {
        let shapeLayer = CAShapeLayer()
        let path = CGMutablePath()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = thickness
        shapeLayer.lineDashPattern = [2, 5] //右边是间距，左边是每段长度
        path.move(to: CGPoint(x:0,y:self.bounds.size.height))
        path.addLine(to: CGPoint(x:self.bounds.size.width,y:self.bounds.size.height))
        shapeLayer.path=path
        shapeLayer.fillColor = UIColor.yellow.cgColor
        self.layer.addSublayer(shapeLayer)

    }
    
}
