//
//  PasswordViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 3/14/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class PasswordViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func changePasswordAction(_ sender: Any) {
        let user = Auth.auth().currentUser
        let alert = UIAlertController(title: "You must reauthenticate before changing your password", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        
        let submitAction = UIAlertAction(title: "OK", style: .default, handler: { [unowned alert] _ in
            let email = alert.textFields![0]
            let password = alert.textFields![1]
            let credential = EmailAuthProvider.credential(withEmail:email.text ?? "", password: password.text ?? "")
            self.passwordTextField.isEnabled = false
            
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticate(with: credential, completion: { (result, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error in Reauthentication!", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.passwordTextField.isEnabled = true
                } else {
                    if (self.passwordTextField.text == nil || self.passwordTextField.text == "") {
                      let alert = UIAlertController(title: "Error", message: "You must enter a new passord", preferredStyle: .alert)
                      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                      alert.addAction(okAction)
                        self.present(alert, animated: true)
                        self.passwordTextField.isEnabled = true
                  } else {
                        
                        //update the password
                        Auth.auth().currentUser?.updatePassword(to: self.passwordTextField.text!) { (error) in
                        if let error = error {
                            let alert = UIAlertController(title: "Error in Update Password!", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                          self.navigationController?.popViewController(animated: true)
                        }
                      }
                  }
                }
            })
        })
        
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func reauthenticate() {
        
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
