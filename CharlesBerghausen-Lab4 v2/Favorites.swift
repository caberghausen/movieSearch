//
//  favoriesDataSource.swift
//  CharlesBerghausen-Lab4 v2
//
//  Created by Charles Berghausen on 7/23/21.
//

import Foundation
import UIKit


class tableViewController: UITableViewController {
    
    var movieNames = ["Harry potter", "Totoro", "Ben Herr"]
    var myFavorites = UserDefaults.standard.array(forKey: "favorites")
    var mutableFavorites = [String]()
    
    
    @IBOutlet var myTableView: UITableView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mutableFavorites = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [String]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mutableFavorites = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [String]()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mutableFavorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteItem") as! tableViewCell
        cell.favoriteTitle.text = mutableFavorites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mutableFavorites.remove(at: indexPath.row)
            UserDefaults.standard.set(mutableFavorites, forKey: "favorites")
            tableView.reloadData()
        }
    }
    
}

class tableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteTitle: UILabel!

}
