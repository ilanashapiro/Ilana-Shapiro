//
//  ProfileViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/27/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, EmergencyContactViewControllerDelegate {
    func updateEmergencyContact(name: String!, number: String!) {
        updateEmergencyContactUI()
    }
    
    var db:Firestore!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emergencyContactLabel: UILabel!
    @IBAction func didTapChangeEmergencyContact(_ sender: Any) {
        

    }
    @IBAction func didTapChangePassword(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        
        updateEmergencyContactUI()
    }
    
    func updateEmergencyContactUI() {
        let emergencyContactRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        emergencyContactRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                self.emergencyContactLabel.text = dataDescription
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToEmergencyContact") {
           if let nav = segue.destination as? UINavigationController, let emergencyContactVC = nav.topViewController as? EmergencyContactViewController {
           emergencyContactVC.delegate = self
           }
        }
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
