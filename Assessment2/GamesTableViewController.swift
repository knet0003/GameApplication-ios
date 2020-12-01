//
//  GamesTableViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import FirebaseAuth
import CoreLocation

class GamesTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    var listenerType: ListenerType = .all
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        gameSessions.removeAll()
        let user = Auth.auth().currentUser?.uid
        let date = Date()
        for game in games {
            if date < game.sessiontime! as Date{
                if game.sessionowner != user {
                    if game.players?.contains(user!) == false{
                        gameSessions.append(game)
                    }
                }
            }
        }
        let currentUser  = databaseController?.getUserByID(user!)
        let userlat = currentUser?.latitude
        let userlong = currentUser?.longitude
        filteredGameSessions = gameSessions
        filteredGameSessions = filteredGameSessions.sorted(){
            let coordinate1 = CLLocation(latitude: userlat!, longitude: userlong!)
            let coordinate2 = CLLocation(latitude: $0.latitude!, longitude: $0.longitude!)
            let coordinate3 = CLLocation(latitude: $1.latitude!, longitude: $1.longitude!)
            let distanceInMeters1 = coordinate1.distance(from: coordinate2)
            let distanceInMeters2 = coordinate1.distance(from: coordinate3)
            return distanceInMeters1 < distanceInMeters2;
        }
        tableView.reloadData()
        
    }
    
    
    var gameSessions: [GameSession] = []
    var filteredGameSessions: [GameSession] = []
    weak var databaseController: DatabaseController?
    
    
    // weak var databaseController = DatabaseController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        gameSessions = databaseController!.gamesessionList
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Game sessions"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.tableFooterView = UIView()
        //        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        let searchField = searchController.searchBar.searchTextField
        searchField.backgroundColor = .systemBackground
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
        // gameSessions.removeAll()
        // filteredGameSessions.removeAll()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGameSessions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath) as! GamesTableViewCell
        let currentCell = filteredGameSessions[indexPath.row]
        cell.gameNameLabel.text = currentCell.gamename
        cell.sessionNameLabel.text = currentCell.sessionname
        cell.playersNeededLabel.text = "Looking for: " + String(currentCell.playersneeded!) + " players"
        let currentuser = databaseController?.authController.currentUser
        let user  = databaseController?.getUserByID(currentuser!.uid)
        let userlat = user?.latitude
        let userlong = user?.longitude
        let coordinate1 = CLLocation(latitude: userlat!, longitude: userlong!)
        let coordinate2 = CLLocation(latitude: currentCell.latitude!, longitude: currentCell.longitude!)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        cell.distanceLabel.text = String(Int(distanceInMeters/1000)) + " kms away"
        let imageUrl = URL(string: currentCell.gameimage!)!
        cell.gameImage.load(url: imageUrl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd-MM-yyyy"
        let sessiontime = dateFormatter.string(from: currentCell.sessiontime!)
        cell.sessionTimeLabel.text = "Time: " + sessiontime
        //  cell.gameImage.image =
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedGame = filteredGameSessions[indexPath.row]
        performSegue(withIdentifier: "showGameInfo", sender: self)
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGameInfo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! GameInfoViewController
                controller.gameSession = filteredGameSessions[indexPath.row]
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased()
        else {
            return
        }
        
        if searchText.count > 0 {
            filteredGameSessions = gameSessions.filter({ (gameSession: GameSession) -> Bool in
                return (gameSession.gamename!.lowercased().contains(searchText.lowercased()) )
            })
        }
        else {
            filteredGameSessions = gameSessions
        }
        let user = Auth.auth().currentUser?.uid
        let currentUser  = databaseController?.getUserByID(user!)
        let userlat = currentUser?.latitude
        let userlong = currentUser?.longitude
        filteredGameSessions = gameSessions
        filteredGameSessions = filteredGameSessions.sorted(){
            let coordinate1 = CLLocation(latitude: userlat!, longitude: userlong!)
            let coordinate2 = CLLocation(latitude: $0.latitude!, longitude: $0.longitude!)
            let coordinate3 = CLLocation(latitude: $1.latitude!, longitude: $1.longitude!)
            let distanceInMeters1 = coordinate1.distance(from: coordinate2)
            let distanceInMeters2 = coordinate1.distance(from: coordinate3)
            return distanceInMeters1 < distanceInMeters2;
        }
        tableView.reloadData()
    }
    
    
    
}
