//
//  SelectGameTableViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit


protocol AddGameDelegate: NSObject {
    func onGameAdded(selectedGame: GameData)
}

class SelectGameTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    let MAX_REQUESTS = 10
    var currentRequestPage: Int = 1
    
    var indicator = UIActivityIndicatorView()
    var apiGames = [GameData]()
    var imageURLs: [String] = []
    var images: [UIImage] = []
    
    weak var delegate: AddGameDelegate?
    
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for game"
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.searchController = searchController
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath) as! SelectGameTableViewCell
        
        let game = apiGames[indexPath.row]
        cell.gameNameLabel?.text = game.name
        let imageUrl = URL(string: game.imageURL!)!
        cell.gameImage.load(url: imageUrl)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt
                                indexPath: IndexPath) {
        let game = apiGames[indexPath.row]
        let _ = delegate?.onGameAdded(selectedGame: game)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Search Bar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return;
        }
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        apiGames.removeAll()
        imageURLs.removeAll()
        images.removeAll()
        
        URLSession.shared.invalidateAndCancel()
        currentRequestPage = 0;
        
        requestGames(gameName: searchText)
    }
    
    // MARK: - Web Request
    
    func requestGames(gameName: String){
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.boardgameatlas.com"
        searchURLComponents.path = "/api/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "name", value: gameName),
            URLQueryItem(name: "client_id", value: "JLBr5npPhV"),
            URLQueryItem(name: "limit", value: "15")]
        let jsonURL = searchURLComponents.url
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data!)
                if let games = volumeData.games {
                    for game in games {
                        self.imageURLs.append(game.imageURL!)
                        
                    }
                    self.apiGames.append(contentsOf: games)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
}
