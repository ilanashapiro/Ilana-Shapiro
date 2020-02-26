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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // didTapSendAuthLink is called when the user presses "sign up" in the app. It creates an account for the user and senss an authentication link to the user's email.
    @IBAction func didTapSendAuthLink(_ sender: Any) {
        if let email = self.emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if (error != nil) {
                        let alert = UIAlertController(title: "Error in Sign Up!", message: error?.localizedDescription, preferredStyle: .alert)
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
    }
    
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

}
