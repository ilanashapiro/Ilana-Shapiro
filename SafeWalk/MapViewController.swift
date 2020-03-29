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
    
    func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
    //gets the distance between two GPS coords. unit should be "km" for kilometers, anything else defaults to miles.
    func getDistanceBetween(startCoordinates: CLLocationCoordinate2D, endCoordinates: CLLocationCoordinate2D, unit: String) -> Double {
//        https://www.geodatasource.com/developers/swift
        let theta = degreesToRadians(startCoordinates.longitude - endCoordinates.longitude)
        let startLatitudeRad = degreesToRadians(startCoordinates.latitude)
        let endLatitudeRad = degreesToRadians(endCoordinates.latitude)

        var dist = sin(startLatitudeRad) * sin(endLatitudeRad) + cos(startLatitudeRad) * cos(endLatitudeRad) * cos(theta)
        dist = acos(dist)
        dist = radiansToDegrees(dist)
        dist = dist * 60 * 1.1515
        if (unit == "km") {
            dist = dist * 1.609344
        }
        return dist
//        https://community.esri.com/groups/coordinate-reference-systems/blog/2017/10/05/haversine-formula
//      Coordinates in decimal degrees (e.g. 2.89078, 12.79797)
//        let lon1 = startCoordinates.longitude
//        let lat1 = startCoordinates.latitude
//
//        let lon2 = endCoordinates.longitude
//        let lat2 = endCoordinates.latitude
//
//        let R = 6371000.0  //radius of Earth in meters
//        let phi_1 = degreesToRadians(lat1)
//        let phi_2 = degreesToRadians(lat2)
//
//        let delta_phi = degreesToRadians(lat2 - lat1)
//        let delta_lambda = degreesToRadians(lon2 - lon1)
//
//        let a = pow(sin(delta_phi / 2.0), 2) + cos(phi_1) * cos(phi_2) * pow(sin(delta_lambda / 2.0), 2)
//
//        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
//
//        var meters = R * c  //output distance in meters
//        var km = meters / 1000.0  // output distance in kilometers

//        meters = round(meters, 3)
//        km = round(km, 3)
        
//        return km
    }
    
    func getMidpoint(startCoordinates: CLLocationCoordinate2D, endCoordinates: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // REFERENCE: https://stackoverflow.com/questions/4656802/midpoint-between-two-latitude-and-longitude
        
        var center = CLLocationCoordinate2D.init()
        
        let longitudeDistRad = degreesToRadians(endCoordinates.longitude - startCoordinates.longitude)
        
        let startLatitudeRad = degreesToRadians(startCoordinates.latitude)
        let endLatitudeRad = degreesToRadians(endCoordinates.latitude)
        let startLongitudeRad = degreesToRadians(startCoordinates.longitude)

        let Bx = cos(endLatitudeRad) * cos(longitudeDistRad)
        let By = cos(endLatitudeRad) * sin(longitudeDistRad)
        let centerLatitudeRad = atan2(sin(startLatitudeRad) + sin(endLatitudeRad), sqrt(pow((cos(startLatitudeRad) + Bx), 2) + pow(By, 2)))
        let centerLongitudeRad = startLongitudeRad + atan2(By, cos(startLatitudeRad) + Bx)

        center.latitude = radiansToDegrees(centerLatitudeRad)
        center.longitude = radiansToDegrees(centerLongitudeRad)
        
        return center
    }

    // https://crime-data-explorer.fr.cloud.gov/api  -- not using this one
    // https://www.crimeometer.com/crime-data-api-documentation
    //********************* Ilana's FBI crime api key: 069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO  *************************************************
    //********************* Ilana's restricted crime-o-meter api key: ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4 ***********************************
    func getCrimesAlongPath(path: GMSPath, startCoordinates:CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D ,startDateTime: String, endDateTime: String, tolerance: Double, units: String) {
//        let fbiAPIKey = "069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO"
//        let endpointFBI = "/api/data/nibrs/aggravated-assault/offense/states/ny/COUNT"
//        let urlStringFBI = "https://api.usa.gov/crime/fbi/sapi/\(endpointFBI)?api_key=069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO"
        let crimeOMeterAPIKey = "ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4"
        
        //is this the correct way to get the start and end coords of the path??
        let startCoordinates = path.coordinate(at: 0)
        let endCoordinates = path.coordinate(at: path.count())
        
        let midpoint = getMidpoint(startCoordinates: startCoordinates, endCoordinates: endCoordinates)
        print("midpoint:", midpoint.latitude, midpoint.longitude)
        let radius = getDistanceBetween(startCoordinates: midpoint, endCoordinates: endCoordinates, unit: units)
        print("radius", radius, units)
        let urlString = "https://api.crimeometer.com/v1/incidents/raw-data?lat=\(midpoint.latitude)&lon=\(midpoint.longitude)&distance=\(radius*10)\(units)&datetime_ini=\(startDateTime)&datetime_end=\(endDateTime)&page=1"

        let url = URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.addValue(crimeOMeterAPIKey, forHTTPHeaderField: "x-api-key")
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error")
            } else {
                do {
//                    print("data:")
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
//                    print(json)
//                    print(json["incidents"])
                    if let incidentsArr = json["incidents"] as? Array<Any> {
                        for incident in incidentsArr {
//                            print(incident)
                            if let incidentDict = incident as? Dictionary<String, Any> {
//                                print(incidentDict)
                                if let incidentLatitude = incidentDict["incident_latitude"] as? Double,
                                    let incidentLongitude = incidentDict["incident_longitude"] as? Double,
                                    let incidentDescription = incidentDict["incident_offense_detail_description"] as? String,
                                    let incidentTitle = incidentDict["incident_offense"] as? String {
                                    print(incidentLatitude, incidentLongitude, incidentDescription)
                                    let incidentCoords = CLLocationCoordinate2D(latitude: incidentLongitude, longitude: incidentLatitude)
                                    if (GMSGeometryIsLocationOnPathTolerance(incidentCoords, path, true, tolerance)) {
                                        DispatchQueue.main.async {
                                            let position = CLLocationCoordinate2D(latitude: incidentLatitude, longitude: incidentLongitude)
                                            let marker = GMSMarker(position: position)
                                            marker.title = incidentTitle
                                            marker.snippet = incidentDescription
                                            marker.map = self.googleMaps
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    func drawAllPathsWithCompletion(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping  (Array<Any>) -> Void) {
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        
        //https://developers.google.com/maps/documentation/directions/intro
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&alternatives=true&key=API_KEY"

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    if let routes = json["routes"] as? Array<Any> {
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
                        completion(routes)
                    }
                } catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
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
        let locationDisneyHall = CLLocationCoordinate2D(latitude: 34.0553, longitude: -118.2498)
        let locationUnionStation = CLLocationCoordinate2D(latitude: 34.0562, longitude: -118.2365)
        let locationLosAngeles = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        let locationNewYork = CLLocationCoordinate2D(latitude: 40.7127837, longitude: -74.0059413)
        drawAllPathsWithCompletion(from: locationClaremont, to: locationUpland) { (routes) in
            for route in routes {
                let encodedPath:String = (route as! NSDictionary).value(forKey: "overview_polyline") as! String
                if let path = GMSPath(fromEncodedPath: encodedPath) {
                    self.getCrimesAlongPath(path: path, startCoordinates: locationClaremont, endCoordinates: locationUpland, startDateTime: "2010-08-26T00:00:00.000Z", endDateTime: "2019-08-27T00:00:00.000Z", tolerance: 5, units: "km")
                }
            }
        }
        
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
