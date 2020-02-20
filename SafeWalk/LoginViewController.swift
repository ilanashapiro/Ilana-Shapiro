//
//  LoginViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/19/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func didTapSendAuthLink(_ sender: Any) {
        if let email = self.emailTextField.text {
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url =
                URL(string: String(format: "https://www.safewalk.com"))// /?email=%@", email))
            // The sign-in operation has to always be completed in the app.
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName("com.safewalk.android",
                                                     installIfNotAvailable: false,
                                                     minimumVersion: "12")
            print()
            Auth.auth().sendSignInLink(toEmail:email,
                                       actionCodeSettings: actionCodeSettings) { error in
              // ...
                if let error = error {
                    let alert = UIAlertController(title: "Error sending signup link to email", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                // The link was successfully sent. Inform the user.
                // Save the email locally so you don't need to ask the user for it again
                // if they open the link on the same device.
                UserDefaults.standard.set(email, forKey: "Email")
                let alert = UIAlertController(title: "Check your email for signup link", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
                // ...
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
