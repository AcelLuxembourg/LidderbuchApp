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
    
    @IBOutlet var lyricsView: LBLyricsView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nameLabel.text = song.name
        lyricsView.paragraphs = song.paragraphs
    }
    
    @IBAction func handleBackButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
}
