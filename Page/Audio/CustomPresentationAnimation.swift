//
//  CustomPresentationAnimation.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomPresentationAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting :Bool
    let duration :TimeInterval = 0.5
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        }
        else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
//        let presentingController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CustomTabBarController
        
        var presentedControllerView :UIView
        if !((transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CustomTabBarController) != nil){
            presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        }else{
            presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        }
//        let presentingControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        

       
        
        // Position the presented view off the top of the container view
        presentedControllerView.frame = transitionContext.finalFrame(for: presentedController!)
        presentedControllerView.center.y += containerView.bounds.size.height
        
        containerView.addSubview(presentedControllerView)
        
 
 
//        let tabBarHeight = presentingController?.tabView.bounds.height

        

        
        // Animate the presented view to it's final position
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            
            
//            presentingController?.tabView.transform = CGAffineTransform(translationX: 0, y: tabBarHeight!)
            presentedControllerView.center.y -= containerView.bounds.size.height
            
            
        }, completion: {(completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        var presentingControllerView :UIView
//        var presentedController:UIViewController
        
        if !((transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? AudioPlayerController) != nil){
            
           presentingControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!

        }else{
           presentingControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        }
        
        
//        let  presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  as? CustomTabBarController
        
        
        
        
        //         Animate the presented view off the bottom of the view
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
           
            
            presentingControllerView.center.y += containerView.bounds.size.height
            
//            presentedController?.tabView.transform = CGAffineTransform.identity
//            presentedController?.tabView.isHidden = false
            
        }, completion: {(completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }

}
