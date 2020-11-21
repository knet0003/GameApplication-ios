//
//  HomeViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/05.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var WelcomeLabel: UILabel!
    var currentSender: Sender?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentSender = Sender(id: UserDefaults.standard.object(forKey: "Uid") as! String, name: UserDefaults.standard.string(forKey: "Name")!)
        WelcomeLabel.text?.append(currentSender!.displayName)
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

}
