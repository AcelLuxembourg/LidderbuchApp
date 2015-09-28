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
        
        setBookmarked(song.bookmarked)
        
        if #available(iOS 9.0, *) {
            self.userActivity = song.createUserActivity()
            self.userActivity!.becomeCurrent()
        }
    }
    
    private func setBookmarked(bookmarked: Bool)
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