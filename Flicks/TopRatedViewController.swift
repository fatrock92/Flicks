//
//  TopRatedViewController.swift
//  Flicks
//
//  Created by Fateh Singh on 3/28/17.
//  Copyright © 2017 Fateh Singh. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class TopRatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {

    var movieDB: [NSDictionary]?
    var searchDB = [NSDictionary()]
    let nowPlayingURL = "https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let lowResPosterURL = "https://image.tmdb.org/t/p/w342"
    var refreshControl: UIRefreshControl!
    let searchBar = UISearchBar()
    var segmentedControl = UISegmentedControl()
    var showSearchResults = false
    
    @IBOutlet weak var topRatedTableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topRatedTableView.delegate = self
        topRatedTableView.dataSource = self
        topRatedTableView.rowHeight = 130;
        networkErrorLabel.layer.cornerRadius = 10
        networkErrorLabel.layer.masksToBounds = true;
        self.networkErrorLabel.isHidden = true
        
        // Add the search bar in.
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        // Add Segmented Control
        let listViewImage = UIImage(named: "iconmonstr-view-3-16.png")
        let gridViewImage = UIImage(named: "iconmonstr-view-5-16.png")
        segmentedControl.insertSegment(with: listViewImage, at: 0, animated: false)
        segmentedControl.insertSegment(with: gridViewImage, at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.white
        
        // Add the search bar in the navigation bar.
        let titleFrame = CGRect(x: 0, y: 0, width: 370, height: 44)
        let searchBarFrame = CGRect(x: 0, y: 0, width: 300, height: 44)
        let segmentedControlFrame = CGRect(x: 305, y: 8, width: 55, height: 28)
        let titleView = UIView(frame: titleFrame)
        searchBar.backgroundImage = UIImage()
        searchBar.frame = searchBarFrame
        segmentedControl.frame = segmentedControlFrame
        titleView.addSubview(searchBar)
        titleView.addSubview(segmentedControl)
        self.navigationItem.titleView = titleView
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        // Get the movie DB
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshAction), for: UIControlEvents.valueChanged)
        topRatedTableView.addSubview(refreshControl)
        
        let url = URL(string: nowPlayingURL)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        print("responseDictionary: \(responseDictionary)")
                        
                        self.movieDB = responseDictionary["results"] as? [NSDictionary]
                        self.topRatedTableView.reloadData()
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.networkErrorLabel.isHidden = true
                    }
                }
                if let error = error {
                    print(error)
                    self.networkErrorLabel.text = "Network Error:\n" + error.localizedDescription
                    self.networkErrorLabel.isHidden = false;
                }
        });
        MBProgressHUD.showAdded(to: self.view, animated: true)
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.endEditing(true)
        let destinationViewController = segue.destination as! DetailViewController
        let cell = sender as! CustomTableViewCell
        destinationViewController.movieDictionary  = cell.movieDictionary
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showSearchResults) {
            return (searchDB.count)
        }
        return (movieDB?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        var dictionary = movieDB
        if(showSearchResults == true) {
            dictionary = searchDB
        }
        
        if dictionary != nil {
            let movie = dictionary![indexPath.row]
            cell.movieDictionary = movie
            let title = movie.value(forKey: "title") as? String
            cell.titleLabel.text = title ?? ""
            let overview = movie.value(forKey: "overview") as? String
            cell.descriptionLabel.text = overview ?? " "
            if let posterPath = movie.value(forKey: "poster_path") as? String
            {
                let posterPathWithURL = URL(string: lowResPosterURL + posterPath)
                cell.posterImage.setImageWith(posterPathWithURL!)
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        updateSearchDB()
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        updateSearchDB()
    }
    
    func updateSearchDB() {
        searchDB.removeAll()
        showSearchResults = true
        
        var searchBarText = searchBar.text ?? ""
        searchBarText = searchBarText.lowercased()
        
        // go through the dictionary and add all the matching things to searchDB
        if movieDB != nil {
            for movie in movieDB! {
                var title = movie.value(forKey: "title") as? String ?? ""
                title = title.lowercased()
                if (title.hasPrefix(searchBarText)) {
                    searchDB.append(movie)
                }
            }
            topRatedTableView.reloadData()
        }
    }
    
    func refreshAction() {
        let url = URL(string: nowPlayingURL)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        self.networkErrorLabel.isHidden = true
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        print("responseDictionary: \(responseDictionary)")
                        
                        self.movieDB = responseDictionary["results"] as? [NSDictionary]
                        self.topRatedTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                    self.networkErrorLabel.isHidden = true
                }
                if let error = error {
                    print(error)
                    self.networkErrorLabel.text = "Network Error:\n" + error.localizedDescription
                    self.networkErrorLabel.isHidden = false;
                }
        });
        task.resume()
    }

}
