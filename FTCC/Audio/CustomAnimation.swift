//
//  CustomAnimation.swift
//  Page
//
//  Created by huiyun.he on 30/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomAnimation: NSObject,UIViewControllerAnimatedTransitioning {
    let isPresenting :Bool
    let duration :TimeInterval = 1
    
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
        
        
        let containerView = transitionContext.containerView  //作为涉及到转换的视图的超视图的视图
        
        let presentingController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CustomTabBarController
        
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  as? AudioPlayerController
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        presentedControllerView?.frame = transitionContext.finalFrame(for: presentedController!)
//      height = containerView.bounds.size.height
        //        let tabBarFrame = presentingController?.tabView.frame
        let tabBarHeight = presentingController?.tabView.bounds.height

        presentedControllerView?.center.y += containerView.bounds.size.height
        
        containerView.addSubview(presentedControllerView!)
        
        
        // Animate the presented view to it's final position
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            presentingController?.tabView.transform = CGAffineTransform(translationX: 0, y: tabBarHeight!)
            presentedControllerView?.center.y -= containerView.bounds.size.height
            
        }, completion: {(completed: Bool) -> Void in
            print("presented finish transition")
            transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView  //作为涉及到转换的视图的超视图的视图

        let presentingControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  as? CustomTabBarController

        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {

            presentedController?.tabView.transform = CGAffineTransform.identity
            //两句都可以
            presentingControllerView?.center.y += containerView.bounds.size.height
            presentedController?.tabView.isHidden = false
        }, completion: {(completed: Bool) -> Void in
            print("presented finish dismiss")
            transitionContext.completeTransition(completed)
        })
    }
    
}
