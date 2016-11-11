//
//  SwipePopTransition.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        // calculate frames
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
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
        topViewLayer.shadowPath = UIBezierPath(rect: topViewLayer.bounds).cgPath
        topViewLayer.shadowColor = UIColor.black.cgColor
        topViewLayer.shadowOffset = CGSize.zero
        topViewLayer.shadowOpacity = shadowOpacity
        topViewLayer.shadowRadius = shadowRadius
        
        // build view hierarchy
        let overlayView = UIView(frame: finalFrame)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = presenting ? 0.0 : overlayAlpha
        
        let containerView = transitionContext.containerView
        containerView.addSubview(bottomViewController.view)
        containerView.addSubview(overlayView)
        containerView.addSubview(topViewController.view)
        
        // animate
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            overlayView.alpha = self.presenting ? self.overlayAlpha : 0.0
        }) 
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            fromViewController.view.frame = fromViewControllerFinalFrame
            toViewController.view.frame = finalFrame
        }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
