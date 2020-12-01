//
//  SignInViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/10/31.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var SignInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    var currentSender: Sender?
    var channelsRef: CollectionReference?
    weak var databaseController: DatabaseController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        let database = Firestore.firestore()
        let settings = database.settings
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = true
        database.settings = settings
        SignInButton.layer.cornerRadius = 5;
        emailTextField.layer.cornerRadius = 5;
        passwordTextField.layer.cornerRadius = 5;
        channelsRef = database.collection("users")
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
                                                            if user != nil {
                                                                self.channelsRef?.whereField("uid", isEqualTo: user!.uid).getDocuments(){(querySnapshot,err) in
                                                                    if let err = err {
                                                                        print("Error getting documents: \(err)")
                                                                    } else {
                                                                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                                                                    }
                                                                }
                                                            }})
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func registerAccount(_ sender: Any) {
        
    }
    
    @IBAction func loginToAccount(_ sender: Any) {
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            displayErrorMessage("Please enter a password")
            return
        }
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            displayErrorMessage("Please enter an email address")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                UserDefaults.standard.set(true, forKey: "status")
                if user != nil {
                    self.channelsRef?.whereField("uid", isEqualTo: user?.user.uid as Any).getDocuments(){(querySnapshot,err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let name = document.get("name") as? String
                                self.currentSender = Sender(id: (user?.user.uid)!, name: name!)
                                
                            }}}}
                
                //                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
                                                    errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
                                                    UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
