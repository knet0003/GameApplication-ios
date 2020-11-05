//
//  AddGameViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit
import MapKit

class AddGameViewController: UIViewController {

    @IBOutlet weak var gameNameTextField: UITextField!
    
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBOutlet weak var playersNeededStepper: UIStepper!
    
    @IBOutlet weak var playersNeededLabel: UILabel!
    
    @IBOutlet weak var sessionTimeView: UIView!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
