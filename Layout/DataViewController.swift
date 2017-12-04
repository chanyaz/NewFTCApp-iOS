
class DataViewController: SuperDataViewController,UIGestureRecognizerDelegate{
//    fileprivate var fetches = ContentFetchResults(
//        apiUrl: "",
//        fetchResults: [ContentSection]()
//    )
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerDown.direction = .down
        swipeGestureRecognizerDown.delegate = self
        webView?.addGestureRecognizer(swipeGestureRecognizerDown)
        self.view.addGestureRecognizer(swipeGestureRecognizerDown)

        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerUp.direction = .up
        swipeGestureRecognizerUp.delegate = self
        webView?.addGestureRecognizer(swipeGestureRecognizerUp)
        self.view.addGestureRecognizer(swipeGestureRecognizerUp)
        
    }
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func isHideAudio(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            PlayerAPI.sharedInstance.fadeOutSmallPlayView()
        }else if sender.direction == .down{
            PlayerAPI.sharedInstance.fadeInSmallPlayView()
        }
    }
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return handleItemSelect(indexPath)
//    }
//
////     MARK: - Move the handle cell selection to a function so that it can be used in different cases
//    fileprivate func handleItemSelect(_ indexPath: IndexPath) -> Bool {
////         MARK: Check the fetchResults to make sure there's no out-of-range error
//        if fetches.fetchResults.count <= indexPath.section || fetches.fetchResults.count == 0 || indexPath.section < 0 {
//            Track.event(category: "CatchError", action: "Out of Range", label: "handleItemSelect 1")
//            print ("There is not enough sections in fetchResults")
//            return false
//        }
//        if fetches.fetchResults[indexPath.section].items.count <= indexPath.row || fetches.fetchResults[indexPath.section].items.count == 0 || indexPath.row < 0 {
//            Track.event(category: "CatchError", action: "Out of Range", label: "handleItemSelect 2")
//            print ("Row is \(indexPath.row). There is not enough rows in fetchResults Section")
//            return false
//        }
//        let selectedItem = fetches.fetchResults[indexPath.section].items[indexPath.row]
//        if layoutStrategy == "Icons"{
//            return false
//        }
//        if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
//            var pageData1 = [ContentItem]()
//            //                    var pageData2 = [ContentItem]()
//            var currentPageIndex = 0
//            var pageIndexCount = 0
//            for (sectionIndex, section) in fetches.fetchResults.enumerated() {
//                for (itemIndex, item) in section.items.enumerated() {
//                    if ["story", "video", "interactive", "photo", "manual"].contains(item.type) {
//                        if sectionIndex == indexPath.section && itemIndex == indexPath.row {
//                            currentPageIndex = pageIndexCount
//                        }
//                        pageData1.append(item)
//                        pageIndexCount += 1
//                    }
//
//                }
//            }
//            let pageDataRaw = pageData1
//
//            let pageData: [ContentItem]
//
//            if selectedItem.type == "manual" {
//                // MARK: For manual html pages in ebooks, hide bottom bar and ads
//                pageData = pageDataRaw
//                detailViewController.showBottomBar = false
//            } else {
//                let withAd = AdLayout.insertFullScreenAd(to: pageDataRaw, for: currentPageIndex)
//                pageData = AdLayout.insertAdId(to: withAd.contentItems, with: adchId)
//                currentPageIndex = withAd.pageIndex
//            }
//
//            //print (pageData)
//
//            pageData[currentPageIndex].isLandingPage = true
//            detailViewController.themeColor = themeColor
//            detailViewController.contentPageData = pageData
//            detailViewController.currentPageIndex = currentPageIndex
//            navigationController?.pushViewController(detailViewController, animated: true)
//        }
//
//        return true
//    }
}

