//
//  LBSongTableViewCell.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 13/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBSongTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    var song: LBSong? {
        didSet {
            if let song = self.song
            {
                nameLabel.text = song.name
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                
                let attributedString = NSMutableAttributedString(string: song.preview)
                attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
                
                previewLabel.attributedText = attributedString
            }
        }
    }
}
