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

/// Custom Navigation Controller Protocol

@objc protocol CustomNavigationControllerDelegate {
    
    /// Push to next scene
    ///
    /// If the view controller wants to enjoy swipe from right edge to push to the next scene,
    /// it has to implement `pushToNextScene` that initiates that segue (or programmatic 
    /// `show` or `push`).
    
    func pushToNextScene()
}

class CustomNavigationController: UINavigationController {
    
    // If you are not doing custom transition to the initial navigation controller, you can
    // comment out the following three routines, as well as the `UIViewControllerTransitioningDelegate`
    // extension and `UIPresentationController` subclass below.
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configure()
    }
    
    private func configure() {
        transitioningDelegate = self   // for presenting the original navigation controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self                // for navigation controller custom transitions
        
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromLeft(_:)))
        left.edges = .left
        view.addGestureRecognizer(left)
        
        let right = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromRight(_:)))
        right.edges = .right
        view.addGestureRecognizer(right)
    }
    
    fileprivate var interactionController: UIPercentDrivenInteractiveTransition?
    
    func handleSwipeFromLeft(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = gesture.translation(in: gesture.view!).x / gesture.view!.bounds.size.width
        
        if gesture.state == .began {
            // if the navigation controller wasn't, itself, presented with a custom transition,
            // you insert this `guard` statement to prevent interactive dismissal performed below.
            //
            // guard viewControllers.count > 1 else {
            //     gesture.state = .cancelled
            //     return
            // }
            
            interactionController = UIPercentDrivenInteractiveTransition()
            if viewControllers.count > 1 {
                popViewController(animated: true)
            } else {
                dismiss(animated: true)
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
//
// Use this for custom transitions as you push/pop between the various child view controllers 
// of the navigation controller. If you don't need a custom animation there, you can comment this
// out.

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

// MARK: - UIViewControllerTransitioningDelegate
//
// This is needed for the animation when we initially present the navigation controller. 
// If you're only looking for custom animations as you push/pop between the child view
// controllers of the navigation controller, this is not needed. This is only for the 
// custom transition of the initial `present` and `dismiss` of the navigation controller 
// itself.

extension CustomNavigationController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

}

class PresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool { return true }
}

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
        }, completion: { finished in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
