//
//  PageCollectionViewLayoutH.swift
//  Page
//
//  Created by huiyun.he on 13/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PageCollectionViewLayoutH: UICollectionViewFlowLayout {
    let adHeight = [CGFloat]();
    var cellPadding: CGFloat = 6.0
    let screenOrientation:UIDeviceOrientation=UIDevice.current.orientation
    
    fileprivate var contentHeight:CGFloat  = 0.0
    fileprivate var contentWidth: CGFloat
    {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    var attributesList = [UICollectionViewLayoutAttributes]()
    var attributesList1 = [UICollectionViewLayoutAttributes]()
    
    
    var numberOfColumns = 3
    var numberOfColumns4 = 4
    override func invalidateLayout() {
        
    }
    
    override class var layoutAttributesClass : AnyClass {
        return UICollectionViewLayoutAttributes.self
    }
    override var collectionViewContentSize : CGSize {
        
        return CGSize(width:(collectionView!.bounds.width),height:contentHeight)
        
    }
    
    override func prepare() {
        //        collectionView?.isPagingEnabled = true
        print("----HHHHhengping   chuxian----")
        
        var preSectionHeight = CGFloat(0);
        
        var adHeight: CGFloat = 0
        let adWidth: CGFloat = 356
        let collectionViewHeight = collectionView!.bounds.height
//        let contentWidth = self.contentWidth
        let numSections = collectionView!.numberOfSections - 1
        
       
                    let contentWidth1 = collectionView!.bounds.width - (collectionView!.contentInset.left + collectionView!.contentInset.right)
            print ("screen1 --\(collectionViewHeight)--")
            print ("contentWidth1 --\(contentWidth1)--")
            if collectionView!.bounds.width<1050{
                adHeight = 350
            }else{
                adHeight = 380
            }
            
            //with ad line
            let widthItemWithAd: CGFloat = (contentWidth1 - adWidth)/3
            let heightItemWithAd = adHeight

            
            let widthItem2: CGFloat = 328
            var heightItem2: CGFloat = 0
            var heightItem1: CGFloat = 0
            
            if collectionView!.bounds.width<1050{
                heightItem2 = (collectionViewHeight - heightItemWithAd)+CGFloat(30)
            }else if collectionView!.bounds.width>1050 && collectionView!.bounds.width<1300{
                heightItem2 = (collectionViewHeight - heightItemWithAd)-CGFloat(30)
            }else{
                heightItem2 = (collectionViewHeight - heightItemWithAd)-CGFloat(50)
            }
            
            
            let widthItem1 = contentWidth1 - widthItem2
            heightItem1 = heightItem2
            
            let widthHotItem = adWidth
            let heightHotItem = heightItemWithAd*2
            
            let widthItemWithHot = widthItemWithAd
            let heightItemWithHot = heightItemWithAd
            
            let widthItemWithSmall = contentWidth1/CGFloat(numberOfColumns4)
            //            let heightItemWithSmall = (collectionViewHeight/CGFloat(2))*1.2
            var heightItemWithSmall: CGFloat = 0
            if collectionView!.bounds.width<1150{
                heightItemWithSmall = (collectionViewHeight/CGFloat(2))*1.2
            }else{
                heightItemWithSmall = (collectionViewHeight/CGFloat(2))
            }
            
            //Define the size of the Offset
            var xOffset = [CGFloat]()
            for column in 0 ..< 4 {
                xOffset.append(CGFloat(column) * widthItemWithSmall )
            }
            let sectionHeight=CGFloat(0);
            
            if numSections != -1{
                
                for j in 0...numSections {
                    
                    let endIndex = collectionView!.numberOfItems(inSection: j)
                    
                    //                    print ("collectionView!.contentInset --\(collectionView!.bounds.height)--")
                    
                    
                    if endIndex != 0{
                        
                        
                        var column = 0
                        var yOffset = [CGFloat](repeating: preSectionHeight+heightItem1+heightItemWithAd+heightHotItem, count: numberOfColumns4)
                        
                        attributesList = (0...endIndex-1).map { (i) ->UICollectionViewLayoutAttributes in
                            
                            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: j))
                            
                            
                            if   i == 0{
                                
                                let frame = CGRect(x: 0, y: 0, width: widthItem1, height: heightItem1)
                                attributes.frame = frame
                                
                            }else if  i==1 {
                                
                                let frame = CGRect(x: widthItem1, y: 0, width: widthItem2, height: heightItem2)
                                attributes.frame = frame
                            }else if i==2 {
                                
                                let frame = CGRect(x: 0, y: preSectionHeight+heightItem1, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                                
                            }else if i==3 {
                                let frame = CGRect(x: widthItemWithAd, y: preSectionHeight+heightItem1, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==4 {
                                let frame = CGRect(x: widthItemWithAd*2, y:preSectionHeight+heightItem1, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==5{
                                let frame = CGRect(x: widthItemWithAd*3, y: preSectionHeight+heightItem1, width: adWidth, height: adHeight)
                                attributes.frame = frame
                            }else if i==6 {
                                let frame = CGRect(x: 0, y: preSectionHeight+heightItem1+heightItemWithAd, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==7 {
                                let frame = CGRect(x: widthItemWithAd, y: preSectionHeight+heightItem1+heightItemWithAd, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==8 {
                                let frame = CGRect(x: widthItemWithAd*2, y:preSectionHeight+heightItem1+heightItemWithAd, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==9 {
                                let frame = CGRect(x: widthItemWithAd*3, y:preSectionHeight+heightItem1+heightItemWithAd, width: widthHotItem, height: heightHotItem)
                                attributes.frame = frame
                            }else if i==10 {
                                let frame = CGRect(x: 0, y: preSectionHeight+heightItem1+heightItemWithAd*2, width: widthItemWithHot, height: heightItemWithHot)
                                attributes.frame = frame
                            }else if i==11 {
                                let frame = CGRect(x: widthItemWithAd, y: preSectionHeight+heightItem1+heightItemWithAd*2, width: widthItemWithHot, height: heightItemWithHot)
                                attributes.frame = frame
                            }else if i==12 {
                                let frame = CGRect(x: widthItemWithAd*2, y:preSectionHeight+heightItem1+heightItemWithAd*2, width: widthItemWithHot, height: heightItemWithHot)
                                attributes.frame = frame
                            }
                                
                                
                            else{
                                
                                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthItemWithSmall, height: heightItemWithSmall)
                                
                                attributes.frame = frame
                                
                                yOffset[column] = yOffset[column] + heightItemWithSmall
//                                contentHeight = max(contentHeight, frame.maxY)
                                contentHeight = yOffset[column]
                                if column >= numberOfColumns4 - 1{
                                    column = 0
                                }else{
                                    column = column + 1
                                }
                            }
                            attributesList1.append(attributes)
                            return attributes
                        }//map循坏
                    }//if endIndex != -1
                    preSectionHeight = preSectionHeight + sectionHeight
                }//for j in 0...numSections
                
                
            }//if numSections != -1
            
  
        
    }
    //    As long as the rolling screen method is invoked
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList1
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        return attributesList[indexPath.row]
    }
    //    As long as the layout of the page properties change will call again
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
