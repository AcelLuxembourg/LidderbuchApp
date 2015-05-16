//
//  LBSongbookViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 13/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBSongbookViewController: LBViewController, LBSongbookDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    var songbook: LBSongbook!
    var songs = [LBSong]()
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Lidderbuch"
        
        songbook = LBSongbook()
        songbook.delegate = self
        songbook.update()
    }
    
    func songbookDidChange(songbook: LBSongbook)
    {
        update()
    }
    
    func update()
    {
        songs = songbook.songs
        
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! LBSongTableViewCell
        
        let row = indexPath.row
        cell.song = songs[row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowSong", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "ShowSong")
        {
            // inject selected song into song view controller
            if let songViewController = segue.destinationViewController as? LBSongViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow() {
                    songViewController.song = songs[selectedIndexPath.row]
                }
            }
        }
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if viewController === self {
            if let selectedRowIndexPath = tableView.indexPathForSelectedRow() {
                tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: animated)
            }
        }
    }
}
