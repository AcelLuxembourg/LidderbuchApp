//
//  LBSongViewController.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBSongViewController: LBViewController,
    LBLyricsViewDelegate
{
    private var viewTimer: NSTimer?
    private var viewTracked = false
    
    var song: LBSong!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var lyricsScrollView: LBLyricsView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var delegate: LBSongViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let lineHeightMultipleStyle = NSMutableParagraphStyle()
        lineHeightMultipleStyle.lineHeightMultiple = 1.25
        
        let nameAttributedString = NSMutableAttributedString(string: song.name)
        nameAttributedString.addAttribute(NSParagraphStyleAttributeName, value: lineHeightMultipleStyle, range: NSMakeRange(0, nameAttributedString.length))
        
        nameLabel.attributedText = nameAttributedString
        
        let detailAttributedString = NSMutableAttributedString(string: song.detail)
        detailAttributedString.addAttribute(NSParagraphStyleAttributeName, value: lineHeightMultipleStyle, range: NSMakeRange(0, detailAttributedString.length))
        
        detailLabel.attributedText = detailAttributedString
        
        lyricsScrollView.paragraphs = song.paragraphs
        lyricsScrollView.lyricsViewDelegate = self
        
        updateView()
        
        // observe application active state
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("applicationWillResignActiveNotification:"), name: UIApplicationWillResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("applicationDidBecomeActiveNotification:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // report user activity
        if #available(iOS 9.0, *) {
            self.userActivity = song.createUserActivity()
            self.userActivity!.becomeCurrent()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        startTrackingView()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        stopTrackingView()
    }
    
    func updateView()
    {
        // update bookmark button icon
        let bookmarkIconName = song.bookmarked ? "BookmarkedIcon" : "BookmarkIcon"
        bookmarkButton.setImage(UIImage(named: bookmarkIconName), forState: .Normal)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        // clear highlighted line when scrolling
        if lyricsScrollView.highlightedLine != nil {
            UIView.animateWithDuration(0.2) {
                self.lyricsScrollView.highlightedLine = nil
            }
        }
    }
    
    func lyricsView(lyricsView: LBLyricsView, didHighlightLine line: Int?)
    {
        // hide header bar when a line gets highlighted
        UIView.animateWithDuration(0.1) {
            if line != nil {
                self.headerBar.verticalTranslation = self.headerBar.bounds.height
            }
        }
    }
    
    // MARK: View Tracking
    
    func startTrackingView()
    {
        if viewTimer == nil && !viewTracked {
            viewTimer = NSTimer.scheduledTimerWithTimeInterval(
                LBVariables.songViewDuration, target: self, selector: Selector("viewTimerDidFire:"),
                userInfo: nil, repeats: false)
        }
    }
    
    func stopTrackingView()
    {
        if viewTimer != nil {
            viewTimer?.invalidate()
            viewTimer = nil;
        }
    }
    
    func viewTimerDidFire(timer: NSTimer)
    {
        // track view
        song.views++
        song.viewTime = NSDate()
        
        delegate?.songViewController(self, songDidChange: song)
        
        viewTracked = true
        stopTrackingView()
    }
    
    func applicationDidBecomeActiveNotification(notification: NSNotification)
    {
        startTrackingView()
    }
    
    func applicationWillResignActiveNotification(notification: NSNotification)
    {
        stopTrackingView()
    }
    
    // MARK: Header Buttons
    
    @IBAction func handleBackButton(sender: UIButton)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func handleBookmarkButton(sender: UIButton)
    {
        // toggle song bookmark
        song.bookmarked = !song.bookmarked
        delegate?.songViewController(self, songDidChange: song)
        
        updateView()
    }
    
    @IBAction func handleShareButton(sender: UIButton)
    {
        let activityViewController = UIActivityViewController(
            activityItems: [song.url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}

protocol LBSongViewControllerDelegate
{
    func songViewController(songViewController: LBSongViewController, songDidChange song: LBSong)
}