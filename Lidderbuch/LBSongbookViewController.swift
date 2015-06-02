//
//  LBSongbookViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 13/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBSongbookViewController: LBViewController,
    LBSongbookDelegate,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate
{
    var songbook: LBSongbook!
    var songs = [LBSong]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searchingInBackground = false
    var searchActive = false {
        didSet {
            headerBar.disableVerticalTranslation = searchActive
            
            if !searchActive {
                songs = songbook.songs
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Lidderbuch"
        
        songbook = LBSongbook()
        songbook.delegate = self
        songs = songbook.songs
    }
    
    func songbookDidUpdate(songbook: LBSongbook)
    {
        if !searchActive {
            songs = songbook.songs
        } else {
            tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 95.0
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
        searchTextField.resignFirstResponder()
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
    
    func search()
    {
        // cancel if already searching in background
        if !searchingInBackground
        {
            let keywords = searchTextField.text
            
            searchingInBackground = true
            
            songbook.search(keywords, callback: {
                (songs, keywords) in
                
                self.searchingInBackground = false
                
                if (self.searchActive)
                {
                    // show search results
                    self.songs = songs
                    
                    // scroll to top
                    self.scrollView.contentOffset = CGPoint(x: 0.0, y: -self.scrollView.contentInset.top)
                    
                    // search again if keywords have been changed
                    if keywords != self.searchTextField.text {
                        self.search()
                    }
                }
            })
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        searchActive = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if searchTextField.text == "" {
            searchActive = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func handleSearchTextFieldChange(textField: UITextField) {
        search()
    }
}
