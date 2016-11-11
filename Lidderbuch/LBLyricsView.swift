//
//  LBLyricsView.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBLyricsView: UIScrollView
{
    fileprivate var lineOrigins: [CGPoint]!
    fileprivate var lineViews: [[UIView]]!
    
    weak var lyricsViewDelegate: LBLyricsViewDelegate?
    @IBOutlet var headerView: UIView? {
        didSet {
            if headerView != nil {
                addSubview(headerView!)
            } else if oldValue != nil {
                oldValue!.removeFromSuperview()
            }
            
            invalidateLyricsLayout()
        }
    }
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var paragraphs = [LBParagraph]() {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var font = UIFont(name: "Georgia", size: 17.0)! {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var textColor = UIColor(white: 0.15, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lyricsInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0) {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var lineHeight: CGFloat = 27 {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var paragraphPadding: CGFloat = 27 {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    fileprivate let lineWrapInset: CGFloat = 24
    
    var refrainParagraphInset: CGFloat = 0 {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var refrainFont: UIFont = UIFont(name: "Georgia-Italic", size: 17.0)! {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var highlightedLine: Int? = nil {
        didSet {
            if highlightedLine != oldValue && lineViews != nil
            {
                // go through all anchor views
                for i in 0..<lineViews!.count
                {
                    var anchorAlpha: CGFloat = 1.0
                    
                    if highlightedLine != nil &&  i != highlightedLine! {
                        anchorAlpha = 0.4
                    }
                    
                    // change alpha of views
                    let views = lineViews![i]
                    for view in views {
                        view.alpha = anchorAlpha
                    }
                }
                
                if highlightedLine != nil {
                    scrollToLine(highlightedLine!)
                }
                
                // inform delegate
                if let delegate = lyricsViewDelegate {
                    delegate.lyricsView(self, didHighlightLine: highlightedLine)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // redraw content if bounds change
        contentMode = .redraw
        backgroundColor = UIColor.white
        
        // configure tab gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LBLyricsView.handleTapGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        layoutLyrics()
    }
    
    fileprivate func invalidateLyricsLayout()
    {
        // reset layout
        lineOrigins = nil
        lineViews = nil
    }
    
    fileprivate func layoutLyrics()
    {
        let width = bounds.size.width
        
        // only layout if width changed
        if contentSize.width == width {
            return
        }
        
        // remove all views
        if lineViews != nil {
            for fragmentViews in lineViews {
                for fragmentView in fragmentViews {
                    fragmentView.removeFromSuperview()
                }
            }
        }
        
        // reset layout
        lineOrigins = [CGPoint]()
        lineViews = [[UIView]]()
        
        // load images
        let lineBreakImage = UIImage(named: "LineBreakIcon")!
        
        // layout each paragraph
        var y: CGFloat = lyricsInset.top
        
        // let the cursor jump below header view
        if headerView != nil {
            y += headerView!.bounds.size.height
        }
        
        for paragraph: LBParagraph in paragraphs
        {
            let paragraphFont: UIFont = (paragraph.refrain ? refrainFont : font)
            
            let lines = paragraph.content.components(separatedBy: "\n")
            for line: String in lines
            {
                // determin line alpha according to highlighted line
                var lineAlpha: CGFloat = 1.0
                
                if highlightedLine != nil && lineViews.count + 1 != highlightedLine! {
                    lineAlpha = 0.4
                }
                
                // wrap line in multiple fragments
                //  and consume remainder
                var fragmentViews = [UIView]()
                var remainder: String? = line
                
                while (remainder != nil)
                {
                    // calculate line offset
                    let x: CGFloat = 0
                        + lyricsInset.left
                        + (paragraph.refrain ? refrainParagraphInset : 0)
                        + (fragmentViews.count > 0 ? lineWrapInset : 0)
                    
                    if fragmentViews.count == 0
                    {
                        // at first iteration store line origin
                        lineOrigins.append(CGPoint(x: x, y: y))
                    }
                    else if fragmentViews.count == 1
                    {
                        // create line break view
                        let lineBreakView = UIImageView()
                        lineBreakView.image = lineBreakImage
                        lineBreakView.alpha = lineAlpha
                        lineBreakView.frame = CGRect(x: x - 22.0, y: y, width: 0.0, height: 0.0)
                        lineBreakView.sizeToFit()
                        
                        fragmentViews.append(lineBreakView)
                        addSubview(lineBreakView)
                    }
                    
                    // wrap line in container width
                    let result = wrapText(remainder!, font: font, containerWidth: width - x - lyricsInset.right)
                    remainder = result.remainder
                    
                    // create line fragment view
                    let fragmentView = UILabel()
                    fragmentView.text = result.fragment
                    fragmentView.textColor = textColor
                    fragmentView.font = paragraphFont
                    fragmentView.alpha = lineAlpha
                    fragmentView.frame = CGRect(x: x, y: y, width: 0.0, height: 0.0)
                    fragmentView.sizeToFit()
                    
                    fragmentViews.append(fragmentView)
                    addSubview(fragmentView)
                    
                    y += lineHeight
                }
                
                // add fragment views to line
                lineViews.append(fragmentViews)
            }
            
            y += paragraphPadding
        }
        
        y += lyricsInset.bottom - paragraphPadding
        
        // set the intrinsic layout size
        contentSize = CGSize(width: width, height: y)
    }
    
    fileprivate func wrapText(_ text: String, font: UIFont, containerWidth: CGFloat)
        -> (fragment: String, remainder: String?)
    {
        // compose attributed string with given font
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSFontAttributeName, value: font,
            range: NSMakeRange(0, attributedString.length))
        
        // compose layout manager
        let layoutManager = NSLayoutManager()
        
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: CGFloat.greatestFiniteMagnitude));
        layoutManager.addTextContainer(textContainer)
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        
        var result: (fragment: String, remainder: String?)?
        
        // go through each line fragment
        layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(0, layoutManager.numberOfGlyphs), using: {
            (rect, usedRect, textContainer, glyphRange, stop) in
            
            // we are only interested in the first fragment
            if (result == nil)
            {
                let range = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                
                // substring wrapped line and remainder
                let fragment = NSString(string: text).substring(with: range)
                let remainder: String = NSString(string: text).substring(from: range.length)
                
                result = (fragment: fragment, remainder: (remainder.characters.count > 0 ? remainder : nil))
            }
        })
        
        return result!
    }
    
    func lineNextToTopOffset(_ topOffset: CGFloat) -> Int
    {
        layoutLyrics()
        
        if lineOrigins.count < 2 {
            return 0
        }
        
        var line = 1
        while line < lineOrigins.count - 1 && lineOrigins[line].y <= topOffset + contentInset.top + bounds.size.height * 0.15 {
            line += 1
        }
        
        let middleBetweenLinesTopOffset = (lineOrigins[line].y - lineOrigins[line - 1].y) * 0.5 + lineOrigins[line - 1].y
        
        // choose nearest neighbour line
        return (topOffset < middleBetweenLinesTopOffset ? line - 1 : line)
    }
    
    func scrollToLine(_ line: Int)
    {
        let offsetTop = max(lineOrigins[line].y - contentInset.top - bounds.size.height * 0.15, 0.0)
        
        self.contentOffset = CGPoint(x: self.contentOffset.x, y: offsetTop)
    }
    
    @IBAction func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer)
    {
        var line: Int?
        
        // choose line
        if highlightedLine == nil {
            if contentOffset.y <= 0 {
                line = 0
            } else {
                line = lineNextToTopOffset(contentOffset.y)
            }
        } else {
            line = highlightedLine! + 1
        }
        
        if line! >= lineOrigins.count
        {
            // reached end of lyrics
            line = nil
            
            // scroll to top
            UIView.animate(withDuration: 0.3, animations: {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: -self.contentInset.top)
            }) 
        }
        
        // highlight line
        UIView.animate(withDuration: 0.2, animations: {
            self.highlightedLine = line
        }) 
    }
}

protocol LBLyricsViewDelegate: class
{
    func lyricsView(_ lyricsView: LBLyricsView, didHighlightLine line: Int?)
}
