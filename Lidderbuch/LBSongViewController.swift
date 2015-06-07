//
//  LBSongViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 15/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBSongViewController: LBViewController,
    LBLyricsViewDelegate
{
    var song: LBSong!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lyricsScrollView: LBLyricsView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var delegate: LBSongViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameParagraphStyle = NSMutableParagraphStyle()
        nameParagraphStyle.lineHeightMultiple = 1.25
        
        let nameAttributedString = NSMutableAttributedString(string: song.name)
        nameAttributedString.addAttribute(NSParagraphStyleAttributeName, value: nameParagraphStyle, range: NSMakeRange(0, nameAttributedString.length))
        
        nameLabel.attributedText = nameAttributedString
        
        lyricsScrollView.paragraphs = song.paragraphs
        lyricsScrollView.lyricsViewDelegate = self
        
        setBookmarked(song.bookmarked)
    }
    
    func setBookmarked(bookmarked: Bool)
    {
        let bookmarkIconName = song.bookmarked ? "BookmarkedIcon" : "BookmarkIcon"
        bookmarkButton.setImage(UIImage(named: bookmarkIconName), forState: .Normal)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        // clear highlighted line
        UIView.animateWithDuration(0.2) {
            self.lyricsScrollView.highlightedLine = nil
        }
    }
    
    func lyricsView(lyricsView: LBLyricsView, didHighlightLine line: Int?)
    {
        // hide header bar
        UIView.animateWithDuration(0.1) {
            if line != nil {
                self.headerBar.verticalTranslation = self.headerBar.bounds.height
            }
        }
    }
    
    @IBAction func handleBackButtonTap(sender: UIButton)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func handleBookmarkButtonTap(sender: UIButton)
    {
        // toggle song bookmark
        song.bookmarked = !song.bookmarked
        delegate?.songViewController(self, songDidChange: song)
        
        // update ui
        setBookmarked(song.bookmarked)
    }
    
    @IBAction func handleShareButtonTap(sender: UIButton)
    {
        let activityViewController = UIActivityViewController(
            activityItems: [song.name, song.url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}

protocol LBSongViewControllerDelegate
{
    func songViewController(songViewController: LBSongViewController, songDidChange song: LBSong)
}