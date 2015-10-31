//
//  ViewController.swift
//  KFlickr
//
//  Created by Kevin Luo on 10/30/15.
//  Copyright © 2015 Kevin Luo. All rights reserved.
//  https://www.youtube.com/watch?v=XmLdEcq-QNI
//

import UIKit

class ViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let URL_PHTOS = "https://api.flickr.com/services/rest/?format=json&api_key=b7579223391202d202cedadbeb2dec98&method=flickr.people.getPublicPhotos&user_id=9205063@N02"
    let URL_BASE = "http://api.themoviedb.org/3/movie/popular?api_key=ff743742b3b6c89feb59dfc138b4c12f"

    let defaultSize = CGSizeMake(280, 422)
    let focusSize = CGSizeMake(308, 464)
    
    var movies = [Movie]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        downloadData()
    }
    
    func downloadData() {
        
        let url = NSURL(string: URL_BASE)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) ->
            Void in
            
            if error != nil{
                print(error.debugDescription)
                
            } else {
                do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    
                    if let results = dict!["results"] as? [Dictionary<String, AnyObject>] {
                        
                        for obj in results {
                            let movie = Movie(movieDict: obj)
                            self.movies.append(movie)
                        }
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.collectionView.reloadData()
                        }
                    }
                    
                } catch{
                }
            }
            
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as? MovieCell{
            
            let movie = movies[indexPath.row]
            cell.configreCell(movie)
            
            if cell.gestureRecognizers?.count == nil {
                
                let tap = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
                
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                
                cell.addGestureRecognizer(tap)
            }
            
            return cell
            
        } else {
            return MovieCell()
        }
    }
    
    func tapped(gesture: UIGestureRecognizer) {
        if let cell = gesture.view as? MovieCell {
            print("You chose: \(cell.movieLbl.text)")
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(280, 422)
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let prev = context.previouslyFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { ()->Void in
                prev.movieImg.frame.size = self.defaultSize
            })
        }

        if let next = context.nextFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { ()->Void in
                next.movieImg.frame.size = self.focusSize
            })
        }
    }
}