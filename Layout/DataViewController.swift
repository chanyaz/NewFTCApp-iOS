
class DataViewController: SuperDataViewController,UIGestureRecognizerDelegate{
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
            let customNavigation = self.navigationController as? CustomNavigationController
            //            customNavigation?.tabView.isHidden = true
            if  let tabAudioView = customNavigation?.tabView{
                let deltaY = tabAudioView.bounds.height
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    tabAudioView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                    tabAudioView.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }
            
        }else if sender.direction == .down{
            let customNavigation = self.navigationController as? CustomNavigationController
            if  let tabAudioView = customNavigation?.tabView{
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    tabAudioView.transform = CGAffineTransform.identity
                    tabAudioView.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return handleItemSelect(indexPath)
    }
    
    // MARK: - Move the handle cell selection to a function so that it can be used in different cases
    fileprivate func handleItemSelect(_ indexPath: IndexPath) -> Bool {
        // MARK: Check the fetchResults to make sure there's no out-of-range error
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
        if layoutStrategy == "Icons"{
            return false
        }
        return false
    }
}

