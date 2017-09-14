//
//  CustomPresentionCon.swift
//  Page
//
//  Created by huiyun.he on 12/09/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomPresentionCon: UIPresentationController {
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
                self.dimmingView.alpha = 3.0
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
                self.dimmingView.alpha  = 1.0
            }, completion:nil)
        }
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
        }
    }
    override var frameOfPresentedViewInContainerView: CGRect{
        
        guard
            let containerView = containerView
            else {
                return CGRect()
        }
        
        
        let frame = CGRect(x:0,y:0,width:containerView.bounds.width,height:containerView.bounds.height)
        return frame
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        }, completion:nil)
    }
    
}
