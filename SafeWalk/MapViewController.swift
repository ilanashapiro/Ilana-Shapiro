//
//  MapViewController.swift
//  SafeWalk
//
//  Created by Jenna Brandt on 2/22/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

enum Location {
    case startLocation
    case destinationLocation
}

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
  
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
  
    // creates the page that is shown when loaded - contains map and search bars
    override func viewDidLoad() {
        super.viewDidLoad()
      
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        // create a GMSCameraPosition that tells the map to display the coordinate location of Claremont, CA
        // note that this snaps camera to Claremont no matter user's current location - change this later
        let camera = GMSCameraPosition.camera(withLatitude: 34.1, longitude: -117.7, zoom: 12.0)
        
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        
        startLocation.placeholder = "Start Location"
        startLocation.textColor = UIColor.lightGray
        
        destinationLocation.placeholder = "Destination Location"
        destinationLocation.textColor = UIColor.lightGray
        
    }
    
    // a function that can create markers on the map
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMaps
    }
    
//    // location manager delegates
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error getting location: \(error)")
//    }
//
//    // location manager delegates continued
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last
//
//        let locationClaremont = CLLocation(latitude: 34.1, longitude: -117.7)
//
//    }
    
    // the following functions essentially allow map functionality
    // if you click a point on the map, these functions store the coordinates of that point
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true

        if (gesture) {
            mapView.selectedMarker = nil
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Coordinate \(coordinate)")
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    // add func drawPath() here !!
    func drawPath(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=API_KEY"

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    let routes = json["routes"] as! NSArray
                    
                    DispatchQueue.main.async {
                        self.googleMaps.clear()
                        for route in routes {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3

                            let bounds = GMSCoordinateBounds(path: path!)
                            self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))

                            polyline.map = self.googleMaps
                        }
                    }
                } catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    // when start location is tapped, open search location
    @IBAction func openStartLocation(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        // change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
    }
    
    
    // when destination location is tapped, open search location
    @IBAction func openDestinationLocation(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
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

    @objc func profileButtonTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    // https://crime-data-explorer.fr.cloud.gov/api  -- not using this one
    // https://www.crimeometer.com/crime-data-api-documentation
    func getNumberCrimesInLocationRadius(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, within radius: Double) -> Int {
        let urlString = "https://private-anon-e3a624e21e-crimeometer.apiary-mock.com/v1/incidents/raw-data?lat=\(source.latitude)&lon=\(source.longitude)&distance=10km&datetime_ini=2019-04-20T16:54:00.000Z&datetime_end=2019-04-25T16:54:00.000Z&page=page"
        
        //"https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=API_KEY"

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    let routes = json["routes"] as! NSArray
                    
                    DispatchQueue.main.async {
                        self.googleMaps.clear()
                        for route in routes {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3

                            let bounds = GMSCoordinateBounds(path: path!)
                            self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))

                            polyline.map = self.googleMaps
                        }
                    }
                } catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        return 0
    }

    // custom loading of the view to display Google Maps
    override func loadView() {
        super.loadView()
        
        definesPresentationContext = true

        // navigation buttons on the map view controller
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logout))
        let profileButton = UIBarButtonItem(title: "Go to Profile", style: UIBarButtonItem.Style.plain, target: self, action:#selector(profileButtonTapped))
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItem = profileButton
        
        let locationClaremont = CLLocationCoordinate2D(latitude: 34.0967, longitude: -117.7198)
        let locationUpland = CLLocationCoordinate2D(latitude: 34.0975, longitude: -117.76484)
        drawPath(from: locationClaremont, to: locationUpland)
    }

}

// GMS Auto Complete Delegate for autocomplete search location
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ mapViewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ mapViewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
        
        // set the coordinate to the choice
        if locationSelected == .startLocation {
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Start Location", iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        else {
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "End Location", iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ mapViewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UISearchBar {
    func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
