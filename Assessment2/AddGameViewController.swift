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

class AddGameViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var gameName: UIButton!
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBAction func playersNeededStepper(_ sender: UIStepper) {
        playersNeededLabel.text = String(sender.value)
    }
    
    @IBOutlet weak var playersNeededLabel: UILabel!
    
    @IBAction func sessionTime(_ sender: UIDatePicker) {
        
    }
    
    @IBOutlet weak var locationMapView: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var saveButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 10
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //blue dot on the map
        self.locationMapView.showsUserLocation = true
        //tracking mode on
        self.locationMapView.userTrackingMode = .follow
        locationMapView.delegate = self
        let longtap = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longtap.minimumPressDuration = 1.0
        locationMapView.addGestureRecognizer(longtap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     locationManager.startUpdatingLocation()
     }
    
    override func viewDidDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     locationManager.stopUpdatingLocation()
     }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }

        // Do any additional setup after loading the view.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            let location = locations.last
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: (location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) //zoom on map
        self.locationMapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        }

    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x , y: frames.origin.y, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
            transparentView.backgroundColor =  UIColor.darkGray.withAlphaComponent(0.9)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x , y: frames.origin.y, width: frames.width, height: 200)
        }, completion: nil)
        
    }
    
    @objc func removeTransparentView(){
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x , y: frames.origin.y, width: frames.width, height: 0)
            
        }, completion: nil)
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {

        if gesture.state == .ended {
            let point = gesture.location(in: self.locationMapView)
            let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
            print(coordinate)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Set title and subtitle if you want
            annotation.title = "Title"
            annotation.subtitle = "subtitle"
            self.locationMapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func onGameSelected(_ sender: Any) {
        selectedButton = gameName
        addTransparentView(frames: gameName.frame)
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
        
        
    }
    
 
    
}
