//
//  NowPlayingViewController.swift
//  Flicks
//
//  Created by Fateh Singh on 3/28/17.
//  Copyright © 2017 Fateh Singh. All rights reserved.
//

import UIKit
import AFNetworking

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var movieDB: [NSDictionary]?
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let nowPlayingURL = "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    @IBOutlet weak var nowPlayingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
        nowPlayingTableView.rowHeight = 125;

        // Get the movie DB
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
                        self.nowPlayingTableView.reloadData()
                    }
                }
                if let error = error {
                    print(error)
                    // show the error here!!
                }
        });
        task.resume()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! DetailViewController
        destinationViewController.largePosterImage = nil;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (movieDB?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        if movieDB != nil {
            let movie = movieDB![indexPath.row]
            let title = movie.value(forKey: "title") as? String
            cell.titleLabel.text = title ?? ""
            let overview = movie.value(forKey: "overview") as? String
            cell.descriptionLabel.text = overview ?? " "
        }
        return cell
    }
    
            

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
