//
//  DetailViewController.swift
//  Flicks
//
//  Created by Fateh Singh on 3/29/17.
//  Copyright © 2017 Fateh Singh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var largePosterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    let posterURL = "https://image.tmdb.org/t/p/original"
    let lowResPosterURL = "https://image.tmdb.org/t/p/w45"
    
    weak var movieDictionary: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        
        if movieDictionary != nil {
            var title = movieDictionary.value(forKey: "title") as? String
            if title == nil {
                title = movieDictionary.value(forKey: "name") as? String
            }
            titleLabel.text = title ?? ""
            
            var releaseDate = movieDictionary.value(forKey: "release_date") as? String
            if releaseDate == nil {
                releaseDate = movieDictionary.value(forKey: "first_air_date") as? String
            }
            releaseDateLabel.text = releaseDate ?? ""
            
            let overview = movieDictionary.value(forKey: "overview") as? String
            descriptionLabel.text = overview ?? " "
            let voteAvg = movieDictionary.value(forKey: "vote_average") as? Double ?? 0
            let voteCount = movieDictionary.value(forKey: "vote_count") as? Int ?? 0
            let voteStr = String(voteAvg) + "/10 out of " + String(voteCount) + " votes"
            ratingLabel.text = voteStr
            
            if let posterPath = movieDictionary.value(forKey: "poster_path") as? String
            {
                let lowResPosterPathWithURL = URLRequest(url: URL(string: lowResPosterURL + posterPath)!)
                largePosterImage.setImageWith(lowResPosterPathWithURL, placeholderImage: nil,
                                              success: { (imageRequest, imageResponse, smallImage) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image and then load the large poster")
                        self.largePosterImage.alpha = 0.0
                        self.largePosterImage.image = smallImage
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.largePosterImage.alpha = 1.0
                        }, completion: { (success) -> Void in
                            let posterPathWithURL = URL(string: self.posterURL + posterPath)
                            self.largePosterImage.setImageWith(posterPathWithURL!, placeholderImage: smallImage)
                        })
                    } else {
                        print("Image was cached!, use large poster instead.")
                        let posterPathWithURL = URL(string: self.posterURL + posterPath)
                        self.largePosterImage.setImageWith(posterPathWithURL!, placeholderImage: smallImage)
                    }
                })
            }
        }
        
        // setup the scroll view
        descriptionLabel.sizeToFit()
        boxView.layer.cornerRadius = 10
        boxView.layer.masksToBounds = true
        boxView.frame.size.height = descriptionLabel.frame.size.height + descriptionLabel.frame.origin.y + 25
        scroll.contentSize = CGSize(width: scroll.frame.size.width, height: boxView.frame.size.height + boxView.frame.origin.y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
