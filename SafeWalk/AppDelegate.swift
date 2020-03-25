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

//********************* Ilana's FBI crime api key: 069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO  ****************************************************
//********************* Ilana's restricted crime-o-meter api key: ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4 **************************************
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        AIzaSyDUHxMro0w_AjO4xsCQzYVWTfMXILeBS9g   jenna's key
        GMSServices.provideAPIKey("AIzaSyAsUXoPmqBV1DmcSqiLwHCYkb2llbBh3Xc")
        GMSPlacesClient.provideAPIKey("AIzaSyAsUXoPmqBV1DmcSqiLwHCYkb2llbBh3Xc")
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
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

