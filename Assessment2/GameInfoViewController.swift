//
//  GameInfoViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class GameInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, DatabaseListener, UITextFieldDelegate {
    var listenerType: ListenerType = .all
    var button_defaultmode: String = "edit"
    var lat: Double = 0
    var long: Double = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameOwnerLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var sessionTimeLabel: UILabel!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBOutlet weak var joinUsersTable: UITableView!
    @IBOutlet weak var sessionTimeDatepicker: UIDatePicker!
    
    @IBAction func playersStepper(_ sender: UIStepper) {
        playersLabel.text = String(Int(sender.value))
    }
    
    @IBOutlet weak var joinButton: UIButton!
    weak var databaseController: DatabaseController?
    var gameSession: GameSession?
    let db = Firestore.firestore()
    var annotation = CLLocationCoordinate2D()
    var userList = [User]()
    
    @IBOutlet weak var stepper: UIStepper!
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        super.viewDidLoad()
        joinUsersTable.delegate = self;
        joinUsersTable.dataSource = self;
        joinUsersTable.tableFooterView = UIView(frame: .zero)
        //        scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height+100)
        joinButton.layer.cornerRadius = 5;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        sessionNameTextField.delegate = self
        databaseController = appDelegate.databaseController
        sessionNameTextField.borderStyle = .none
        sessionNameTextField.isUserInteractionEnabled = false
        stepper.isHidden = true
        sessionTimeDatepicker.isHidden = true
        gameNameLabel.text = gameSession?.gamename
        sessionNameTextField.text = gameSession?.sessionname
        playersLabel.text = String((gameSession?.playersneeded)!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd/MM/YYYY"
        let time = dateFormatter.string(from: (gameSession?.sessiontime)!)
        sessionTimeLabel.text = time
        locationMapView.delegate = self
        let currentuserid = Auth.auth().currentUser?.uid
        
        let userlat = databaseController?.getUserByID(currentuserid!)?.latitude
        let userlong = databaseController?.getUserByID(currentuserid!)?.longitude
        lat = userlat!
        long = userlong!
        let ownername = databaseController?.getUserByID((gameSession?.sessionowner)!)!.name
        gameOwnerLabel.text = ownername
        if currentuserid == gameSession?.sessionowner {
            joinButton.isHidden = true
            editButton.isEnabled = true
            
        } else {
            joinButton.isHidden = false
            editButton.isEnabled = false
            editButton.title = ""
        }
        if gameSession?.players?.contains(currentuserid!) == true{
            joinButton.isHidden = true
        }
        userList.append((self.databaseController?.getUserByID((gameSession?.sessionowner)!))!)
        if gameSession?.players?.count != nil {
            let players = gameSession?.players
            for player in players! {
                userList.append((self.databaseController?.getUserByID(player))!)
            }
        }
        self.joinUsersTable.reloadData()
        //let userlong = UserDefaults.standard.double(forKey: "Long")
        let userLocation = CLLocationCoordinate2DMake(userlat!, userlong!)
        // annotation = userLocation
        let sessionlat = gameSession?.latitude
        let sessionlong = gameSession?.longitude
        let sessionlocation = CLLocationCoordinate2DMake(sessionlat!, sessionlong!)
        showRouteOnMap(pickupCoordinate: userLocation, destinationCoordinate: sessionlocation)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection
                    section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playersCell", for: indexPath)
        let user = userList[indexPath.row]
        print(user)
        cell.textLabel?.textColor = UIColor.green
        cell.detailTextLabel?.textColor = UIColor.white
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    // DatabaseListener methods
    func onUserChange(change: DatabaseChange, users: [User]) {
        
        
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        if change == .update {
            for game in games {
                if game.sessionid == gameSession?.sessionid {
                    gameSession = game
                }
            }
        }
    }
    
    //joinGame button
    @IBAction func joinGame(_ sender: Any) {
        guard let currentuseruid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let currentUser = databaseController?.getUserByID(currentuseruid) else{
            return
        }
        if databaseController?.addUserToGameSession(user: currentUser, gameSession: gameSession!) == true {
            displayMessage(title: "Join successful", message: "You have successfully joined the session")
        } else {
            displayMessage(title: "Error in joining", message: "You could not join the session")
        }
        
    }
    
    @IBAction func editDetails(_ sender: Any) {
        if button_defaultmode == "edit" {
            button_defaultmode = "save"
            sessionTimeLabel.isHidden = true
            stepper.isHidden = false
            sessionNameTextField.borderStyle = .roundedRect
            sessionNameTextField.isUserInteractionEnabled = true
            //UITextField *yourTextField = [[UITextField alloc]init];
            //        CGFloat yourSelectedFontSize = 14.0 ;
            //        UIFont *yourNewSameStyleFont = [sessionNameTextField.font fontWithSize:yourSelectedFontSize];
            //        sessionNameTextField.font = yourNewSameStyleFont ;
            sessionNameTextField.font =  UIFont.init(name: (sessionNameTextField.font?.fontName)!, size: 14.0)
            sessionTimeDatepicker.isHidden = false
            editButton.title = "Done"
        }
        else {
            let sessionid: String = (gameSession?.sessionid)!
            if let text = sessionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                db.collection("games").document(sessionid).updateData(["sessionname": text])
                sessionNameTextField.borderStyle = .none
                sessionNameTextField.isUserInteractionEnabled = false
                view.endEditing(true)
            }
            
            db.collection("games").document(sessionid).updateData(["latitude": lat, "longitude": long])
            guard let playersneeded = playersLabel.text else {
                displayMessage(title: "No player number", message: "Please add how many players you need")
                return
            }
            let playersnumber = Int(playersneeded) ?? 1
            db.collection("games").document(sessionid).updateData(["playersneeded": playersnumber])
            let sessionTime = sessionTimeDatepicker.date
            db.collection("games").document(sessionid).updateData(["sessiontime": sessionTime])
            button_defaultmode = "edit"
            sessionTimeLabel.isHidden = false
            stepper.isHidden = true
            sessionNameTextField.borderStyle = .none
            sessionNameTextField.isUserInteractionEnabled = false
            //UITextField *yourTextField = [[UITextField alloc]init];
            //        CGFloat yourSelectedFontSize = 14.0 ;
            //        UIFont *yourNewSameStyleFont = [sessionNameTextField.font fontWithSize:yourSelectedFontSize];
            //        sessionNameTextField.font = yourNewSameStyleFont ;
            sessionNameTextField.font =  UIFont.init(name: (sessionNameTextField.font?.fontName)!, size: 17.0)
            sessionTimeDatepicker.isHidden = true
            editButton.title = "Edit"
            //navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterCountLimit = 0
        var newLength = 0
        let text = (sessionNameTextField.text! as NSString).replacingCharacters(in: range, with: string)
        if text.isEmpty {
            sessionNameTextField.text = UserDefaults.standard.string(forKey: "Name")!
        } else{
            let startingLength = textFieldToChange.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            newLength = startingLength + lengthToAdd - lengthToReplace
        }
        return newLength > characterCountLimit
    }
    
    @IBAction func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        // self.locationMapView.removeAnnotation(annotation)
        if gesture.state == .ended {
            let point = gesture.location(in: self.locationMapView)
            let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
            let newSessionLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
            // annotation = mkp
            let currentuserid = Auth.auth().currentUser?.uid
            if button_defaultmode == "save" {
                if currentuserid == gameSession?.sessionowner {
                    let userlat = databaseController?.getUserByID(currentuserid!)?.latitude
                    let userlong = databaseController?.getUserByID(currentuserid!)?.longitude
                    
                    let userlocation = CLLocationCoordinate2DMake(userlat!, userlong!)
                    let ann = locationMapView.annotations
                    let overlays = locationMapView.overlays
                    for overlay in overlays {
                        locationMapView.removeOverlay(overlay)
                    }
                    for a in ann {
                        locationMapView.removeAnnotation(a)
                    }
                    showRouteOnMap(pickupCoordinate: userlocation, destinationCoordinate: newSessionLocation)
                    
                    lat = Double(newSessionLocation.latitude)
                    long = Double(newSessionLocation.longitude)
                    
                }
            }
        }
    }
    
    //Code source: https://stackoverflow.com/questions/29319643/how-to-draw-a-route-between-two-locations-using-mapkit-in-swift
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
            sourceAnnotation.title = "Home"
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
            destinationAnnotation.title = "Game Location"
        }
        
        self.locationMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.locationMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.locationMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    
    // MARK - Utility function
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
