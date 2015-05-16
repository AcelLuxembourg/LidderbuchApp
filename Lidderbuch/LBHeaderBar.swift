//
//  LBHeaderBar.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 14/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBHeaderBar: UIView, UIScrollViewDelegate
{
    var verticalTranslation: CGFloat = 0
    var cancelSlideTimer: NSTimer?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: bounds.size.width, height: 60.0)
    }

    override func drawRect(rect: CGRect)
    {
        // background color
        var backgroundRect = self.bounds
        backgroundRect.size.height -= 1.0
        let backgroundContainer = UIBezierPath(rect: backgroundRect)
        
        UIColor.whiteColor().setFill()
        backgroundContainer.fill()
        
        // separator
        let separatorLine = UIBezierPath()
        separatorLine.moveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height - 0.5))
        separatorLine.addLineToPoint(CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - 0.5))
        
        UIColor(white: 0.0, alpha: 0.13).setStroke()
        separatorLine.stroke()
    }
    
    func slideVertically(delta: CGFloat)
    {
        let verticalTranslation = max(min(self.verticalTranslation + delta, bounds.size.height), 0)
        
        // check if vertical translation changed
        if self.verticalTranslation != verticalTranslation
        {
            // translate view
            transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, -verticalTranslation)
            self.verticalTranslation = verticalTranslation
            
            // create finish timer
            cancelSlideTimer?.invalidate()
            cancelSlideTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("handleCancelSlideTimer:"), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func handleCancelSlideTimer(timer: NSTimer)
    {
        // slide down animated if slide not finished yet
        if verticalTranslation != bounds.size.height && verticalTranslation != 0 {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.slideVertically(-self.bounds.size.height)
            })
        }
    }
}
