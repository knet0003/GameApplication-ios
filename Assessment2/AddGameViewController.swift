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

class AddGameViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, GameDelegate, UITextFieldDelegate, DatabaseListener {
    var listenerType: ListenerType = .all
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBOutlet weak var sessionDatepicker: UIDatePicker!
    
    @IBAction func playersNeededStepper(_ sender: UIStepper) {
        playersNeededLabel.text = String(sender.value)
    }
    
    @IBOutlet weak var playersNeededLabel: UILabel!
    
    @IBAction func sessionTime(_ sender: UIDatePicker) {
    } //not sure if needed
    
    
    @IBOutlet weak var locationMapView: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedGame: String?
    weak var databaseController: DatabaseProtocol?
    
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        longtap.minimumPressDuration = 1.0
        locationMapView.addGestureRecognizer(longtap)
        sessionDatepicker.minimumDate = Date()
        
        sessionNameTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
         databaseController = appDelegate.databaseController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     locationManager.startUpdatingLocation()
     }
    
    override func viewDidDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     locationManager.stopUpdatingLocation()
     }
    
    

        // Do any additional setup after loading the view.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            let location = locations.last
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: (location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) //zoom on map
            self.locationMapView.setRegion(region, animated: true)
        }
    
    
    
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func saveGame(_ sender: Any) {
        guard let gamename = gameNameLabel.text else{
            displayMessage(title: "Empty details", message: "Please select a game you want to play first")
            return
        }
        guard let sessionname = sessionNameTextField.text else {
            displayMessage(title: "Empty details", message: "Please add a session name first")
            return
        }
        let sessionTime = sessionDatepicker.date
        
        guard let user = Auth.auth().currentUser?.uid else {
            displayMessage(title: "Not logged in", message: "Please log in first to create a new game session")
             return
        }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let playersneeded = Int(playersNeededLabel.text!)!
        let db = Firestore.firestore()
        var ref = db.collection("games").addDocument(data: [
                                                               "Game name": gamename,
                                                               "Session name": sessionname,
                                                               "Lat": latitude as Double,
                                                               "Long": longitude as Double,
                                                        "Players needed": playersneeded as Int,
                                                        "Session Time": sessionTime,
                                                               "Owner": user])
        
    }
    
    // MARK - GameDelegate methods
    
    func onGameAdded(selectedGame: GameData) {
        self.selectedGame = selectedGame.name
        gameNameLabel.text = self.selectedGame
    }
    
    
    // MARK - Utility function
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
        style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK UITextfield deleage function
    func textFieldDidBeginEditing(_ textField: UITextField) {
           // setDefaultStyleForFormElements()
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

    
}
