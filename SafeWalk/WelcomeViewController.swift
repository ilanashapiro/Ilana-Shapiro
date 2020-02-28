//
//  WelcomeViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/27/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import FirebaseUI

class WelcomeViewController: UIViewController {
    @IBAction func didTapFirebaseUI(_ sender: Any) {
        //get the default auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            print("Error: authUI is nil")
            return
        }
        
        //set ourselves as the delegate
        authUI?.delegate? = self
        
        //get a reference to the auth UI view controller. Can force unwrap the optional since we just check for nil value above
        let authViewController = authUI!.authViewController()
        
        //Show it
        present(authViewController, animated: true, completion: nil)
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

extension WelcomeViewController: FUIAuthDelegate  {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
         
        // Check if there was an error
        if error != nil {
            print("Error: error in sign in")
            return
        }
        
        
    }
}
