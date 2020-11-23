//
//  ProfileViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit

class ProfileViewController: UIViewController,MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationMapView: MKMapView!
    var channelsRef: CollectionReference?
    let annotation = MKPointAnnotation()
    let db = Firestore.firestore()
    
    @IBAction func editFields(_ sender: Any) {
        nameLabel.isHidden = true
        nameTextField.isHidden = false
        nameTextField.text = nameLabel.text
    }
    
    
    override func viewDidLoad() {
        var dob: Date?
        var lat: Double?
        var long: Double?
        super.viewDidLoad()
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameTextField.text = nil
        nameLabel.text = UserDefaults.standard.string(forKey: "Name")!
        emailLabel.text  = UserDefaults.standard.string(forKey: "Email")!
        dob = UserDefaults.standard.object(forKey: "Dob") as! Date
        lat = UserDefaults.standard.double(forKey: "Lat")
        long = UserDefaults.standard.double(forKey: "Long")
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dob!, to: today)

        let ageYears = components.year
        ageLabel.text = String(ageYears!)
        ageLabel.text?.append(" Years")
        
        let newSelectedCoordinates = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        annotation.coordinate = newSelectedCoordinates
        let allPreviosAnnotation = locationMapView.annotations
        locationMapView.removeAnnotations(allPreviosAnnotation)
        locationMapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: newSelectedCoordinates, span: span)
        self.locationMapView.setRegion(region, animated: true)
        
//        ageLabel.text = UserDefaults.standard.string(forKey: "Dob")
    }

    func textFieldShouldReturn(userText: UITextField) -> Bool {
            userText.resignFirstResponder()
            return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            nameLabel.text = text
            UserDefaults.standard.set(text, forKey: "Name")
            let user = Auth.auth().currentUser
            db.collection("users").document(user!.uid).updateData(["Name": text])
        nameTextField.isHidden = true
        nameLabel.isHidden = false
        view.endEditing(true)
        
    }
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterCountLimit = 0
        var newLength = 0
        let text = (nameTextField.text! as NSString).replacingCharacters(in: range, with: string)
        if text.isEmpty {
            nameLabel.text = UserDefaults.standard.string(forKey: "Name")!
        } else{
            let startingLength = textFieldToChange.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            newLength = startingLength + lengthToAdd - lengthToReplace
        }
      return newLength > characterCountLimit
    }
    
    @IBAction func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        self.locationMapView.removeAnnotation(annotation)
        if gesture.state == .ended {
            let point = gesture.location(in: self.locationMapView)
            let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
            annotation.coordinate = coordinate
            self.locationMapView.addAnnotation(annotation)
            UserDefaults.standard.set(annotation.coordinate.latitude, forKey: "Lat")
            UserDefaults.standard.set(annotation.coordinate.longitude, forKey: "Long")
            let lat = Double(annotation.coordinate.latitude)
            let long = Double(annotation.coordinate.longitude)
            let user = Auth.auth().currentUser
            db.collection("users").document(user!.uid).updateData(["Lat": lat, "Long": long])
            
                }
            }
    
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
        style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
