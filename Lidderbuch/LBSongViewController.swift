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
    fileprivate var viewTimer: Timer?
    fileprivate var viewTracked = false
    
    var song: LBSong!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var lyricsScrollView: LBLyricsView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LBSongViewController.applicationWillResignActiveNotification(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LBSongViewController.applicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // report user activity
        if #available(iOS 9.0, *) {
            self.userActivity = song.createUserActivity()
            self.userActivity!.becomeCurrent()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        startTrackingView()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        stopTrackingView()
    }
    
    func updateView()
    {
        // update bookmark button icon
        let bookmarkIconName = song.bookmarked ? "BookmarkedIcon" : "BookmarkIcon"
        bookmarkButton.setImage(UIImage(named: bookmarkIconName), for: UIControlState())
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        // clear highlighted line when scrolling
        if lyricsScrollView.highlightedLine != nil {
            UIView.animate(withDuration: 0.2, animations: {
                self.lyricsScrollView.highlightedLine = nil
            }) 
        }
    }
    
    func lyricsView(_ lyricsView: LBLyricsView, didHighlightLine line: Int?)
    {
        // hide header bar when a line gets highlighted
        UIView.animate(withDuration: 0.1, animations: {
            if line != nil {
                self.headerBar.verticalTranslation = self.headerBar.bounds.height
            }
        }) 
    }
    
    // MARK: View Tracking
    
    func startTrackingView()
    {
        if viewTimer == nil && !viewTracked {
            viewTimer = Timer.scheduledTimer(
                timeInterval: LBVariables.songViewDuration, target: self, selector: #selector(LBSongViewController.viewTimerDidFire(_:)),
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
    
    func viewTimerDidFire(_ timer: Timer)
    {
        // track view
        song.views += 1
        song.viewTime = Date()
        
        delegate?.songViewController(self, songDidChange: song)
        
        viewTracked = true
        stopTrackingView()
    }
    
    func applicationDidBecomeActiveNotification(_ notification: Notification)
    {
        startTrackingView()
    }
    
    func applicationWillResignActiveNotification(_ notification: Notification)
    {
        stopTrackingView()
    }
    
    // MARK: Header Buttons
    
    @IBAction func handleBackButton(_ sender: UIButton)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBookmarkButton(_ sender: UIButton)
    {
        // toggle song bookmark
        song.bookmarked = !song.bookmarked
        delegate?.songViewController(self, songDidChange: song)
        
        updateView()
    }
    
    @IBAction func handleShareButton(_ sender: UIButton)
    {
        let activityViewController = UIActivityViewController(
            activityItems: [song.url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]

        if let popOver = activityViewController.popoverPresentationController {
            popOver.sourceView = self.shareButton
            popOver.sourceRect = self.shareButton.bounds
        }
        present(activityViewController, animated: true, completion: nil)
    }
}

protocol LBSongViewControllerDelegate
{
    func songViewController(_ songViewController: LBSongViewController, songDidChange song: LBSong)
}
