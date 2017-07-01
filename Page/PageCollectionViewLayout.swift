//
//  PageCollectionViewLayout.swift
//  Page
//
//  Created by huiyun.he on 01/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PageCollectionViewLayout: UICollectionViewFlowLayout{
    var attributesList = [UICollectionViewLayoutAttributes]()
    var attributesLists = [[UICollectionViewLayoutAttributes]]()
    var numberOfColumns = 3
    let itemSize0 = CGSize(width: 133, height: 173)
    
    private var contentHeight:CGFloat=0.0
    override func invalidateLayout() {
        
    }
    
    override class var layoutAttributesClass : AnyClass {
        print ("found --yunxing----")
        return UICollectionViewLayoutAttributes.self
    }
    override var collectionViewContentSize : CGSize {
        
        return CGSize(width:(collectionView!.bounds.width),height:contentHeight)
        
    }
    
    override func prepare() {
        
        //        collectionView?.reloadData()
        
        let contentWidth = collectionView?.bounds.width
        //        let startIndex = 0
        let numSections = collectionView!.numberOfSections - 1
        
        let widthPerItem = contentWidth!/CGFloat(3)
        let heightPerItem = widthPerItem * 0.618
        
        //定义Offset的大小
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * widthPerItem )
        }
        var column = 0
        var yOffset = [CGFloat](repeating: heightPerItem, count: numberOfColumns)
        
        //第1个cell的宽高
        let widthItem1 = widthPerItem*2
        let heightItem1 = heightPerItem
        //第2个cell的宽高
        let widthItem2 = widthPerItem
        let heightItem2 = heightPerItem/2
        //第3个cell的宽高
        let widthItem3 = widthPerItem
        let heightItem3 = heightPerItem/2
        
        
        if numSections != -1{
            
            
            //            for j in 0...numSections {
            
            //                attributesList = []
            let endIndex = collectionView!.numberOfItems(inSection: 1)
            print ("endIndex --\(String(describing: endIndex))--")
            if endIndex != 0{
                attributesList = (0...endIndex-1).map { (i) ->UICollectionViewLayoutAttributes in
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 1))
                    //          j==1 &&      attributes.size =  CGSize(width:widthPerItem,height:heightPerItem)
                    
                    if  i == 0{
                        
                        let frame = CGRect(x: 0, y: 200, width: widthItem1, height: heightItem1)
                        attributes.frame = frame
                        
                    }else if   i==1 {
                        
                        let frame = CGRect(x: widthItem1, y: 200, width: widthItem2, height: heightItem2)
                        attributes.frame = frame
                    }else if i==2 {
                        
                        let frame = CGRect(x: widthItem1, y: heightItem2, width: widthItem3, height: heightItem3)
                        attributes.frame = frame
                        
                    }else{
                        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthPerItem, height: heightPerItem/2)
                        //                            let frame = CGRect(x: CGFloat(i*10+150), y: yOffset[column], width: widthPerItem, height: heightPerItem)
                        attributes.frame = frame
                        
                        yOffset[column] = yOffset[column] + heightPerItem/2
                        contentHeight = max(contentHeight, frame.maxY)
                    }
                    
                    if column >= numberOfColumns - 1{
                        column = 0
                    }else{
                        column = column + 1
                    }
                    
                    //                         print ("attribute size1111111----\(attributes)----111111")
                    return attributes
                }//map循坏
                
            }//if endIndex != -1{
            attributesLists.append(attributesList)
            //                print ("attribute size1111111----\(attributesList)----111111")
            //            }//for j in 0...numSections
            //            print ("attribute size222222----\(attributesLists)----22222")
        }//if numSections != -1
        
        
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let numSections1 = collectionView!.numberOfSections - 1
        if numSections1 != -1{
            //            for j in 0...numSections1 {
            let endIndex1 = collectionView!.numberOfItems(inSection: 1)
            print ("endIndex1 --\(String(describing: endIndex1))--")
            return attributesList
            //            }
        }
        //        print ("attribute size222222----\(attributesLists)----22222")
        return nil
        
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        print ("indexPath width--\(indexPath.section)--sections")
        return attributesList[indexPath.row]
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

