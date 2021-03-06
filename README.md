# Movie Search iOS App

This project queries The Movie Database (TMBD) API to allow a user to search their database of movies for a keyword, populating a CollectionView with up to 20 results. It has an activity indicator that animates while the app processes the response in a background thread using async, and per best practices, it reuses already allocated cells in the CollectionView to allow for lagless scrolling and stores image results in a cache. Tapping on a movie on the results page pulls up a detailed view that includes the movie's release date, rating, and description. I used XCode's storyboard feature to design controllers, segues, and the layout of the app.<br>
It also allows users to add/delete movies from a favorites list, displayed in a TableView, which is managed by an array stored in User Defaults and is persistent between app launches.<br>
Most code is in [MovieCollectionViewController.swift](https://github.com/caberghausen/movieSearch/blob/main/CharlesBerghausen-Lab4%20v2/MoviesCollectionViewController.swift).

<img src="./MovieSearchDemo.gif" alt="demo of functionality" height="400"/>
