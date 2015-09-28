//
//  LBSongbookViewController.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBSongbookViewController: LBViewController,
    LBSongbookDelegate,
    LBSongViewControllerDelegate,
    UIViewControllerTransitioningDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate
{
    lazy var songbook: LBSongbook = {
        let songbook = LBSongbook()
        return songbook
    }()
    
    var searchingInBackground = false
    var searchSongs: [LBSong]? {
        didSet {
            let searchActive = (searchSongs != nil)
            
            headerBar.disableVerticalTranslation = searchActive
            tableView.reloadData()
            
            UIView.animateWithDuration(0.15) {
                self.cancelSearchButton.alpha = searchActive ? 1.0 : 0.0
            }
        }
    }
    
    var viewDidAppearOnce = false
    var songToShowWhenViewAppears: LBSong?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelSearchButton: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        songbook.delegate = self
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        cancelSearchButton.alpha = 0.0
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let selectedRowIndexPath = tableView.indexPathForSelectedRow
        
        UIView.setAnimationsEnabled(false)
        
        tableView.reloadData()
        
        // preserve selected row
        tableView.selectRowAtIndexPath(selectedRowIndexPath, animated: false, scrollPosition: .None)
        
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        viewDidAppearOnce = true
        
        if let song = self.songToShowWhenViewAppears {
            self.songToShowWhenViewAppears = nil
            showSong(song)
        }
    }
    
    func songbookDidUpdate(songbook: LBSongbook)
    {
        if searchSongs != nil {
            search()
        }
    
        let selectedRowIndexPath = tableView.indexPathForSelectedRow
        tableView.reloadData()
        
        // preserve selected row (if not in bookmark category)
        if selectedRowIndexPath?.section != 0 {
            tableView.selectRowAtIndexPath(selectedRowIndexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func songViewController(songViewController: LBSongViewController, songDidChange song: LBSong)
    {
        songbook.integrateSong(song, preserveMeta: false, propagate: true)
    }
    
    private func songForRowAtIndexPath(indexPath: NSIndexPath) -> LBSong?
    {
        if searchSongs != nil {
            return searchSongs![indexPath.row]
        } else if indexPath.row > 0 {
            let category = songbook.categories[indexPath.section]
            return songbook.categorySongs[category]![indexPath.row - 1]
        }
        
        return nil
    }
    
    private func rowIndexPathForSong(song: LBSong) -> NSIndexPath?
    {
        // find index of category and song if it exists
        if let
            categorySongs = songbook.categorySongs[song.category],
            categoryIndex = songbook.categories.indexOf(song.category),
            songIndexInCategory = categorySongs.indexOf(song)
        {
            // convert index to row index path
            let section = songbook.categories.startIndex.distanceTo(categoryIndex)
            let row = categorySongs.startIndex.distanceTo(songIndexInCategory) + 1
            return NSIndexPath(forRow: row, inSection: section)
        }
        
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if searchSongs != nil {
            return 1
        }
        
        return songbook.categories.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchSongs != nil {
            return searchSongs!.count
        }
        
        let category = songbook.categories[section]
        let count = songbook.categorySongs[category]!.count
        
        if count == 0 {
            return 0
        }
        
        return count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if searchSongs == nil && indexPath.row == 0
        {
            // category cell
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! LBCategoryTableViewCell
        
            cell.category = songbook.categories[indexPath.section]
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
            
            return cell
        }
        else
        {
            // song cell
            let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! LBSongTableViewCell
            
            cell.song = songForRowAtIndexPath(indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if songForRowAtIndexPath(indexPath) != nil {
            performSegueWithIdentifier("ShowSong", sender: self)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func showSongWithId(id: Int) -> Bool
    {
        if let song = songbook.songWithId(id)
        {
            showSong(song)
            return true
        }
        
        return false
    }
    
    func showSongWithURL(url: NSURL) -> Bool
    {
        if let song = songbook.songWithURL(url)
        {
            showSong(song)
            return true
        }
        
        return false
    }
    
    func showSong(song: LBSong)
    {
        if !viewDidAppearOnce
        {
            // postpone request to show song
            songToShowWhenViewAppears = song
        }
        else
        {
            if let indexPath = rowIndexPathForSong(song)
            {
                // pop to this view controller
                navigationController?.popToViewController(self, animated: false)
                
                // select song row
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Middle)
                
                // perform segue to song
                performSegueWithIdentifier("ShowSong", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        searchTextField.resignFirstResponder()
        
        if segue.identifier == "ShowSong"
        {
            // inject selected song into song view controller
            if let songViewController = segue.destinationViewController as? LBSongViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    songViewController.delegate = self
                    songViewController.song = songForRowAtIndexPath(selectedIndexPath)!
                }
            }
        }
        else if segue.identifier == "ShowMenu"
        {
            segue.destinationViewController.transitioningDelegate = self
            segue.destinationViewController.modalPresentationStyle = .Custom
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LBModalTransitionAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LBModalTransitionAnimator(presenting: false)
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if viewController === self {
            if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: animated)
            }
        }
    }
    
    func search()
    {
        // cancel if already searching in background
        if !searchingInBackground && searchTextField.text != nil
        {
            let keywords = searchTextField.text!
            
            searchingInBackground = true
            
            songbook.search(keywords, callback: {
                (songs, keywords) in
                
                self.searchingInBackground = false
                
                if (self.searchSongs != nil)
                {
                    // show search results
                    self.searchSongs = songs
                    
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
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if searchSongs == nil {
            searchSongs = [LBSong]()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if searchTextField.text == "" {
            searchSongs = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        searchTextField.resignFirstResponder()
        return true
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        // remove keyboard when user starts scrolling
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func handleSearchTextFieldChange(textField: UITextField)
    {
        search()
    }
    
    @IBAction func handleMenuButtonTap(sender: UIButton)
    {
        performSegueWithIdentifier("ShowMenu", sender: self)
    }
    
    @IBAction func handleSearchButtonTap(sender: UIButton)
    {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func handleCancelSearchButtonTap(sender: UIButton)
    {
        // clear search and remove keyboard
        searchTextField.resignFirstResponder()
        searchSongs = nil
        searchTextField.text = ""
    }
}
