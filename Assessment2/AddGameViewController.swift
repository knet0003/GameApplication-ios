//
//  AddGameViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import MapKit
import SwiftUI
import CoreMotion
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Firebase

class AddGameViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, AddGameDelegate, UITextFieldDelegate, DatabaseListener {
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    var listenerType: ListenerType = .all
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBOutlet weak var sessionDatepicker: UIDatePicker!
    
    @IBAction func playersNeededStepper(_ sender: UIStepper) {
        playersNeededLabel.text = String(Int(sender.value))
    }
    
    @IBOutlet weak var playersNeededLabel: UILabel!
    
    @IBAction func sessionTime(_ sender: UIDatePicker) {
    } //not sure if needed
    
    
    @IBOutlet weak var locationMapView: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var selectGameButton: UIButton!
    
    var selectedGameName: String?
    var selectedGameImage: String?
    var user = User()
    
    weak var databaseController: DatabaseController?
    
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5;
        selectGameButton.layer.cornerRadius = 5;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        //blue dot on the map
        self.locationMapView.showsUserLocation = true
        //tracking mode on
        self.locationMapView.userTrackingMode = .follow
        locationMapView.delegate = self
        let longtap = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longtap.minimumPressDuration = 0.6
        gameNameLabel.text = " "
        locationMapView.addGestureRecognizer(longtap)
        let currentuser = databaseController?.authController.currentUser
        user  = (databaseController?.getUserByID(currentuser!.uid))!
        let center = CLLocationCoordinate2D(latitude: user.latitude!, longitude: (user.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) //zoom on map
        self.locationMapView.setRegion(region, animated: true)
        annotation.coordinate = center
        annotation.title = "Home"
        self.locationMapView.addAnnotation(annotation)
        
        sessionDatepicker.minimumDate = Date()
        
        sessionNameTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    /*  override func didReceiveMemoryWarning() {
     super.didReceiveMemoryWarning()
     } */
    
    
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //
    //            let location = locations.last
    //            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: (location?.coordinate.longitude)!)
    //            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) //zoom on map
    //            self.locationMapView.setRegion(region, animated: true)
    //    }
    
    
    
    
    @IBAction func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        self.locationMapView.removeAnnotation(annotation)
        if gesture.state == .ended {
            let point = gesture.location(in: self.locationMapView)
            let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
            //Now use this coordinate to add annotation on map.
            annotation.coordinate = coordinate
            self.locationMapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func saveGame(_ sender: Any) {
        var gamename: String
        if let text = self.gameNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            gamename = text
        } else {
            displayMessage(title: "Empty details", message: "Please select a game you want to play first")
            return
        }
        var sessionname: String
        if let text = self.sessionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            sessionname = text
        } else {
            displayMessage(title: "Empty details", message: "Please add a session name first")
            return
        }
        let sessionTime = sessionDatepicker.date
        
        guard let user = Auth.auth().currentUser?.uid else {
            displayMessage(title: "Not logged in", message: "Please log in first to create a new game session")
            return
        }
        
        guard let playersneeded = playersNeededLabel.text else {
            displayMessage(title: "No player number", message: "Please add how many players you need")
            return
        }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        if longitude != 0 && longitude != 0 {
        } else {
            displayMessage(title: "No location selected", message: "Please select a session location from the map")
            return
        }
        guard let gameimage = selectedGameImage else {
            displayMessage(title: "No game image", message: "Please add image")
            return
        }
        let playersnumber = Int(playersneeded) ?? 1
        if let game = databaseController?.addGameSession(game: gamename, sessionname: sessionname, playersneeded: playersnumber, latitude: latitude, longitude: longitude, sessiontime: sessionTime, sessionowner: user, gameimage: gameimage), game != nil {
            displayMessage(title: "Session Added", message: "You successfully created a session!")
            // navigationController?.popViewController(animated: true)
            sessionNameTextField.text?.removeAll()
            gameNameLabel.text = "  "
            playersNeededLabel.text = "1"
            //  sessionDatepicker.date = Date()
            locationMapView.removeAnnotation(annotation)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK - GameDelegate methods
    
    func onGameAdded(selectedGame: GameData) {
        self.selectedGameName = selectedGame.name
        self.selectedGameImage = selectedGame.imageURL
        gameNameLabel.text = self.selectedGameName
    }
    
    
    // MARK - Utility function
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK UITextfield delegate function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchGame" {
            let destination = segue.destination as! SelectGameTableViewController
            destination.delegate = self
        }
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterCountLimit = 30
        _ = (sessionNameTextField.text! as NSString).replacingCharacters(in: range, with: string)
        let startingLength = textFieldToChange.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        return newLength < characterCountLimit
    }
    
    
}
