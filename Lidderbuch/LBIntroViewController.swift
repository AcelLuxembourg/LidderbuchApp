//
//  LBIntroViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 07/06/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBIntroViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    
    private var frame: Int = -1
    private let frameCount: Int = 25
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        imageView.clipsToBounds = true
        
        // wait to prevent frame skip
        NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: Selector("startAnimation:"), userInfo: nil, repeats: false)
    }
    
    @IBAction func startAnimation(timer: NSTimer)
    {
        // start animation at 25 fps
        NSTimer.scheduledTimerWithTimeInterval(0.04, target: self, selector: Selector("animationTick:"), userInfo: nil, repeats: true)
    }
    
    @IBAction func animationTick(timer: NSTimer)
    {
        if ++frame < 25
        {
            // move down to next frame
            let imageLayer = imageView.layer
            var contentsRect = imageLayer.contentsRect
            contentsRect.origin.y = CGFloat(frame) * (CGFloat(1.0) / CGFloat(frameCount))
            imageLayer.contentsRect = contentsRect
        }
        else
        {
            // animation completed
            timer.invalidate()
            
            // proceed to songbook
            performSegueWithIdentifier("ShowSongbook", sender: self)
        }
    }
}