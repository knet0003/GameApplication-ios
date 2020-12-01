//
//  RegisterViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import FirebaseAuth
import MapKit
import Firebase
import FirebaseFirestore

class RegisterViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var DoBDatePicker: UIDatePicker!
    @IBOutlet weak var locationMapView: MKMapView!
    weak var databaseController: DatabaseController?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    static let DEFAULT_MAP_LAT = -37.830531
    static let DEFAULT_MAP_LON = 144.981197
    let annotation = MKPointAnnotation()
    //    @IBOutlet weak var showPassImage: UIImageView!
    //    var iconClick = true
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 5;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationMapView.showsUserLocation = true
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedWhenInUse {
            // If not currently authorised, hide button
            //useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            else if authorisationStatus == .authorizedWhenInUse{
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        DoBDatePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
        //        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("imageTapped:")))
        //
        //            // add it to the image view;
        //        showPassImage.addGestureRecognizer(tapGesture)
        //            // make sure imageView can be interacted with by user
        //        showPassImage.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManager delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
                            locations: [CLLocation]) {
        if let location = locations.last {
            if currentLocation == nil{
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                self.locationMapView.setRegion(region, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
                                                    errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
                                                    UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func validateFields() -> Bool?{
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            currentLocation == nil{
            displayErrorMessage("Please enter all fields")
            return false
        }
        return true
        
    }
    
    @IBAction func TapGestureBegan(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationView = sender.location(in: locationMapView)
            let tappedView = locationMapView.convert(locationView, toCoordinateFrom: locationMapView)
            let newSelectedCoordinates = CLLocationCoordinate2D(latitude: tappedView.latitude, longitude: tappedView.longitude)
            annotation.coordinate = newSelectedCoordinates
            let allPreviosAnnotation = locationMapView.annotations
            locationMapView.removeAnnotations(allPreviosAnnotation)
            locationMapView.addAnnotation(annotation)
            currentLocation = newSelectedCoordinates
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: currentLocation!, span: span)
            self.locationMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func register(_ sender: UIButton) {
        if validateFields() == false
        {
            return
        }
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let Dob = DoBDatePicker.date
        Auth.auth().createUser(withEmail: email, password: password) { [self] (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            }
            else{
                databaseController?.addUser(uid: (user?.user.uid)!, name: name, latitude: self.annotation.coordinate.latitude, longitude: self.annotation.coordinate.longitude, DoB: Dob, email: email)
                /* let db = Firestore.firestore()
                 // db.collection("users").document(user!.user.uid).setData([
                 "name": name,
                 "DoB": Dob,
                 "latitude": self.currentLocation!.latitude as Double,
                 "longitude": self.currentLocation!.longitude as Double,
                 "uid": user!.user.uid]) */
                self.navigationController?.popViewController(animated: true)
                performSegue(withIdentifier: "backToSignin", sender: self)
            }
        }
        
    }
    
    
    @IBAction func backToSignin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "backToSignin", sender: self)
        
    }
    
    
}
