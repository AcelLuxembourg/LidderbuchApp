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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        // prepare arrow view
        var arrowView: UIView
        
        if containerView.subviews.last != nil {
            arrowView = containerView.subviews.last!
        } else {
            arrowView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: arrowSize, height: arrowSize))
            arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.25))
            arrowView.backgroundColor = toViewController.view.backgroundColor
        }
        
        if (presenting)
        {
            fromViewController.view.isUserInteractionEnabled = false
            
            // create view hierarchy
            containerView.addSubview(toViewController.view)
            containerView.addSubview(arrowView)
            
            // calculate fitting height with horizontal priority UILayoutPriorityDefaultHigh
            //  and vertical priority UILayoutPriorityFittingSizeLevel
            let modalHeight = toViewController.view.systemLayoutSizeFitting(finalFrame.size, withHorizontalFittingPriority: UILayoutPriority(rawValue: 750), verticalFittingPriority: UILayoutPriority(rawValue: 50)).height
            
            // position modal view and arrow
            toViewController.view.frame = CGRect(x: 0.0, y: -modalHeight, width: containerView.bounds.size.width, height: modalHeight)
            
            arrowView.center = CGPoint(x: arrowInset, y: -arrowSize)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions(), animations:
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
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        else
        {
            toViewController.view.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions(), animations:
            {
                // move views
                toViewController.view.frame = finalFrame
                
                arrowView.center = CGPoint(x: self.arrowInset, y: -self.arrowSize)
                    
                var fromViewControllerFrame = fromViewController.view.frame
                fromViewControllerFrame.origin.y = -fromViewController.view.bounds.size.height
                fromViewController.view.frame = fromViewControllerFrame
                
            }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
