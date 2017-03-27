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
import UIKit.UIGestureRecognizerSubclass

@objc protocol CustomNavigationControllerDelegate {
    func pushToNextScene()
}

class CustomNavigationController: UINavigationController {
    
    // If you want to do a custom transition to the initial navigation controller,
    // comment out the following routines, as well as the `UIViewControllerTransitioningDelegate`
    // extension and `UIPresentationController` subclass below.
    //
    // public required init?(coder aDecoder: NSCoder) {
    //     super.init(coder: aDecoder)
    //     configure()
    // }
    //
    // override init(rootViewController: UIViewController) {
    //     super.init(rootViewController: rootViewController)
    //     configure()
    // }
    //
    // private func configure() {
    //     transitioningDelegate = self   // for presenting the original navigation controller
    // }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self                // for navigation controller custom transitions
        
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromLeft(_:)))
        left.edges = .left
        view.addGestureRecognizer(left);
        
        let right = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromRight(_:)))
        right.edges = .right
        view.addGestureRecognizer(right);
    }
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    func handleSwipeFromLeft(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = gesture.translation(in: gesture.view!).x / gesture.view!.bounds.size.width
        
        if gesture.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            if viewControllers.count > 1 {
                popViewController(animated: true)
            } else {
                gesture.state = .cancelled
                interactionController = nil
                
                // if the navigation controller was, itself, presented with a custom transition,
                // you could remove the cancelation of the gesture above and initiate the dismissal
                // like shown below, if you wanted.
                //
                // dismiss(animated: true)
            }
        } else if gesture.state == .changed {
            interactionController?.update(percent)
        } else if gesture.state == .ended {
            if percent > 0.5 && gesture.state != .cancelled {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }
    
    func handleSwipeFromRight(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = -gesture.translation(in: gesture.view!).x / gesture.view!.bounds.size.width
        
        if gesture.state == .began {
            guard let currentViewController = viewControllers.last as? CustomNavigationControllerDelegate else {
                gesture.state = .cancelled
                return
            }
            interactionController = UIPercentDrivenInteractiveTransition()
            currentViewController.pushToNextScene()
        } else if gesture.state == .changed {
            interactionController?.update(percent)
        } else if gesture.state == .ended {
            if percent > 0.5 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }
    
}

// MARK: - UINavigationControllerDelegate

extension CustomNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            return ForwardAnimator()
        } else if operation == .pop {
            return BackAnimator()
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}

//// MARK: - UIViewControllerTransitioningDelegate
////
//// This is needed for the animation when we initially present the navigation controller
//
//extension CustomNavigationController: UIViewControllerTransitioningDelegate {
//
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return ForwardAnimator()
//    }
//    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return BackAnimator()
//    }
//    
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactionController
//    }
//    
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactionController
//    }
//    
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return PresentationController(presentedViewController: presented, presenting: presenting)
//    }
//    
//}
//
//class PresentationController: UIPresentationController {
//    override var shouldRemovePresentersView: Bool { return true }
//}

class ForwardAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let toView = context.viewController(forKey: .to)!.view!
        
        context.containerView.addSubview(toView)
        
        toView.alpha = 0.0
        
        UIView.animate(withDuration: transitionDuration(using: context), animations: {
            toView.alpha = 1.0
            return
        }, completion: { finished in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
}

class BackAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let toView   = context.viewController(forKey: .to)!.view!
        let fromView = context.viewController(forKey: .from)!.view!
        
        context.containerView.insertSubview(toView, belowSubview: fromView)
        
        UIView.animate(withDuration: transitionDuration(using: context), animations: {
            fromView.alpha = 0.0
            return
        }, completion: { finished in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
