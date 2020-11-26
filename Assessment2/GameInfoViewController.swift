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

class GameInfoViewController: UIViewController, MKMapViewDelegate, DatabaseListener, UITextFieldDelegate {
    var listenerType: ListenerType = .all
    
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
    

    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
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
    var userList: [User] = []
    
    @IBOutlet weak var stepper: UIStepper!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        sessionNameTextField.delegate = self
        databaseController = appDelegate.databaseController
        sessionNameTextField.isHidden = true
        stepper.isHidden = true
        sessionTimeDatepicker.isHidden = true
        gameNameLabel.text = gameSession?.gamename
        sessionNameLabel.text = gameSession?.sessionname
        playersLabel.text = String((gameSession?.playersneeded)!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd/MM/YYYY"
        let time = dateFormatter.string(from: (gameSession?.sessiontime)!)
        sessionTimeLabel.text = time
        locationMapView.delegate = self
        let currentuserid = Auth.auth().currentUser?.uid
        
        let userlat = databaseController?.getUserByID(currentuserid!)?.latitude
        let userlong = databaseController?.getUserByID(currentuserid!)?.longitude
        let ownername = databaseController?.getUserByID((gameSession?.sessionowner)!)!.name
        gameOwnerLabel.text = ownername
        if currentuserid == gameSession?.sessionowner {
            joinButton.isHidden = true
            editButton.isEnabled = true
            
        } else {
            joinButton.isHidden = false
            editButton.isEnabled = false
        }
        if gameSession?.players?.count != 0 {
            let players = gameSession?.players
            for player in players! {
                userList.append(player)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerscell", for: indexPath)
        let user = userList[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
      }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
        sessionNameLabel.isHidden = true
        sessionTimeLabel.isHidden = true
        stepper.isHidden = false
        sessionNameTextField.isHidden = false
        sessionTimeDatepicker.isHidden = false
        
        
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
            userText.resignFirstResponder()
            return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let text = sessionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            sessionNameLabel.text = text
            let sessionid: String = (gameSession?.sessionid)!
            db.collection("games").document(sessionid).updateData(["sessionname": text])
            sessionNameTextField.isHidden = true
            sessionNameLabel.isHidden = false
        view.endEditing(true)
    }
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
            
            let lat = Double(newSessionLocation.latitude)
            let long = Double(newSessionLocation.longitude)
            let sessionid: String = (gameSession?.sessionid)!
            db.collection("games").document(sessionid).updateData(["latitude": lat, "longitude": long])
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
        }

        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
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
