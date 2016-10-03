
//
//  TransitionOperator.swift
//  NavTransition
//
//  Created by Jonathan Yu on 6/23/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

// http://www.appdesignvault.com/custom-transition-slide-out-navigation/

import Foundation
import UIKit

class TransitionOperator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
   
    let screenFrame = CGRectMake(0, 0, 375, 667)
    
    var tmp: UIViewController!
    
    var snapshot: UIView!
    var isPresenting: Bool = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }

    // Animate transition to or from navigation bar
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if (isPresenting) {
            presentNavigation(transitionContext)
        } else {
            dismissNavigation(transitionContext)
        }
    }
    
    // Present navigation bar
    func presentNavigation(transitionContext: UIViewControllerContextTransitioning) {
        
        tmp = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let container = transitionContext.containerView()
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toViewController!.view
        
        let size = toView.frame.size
        var offSetTransform = CGAffineTransformMakeTranslation(size.width - 160, 0)
        offSetTransform = CGAffineTransformScale(offSetTransform, 0.6, 0.6)
        
        snapshot = fromView.snapshotViewAfterScreenUpdates(true)
//        snapshot = fromView
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "action:")
        snapshot.addGestureRecognizer(tapRecognizer)
        
        container.addSubview(toView)
//        container.addSubview(snapshot)
        toView.addSubview(snapshot)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: nil, animations: { () -> Void in
            
            self.snapshot.transform = offSetTransform
            
            }, completion: { (finished: Bool) -> Void in
                
                transitionContext.completeTransition(true)
                
        })
        
        // Set bounds of mini-frame
        miniFrame = snapshot.frame
        
    }

    // Dismiss Navigation View when mini-view is pressed
    func action(gestureRecognizer: UIGestureRecognizer) {

        if (miniFrame.contains(gestureRecognizer.locationInView(tmp.view))) {
//            self.snapshot.transform = CGAffineTransformIdentity
//            self.snapshot.removeFromSuperview()
            tmp.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Dismiss navigation bar
    func dismissNavigation(transitionContext: UIViewControllerContextTransitioning) {

        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: nil, animations: { () -> Void in
            
            self.snapshot.transform = CGAffineTransformIdentity
            
            }, completion: { (finished: Bool) -> Void in
                
                transitionContext.completeTransition(true)
//                self.snapshot.removeFromSuperview()
                self.snapshot.frame = self.screenFrame
        })
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
 
    
    
}
