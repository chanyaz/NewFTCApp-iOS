//
//  PageCollectionViewLayout.swift
//  Page
//
//  Created by huiyun.he on 01/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PageCollectionViewLayoutV: UICollectionViewFlowLayout{
    
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
        print("shuping")

        var preSectionHeight = CGFloat(0);
        
        var adHeight: CGFloat = 0
        let adWidth: CGFloat = 356
        let collectionViewHeight = collectionView!.bounds.height
        let contentWidth = self.contentWidth
        let numSections = collectionView!.numberOfSections - 1
        
            print ("screen --\(contentWidth)--")
            
            if contentWidth<800{
                adHeight = 350
            }else{
                adHeight = 380
            }
            //The first cell
            let widthItem1 = contentWidth
            let heightItem1 = widthItem1*0.35
            
            //with ad line
            let widthItemWithAd = (contentWidth - adWidth)/2
  
            let heightItemWithAd = adHeight
            //middle line
            let widthItem2 = contentWidth/CGFloat(numberOfColumns)
            //        let heightItem2 = collectionViewHeight - heightItemWithAd - heightItem1
            var heightItem2: CGFloat = 0
            if contentWidth<1200{
                heightItem2 = heightItemWithAd*1.0
            }else{
                heightItem2 = heightItemWithAd
            }
            let widthItem789 = contentWidth/CGFloat(numberOfColumns)
            let heightItem789 = collectionViewHeight/CGFloat(3)*1.1
            

            
            let widthHotItem = adWidth
            let heightHotItem = heightItemWithAd * 2
            
            let widthItemWithSmall = contentWidth/CGFloat(numberOfColumns)
            let heightItemWithSmall = collectionViewHeight/CGFloat(3)*1.1
            
            //Define the size of the Offset
            var xOffset = [CGFloat]()
            for column in 0 ..< 4 {
                xOffset.append(CGFloat(column) * widthItemWithSmall )
            }
            let sectionHeight=CGFloat(0);
            
            //        print ("screen --\(UIScreen.main.bounds)--")
            if numSections != -1{
                
                for j in 0...numSections {
                    
                    let endIndex = collectionView!.numberOfItems(inSection: j)
                    
                    //            print ("collectionView!.contentInset --\(collectionView!.bounds.height)--")
                    
                    
                    if endIndex != 0{
                        
                        //                    let sectionHeight0 = Int((endIndex-3)/3)+1
                        //                     sectionHeight = CGFloat(sectionHeight0)*heightPerItem/2+heightItem1/2
                        //
                        
                        
                        var column = 0
                        var yOffset = [CGFloat](repeating: preSectionHeight+heightItem1+heightItemWithAd+heightItem2+heightHotItem+heightItem789, count: numberOfColumns)
                        
                        attributesList = (0...endIndex-1).map { (i) ->UICollectionViewLayoutAttributes in
                            
                            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: j))
                            
                            
                            if   i == 0{
                                
                                let frame = CGRect(x: 0, y: preSectionHeight, width: widthItem1, height: heightItem1)
                                attributes.frame = frame
                                
                            }else if   i==1 {
                                
                                let frame = CGRect(x: 0, y: preSectionHeight+heightItem1, width: widthItem2, height: heightItem2)
                                attributes.frame = frame
                            }else if i==2 {
                                
                                let frame = CGRect(x: widthItem2, y: preSectionHeight+heightItem1, width: widthItem2, height: heightItem2)
                                attributes.frame = frame
                                
                            }else if i==3 {
                                let frame = CGRect(x: widthItem2*2, y: preSectionHeight+heightItem1, width: widthItem2, height: heightItem2)
                                attributes.frame = frame
                            }else if i==4 {
                                let frame = CGRect(x: 0, y: preSectionHeight+heightItem1+heightItem2, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==5{
                                let frame = CGRect(x: widthItemWithAd, y: preSectionHeight+heightItem1+heightItem2, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==6{
                                let frame = CGRect(x: widthItemWithAd*2, y: heightItem1+heightItem2, width: adWidth, height: adHeight)
                                attributes.frame = frame
                            }else if i==7{
                                let frame = CGRect(x: 0, y: heightItem1+heightItem2+heightItemWithAd, width: widthItem789, height: heightItem789)
                                attributes.frame = frame
                            }else if i==8{
                                let frame = CGRect(x: widthItem789, y: heightItem1+heightItem2+heightItemWithAd, width: widthItem789, height: heightItem789)
                                attributes.frame = frame
                            }else if i==9{
                                let frame = CGRect(x: widthItem789*2, y: heightItem1+heightItem2+heightItemWithAd, width: widthItem789, height: heightItem789)
                                attributes.frame = frame
                            }else if i==10{
                                let frame = CGRect(x: 0, y: heightItem1+heightItem2+heightItemWithAd+heightItem789, width: widthHotItem, height: heightHotItem)
                                attributes.frame = frame
                            }else if i==11{
                                let frame = CGRect(x: widthHotItem, y: heightItem1+heightItem2+heightItemWithAd+heightItem789, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==12{
                                let frame = CGRect(x: widthHotItem+widthItemWithAd, y: heightItem1+heightItem2+heightItemWithAd+heightItem789, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==13{
                                let frame = CGRect(x: widthHotItem, y: heightItem1+heightItem2+heightItemWithAd*2+heightItem789, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }else if i==14{
                                let frame = CGRect(x: widthHotItem+widthItemWithAd, y: heightItem1+heightItem2+heightItemWithAd*2+heightItem789, width: widthItemWithAd, height: heightItemWithAd)
                                attributes.frame = frame
                            }
                                
                            else{
                                
                                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthItemWithSmall, height: heightItemWithSmall)
                                
                                attributes.frame = frame
                                
                                yOffset[column] = yOffset[column] + heightItemWithSmall
//                                contentHeight = max(contentHeight, frame.maxY)
                                contentHeight = yOffset[column]
                                if column >= numberOfColumns - 1{
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
                    //          print ("attribute size1111111----\(attributesList1)----111111")
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
