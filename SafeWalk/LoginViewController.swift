//
//  LoginViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/26/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // signInAction is called when the user presses "sign in" in the app. It logs a user in, but only if the user already has an account and was verified through email.
    @IBAction func signInAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if (error != nil) {
                let alert = UIAlertController(title: "Error in Sign In!", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                strongSelf.present(alert, animated: true)
            } else if (!(authResult?.user.isEmailVerified ?? false)) {
                let alert = UIAlertController(title: "Error in Sign In!", message: "Verify account by clicking on the link sent to your email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                strongSelf.present(alert, animated: true)
            } else {
                strongSelf.performSegue(withIdentifier: "mapSegue", sender: self)
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
