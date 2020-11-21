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

class ProfileViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationMapView: MKMapView!
    override func viewDidLoad() {
        var dob: Date?
        var lat: Double?
        var long: Double?
        super.viewDidLoad()
        nameLabel.text  = UserDefaults.standard.string(forKey: "Name")!
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = newSelectedCoordinates
        let allPreviosAnnotation = locationMapView.annotations
        locationMapView.removeAnnotations(allPreviosAnnotation)
        locationMapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: newSelectedCoordinates, span: span)
        self.locationMapView.setRegion(region, animated: true)
//        ageLabel.text = UserDefaults.standard.string(forKey: "Dob")
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
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
