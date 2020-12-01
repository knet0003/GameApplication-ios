//
//  NotificationTableViewController.swift
//  Assessment2
//
//  Created by user173263 on 12/1/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NotificationTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .all
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    var user = User()
    var channels = [Notification]()
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    weak var databaseController: DatabaseController?
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //let currentuserid = Auth.auth().currentUser!.uid
        let currentuser = databaseController?.authController.currentUser
        user  = (databaseController?.getUserByID(currentuser!.uid))!
        //print(self.currentSender?.displayName as Any)
        
        let database = Firestore.firestore()
        channelsRef = database.collection("notifications")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseListener = channelsRef?.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.channels.removeAll()
            
            querySnapshot?.documents.forEach({snapshot in
                if snapshot["uid"] as! String == self.user.uid{
                    let id = snapshot["Title"]
                    let time = snapshot["time"] as! Timestamp?
                    let date = time?.dateValue()
                    let game = self.databaseController?.getGameByID(snapshot["gameid"] as! String)
                    let channel = Notification(id: id as! String, name: (game?.sessionname!)!, date: date ?? Date())
                    self.channels.append(channel)
                }
            })
            self.channels = self.channels.sorted(){
                return $0.date > $1.date;
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        databaseListener?.remove()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        
        let channel = channels[indexPath.row]
        cell.textLabel?.textColor = UIColor.green
        
        cell.textLabel?.text = channel.id
        cell.detailTextLabel?.text = channel.name
        cell.detailTextLabel?.textColor = UIColor.white
        // Configure the cell...
        
        return cell
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        return nil
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
