//
//  MasterViewController.swift
//  MovieLister
//
//  Created by Matt Long on 11/6/15.
//  Copyright © 2015 Matt Long. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    let url = NSURL(string: "https://itunes.apple.com/us/rss/topmovies/limit=50/json")

    var movies = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.downloadData()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    func downloadData() {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(self.url!) { [weak self] (data, response, error) -> Void in
            do {
                if let records = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject] {
                    self?.movies = records.movieEntries
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?.tableView.reloadData()
                    })
                }
            } catch {
                
            }
        }
        
        task.resume()
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {

        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    var images = [NSIndexPath:UIImage]()

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = self.movies[indexPath.row]
        
        cell.textLabel!.text = object.movieName           // Movie name property
        cell.detailTextLabel!.text = object.movieSummary  // Movie summary property

        
        if let image = self.images[indexPath] {          // Use the cached image if it exists
            cell.imageView?.image = image
        } else {                                         // Otherwise download it
            if let url = object.movieThumnailURL {       // Movie thumbnail URL property
                let task = NSURLSession.sharedSession().dataTaskWithURL(url) { [weak self] (data, response, error) -> Void in
                    if let data = data {
                        if let image = UIImage(data: data) {
                            self?.images[indexPath] = image  // Cache the image so it doesn't get re-requested
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            })
                        }
                        
                    }
                }
                
                task.resume()
                
            }
        }
        
        return cell
    }

}

extension Dictionary where Key : StringLiteralConvertible, Value : AnyObject {
    
    var movieName : String {
        if let nameObj = self["im:name"] as? [String:AnyObject] {
            return nameObj["label"] as! String
        }
        return ""
    }

    var movieSummary : String {
        if let summary = self["summary"] as? [String:AnyObject] {
            return summary["label"] as! String
        }
        return ""
    }
    
    var movieThumnailURL : NSURL? {
        if let imageItems = self["im:image"] as? [[String:AnyObject]] {
            let firstOne = imageItems[0]["label"] as! String
            return NSURL(string: firstOne)
        }
        return nil
    }
    
    var movieEntries : [[String:AnyObject]] {
        if let feed = self["feed"] as? [String:AnyObject] {
            return feed["entry"] as! [[String:AnyObject]]
        }
        return []
    }
}

