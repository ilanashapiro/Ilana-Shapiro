//
//  SignUpViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/19/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    var db:Firestore!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactPhoneTextField: UITextField!
    
    // didTapSendAuthLink is called when the user presses "sign up" in the app. It creates an account for the user and senss an authentication link to the user's email.
    @IBAction func didTapSendAuthLink(_ sender: Any) {
        if let email = self.emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password)
            { authResult, error in
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if (self.passwordTextField.text == "" || self.emailTextField.text == "" || self.nameTextField.text == "" || self.contactNameTextField.text == "" || self.contactPhoneTextField.text == "") {
                        let alert = UIAlertController(title: "You must enter values for all fields", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    
                    else if self.contactPhoneTextField!.text?.count != 10 || !self.contactPhoneTextField.text!.isNumeric {
                        let alert = UIAlertController(title: "Error!", message: "Enter the number in the format 0000000000 (note that the country code defaults to 1 as only US-based calling is currently supported)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                        
                    else if (error != nil) {
                        let alert = UIAlertController(title: "Error in Sign Up!", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let changeRequest = user.createProfileChangeRequest()

                        changeRequest.displayName = self.nameTextField.text
                        changeRequest.commitChanges { error in
                        if let error = error {
                            let alert = UIAlertController(title: "Error in Sign Up!", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            return
                        }
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(password, forKey: "password")
                            let alert = UIAlertController(title: "Sign up successful! Verification link sent to " + email + ".", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Go to Login", style: .default, handler: {action in self.performSegue(withIdentifier: "loginSegue", sender: self)}))
                            self.present(alert, animated: true)
                       }
                     }
                    
                    
                }
                
                let contactName = self.contactNameTextField.text!
                let number = self.contactPhoneTextField.text!
                
                let emergencyContactData: [String: Any] = [
                    "contactName": contactName,
                    "number": number,
                ]
                
                
                // update Firebase
                self.updateEmergencyContactData(data: emergencyContactData)
                
                // alert emergency contact when updated
                let alert = UIAlertController(title: "Message sent!", message: "Your emergency contact was notified that you added them.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }
    
    func updateEmergencyContactData(data: [String: Any]) {
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(data, merge: true) { err in
            if let err = err {
                print("Error updating emergency contact in database: \(err)")
                let alert = UIAlertController(title: "Error updating emergency contact in database: \(err)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}
