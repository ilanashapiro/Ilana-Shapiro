//
//  DirectionsViewController.swift
//  SafeWalk
//
//  Created by Jenna Brandt on 3/10/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

class DirectionsViewController: UIViewController {
    
    // goes back to choose path maps page
    
    @objc func backButtonTapped() {
        performSegue(withIdentifier: "backSegue", sender: self)
        
    }

    @objc func profileButtonTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    // custom loading of the view to display Google Maps
    override func loadView() {
        super.loadView()
        
//        definesPresentationContext = true
//
//        // navigation buttons on the map view controller
//        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonTapped))
        let profileButton = UIBarButtonItem(title: "Go to Profile", style: UIBarButtonItem.Style.plain, target: self, action:#selector(profileButtonTapped))
//        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = profileButton
    }
    
    
    @IBAction func call911(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://911")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
}

