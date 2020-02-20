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
            let scheme = "https"
            let uriPrefix = "safewalk.page.link"
//            components.scheme =
            let queryItemEmailName = "email"
            
            var components = URLComponents()
            components.scheme = scheme
            components.host = uriPrefix
            
            let emailURLQueryItem = URLQueryItem(name: queryItemEmailName, value: email)
            components.queryItems = [emailURLQueryItem]
            
            guard let linkParameter = components.url else { return }
            print("The link parameter is: \(linkParameter)")
            
            actionCodeSettings.url = URL(string: "https://safewalk.page.link/?link=https://safewalk.com/signup") //linkParameter
                //URL(string: String(format: "https://www.safewalk.page.link"))// /?email=%@", email))
            // The sign-in operation has to always be completed in the app.
            actionCodeSettings.handleCodeInApp = true 
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName("com.safewalk.android",
                                                     installIfNotAvailable: false,
                                                     minimumVersion: "12")
            actionCodeSettings.dynamicLinkDomain = "safewalk.page.link"
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
                let alert = UIAlertController(title: "Success!", message: nil, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Open Email", style: .default, handler: { (ACTION) in
//                    self.navigationController?.popViewController(animated: true)
//                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
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
