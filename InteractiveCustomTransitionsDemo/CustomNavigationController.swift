//
//  CustomNavigationController.swift
//  deleteme10
//
//  Created by Robert Ryan on 10/31/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

import UIKit

@objc protocol CustomNavigationControllerDelegate {
    func pushToNextScene()
}

class CustomNavigationController: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self   // for presenting the original navigation controller
        delegate = self                // for navigation controller custom transitions
        
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: "handleSwipeFromLeft:")
        left.edges = .Left
        self.view.addGestureRecognizer(left);
        
        let right = UIScreenEdgePanGestureRecognizer(target: self, action: "handleSwipeFromRight:")
        right.edges = .Right
        self.view.addGestureRecognizer(right);
    }
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    func handleSwipeFromLeft(gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = gesture.translationInView(gesture.view!).x / gesture.view!.bounds.size.width
        
        if gesture.state == .Began {
            interactionController = UIPercentDrivenInteractiveTransition()
            if viewControllers.count > 1 {
                popViewControllerAnimated(true)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else if gesture.state == .Changed {
            interactionController?.updateInteractiveTransition(percent)
        } else if gesture.state == .Ended {
            if percent > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        }
    }
    
    func handleSwipeFromRight(gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = -gesture.translationInView(gesture.view!).x / gesture.view!.bounds.size.width
        
        if gesture.state == .Began {
            if let currentViewController = viewControllers.last as? CustomNavigationControllerDelegate {
                interactionController = UIPercentDrivenInteractiveTransition()
                currentViewController.pushToNextScene()
            }
        } else if gesture.state == .Changed {
            interactionController?.updateInteractiveTransition(percent)
        } else if gesture.state == .Ended {
            if percent > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .Push {
            return ForwardAnimator()
        } else if operation == .Pop {
            return BackAnimator()
        }
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}

class ForwardAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        
        context.containerView()?.addSubview(toView!)
        
        toView?.alpha = 0.0
        
        UIView.animateWithDuration(transitionDuration(context), animations: {
            toView?.alpha = 1.0
            return
        }, completion: { finished in
            context.completeTransition(!context.transitionWasCancelled())
        })
    }
    
}

class BackAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView = context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        
        context.containerView()?.insertSubview(toView!, belowSubview: fromView!)
        
        UIView.animateWithDuration(transitionDuration(context), animations: {
            fromView?.alpha = 0.0
            return
        }, completion: { finished in
            context.completeTransition(!context.transitionWasCancelled())
        })
    }
}
