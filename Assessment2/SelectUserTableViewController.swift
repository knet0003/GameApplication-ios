//
//  SelectUserTableViewController.swift
//  Assessment2
//
//  Created by user173263 on 11/29/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SelectUserTableViewController: UITableViewController, UISearchBarDelegate, DatabaseListener {
    var listenerType: ListenerType = .users
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    
    
    var users = [UserInfo]()
    var user = User()
    let user_SEGUE = "userSegue"
    let user_CELL = "userCell"
    var selectedUser = User()
    var presentUserList = [String]()
    
    var usersRef: CollectionReference?
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    weak var databaseController: DatabaseController?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        let currentuser = databaseController?.authController.currentUser
        user  = (databaseController?.getUserByID(currentuser!.uid))!
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for user"
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        let database = Firestore.firestore()
        usersRef = database.collection("users")
        channelsRef = database.collection("channels")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllUsers()
    }
    
    
    func loadAllUsers() {
        databaseListener = usersRef?.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.users.removeAll()
            
            querySnapshot?.documents.forEach({snapshot in
                if self.presentUserList.contains(snapshot["uid"] as! String) == false{
                    let user = UserInfo(uid: snapshot["uid"] as! String, name: snapshot["name"] as! String, email: snapshot["email"] as! String)
                    self.users.append(user)
                }
            })
            
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser.uid = users[indexPath.row].uid
        selectedUser.name = users[indexPath.row].name
        selectedUser.email = users[indexPath.row].email
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUser = User()
    }
    
    @IBAction func newMessage(_ sender: Any) {
        self.channelsRef?.addDocument(data: ["uid1": self.user.uid, "uid2": self.selectedUser.uid])
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: user_CELL, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.textColor = UIColor.green
        cell.detailTextLabel?.textColor = UIColor.white
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
