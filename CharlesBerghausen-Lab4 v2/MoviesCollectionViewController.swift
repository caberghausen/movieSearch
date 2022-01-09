//
//  moviesCollectionViewController.swift
//  CharlesBerghausen-Lab4 v2
//
//  Created by Charles Berghausen on 7/19/21.
//

//followed from https://www.raywenderlich.com/18895088-uicollectionview-tutorial-getting-started#toc-anchor-001

import UIKit

let myAPIKey = "05370e446984618aa458a3c55df59e97"

class moviesCollectionViewController: UICollectionViewController {
    struct APIresults: Decodable {
        var results: [Movie]
        init() {
            results = [Movie]()
        }
        mutating func addMovie(id: Int, poster_path: String, title: String, release_date: String, vote_average: Double, overview: String, vote_count: Int) {
            let newMovie = Movie(id: id, poster_path: poster_path, title: title, release_date: release_date, vote_average: vote_average, overview: overview, vote_count: vote_count)
            self.results.append(newMovie)
        }
    }
    struct Movie: Decodable {
        let id: Int!
        let poster_path: String?
        let title: String
        let release_date: String?
        let vote_average: Double
        let overview: String
        let vote_count: Int!
        init(id: Int, poster_path: String, title: String, release_date: String, vote_average: Double, overview: String, vote_count: Int){
            self.id = id
            self.poster_path = poster_path
            self.title = title
            self.release_date = release_date
            self.vote_average = vote_average
            self.overview = overview
            self.vote_count = vote_count
        }
    }
    struct Configuration: Decodable {
        struct images: Decodable {
            let base_url: String
            let poster_sizes: [String]
        }
    }
    
    //let hardCodeMovieArray: [Movie] = [Movie]()
    let hardCodeResults: APIresults = APIresults()
    
    private let reuseIdentifier = "MovieCell"
    private let sectionInsets = UIEdgeInsets(
      top: 20.0,
      left: 20.0,
      bottom: 0,
      right: 20.0)
    let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (movieResults.results.count + 2) / 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == (movieResults.results.count + 2) / 3 - 1 {
            return movieResults.results.count % 3
        }
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MoviePosterCell
        let twoDIndex: Int = indexPath.section * 3 + indexPath.row
        if movieResults.results.count > twoDIndex {
            //movie id is used to insert images into cache dictionary variable
            let theMovie = movieResults.results[twoDIndex]
            cell.movieTitle.text = theMovie.title
            if self.cache[theMovie.id] != nil {
                cell.posterView.image = self.cache[theMovie.id]
            }
            else {
                cell.posterView.image = nil
            }
        }
        
        return cell
    }
    

    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet weak var searchFieldOutlet: UITextField!
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    @IBAction func primaryAction(_ sender: Any) {
        print("search query: \(searchFieldOutlet.text!)")
        guard searchFieldOutlet.text != nil else {
            print("empty")
            return
        }
        myCollectionView.addSubview(activityIndicator)
        activityIndicator.frame = myCollectionView.bounds
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        DispatchQueue.main.async {
            self.searchMovies(self.searchFieldOutlet.text!)
        }
    }
    
    var movieResults: APIresults = APIresults()
    
    func searchMovies(_ keyword: String) {
        //below followed from https://www.hackingwithswift.com/books/ios-swiftui/
        //sending-and-receiving-codable-data-with-urlsession-and-swiftui
        let urlKeyword = keyword.replacingOccurrences(of: " ", with: "+")
        let apiURL = "https://api.themoviedb.org/3/search/movie?api_key=" + myAPIKey + "&query=" + urlKeyword
        guard let url = URL(string: apiURL) else {
            print("Error: invalid URL")
            return
        }
        let request = URLRequest(url: url)
        //URLSession automatically executes tasks in background
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("data: \(data)")
                if let decodedResponse = try? JSONDecoder().decode(APIresults.self, from: data) {
                    print("decoded Response: \(decodedResponse)")
                    self.movieResults = decodedResponse
                    //print("movieResults array: \(self.movieResults)")
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        self.getImagesFromSearch()
                    }
                }
                return
            }
            // if we're still here it means there was a problem
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    
    //UIImage cache
    var cache: [Int: UIImage] = [:]
    
    func getImagesFromSearch() {
        cache.removeAll()
        print("Fetching images...")
        for movie in movieResults.results {
            //to avoid unsafe unwrapping
            guard movie.poster_path != nil else {
                print("\(movie.title) has no poster")
                continue
            }
            let posterURL = "https://image.tmdb.org/t/p/w154/" + movie.poster_path!
            guard let url = URL(string: posterURL) else {
                print("Error: poster URL not found while downloading image")
                continue
            }
            downloadImage(from: url, forMovieId: movie.id)
        }
        refreshView()
    }
    
    func getImageForDetailView(movie: Movie) {
        guard movie.poster_path != nil else {
            print("\(movie.title) has no poster")
            return
        }
        let posterURL = "https://image.tmdb.org/t/p/w500/" + movie.poster_path!
        guard let url = URL(string: posterURL) else {
            print("Error: poster URL not found while downloading image")
            return
        }
        downloadImage(from: url, forMovieId: movie.id)
    }
    
    //similar to https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    func downloadImage(from url: URL, forMovieId id: Int) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            if let newPoster = UIImage(data: data){
                self.cache[id] = newPoster
            }
            else {
                print("Error: poster URL could not be converted to a UIImage")
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func refreshView() {
        let workItem = DispatchWorkItem(qos: .background) {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating();
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        theMovie = movieResults.results[indexPath.section * 3 + indexPath.row]
        getImageForDetailView(movie: theMovie!)
        return true
    }
    

    var theMovie: Movie? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailScreen = segue.destination as? MovieDetails {
            detailScreen.titleVar = theMovie!.title
            var newReleaseDate = theMovie!.release_date
            newReleaseDate?.removeLast(6)
            detailScreen.release_dateVar = newReleaseDate
            detailScreen.overviewVar = theMovie!.overview
            detailScreen.ratingVar = "\(theMovie!.vote_average)/10"
            detailScreen.posterVar = self.cache[theMovie!.id]
            detailScreen.id = theMovie!.id
        }
    }
}

class navController: UINavigationController {
    
}

extension moviesCollectionViewController: UICollectionViewDelegateFlowLayout {
      
      // 3
      func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
      }
      
      // 4
      func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
      }
}


