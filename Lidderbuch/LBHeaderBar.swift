//
//  LBHeaderBar.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBHeaderBar: UIView, UIScrollViewDelegate
{
    var offset : CGFloat { //offset in Header Bar for iphone x and newer for scrolling down
        let modelName = UIDevice.modelName
        let devices = ["iPhone X", "iPhone XS", "Simulator iPhone XS Max", "Simulator iPhone X", "Simulator iPhone XS", "Simulator iPhone XS Max" ]
        if devices.contains(modelName) {
            return 25
        }
        return 0
    }
    
    var lastVerticalTranslation: CGFloat = 0
    var verticalTranslation: CGFloat {
        get {
            return lastVerticalTranslation
        }
        set(newValue) {
            let verticalTranslation = max(min(newValue, bounds.size.height - self.offset), 0)
            if lastVerticalTranslation != verticalTranslation && !disableVerticalTranslation {
                transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: -verticalTranslation)
                lastVerticalTranslation = verticalTranslation
            }
        }
    }
    
    var cancelSlideTimer: Timer?
    
    var disableVerticalTranslation = false {
        didSet {
            if disableVerticalTranslation && disableVerticalTranslation != oldValue {
                UIView.animate(withDuration: 0.1, animations: {
                    self.verticalTranslation = 0
                }) 
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: bounds.size.width, height: 60.0)
    }

    override func draw(_ rect: CGRect)
    {
        // background color
        var backgroundRect = self.bounds
        backgroundRect.size.height -= 1.0
        let backgroundContainer = UIBezierPath(rect: backgroundRect)
        
        UIColor.white.setFill()
        backgroundContainer.fill()
        
        // separator
        let separatorLine = UIBezierPath()
        separatorLine.move(to: CGPoint(x: 0.0, y: self.bounds.size.height - 0.5))
        separatorLine.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - 0.5))
        
        UIColor(white: 0.0, alpha: 0.13).setStroke()
        separatorLine.stroke()
    }
    
    func translateVertically(_ delta: CGFloat)
    {
        let verticalTranslation = max(min(self.verticalTranslation + delta, bounds.size.height-offset), 0)
        
        // check if vertical translation changed
        if self.verticalTranslation != verticalTranslation
        {
            // translate view
            self.verticalTranslation = verticalTranslation
            
            // create finish timer
            cancelSlideTimer?.invalidate()
            cancelSlideTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(LBHeaderBar.handleCancelSlideTimer(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func handleCancelSlideTimer(_ timer: Timer)
    {
        // cancel if slide not finished yet
        if verticalTranslation != bounds.size.height-offset && verticalTranslation != 0 {
            UIView.animate(withDuration: 0.1, animations: {
                self.verticalTranslation = 0.0
            }) 
        }
    }
}
