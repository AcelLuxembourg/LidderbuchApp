//
//  LBSongViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 15/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBSongViewController: LBViewController
{
    var song: LBSong!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var lyricsView: LBLyricsView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = song.name
        lyricsView.paragraphs = song.paragraphs
        
        // configure tab gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        // clear highlighted line
        UIView.animateWithDuration(0.2) {
            self.lyricsView.highlightedLine = nil
        }
    }
    
    func scrollToLyricsViewLine(line: Int)
    {
        let lineOrigin = lyricsView.lineOrigin(line)
        let scrollViewOffsetTop = min(lineOrigin.y - self.scrollView.contentInset.top, scrollView.contentSize.height - scrollView.bounds.size.height)
        
        UIView.animateWithDuration(0.2) {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: scrollViewOffsetTop)
        }
    }
    
    @IBAction func handleTapGesture(gestureRecognizer: UITapGestureRecognizer)
    {
        var line: Int?
        
        // choose line
        if lyricsView.highlightedLine == nil {
            line = lyricsView.lineNextToTopOffset(
                scrollView.contentOffset.y + scrollView.contentInset.top)
        } else {
            line = lyricsView.highlightedLine! + 1
        }
        
        if line < lyricsView.lineCount()
        {
            // scroll to chosen line
            scrollToLyricsViewLine(line!)
            
            // hide header bar
            UIView.animateWithDuration(0.1) {
                self.headerBar.verticalTranslation = self.headerBar.bounds.height
            }
        }
        else
        {
            // reached end of lyrics
            line = nil
            
            // scroll to top
            UIView.animateWithDuration(0.3) {
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: -self.scrollView.contentInset.top)
            }
        }
        
        // highlight line
        UIView.animateWithDuration(0.15) {
            self.lyricsView.highlightedLine = line
        }
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func share(sender: UIButton)
    {
        let activityViewController = UIActivityViewController(
            activityItems: [song.name, song.url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}