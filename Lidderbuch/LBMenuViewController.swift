//
//  LBMenuViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 06/06/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBMenuViewController: UIViewController, UIGestureRecognizerDelegate
{
    @IBOutlet weak var creditsTextView: UITextView!
    
    var tapBehindGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        creditsTextView.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // make links clickable
        creditsTextView.editable = false
        creditsTextView.dataDetectorTypes = .Link
        
        // set content
        creditsTextView.attributedText = prepareCreditsAttributedText()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if tapBehindGestureRecognizer == nil
        {
            // create tap behind gesture recognizer
            tapBehindGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapBehindGesture:"))
            tapBehindGestureRecognizer.numberOfTapsRequired = 1
            tapBehindGestureRecognizer.delegate = self
            view.window?.addGestureRecognizer(tapBehindGestureRecognizer)
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        view.window?.removeGestureRecognizer(tapBehindGestureRecognizer)
    }
    
    func prepareCreditsAttributedText() -> NSAttributedString
    {
        // screen width break points to make the text look good
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        var fontSize: CGFloat = 17.0
        if screenWidth >= 375.0 {
            fontSize = 17.5
        } else if screenWidth >= 414.0 {
            fontSize = 19.0
        }
        
        let font = UIFont(name: "Georgia", size: fontSize)!
        let color = UIColor(white: 1.0, alpha: 0.6)
        
        // get credits
        let creditsText = NSLocalizedString("credits text", comment: "")
        let creditsLinks = [
            "Lidderbuch": "itms://itunes.apple.com/app/lidderbuch/id997143407?mt=8",
            "ACEL": "http://acel.lu/",
            "Fränz Friederes": "http://2f.lt/1GioavM",
            "GitHub": "https://github.com/AcelLuxembourg/LidderbuchApp",
            NSLocalizedString("credits text contact us", comment: "Contact us part which gets transformed to a link."): "http://acel.lu/about/contact"
        ]
        
        let attributedText = NSMutableAttributedString(string: creditsText)
        let fullTextRange = NSMakeRange(0, attributedText.length)
        
        // paragraph style attribute
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: fullTextRange)
        
        // set font
        attributedText.addAttribute(NSFontAttributeName, value: font, range: fullTextRange)
        
        // set foreground color
        attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: fullTextRange)
        
        // set link attribute for each link
        for (name, href) in creditsLinks
        {
            if let range = creditsText.rangeOfString(name, options: NSStringCompareOptions.DiacriticInsensitiveSearch, range: nil, locale: nil)
            {
                let textRange = NSMakeRange(distance(creditsText.startIndex, range.startIndex), distance(range.startIndex, range.endIndex))
                attributedText.addAttribute(NSLinkAttributeName, value: NSURL(string: href)!, range: textRange)
            }
        }
        
        return attributedText
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let location = gestureRecognizer.locationInView(view!)
        if view.pointInside(location, withEvent: nil) {
            return false
        }
        
        return true
    }
    
    @IBAction func handleTapBehindGesture(gestureRecognizer: UITapGestureRecognizer)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}