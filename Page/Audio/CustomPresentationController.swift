//
//  CustomPresentationController.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    lazy var dimmingView :UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        
        view.backgroundColor = UIColor(red: 2.0, green: 1.0, blue: 1.0, alpha: 0.5)
        view.alpha = 0.0
        return view
    }()
    override func presentationTransitionWillBegin() {
        guard
            let containerView = containerView,
            let presentedView = presentedView
            else {
                return
        }
        
        // Add the dimming view and the presented view to the heirarchy
        dimmingView.frame = containerView.bounds
//        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)
        
        // Fade in the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//                self.dimmingView.alpha = 3.0
            }, completion:nil)
        }
    }
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
//            self.dimmingView.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//                self.dimmingView.alpha  = 2.0
            }, completion:nil)
        }
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
//            self.dimmingView.removeFromSuperview()
        }
    }
    override var frameOfPresentedViewInContainerView: CGRect{
        
        guard
            let containerView = containerView
            else {
                return CGRect()
        }
        var frame :CGRect
        if !((self.presentedViewController as? ListPerColumnViewController) != nil) {
             frame = CGRect(x:0,y:0,width:containerView.bounds.width,height:containerView.bounds.height)
        }else{
            frame = CGRect(x:0,y:300,width:containerView.bounds.width,height:containerView.bounds.height-300)
        }

        return frame
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
//        guard
//            let containerView = containerView
//            else {
//                return
//        }

        coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//            self.dimmingView.frame  = CGRect(x:0,y:0,width:300,height:100)
            //            self.dimmingView.frame = containerView.bounds
        }, completion:nil)
    }

}
