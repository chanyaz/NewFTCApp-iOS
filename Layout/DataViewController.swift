
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
}
