//
//  HomeViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        let currentCell = gameSessions[indexPath.row]
        cell.backgroundColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = currentCell.gamename
        return cell
    }
    
    var listenerType: ListenerType = .all
    var user = User()
    var gameSessions = [GameSession]()
    var gameSessionIds = [String]()
    var center = UNUserNotificationCenter.current()
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
        let user = Auth.auth().currentUser?.uid
        let currentUser  = databaseController?.getUserByID(user!)
        let userlat = currentUser?.latitude
        let userlong = currentUser?.longitude
        let date = Date()
        for game in games{
            if game.sessionowner != user  && date < game.sessiontime! as Date {
                if gameSessionIds.contains(game.sessionid!) == false{
                    let coordinate1 = CLLocation(latitude: userlat!, longitude: userlong!)
                    let coordinate2 = CLLocation(latitude: game.latitude!, longitude: game.longitude!)
                    let distanceInKms = coordinate1.distance(from: coordinate2)/1000
                    if distanceInKms <= 100 {
                        let content = UNMutableNotificationContent()
                        content.title = "New Game"
                        content.body = game.gamename! + " " + game.sessionname!
                        content.badge = 1
                        let date = Date()
                        print(date)
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        let uuidString = UUID().uuidString
                        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                        center.add(request){(error) in }
                        let alert = UIAlertController(title: "New Game", message:
                                                        game.gamename! + " " + game.sessionname!, preferredStyle:
                                                            UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style:
                                                        UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        databaseController?.database.collection("notifications").addDocument(data: ["Title": "New Game", "gameid": game.sessionid!,"uid": user, "time": date ])
                    }
                }
            }
        }
        gameSessions.removeAll()
        gameSessionIds.removeAll()
        
        for game in games {
            if date < game.sessiontime! as Date{
                if game.sessionowner != user {
                    if game.players?.contains(user!) == false{
                        gameSessions.append(game)
                        gameSessionIds.append(game.sessionid!)
                    }
                }
            }
        }
    /*    for game in games {
            gameSessions.append(game)
          
        } */
        
        
        gameSessions = gameSessions.sorted(){
            let coordinate1 = CLLocation(latitude: userlat!, longitude: userlong!)
            let coordinate2 = CLLocation(latitude: $0.latitude!, longitude: $0.longitude!)
            let coordinate3 = CLLocation(latitude: $1.latitude!, longitude: $1.longitude!)
            let distanceInMeters1 = coordinate1.distance(from: coordinate2)
            let distanceInMeters2 = coordinate1.distance(from: coordinate3)
            return distanceInMeters1 < distanceInMeters2;
        }
        gamesTable.reloadData()
        
    }
    
    
    @IBOutlet weak var gamesTable: UITableView!
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var WelcomeLabel: UILabel!
    weak var databaseController: DatabaseController?
    //  var currentSender: Sender?
    
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        super.viewDidLoad()
        gamesTable.delegate = self;
        gamesTable.dataSource = self;
        gamesTable.tableFooterView = UIView(frame: .zero)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            
        }
        joinGameButton.layer.cornerRadius = 5;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //self.currentSender = Sender(id: UserDefaults.standard.object(forKey: "Uid") as! String, name: UserDefaults.standard.string(forKey: "Name")!)
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        databaseController?.addListener(listener: self)
        let currentauthuser = databaseController?.authController.currentUser
        //print(currentauthuser?.uid)
        user = (databaseController?.getUserByID(currentauthuser!.uid as String))!
        //print(user.name)
        let name = user.name
        WelcomeLabel.text = "Welcome back, " + name!
        // loadAllGames()
    }
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
        gameSessions.removeAll()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
