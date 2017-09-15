//
//  CustomNavigationController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit



class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var tabName: String? = nil
    var isLightContent = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tabBarController?.tabBar.tintColor = AppNavigation.getThemeColor(for: tabName)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let currentTabName = tabName {
            isLightContent = AppNavigation.isNavigationPropertyTrue(for: currentTabName, of: "isNavLightContent")
            if isLightContent == true {
                return UIStatusBarStyle.lightContent
            }
        }
        return UIStatusBarStyle.default
    }
    
    
    /*
     
     // MARK: - https://stackoverflow.com/questions/28949537/uipageviewcontroller-detecting-pan-gestures
     // MARK: Test custom popping
     var interactivePopTransition: UIPercentDrivenInteractiveTransition!
     //var popRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer))
     
     override func viewDidLoad() {
     super.viewDidLoad()
     let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handler))
     gestureRecognizer.delegate = self
     view.addGestureRecognizer(gestureRecognizer)
     }
     
     func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
     print ("the operation is \(operation)")
     if (operation == .pop) {
     print ("the operation is pop")
     return CustomPopTransition()
     } else {
     print ("the operation is not pop")
     return nil
     }
     }
     
     func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
     print ("check the animationController type")
     if animationController is CustomPopTransition {
     print ("animationController is custom pop transition")
     return interactivePopTransition
     } else {
     print ("animationController is not custom pop transition")
     return nil
     }
     }
     
     
     
     
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
     
     return true
     }
     
     // MARK: This is working!
     func handler(_ recognizer: UIPanGestureRecognizer) {
     let totalTranslation = recognizer.translation(in: view)
     var progress = recognizer.translation(in: self.view).x / self.view.bounds.size.width
     progress = min(1, max(0, progress))
     
     if (recognizer.state == .began) {
     // Create a interactive transition and pop the view controller
     
     print ("current recognizer state is .began")
     return
     self.interactivePopTransition = UIPercentDrivenInteractiveTransition()
     self.popViewController(animated: true)
     } else if (recognizer.state == .changed) {
     // Update the interactive transition's progress
     print ("current recognizer state is .changed")
     return
     interactivePopTransition.update(progress)
     } else if (recognizer.state == .ended || recognizer.state == .cancelled) {
     // Finish or cancel the interactive transition
     print ("current recognizer state is .ended or .cancelled")
     return
     
     if (progress > 0.5) {
     interactivePopTransition.finish()
     }
     else {
     interactivePopTransition.cancel()
     }
     interactivePopTransition = nil
     }
     }
     
     // MARK: test custom popping end
     
     */
    
}


