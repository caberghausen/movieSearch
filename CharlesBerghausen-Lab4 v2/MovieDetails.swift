//
//  MovieDetails.swift
//  CharlesBerghausen-Lab4 v2
//
//  Created by Charles Berghausen on 7/23/21.
//

import UIKit

class MovieDetails: UIViewController {
    
    var posterVar: UIImage? = nil
    var titleVar: String = "Title"
    var release_dateVar: String? = nil
    var overviewVar: String = "Overview"
    var ratingVar: String = "Rating"
    var id: Int = 0
    var myFavorites = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailTitle?.text = titleVar
        release_date?.text = release_dateVar ?? "--"
        overview?.text = overviewVar
        rating?.text = String(ratingVar)
        poster?.image = posterVar
        if let favArray = UserDefaults.standard.array(forKey: "favorites") {
            for title in favArray {
                myFavorites.append(title as! String)
            }
        }
    }
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var release_date: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    @IBAction func addToFavorites(_ sender: Any) {
        
        print("adding to favs")
        myFavorites.append(titleVar)
        UserDefaults.standard.set(myFavorites, forKey: "favorites")
        print(UserDefaults.standard.array(forKey: "favorites") ?? "nil")
    }
}
