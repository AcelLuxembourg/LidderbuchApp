//
//  LBSongViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 15/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

struct LBSongViewControllerConstants {
    static let lineMarkerPositionRelativeToLineHeight: CGFloat = 0.38
}

class LBSongViewController: LBViewController
{
    var song: LBSong!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var lineMarkView: UIImageView!
    
    @IBOutlet var lyricsView: LBLyricsView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = song.name
        lyricsView.paragraphs = song.paragraphs
        
        // create line marker view
        lineMarkView = UIImageView(image: UIImage(named: "LineMarkIcon")!)
        view.addSubview(lineMarkView)
        
        // configure tab gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // layout line marker view
        let lineMarkerViewSize = lineMarkView.intrinsicContentSize()
        let lineMarkerViewOrigin = CGPoint(x: lyricsView.frame.origin.x - lineMarkerViewSize.width - 9.0, y: lyricsView.frame.origin.y + scrollView.contentInset.top - lineMarkerViewSize.height * 0.5 + lyricsView.lineHeight * LBSongViewControllerConstants.lineMarkerPositionRelativeToLineHeight)
        lineMarkView.frame = CGRect(origin: lineMarkerViewOrigin, size: lineMarkerViewSize)
        
        // layout bottom inset to scroll view
        var scrollViewContentInset = scrollView.contentInset
        scrollViewContentInset.bottom = scrollView.bounds.size.height - lineMarkView.frame.midY - lyricsView.lineHeight * (1.0 - LBSongViewControllerConstants.lineMarkerPositionRelativeToLineHeight)
        scrollView.contentInset = scrollViewContentInset
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        scrollToNextLyricsLineAnchor()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNextLyricsLineAnchor()
        }
    }
    
    func lyricsViewPosition() -> CGFloat {
        return scrollView.contentOffset.y + scrollView.contentInset.top
    }
    
    func scrollToLyricsViewAnchor(anchor: CGFloat) {
        UIView.animateWithDuration(0.2) {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: anchor - self.scrollView.contentInset.top)
        }
    }
    
    func scrollToNextLyricsLineAnchor() {
        var nearestAnchor = lyricsView.nearestLineAnchor(lyricsViewPosition())
        scrollToLyricsViewAnchor(nearestAnchor)
    }
    
    @IBAction func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        var nextAnchor = lyricsView.nextLineAnchor(lyricsViewPosition())
        scrollToLyricsViewAnchor(nextAnchor)
        
        UIView.animateWithDuration(0.1) {
            self.headerBar.verticalTranslation = self.headerBar.bounds.height
        }
    }
    
    @IBAction func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func share(sender: UIButton)
    {
        let activityItems = [song.name, song.url]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
