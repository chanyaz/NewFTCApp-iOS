//
//  DetailViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DetailViewController: PagesViewController, UINavigationControllerDelegate {

    var viewTitle = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //print (viewTitle)
        // detailTitle.text = viewTitle
        
        //TODO: - Need to add the swipe animation
//        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
//        self.view.addGestureRecognizer(gesture)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
//        navigationController?.popToRootViewController(animated: true)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
//    
//    
//    var interactivePopTransition: UIPercentDrivenInteractiveTransition!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.delegate = self
//
//        // Do any additional setup after loading the view.
//        self.view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
//        //print (viewTitle)
//        detailTitle.text = viewTitle
//        
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        print ("added a pan gesture")
//        addPanGesture(viewController: viewController)
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if operation == .pop {
//            print ("operation is pop")
//            return CustomPopTransition()
//        }
//        if operation == .none {
//            print ("operation is none")
//            return CustomPopTransition()
//        }
//        if operation == .push {
//            print ("operation is push")
//            //return CustomPopTransition()
//        }
//        
//        print ("operation is not known")
//        return nil
//    }
//    
//    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        if animationController is CustomPopTransition {
//            print ("animationController is CustomPopTransition")
//            return interactivePopTransition
//        }
//        print ("animationController is not CustomPopTransition")
//        return nil
//    }
//    
//    func addPanGesture(viewController: UIViewController) {
//        let popRecognizer = UIPanGestureRecognizer(target: self, action: #selector((handlePanRecognizer(recognizer:))))
//        viewController.view.addGestureRecognizer(popRecognizer)
//    }
//    
//    func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
//        // Calculate how far the user has dragged across the view
//        var progress = recognizer.translation(in: self.view).x / self.view.bounds.size.width
//        print (progress)
//        
//        progress = min(1, max(0, progress))
//        if (recognizer.state == .began) {
//            // Create a interactive transition and pop the view controller
//            interactivePopTransition = UIPercentDrivenInteractiveTransition()
//            // self.navigationController?.popViewController(animated: true)
//        } else if (recognizer.state == .changed) {
//            // Update the interactive transition's progress
//            print ("progress is changed to \(progress)")
//            interactivePopTransition.update(progress)
//        } else if (recognizer.state == .ended || recognizer.state == .cancelled) {
//            // Finish or cancel the interactive transition
//            if (progress > 0.5) {
//                interactivePopTransition.finish()
//            }
//            else {
//                interactivePopTransition.cancel()
//            }
//            interactivePopTransition = nil
//        }
//    }
    
    
    
    

}
