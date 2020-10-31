//
//  SignInViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/10/31.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if user != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }})

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerAccount(_ sender: Any) {
        guard let password = passwordTextField.text else {
         displayErrorMessage("Please enter a password")
         return
         }
         guard let email = emailTextField.text else {
         displayErrorMessage("Please enter an email address")
         return
         }

         Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
         if let error = error {
         self.displayErrorMessage(error.localizedDescription)
         }
         }
    }
    
    @IBAction func loginToAccount(_ sender: Any) {
        guard let password = passwordTextField.text else {
         displayErrorMessage("Please enter a password")
         return
         }
         guard let email = emailTextField.text else {
         displayErrorMessage("Please enter an email address")
         return
         }

         Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
         if let error = error {
         self.displayErrorMessage(error.localizedDescription)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
