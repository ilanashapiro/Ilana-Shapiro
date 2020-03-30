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
    
    var locationStart: GMSMarker!
    var locationEnd: GMSMarker!
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
  
    /// Creates the page that is shown when loaded; contains map and search bars
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrLocation()
        
    }
    
    /// Gets the user's real current location
    func getCurrLocation() {
        
        // get user auth to collect location data
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        // show user location if auth provided
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        
    }

    // location manager delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
    }

    // location manager delegates continued
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // user's live location
        let currLocation = locations.last
        let userLat = currLocation!.coordinate.latitude
        let userLong = currLocation!.coordinate.longitude
        
        /* NOTE: for this current location to work, go to the menu bar and
         click Debug > Simulate Location > Add GPX File to Workspace...
         then pick the oldenborg.gpx file in the directory (or put your own
         coordinates) */
        let camera = GMSCameraPosition(latitude: userLat,
                                       longitude: userLong, zoom: 12)
        
        // various google maps preferences
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true

    }
    
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
    
    
    /// When start location is tapped, open search location
    /// Note: GMSAutocomplete only shows 5 at a time
    /// https://stackoverflow.com/questions/31761124/how-to-obtain-more-than-5-results-from-google-maps-places-autocomplete
    /// - Parameter sender: the location entered by the user
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
    
    //https://stackoverflow.com/questions/21130433/generate-a-random-uicolor
    func randomColor() -> UIColor {
        let red = Double(arc4random_uniform(256)) / 255.0
        let green = Double(arc4random_uniform(256)) / 255.0
        let blue = Double(arc4random_uniform(256)) / 255.0
        let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        return color
    }
    
    // units should be km, mi, or ft. Anything else defaults to meters.
    func getMeters(dist:Double, units:String) -> Double {
        if (units == "km") {
            return dist * 1000
        } else if (units == "mi") {
            return (dist / 0.62137) * 1000
        } else if (units == "ft") {
            return dist / 3.2808
        } else {
            return dist
        }
    }

    // https://crime-data-explorer.fr.cloud.gov/api  -- not using this one
    // https://www.crimeometer.com/crime-data-api-documentation
    
    /* Ilana's FBI crime api key:
            69VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO */
    
    /* Ilana's restricted crime-o-meter api key:
            ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4 */
    
    func getCrimesAlongPath(path: GMSPath, startDateTime: String, endDateTime: String, tolerance: Double, units: String) {
        /*
        let fbiAPIKey = "069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO"
        let endpointFBI = "/api/data/nibrs/aggravated-assault/offense/states/ny/COUNT"
        let urlStringFBI =
        "https://api.usa.gov/crime/fbi/sapi/\(endpointFBI)?api_key=069VFLk70Nk35Rq03GO9M3k8zB6vDvjpGtnWAywO"
        */
        let crimeOMeterAPIKey = "ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4"
        
        //is this the correct way to get the start and end coords of the path??
        let startCoordinates = path.coordinate(at: 0)
        let endCoordinates = path.coordinate(at: path.count() - 1)
        
        print("start coord:", startCoordinates)
        print("end coord:", endCoordinates)
        let midpoint = getMidpoint(startCoordinates: startCoordinates, endCoordinates: endCoordinates)
        print("midpoint:", midpoint.latitude, midpoint.longitude)
        let radius = getDistanceBetween(startCoordinates: midpoint, endCoordinates: endCoordinates, unit: units)
        print("radius", radius, units)
        let urlString = "https://api.crimeometer.com/v1/incidents/raw-data?lat=\(midpoint.latitude)&lon=\(midpoint.longitude)&distance=\(radius)\(units)&datetime_ini=\(startDateTime)&datetime_end=\(endDateTime)&page=1"

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
//                                    print(incidentLatitude, incidentLongitude, incidentDescription)
                                    let incidentCoords = CLLocationCoordinate2D(latitude: incidentLatitude, longitude: incidentLongitude)
                                    let toleranceDist = CLLocationDistance(self.getMeters(dist: tolerance, units: units))
                                    if (GMSGeometryIsLocationOnPathTolerance(incidentCoords, path, true, toleranceDist)) {
                                        DispatchQueue.main.async {
                                            let marker = GMSMarker(position: incidentCoords)
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.MAPS_API_KEY
        //https://developers.google.com/maps/documentation/directions/intro
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&alternatives=true&key=\(apiKey)"
        print(urlString)
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    if let routes = json["routes"] as? [[String:Any]] {
                        DispatchQueue.main.async {
                            self.googleMaps.clear()
                            for route in routes {
                                let routeOverviewPolyline:NSDictionary = (route as NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                let points = routeOverviewPolyline.object(forKey: "points")
                                let path = GMSPath.init(fromEncodedPath: points! as! String)
                                let polyline = GMSPolyline.init(path: path)
                                polyline.strokeWidth = 3
                                polyline.strokeColor = self.randomColor()

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
        
        /*
        let locationClaremont = CLLocationCoordinate2D(latitude: 34.0967, longitude: -117.7198)
        let locationUpland = CLLocationCoordinate2D(latitude: 34.0975, longitude: -117.76484)
        let locationDisneyHall = CLLocationCoordinate2D(latitude: 34.0553, longitude: -118.2498)
        let locationUnionStation = CLLocationCoordinate2D(latitude: 34.0562, longitude: -118.2365)
        let locationLosAngeles = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        let locationNewYork = CLLocationCoordinate2D(latitude: 40.7127837, longitude: -74.0059413)
        
        drawAllPathsWithCompletion(
            from: locationClaremont, to: locationUpland) { (routes) in
                for route in routes {
                    
                    let routeOverviewPolyline:NSDictionary = (route as! NSDictionary)
                            .value(forKey: "overview_polyline") as! NSDictionary
                    
                    let points = routeOverviewPolyline.object(forKey: "points")
                    let path = GMSPath.init(fromEncodedPath: points! as! String)
                    
                    self.getCrimesAlongPath(path: path!,
                                            startDateTime: "2010-08-26T00:00:00.000Z",
                                            endDateTime: "2019-08-27T00:00:00.000Z",
                                            tolerance: 10, units: "km")
                    
//                TEST CODE
//                let incidentCoords = CLLocationCoordinate2D(latitude: 34.0811, longitude: -117.7535)
//                let tolerance = CLLocationDistance(self.getMeters(dist: 10, units: "km"))
//                print(GMSGeometryIsLocationOnPathTolerance(incidentCoords, path!, true, tolerance))
                
//                let startCoordinates = path!.coordinate(at: 0)
//                let endCoordinates = path!.coordinate(at: path!.count() - 1)
//
//                print("start coord:", startCoordinates)
//                print("end coord:", endCoordinates)
//
//                let midpoint = self.getMidpoint(startCoordinates: startCoordinates, endCoordinates: endCoordinates)
//                print("midpoint:", midpoint.latitude, midpoint.longitude)
//                let radius = self.getDistanceBetween(startCoordinates: midpoint, endCoordinates: endCoordinates, unit: "km")
//                print("radius", radius, "km")
//                let crimeArrCoordsTEST = [CLLocationCoordinate2D(latitude: 34.0821, longitude: -117.7477),
//                CLLocationCoordinate2D(latitude: 34.0811, longitude: -117.7535),
//                CLLocationCoordinate2D(latitude: 34.082, longitude: -117.7528),
//                CLLocationCoordinate2D(latitude: 34.1025, longitude: -117.7246),
//                CLLocationCoordinate2D(latitude: 34.1005, longitude: -117.7582),
//                CLLocationCoordinate2D(latitude: 34.0821, longitude: -117.7477),
//                CLLocationCoordinate2D(latitude: 34.0811, longitude: -117.7535),
//                CLLocationCoordinate2D(latitude: 34.082, longitude: -117.7528),
//                CLLocationCoordinate2D(latitude: 34.1025, longitude: -117.7246),
//                CLLocationCoordinate2D(latitude: 34.1005, longitude: -117.7582),
//                CLLocationCoordinate2D(latitude: 34.0821, longitude: -117.7477),
//                CLLocationCoordinate2D(latitude: 34.0811, longitude: -117.7535),
//                CLLocationCoordinate2D(latitude: 34.082, longitude: -117.7528),
//                CLLocationCoordinate2D(latitude: 34.1025, longitude: -117.7246),
//                CLLocationCoordinate2D(latitude: 34.1005, longitude: -117.7582)]
            }
        }
         */
        
    }

}

// GMS Auto Complete Delegate for autocomplete search location
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ mapViewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ mapViewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // the location the user just selected
        let placeCoord = place.coordinate
        let workingLocation = CLLocation(latitude: placeCoord.latitude,
                                         longitude: placeCoord.longitude)
        
        // to be the camera's center; will change if both a start and end
        // location were selected already
        var center = place.coordinate
        
        // the marker to drop on the map
        var marker: GMSMarker!
        
        // cases for camera zoom depending on if start or end was just specified
        switch locationSelected {
        case .startLocation:
            
            // overwrite existing start marker
            if (locationStart != nil) {
                locationStart.map = nil
            }
            
            // update the start location
            locationStart = GMSMarker(position: workingLocation.coordinate)
            marker = locationStart
            
            // if an end location was also previously selected then get the
            // midpoint of the selected location and end destination
            if (locationEnd != nil) {
                center = getMidpoint(startCoordinates: placeCoord,
                                     endCoordinates: locationEnd.position)
            }
            
            startLocation.text = place.name
            
        case .destinationLocation:
            
            // overwrite existing end marker
            if (locationEnd != nil) {
                locationEnd.map = nil
            }
            
            // update the end location
            locationEnd = GMSMarker(position: workingLocation.coordinate)
            marker = locationEnd
            
            // if an start location was also previously selected then get the
            // midpoint of the selected location and start destination
            if (locationStart != nil) {
                center = getMidpoint(startCoordinates: placeCoord,
                                     endCoordinates: locationStart.position)
            }
            
            destinationLocation.text = place.name
        
        }
        
        // drop the marker onto the map (delegate to method)
        createMarker(marker: marker, center: center)
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ mapViewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// A function that changes the style of markers and places them on the map
    /// - Parameters:
    ///   - marker: the marker to place and edit
    ///   - center: the center around which the app zooms
    func createMarker(marker: GMSMarker, center: CLLocationCoordinate2D) {
        
        // change map location based on the dropped marker(s)
        let coord1 = (locationStart == nil) ? center : locationStart.position
        let coord2 = (locationEnd == nil) ? center : locationEnd.position
        let bounds = GMSCoordinateBounds(coordinate: coord1, coordinate: coord2)
        self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        
        marker.icon = GMSMarker.markerImage(with: (marker == locationStart) ? .red : .blue)
        marker.map = googleMaps
    }
    
}

extension UISearchBar {
    func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
