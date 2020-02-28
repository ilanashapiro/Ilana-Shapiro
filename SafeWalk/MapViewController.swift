//
//  MapViewController.swift
//  SafeWalk
//
//  Created by Jenna Brandt on 2/22/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class MapViewController: UIViewController {
    //@IBOutlet weak var helloLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //helloLabel.textColor = UIColor.red

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
    
    // logs out the user and returns to the welcome screen, clearing the navigation stack
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let welcomeViewController = storyBoard.instantiateViewController(withIdentifier: "welcomeNavigationController")
            let window = self.view.window
            window?.rootViewController = welcomeViewController
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
  
    // custom loading of the view to display Google Maps
    override func loadView() {
        super.loadView()
        
        //     Create a GMSCameraPosition that tells the map to display the
        //     coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 34.1, longitude: -117.7, zoom: 8.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutButton

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 34.1, longitude: -117.7)
        marker.title = "Claremont"
        marker.snippet = "California"
        marker.map = mapView
    }

}
