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

class ProfileViewController: UIViewController,MKMapViewDelegate, UITextFieldDelegate, DatabaseListener {
    var listenerType: ListenerType = .users
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        for u in users {
            if u.uid == user.uid{
                user = u
            }
        }
        nameLabel.text = user.name
    }
    
    func onGameListChange(change: DatabaseChange, games: [GameSession]) {
        
    }
    
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationMapView: MKMapView!
    var channelsRef: CollectionReference?
    let annotation = MKPointAnnotation()
    var user = User()
    var lat : Double = 0
    var long : Double = 0
    let db = Firestore.firestore()
    weak var databaseController: DatabaseController?
    var button_defaultmode: String = "edit"
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBAction func editFields(_ sender: Any) {
        if button_defaultmode == "edit" {
            button_defaultmode = "save"
            nameLabel.isHidden = true
            nameTextField.isHidden = false
            nameTextField.text = nameLabel.text
            editButton.title = "Save"
            
        }
        else {
            if let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                nameLabel.text = text
                let user = Auth.auth().currentUser
                db.collection("users").document(user!.uid).updateData(["name": text])
                UserDefaults.standard.set(text, forKey: "Name")
                nameTextField.isHidden = true
                nameLabel.isHidden = false
                db.collection("users").document(user!.uid).updateData(["latitude": lat, "longitude": long])
                button_defaultmode = "edit"
                editButton.title = "Edit"
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .darkGray
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.green, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        var dob: Date?
        super.viewDidLoad()
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameTextField.text = nil
        logOutButton.layer.cornerRadius = 5;
        let currentuser = databaseController?.authController.currentUser
        guard let email = currentuser?.email else {
            return
        }
        emailLabel.text = email
        user  = (databaseController?.getUserByID(currentuser!.uid))!
        nameLabel.text = user.name
        dob = user.DoB
        lat = user.latitude!
        long = user.longitude!
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dob!, to: today)
        
        let ageYears = components.year
        ageLabel.text = String(ageYears!)
        ageLabel.text?.append(" Years")
        
        let newSelectedCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.coordinate = newSelectedCoordinates
        let allPreviosAnnotation = locationMapView.annotations
        locationMapView.removeAnnotations(allPreviosAnnotation)
        locationMapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: newSelectedCoordinates, span: span)
        self.locationMapView.setRegion(region, animated: true)
        
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
        if button_defaultmode == "save"{
            self.locationMapView.removeAnnotation(annotation)
            if gesture.state == .ended {
                let point = gesture.location(in: self.locationMapView)
                let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
                annotation.coordinate = coordinate
                self.locationMapView.addAnnotation(annotation)
                lat = Double(annotation.coordinate.latitude)
                long = Double(annotation.coordinate.longitude)
                
                
            }
        }
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
