//
//  ProfileViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/27/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emergencyContactLabel: UILabel!
    @IBAction func didTapChangeEmergencyContact(_ sender: Any) {
    }
    @IBAction func didTapChangePassword(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
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
