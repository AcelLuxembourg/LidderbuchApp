//
//  LBViewController.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBViewController: UIViewController,
    UINavigationControllerDelegate,
    UIGestureRecognizerDelegate,
    UIScrollViewDelegate
{
    @IBOutlet var headerBar: LBHeaderBar!
    @IBOutlet var scrollView: UIScrollView!
    
    var swipeToPopGestureRecognizer: UIPanGestureRecognizer!
    
    private var interactivePopTransition: UIPercentDrivenInteractiveTransition!
    
    private var scrollViewVerticalOffset: CGFloat = 0
    private var scrollViewDecelerating = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // inset content below header bar
        scrollView.contentInset = UIEdgeInsets(top: headerBar.bounds.size.height, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollView.delegate = self
        
        // configure swipe gesture recognizer if this view controller
        //  can be popped by the navigation controller
        if (navigationController?.viewControllers.first !== self)
        {
            swipeToPopGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handleSwipeGestureRecognizer:"))
            swipeToPopGestureRecognizer.delegate = self
            view.addGestureRecognizer(swipeToPopGestureRecognizer)
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // only catch horizontal gesture
        let velocity = swipeToPopGestureRecognizer.velocityInView(view)
        return fabs(velocity.x) > fabs(velocity.y)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // attach self as delegate to inject custom view controller transition
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // detach delegate
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollViewDecelerating = false
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollViewDecelerating = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDecelerating = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        // calculate scroll difference since last call
        let delta = scrollView.contentOffset.y - scrollViewVerticalOffset
        scrollViewVerticalOffset = scrollView.contentOffset.y
        let contentLargerThanScrollView = (scrollView.contentSize.height > scrollView.bounds.size.height)
        
        if !(
            // prevent sliding up when content size is too small
            (!contentLargerThanScrollView && delta > 0)
            
            // prevent sliding up at upper bounce
            || (scrollViewVerticalOffset <= -scrollView.contentInset.top && delta > 0)
            
            // prevent sliding down at lower bounce
            || (scrollViewVerticalOffset >= scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height && contentLargerThanScrollView && delta < 0)
            
            // prevent sliding down when not decelerating and not reached the top
            || (!scrollViewDecelerating && scrollViewVerticalOffset > 0 && contentLargerThanScrollView && delta < 0)
        ) {
            headerBar.translateVertically(delta)
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return LBPushTransitionAnimator(presenting: operation == .Push)
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        if animationController is LBPushTransitionAnimator && interactivePopTransition != nil {
            return interactivePopTransition
        }
        return nil
    }
    
    @IBAction func handleSwipeGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer)
    {
        // calculate percent by gesture distance
        var percent: CGFloat = gestureRecognizer.translationInView(view).x / view.bounds.size.width
        percent = min(1.0, max(0.0, percent))
        
        switch gestureRecognizer.state {
        case .Possible: break
        case .Failed: break
            
        case .Began:
            
            // pop view controller and create percent driven interactive transition
            interactivePopTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewControllerAnimated(true)
            
        case .Changed:
            
            // update transition progress
            interactivePopTransition.updateInteractiveTransition(percent)
            
        case .Cancelled: fallthrough
        case .Ended:
            
            if (percent > 0.5) {
                interactivePopTransition.finishInteractiveTransition()
            } else {
                interactivePopTransition.cancelInteractiveTransition()
            }
            
            interactivePopTransition = nil
        }
    }
}