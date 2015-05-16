//
//  SwipePopTransition.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 15/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning
{
    var reverse: Bool = false
    var overlayAlpha: CGFloat = 0.3
    var shadowOpacity: Float = 0.4
    var shadowRadius: CGFloat = 5.0
    var bottomViewControllerInset: CGFloat = 100.0
    
    init(reverse: Bool) {
        super.init()
        self.reverse = reverse
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? LBViewController,
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? LBViewController
        {
            // calculate frames
            let finalFrame = transitionContext.finalFrameForViewController(toViewController)
            
            var toViewControllerStartFrame = finalFrame
            var fromViewControllerFinalFrame = fromViewController.view.frame
            
            var topViewController: LBViewController
            var bottomViewController: LBViewController
            
            if (reverse)
            {
                topViewController = fromViewController
                bottomViewController = toViewController
                
                toViewControllerStartFrame.origin.x -= bottomViewControllerInset
                fromViewControllerFinalFrame.origin.x = finalFrame.size.width
            }
            else
            {
                topViewController = toViewController
                bottomViewController = fromViewController
                
                toViewControllerStartFrame.origin.x = finalFrame.size.width
                fromViewControllerFinalFrame.origin.x -= bottomViewControllerInset
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
            overlayView.alpha = reverse ? overlayAlpha : 0.0
            
            let containerView = transitionContext.containerView()
            containerView.addSubview(bottomViewController.view)
            containerView.addSubview(overlayView)
            containerView.addSubview(topViewController.view)
            
            // animate
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration) {
                overlayView.alpha = self.reverse ? 0.0 : self.overlayAlpha
            }
            
            UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: {
                fromViewController.view.frame = fromViewControllerFinalFrame
                toViewController.view.frame = finalFrame
            }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}