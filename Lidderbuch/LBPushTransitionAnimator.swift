//
//  SwipePopTransition.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 15/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBPushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var presenting: Bool = false
    var overlayAlpha: CGFloat = 0.3
    var shadowOpacity: Float = 0.4
    var shadowRadius: CGFloat = 5.0
    var bottomViewControllerInset: CGFloat = 100.0
    
    init(presenting: Bool) {
        super.init()
        self.presenting = presenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // calculate frames
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        
        var toViewControllerStartFrame = finalFrame
        var fromViewControllerFinalFrame = fromViewController.view.frame
        
        var topViewController: UIViewController
        var bottomViewController: UIViewController
        
        if (presenting)
        {
            topViewController = toViewController
            bottomViewController = fromViewController
            
            toViewControllerStartFrame.origin.x = finalFrame.size.width
            fromViewControllerFinalFrame.origin.x -= bottomViewControllerInset
        }
        else
        {
            topViewController = fromViewController
            bottomViewController = toViewController
            
            toViewControllerStartFrame.origin.x -= bottomViewControllerInset
            fromViewControllerFinalFrame.origin.x = finalFrame.size.width
        }
        
        toViewController.view.frame = toViewControllerStartFrame
        
        // make the top view controller cast shadow
        let topViewLayer = topViewController.view.layer
        topViewLayer.shadowPath = UIBezierPath(rect: topViewLayer.bounds).CGPath
        topViewLayer.shadowColor = UIColor.blackColor().CGColor
        topViewLayer.shadowOffset = CGSizeZero
        topViewLayer.shadowOpacity = shadowOpacity
        topViewLayer.shadowRadius = shadowRadius
        
        // build view hierarchy
        let overlayView = UIView(frame: finalFrame)
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = presenting ? 0.0 : overlayAlpha
        
        let containerView = transitionContext.containerView()
        containerView.addSubview(bottomViewController.view)
        containerView.addSubview(overlayView)
        containerView.addSubview(topViewController.view)
        
        // animate
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration) {
            overlayView.alpha = self.presenting ? self.overlayAlpha : 0.0
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: {
            fromViewController.view.frame = fromViewControllerFinalFrame
            toViewController.view.frame = finalFrame
        }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}