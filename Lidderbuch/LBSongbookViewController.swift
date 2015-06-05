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
            } else {
                search()
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
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func songbookDidUpdate(songbook: LBSongbook)
    {
        if !searchActive {
            songs = songbook.songs
        } else {
            tableView.reloadData()
        }
    }
    
    func songForRowAtIndexPath(indexPath: NSIndexPath) -> LBSong?
    {
        if searchActive {
            return songs[indexPath.row]
        } else if indexPath.row > 0 {
            let category = songbook.categories[indexPath.section]
            return songbook.categorySongs[category]![indexPath.row - 1]
        }
        
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !searchActive {
            return songbook.categories.count
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchActive {
            return songbook.categorySongs[songbook.categories[section]]!.count + 1
        }
        
        return songs.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if !searchActive && indexPath.row == 0
        {
            // category cell
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! LBCategoryTableViewCell
        
            cell.category = songbook.categories[indexPath.section]
            
            return cell
        }
        else
        {
            // song cell
            let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! LBSongTableViewCell
            
            cell.song = songForRowAtIndexPath(indexPath)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if songForRowAtIndexPath(indexPath) != nil {
            searchTextField.resignFirstResponder()
            performSegueWithIdentifier("ShowSong", sender: self)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "ShowSong")
        {
            // inject selected song into song view controller
            if let songViewController = segue.destinationViewController as? LBSongViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow() {
                    songViewController.song = songForRowAtIndexPath(selectedIndexPath)!
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
