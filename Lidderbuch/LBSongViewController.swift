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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lyricsScrollView: LBLyricsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameParagraphStyle = NSMutableParagraphStyle()
        nameParagraphStyle.lineSpacing = 5
        
        let nameAttributedString = NSMutableAttributedString(string: song.name)
        nameAttributedString.addAttribute(NSParagraphStyleAttributeName, value: nameParagraphStyle, range: NSMakeRange(0, nameAttributedString.length))
        
        nameLabel.attributedText = nameAttributedString
        
        lyricsScrollView.paragraphs = song.paragraphs
        lyricsScrollView.lyricsViewDelegate = self
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