//
//  HomeViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .all
    var user = User()
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    

    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var WelcomeLabel: UILabel!
    weak var databaseController: DatabaseController?
  //  var currentSender: Sender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinGameButton.layer.cornerRadius = 5;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //self.currentSender = Sender(id: UserDefaults.standard.object(forKey: "Uid") as! String, name: UserDefaults.standard.string(forKey: "Name")!)
        let currentauthuser = databaseController?.authController.currentUser
        //print(currentauthuser?.uid)
        user = (databaseController?.getUserByID(currentauthuser!.uid as String))!
        //print(user.name)
        let name = user.name
        WelcomeLabel.text?.append(name!)
        // Do any additional setup after loading the view.
    }
//    override func viewWillAppear(_ animated: Bool) {
//     super.viewWillAppear(animated)
//     databaseController?.addListener(listener: self)
//     }
//
//     override func viewWillDisappear(_ animated: Bool) {
//     super.viewWillDisappear(animated)
//     databaseController?.removeListener(listener: self)
//     }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
