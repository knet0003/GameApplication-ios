//
//  MessageTableViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/04.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = .all
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    
    
    let CHANNEL_SEGUE = "channelSegue"
    let CHANNEL_CELL = "channelCell"
    var currentSender: Sender?
    var channels = [Channel]()
    var user = User()
    var presentUserList = [String]()
    
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    weak var databaseController: DatabaseController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //let currentuserid = Auth.auth().currentUser!.uid
        let currentuser = databaseController?.authController.currentUser
        user  = (databaseController?.getUserByID(currentuser!.uid))!
        presentUserList.append(currentuser!.uid)
        self.currentSender = Sender(id: currentuser!.uid , name: user.name!)
        //print(self.currentSender?.displayName as Any)
        
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        
        
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
                if snapshot["uid1"] as! String == self.user.uid{
                    let id = snapshot.documentID
                    let otherUser = self.databaseController?.getUserByID(snapshot["uid2"] as! String)
                    self.presentUserList.append(otherUser!.uid!)
                    let channel = Channel(id: id, name: (otherUser?.name!)!)
                    self.channels.append(channel)
                }
                else if snapshot["uid2"] as! String == self.user.uid{
                    let id = snapshot.documentID
                    let otherUser = self.databaseController?.getUserByID(snapshot["uid1"] as! String)
                    self.presentUserList.append(otherUser!.uid!)
                    let channel = Channel(id: id, name: (otherUser?.name!)!)
                    self.channels.append(channel)
                }
            })
            
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHANNEL_CELL,
                                                 for: indexPath)
        let channel = channels[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        cell.textLabel?.text = channel.name
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt
                                indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: CHANNEL_SEGUE, sender: channel)
    }
    
    @IBAction func newMessage(_ sender: Any) {
        performSegue(withIdentifier: "newMessageSegue", sender: sender)
    }
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
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == CHANNEL_SEGUE {
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChatMessagesViewController
            
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
        }
        if segue.identifier == "newMessageSegue" {
            let destinationVC = segue.destination as! SelectUserTableViewController
            destinationVC.presentUserList = presentUserList
        }
    }
    
    
}
