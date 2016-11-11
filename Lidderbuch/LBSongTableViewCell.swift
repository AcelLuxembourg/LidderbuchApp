//
//  LBSongTableViewCell.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
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
                // name attributed string
                let nameAttributedString = NSMutableAttributedString()
                
                if let number = song.number {
                    let numberAttributedString = NSMutableAttributedString(string: "\(number) ")
                    numberAttributedString.addAttribute(NSForegroundColorAttributeName, value: LBVariables.tintColor, range: NSMakeRange(0, numberAttributedString.length))
                    nameAttributedString.append(numberAttributedString)
                }
                
                nameAttributedString.append(NSMutableAttributedString(string: song.name))
                
                nameLabel.attributedText = nameAttributedString
                
                // preview attributed string
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                
                let previewAttributedString = NSMutableAttributedString(string: song.preview)
                previewAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, previewAttributedString.length))
                
                previewLabel.attributedText = previewAttributedString
            }
        }
    }
}
