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
    var currentSender: Sender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
                                                            if user != nil {
                                                                self.currentSender = Sender(id: user!.uid, name: "Viki")
                                                                UserDefaults.standard.set(user!.uid, forKey: "Uid")
                                                                UserDefaults.standard.set("Viki", forKey: "Name")
                                                                UserDefaults.standard.synchronize()
                                                                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                                                            }})
        
        // Do any additional setup after loading the view.
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
