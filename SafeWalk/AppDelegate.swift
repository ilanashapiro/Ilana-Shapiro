//
//  AppDelegate.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/16/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleMaps
import GooglePlaces
import CoreLocation

// for getting user's location updates
@objc protocol AppDelegateLocationUpdateDelegate : NSObjectProtocol {
    @objc optional func currentLocationUpdate(_ location:CLLocation)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    /* AIzaSyDUHxMro0w_AjO4xsCQzYVWTfMXILeBS9g | Jenna's key */
    /* AIzaSyD0LYhCqrg3c3fdoEyYH7l0gptZ_mHTedw | Gabe's key (for billing) */
    let MAPS_API_KEY = "AIzaSyD0LYhCqrg3c3fdoEyYH7l0gptZ_mHTedw"
    
    // for getting user's location updates
    let locationManager = CLLocationManager()
    var appDelegateLocationUpdateDelegate: AppDelegateLocationUpdateDelegate?
    var currentLocation:CLLocation!
    
    // for getting user's location updates
    class func SharedDelegate () -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(MAPS_API_KEY)
        GMSPlacesClient.provideAPIKey(MAPS_API_KEY)
        
        // for getting user's location updates
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                print("Restricted.")
                break
            case .denied:
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resource s that were specific to the discarded scenes, as they will not return.
    }
    
    // for getting user's location updates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // for getting user's location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last! as CLLocation
        
        if (self.appDelegateLocationUpdateDelegate != nil && (self.appDelegateLocationUpdateDelegate?.responds(to: #selector(self.appDelegateLocationUpdateDelegate?.currentLocationUpdate(_:))))!) {
            self.appDelegateLocationUpdateDelegate?.currentLocationUpdate!(locations.last! as CLLocation)
        }
        print("User current location: ", locations)
    }
}

