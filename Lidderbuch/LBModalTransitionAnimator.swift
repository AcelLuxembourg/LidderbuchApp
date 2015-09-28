//
//  LBModalTransitionAnimator.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var presenting: Bool = false
    var arrowInset: CGFloat = 29.0
    var arrowSize: CGFloat = 11.0
    
    init(presenting: Bool) {
        super.init()
        self.presenting = presenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()!
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        
        // prepare arrow view
        var arrowView: UIView
        
        if containerView.subviews.last != nil {
            arrowView = containerView.subviews.last!
        } else {
            arrowView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: arrowSize, height: arrowSize))
            arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.25))
            arrowView.backgroundColor = toViewController.view.backgroundColor
        }
        
        if (presenting)
        {
            fromViewController.view.userInteractionEnabled = false
            
            // create view hierarchy
            containerView.addSubview(toViewController.view)
            containerView.addSubview(arrowView)
            
            // calculate fitting height with horizontal priority UILayoutPriorityDefaultHigh
            //  and vertical priority UILayoutPriorityFittingSizeLevel
            let modalHeight = toViewController.view.systemLayoutSizeFittingSize(finalFrame.size, withHorizontalFittingPriority: 750, verticalFittingPriority: 50).height
            
            // position modal view and arrow
            toViewController.view.frame = CGRect(x: 0.0, y: -modalHeight, width: containerView.bounds.size.width, height: modalHeight)
            
            arrowView.center = CGPoint(x: arrowInset, y: -arrowSize)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseInOut, animations:
            {
                // move views
                var toViewControllerFrame = toViewController.view.frame
                toViewControllerFrame.origin.y = 0.0
                toViewController.view.frame = toViewControllerFrame
                
                arrowView.center = CGPoint(x: self.arrowInset, y: modalHeight)
                
                var fromViewControllerFrame = fromViewController.view.frame
                fromViewControllerFrame.origin.y = toViewControllerFrame.height
                fromViewController.view.frame = fromViewControllerFrame
                
            }, completion: { (finished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
        else
        {
            toViewController.view.userInteractionEnabled = true
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseInOut, animations:
            {
                // move views
                toViewController.view.frame = finalFrame
                
                arrowView.center = CGPoint(x: self.arrowInset, y: -self.arrowSize)
                    
                var fromViewControllerFrame = fromViewController.view.frame
                fromViewControllerFrame.origin.y = -fromViewController.view.bounds.size.height
                fromViewController.view.frame = fromViewControllerFrame
                
            }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
