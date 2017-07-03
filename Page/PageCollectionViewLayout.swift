//
//  PageCollectionViewLayout.swift
//  Page
//
//  Created by huiyun.he on 01/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PageCollectionViewLayout: UICollectionViewFlowLayout{
//    NSMutableSet* attributes = [NSMutableSet set];
    let attributes1 = NSMutableSet()
    var letters = Set<UICollectionViewLayoutAttributes>()
    
    let adHeight = [CGFloat]();
    
    
    var sectionCGRect = [CGRect]()
    var attributesList = [UICollectionViewLayoutAttributes]()
    var attributesList1 = [UICollectionViewLayoutAttributes]()
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
        attributes1.add(attributesList)
//        letters.insert(attributesList)
        //        collectionView?.reloadData()
        let adWidth = CGFloat(100);
//        let adHeight2 = CGFloat(300);
        var lastSectionHeight = CGFloat(0);
        
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
        
        
        //第1个cell的宽高
        let widthItem1 = widthPerItem*2
        let heightItem1 = heightPerItem
        //第2个cell的宽高
        let widthItem2 = widthPerItem
        let heightItem2 = heightPerItem/2
        //第3个cell的宽高
        let widthItem3 = widthPerItem
        let heightItem3 = heightPerItem/2
        
        var sectionHeight=CGFloat(0);
        

        if numSections != -1{

          for j in 0...numSections {
            
            

            
            // attributesList = []
            let endIndex = collectionView!.numberOfItems(inSection: j)
            
            
//            print ("endIndex --\(String(describing: endIndex))--")
            
            
            //如果section是广告
            if endIndex == 0{
                //获取广告section的高度给sectionHeight
                sectionHeight=200
                //把广告的attributes添加到attributesList1
//                Ad()
//                let indexPath = IndexPath(item: 0, section: 0)
//                let att = PageLayoutAttributes(forCellWith: indexPath)
//                att.height = 500
//                att.color = UIColor.red
//                print("shuchu ad")
//                att.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
//                attributesList1.append(att)
            }
            if endIndex != 0{
                //获取section
//                if j==0{
                //计算section的高度
                    let sectionHeight0 = Int((endIndex-3)/3)+1
                     sectionHeight = CGFloat(sectionHeight0)*heightPerItem/2+heightItem1/2
//                }else{
                
//                }
                
                let cgrect = CGRect(x: 0, y: lastSectionHeight, width: contentWidth!, height:sectionHeight )
                sectionCGRect.append(cgrect)
                
                
                var column = 0
                var yOffset = [CGFloat](repeating: lastSectionHeight+heightPerItem, count: numberOfColumns)
                
                attributesList = (0...endIndex-1).map { (i) ->UICollectionViewLayoutAttributes in
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: j))

                
                    if   i == 0{
                        
                        let frame = CGRect(x: 0, y: lastSectionHeight, width: widthItem1, height: heightItem1)
                        attributes.frame = frame
                        
                    }else if   i==1 {
                        
                        let frame = CGRect(x: widthItem1, y: lastSectionHeight, width: widthItem2, height: heightItem2)
                        attributes.frame = frame
                    }else if i==2 {
                        
                        let frame = CGRect(x: widthItem1, y: lastSectionHeight+heightItem2, width: widthItem3, height: heightItem3)
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
                    
                    // print ("attribute size1111111----\(attributes)----111111")
//                    return attributes
                    attributesList1.append(attributes)
                    return attributes
                }//map循坏
//                attributesLists.append(attributesList)
                
            }//if endIndex != -1
            lastSectionHeight = lastSectionHeight + sectionHeight
          
//          print ("attribute size1111111----\(attributesList)----111111")
            }//for j in 0...numSections
//             self.layoutAttributesForElements(in: sectionCGRect[0])
          
//            print ("attribute size222222----\(sectionCGRect)----22222")
        }//if numSections != -1
//        else{

//        }
       
        
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//       print ("attribute1 size1111111----\(attributesList1)----111111")
//       print ("attribute size222222----\(sectionCGRect)----22222")
        
            return attributesList1


    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
//        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class PageLayoutAttributes:UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var height: CGFloat = 500.0
//    var color: CGColor = GL_RED as! CGColor
    var color: UIColor = UIColor.red
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! PageLayoutAttributes
        copy.height = height
        copy.color = color
        return copy
    }
    
}
