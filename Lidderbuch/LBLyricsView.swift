//
//  LBLyricsView.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 13/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBLyricsView: UIView
{
    private var textLayout: [[[String]]]?
    private var textLayoutWidth: CGFloat?
    
    private let lineWrapInset: CGFloat = 25
    
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
    
    var textColor = UIColor(white: 0.2, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
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
    
    var refrainParagraphInset: CGFloat = 0 {
        didSet {
            invalidateLyricsLayout()
        }
    }
    
    var refrainParagraphTextColor = UIColor(white: 0.5, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // redraw content if bounds change
        self.contentMode = .Redraw
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if (
            textLayoutWidth != nil
            && textLayoutWidth != self.bounds.size.width
        ) {
            // width changed, height may be invalid
            invalidateIntrinsicContentSize()
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        // compose text attributes
        let normalTextAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        ]
        
        let refrainTextAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: refrainParagraphTextColor
        ]
        
        // load images
        let lineBreakIconImage = UIImage(named: "LineBreakIcon")!
        
        // calculate text layout
        let textLayout = layoutText(self.bounds.size.width)
        
        var y: CGFloat = 0
        for var i = 0; i < paragraphs.count; i++
        {
            // draw paragraph
            let paragraph = paragraphs[i]
            let lines: [[String]] = textLayout[i]
            
            for fragments: [String] in lines {
                for var j = 0; j < fragments.count; j++
                {
                    var x: CGFloat = 0
                        + (paragraph.refrain ? refrainParagraphInset : 0)
                        + (j > 0 ? lineWrapInset : 0)
                    
                    var text = fragments[j]
                    
                    var textAttributes = (paragraph.refrain ?
                        refrainTextAttributes : normalTextAttributes)
                    
                    if (j > 0)
                    {
                        // draw line break icon
                        lineBreakIconImage.drawAtPoint(CGPoint(x: x - 22, y: y))
                    }
                    
                    // draw line
                    NSString(string: text).drawAtPoint(
                        CGPoint(x: x, y: y),
                        withAttributes: textAttributes)
                    
                    y += lineHeight
                }
            }
            
            y += paragraphPadding
        }
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        let width = self.bounds.size.width
        let textLayout = layoutText(width)
        
        // sum paragraph padding
        var height: CGFloat = CGFloat(textLayout.count - 1) * paragraphPadding
        
        // sum fragment line height
        for lines: [[String]] in textLayout {
            for fragments: [String] in lines {
                height += CGFloat(fragments.count) * lineHeight
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func invalidateLyricsLayout()
    {
        // reset precalculated lyrics layout
        textLayout = nil
        textLayoutWidth = nil
        
        // notify possible bounds change
        invalidateIntrinsicContentSize()
    }
    
    private func layoutText(width: CGFloat) -> [[[String]]]
    {
        // invalid width
        if (width == 0) {
            return [[[String]]]()
        }
        
        // return cached result if available
        if textLayoutWidth == width {
            return textLayout!
        }
        
        // text layout array
        // paragraphs -> lines -> fragments
        textLayout = [[[String]]]()
        textLayoutWidth = width
        
        // layout each paragraph's content
        for paragraph: LBParagraph in paragraphs
        {
            var paragraphLines = paragraph.content.componentsSeparatedByString("\n")
            
            var lines = [[String]]()
            
            for paragraphLine: String in paragraphLines
            {
                var fragments = [String]()
                
                // wrap line in multiple fragments
                //  and consume remainder
                var remainder: String? = paragraphLine
                
                while (remainder != nil)
                {
                    // calculate container width
                    var containerWidth = width
                        - (paragraph.refrain ? refrainParagraphInset : 0)
                        - (fragments.count > 0 ? lineWrapInset : 0)
                    
                    // wrap line in container
                    let result = wrapText(remainder!, font: font, containerWidth: containerWidth)
                    fragments.append(result.fragment)
                    remainder = result.remainder
                }
                
                // add line fragments to paragraph lines
                lines.append(fragments)
            }
            
            // add paragraph lines to paragraph
            textLayout!.append(lines)
        }
        
        return textLayout!
    }
    
    private func wrapText(text: String, font: UIFont, containerWidth: CGFloat)
        -> (fragment: String, remainder: String?)
    {
        // compose attributed string with given font
        var attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSFontAttributeName, value: font,
            range: NSMakeRange(0, attributedString.length))
        
        // compose layout manager
        let layoutManager = NSLayoutManager()
        
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: CGFloat.max));
        layoutManager.addTextContainer(textContainer)
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        
        var result: (fragment: String, remainder: String?)?
        
        // go through each line fragment
        layoutManager.enumerateLineFragmentsForGlyphRange(NSMakeRange(0, layoutManager.numberOfGlyphs), usingBlock: {
            (rect, usedRect, textContainer, glyphRange, stop) in
            
            // we are only interested in the first fragment
            if (result == nil)
            {
                let range = layoutManager.characterRangeForGlyphRange(glyphRange, actualGlyphRange: nil)
                
                // substring wrapped line and remainder
                let fragment = NSString(string: text).substringWithRange(range)
                var remainder: String = NSString(string: text).substringFromIndex(range.length)
                
                result = (fragment: fragment, remainder: (count(remainder) > 0 ? remainder : nil))
            }
        })
        
        return result!
    }
}
