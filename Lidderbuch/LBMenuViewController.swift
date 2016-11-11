//
//  LBMenuViewController.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
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
            NSForegroundColorAttributeName: UIColor.white]
        
        // make links clickable
        creditsTextView.isEditable = false
        creditsTextView.dataDetectorTypes = .link
        
        // set content
        creditsTextView.attributedText = prepareCreditsAttributedText()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if tapBehindGestureRecognizer == nil
        {
            // create tap behind gesture recognizer
            tapBehindGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LBMenuViewController.handleTapBehindGesture(_:)))
            tapBehindGestureRecognizer.numberOfTapsRequired = 1
            tapBehindGestureRecognizer.delegate = self
            view.window?.addGestureRecognizer(tapBehindGestureRecognizer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        view.window?.removeGestureRecognizer(tapBehindGestureRecognizer)
    }
    
    func prepareCreditsAttributedText() -> NSAttributedString
    {
        // screen width break points to make the text look good
        let screenWidth = UIScreen.main.bounds.size.width
        
        var fontSize: CGFloat = 15.5
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
            "ACEL": "https://acel.lu/",
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
            if let range = creditsText.range(of: name, options: NSString.CompareOptions.diacriticInsensitive, range: nil, locale: nil)
            {
                let textRange = NSMakeRange(creditsText.characters.distance(from: creditsText.startIndex, to: range.lowerBound), creditsText.characters.distance(from: range.lowerBound, to: range.upperBound))
                attributedText.addAttribute(NSLinkAttributeName, value: URL(string: href)!, range: textRange)
            }
        }
        
        return attributedText
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let location = gestureRecognizer.location(in: view!)
        if view.point(inside: location, with: nil) {
            return false
        }
        
        return true
    }
    
    @IBAction func handleTapBehindGesture(_ gestureRecognizer: UITapGestureRecognizer)
    {
        dismiss(animated: true, completion: nil)
    }
}
