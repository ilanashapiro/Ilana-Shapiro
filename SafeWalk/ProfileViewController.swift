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
    
    func updateEmergencyContact(_ controller: EmergencyContactViewController, contactName: String!, number: String!) {
        self.emergencyContactNameLabel.text = contactName
        self.emergencyContactNumberLabel.text = formatPhoneNumber(number: number)
        
    controller.navigationController?.popViewController(animated: true)
    }
    
    var db: Firestore!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emergencyContactNameLabel: UILabel!
    @IBOutlet weak var emergencyContactNumberLabel: UILabel!
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        let user = Auth.auth().currentUser
        let alert = UIAlertController(title: "You must reauthenticate before deleting your account (type your email, press return, then type your password)", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField { (password) in
            password.isSecureTextEntry = true
        }
        
        let submitAction = UIAlertAction(title: "OK", style: .default, handler: { [unowned alert] _ in
            let email = alert.textFields![0]
            let password = alert.textFields![1]
            let credential = EmailAuthProvider.credential(withEmail:email.text ?? "", password: password.text ?? "")
            
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticate(with: credential, completion: { (result, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error in Reauthentication!", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    user?.delete { error in
                        if let error = error {
                            let alert = UIAlertController(title: "Error in delete account!", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let welcomeNavigationController = storyBoard.instantiateViewController(withIdentifier: "welcomeNavigationController")
                            let window = self.view.window
                            window?.rootViewController = welcomeNavigationController
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        
        
    
        
        
//        emergencyContactNameLabel.text = SignUpViewController().contactNameTextField.text
//        
//        
//        if SignUpViewController().contactPhoneTextField != nil {
//            emergencyContactNumberLabel.text = SignUpViewController().contactPhoneTextField.text
//        }
        
        updateEmergencyContactUI()
    }
    
    func updateEmergencyContactUI() {
        let emergencyContactRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        emergencyContactRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.emergencyContactNameLabel.text = document.get("contactName") as? String
                let number = (document.get("number") as? String)
                guard number != nil else { return }
                self.emergencyContactNumberLabel.text = self.formatPhoneNumber(number: number)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToEmergencyContact") {
            let emergencyContactVC = segue.destination as! EmergencyContactViewController
            emergencyContactVC.delegate = self
        }
    }
    
    func formatPhoneNumber(number: String!) -> String {
        if number.count != 10 || !number.isNumeric {
            return "INPUT ERROR"
        }
        let areaCode = "(" + number[number!.index(number!.startIndex, offsetBy: 0)..<number!.index(number!.startIndex, offsetBy: 3)] + ") "
        let firstThreeDigits = number[number!.index(number!.startIndex, offsetBy: 3)..<number!.index(number!.startIndex, offsetBy: 6)] + "-"
        let lastFourDigits = number[number!.index(number!.endIndex, offsetBy: -4)..<number!.index(number!.endIndex, offsetBy: 0)]
        return areaCode + firstThreeDigits + lastFourDigits
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
