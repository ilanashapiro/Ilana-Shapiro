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
    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var destinationLocationTextField: UITextField!
    @IBOutlet weak var getPathButton: UIButton!
    @IBOutlet weak var currentToOrigin: UIButton!
    @IBOutlet weak var nextDirectionTextView: UITextView!
    @IBOutlet weak var exitRouteButton: UIButton!
    @IBOutlet weak var directionsListButton: UIButton!
    @IBOutlet weak var selectPathButton: UIButton!
    @IBOutlet weak var pathSelectInstructionsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    enum UIRouteState {
        case notChosenRoute
        case pathSelection
        case onRoute
    }
    
    var selectedStartLocation = CLLocationCoordinate2D()
    var selectedDestinationLocation = CLLocationCoordinate2D()
    
    var locationStart: GMSMarker!
    var locationEnd: GMSMarker!
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var lastTappedRoutePolyline = GMSPolyline()
    var chosenRoute = [String:Any]()
    var directionsList = [String]()
    var polylineDict = [GMSPolyline:NSDictionary]()
    
// code to save the markers in the tolerance of each path for filtering once the user chooses the path. However, this  doesn't appear to give much benefit to the user (i.e. it seems ok to keep all crimes on the UI), and it takes a long time, so commenting it out for now. It replaces polylineList in function
//    var markersPerRoute = [String:[Any]]()

    
    @IBAction func didTapExitRoute(_ sender: Any) {
        googleMaps.clear()
        setRouteUI(routeStatus: .notChosenRoute)
        selectedStartLocation.latitude = 0.0
        selectedDestinationLocation.latitude = 0.0
        startLocationTextField.text = ""
        destinationLocationTextField.text = ""
    }
    
    @IBAction func didTapSelectPath(_ sender: Any) {
        if (chosenRoute.count == 0) {
            let alert = UIAlertController(title: "Please select a path", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        setRouteUI(routeStatus: .onRoute)
        
        // clear the map and redraw the chosen route only
        googleMaps.clear()
        let routeOverviewPolyline:NSDictionary = (chosenRoute as NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
        let points = routeOverviewPolyline.object(forKey: "points")
        let path = GMSPath.init(fromEncodedPath: points! as! String)
        let tappedPolyline = GMSPolyline.init(path: path)
        tappedPolyline.strokeWidth = 3
        let bounds = GMSCoordinateBounds(path: path!)
        googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
        tappedPolyline.map = self.googleMaps
        
        let startMarker = GMSMarker(position: tappedPolyline.path!.coordinate(at: 0))
        let endMarker = GMSMarker(position: tappedPolyline.path!.coordinate(at: path!.count() - 1))
        startMarker.icon = GMSMarker.markerImage(with: UIColor.magenta)
        startMarker.title = "START"
        startMarker.map = googleMaps
        endMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        endMarker.title = "END"
        endMarker.map = googleMaps
        
        // code to save the markers in the tolerance of each path for filtering once the user chooses the path. However, this  doesn't appear to give much benefit to the user (i.e. it seems ok to keep all crimes on the UI), and it takes a long time, so commenting it out for now.
        // plot the crimes that are in the tolerance of the given path only
//        for incident in markersPerRoute[points! as! String]! {
//            if let incidentDict = incident as? Dictionary<String, Any> {
//                let incidentLatitude = incidentDict["incident_latitude"] as! Double
//                let incidentLongitude = incidentDict["incident_longitude"] as! Double
//                let incidentDescription = incidentDict["incident_offense_detail_description"] as! String
//                let incidentTime = incidentDict["incident_date"] as! String
//                let incidentTitle = incidentDict["incident_offense"] as! String
//                let incidentCoords = CLLocationCoordinate2D(latitude: incidentLatitude, longitude: incidentLongitude)
//
//                let marker = GMSMarker(position: incidentCoords)
//                marker.title = incidentTitle
//                marker.snippet = incidentTime + ":" + incidentDescription
//                marker.snippet = incidentDescription
//                marker.map = self.googleMaps
//            }
//        }
        
        //remove the paths you didn't choose (keeps all crimes on screen)
        for polyline in polylineDict.keys {
            if polyline == tappedPolyline{
                polyline.strokeColor = UIColor.blue
            } else {
                polyline.map = nil
            }
        }
        
        let directionsListTuples = getDirectionsListFromRoute(route: chosenRoute)
        
        //THIS IS JUST A TES NORMALLY THE USER NEEDS TO SELECT A PATH BEFORE THIS GETS DISPLAYED
        //THERE SHOULD BE AN INTERMEDIATE UI FOR THE PATH SELECTION STAGE
        if (directionsListTuples.count > 0) {
            //the first part of the tuple (i.e. element 0) is the string description of the direction
            nextDirectionTextView.text = directionsListTuples[0].0.htmlToString
            
            //NEED TO MAKE IT SO THE NEXT DIRECTION UPDATES WHEN THE USER PASSES GETS TO THE END LOCATION OF THIS LEG (STORED AS SECOND TUPLE VAL IN THE DIRECTIONSLIST ARRAY) VIA GPS. THIS ISN'T HANDLED HERE THIS IS JUST SETUP.
        }
    }
    
    @IBAction func didTapGetPath(_ sender: Any) {
        if (selectedStartLocation.latitude == 0.0 || selectedDestinationLocation.latitude == 0.0) {
            let alert = UIAlertController(title: "Please enter both a start and end destination", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        setRouteUI(routeStatus: .pathSelection)
        
        drawAllPathsWithCompletion(from: selectedStartLocation, to: selectedDestinationLocation) { (routes) in
            for route in routes {
                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                let points = routeOverviewPolyline.object(forKey: "points")
                let path = GMSPath.init(fromEncodedPath: points! as! String)

                self.getCrimesInPastYear(path: path!, tolerance: 1, units: "km")
            }
        }
    }
    
    func getCrimesInPastYear(path:GMSPath, tolerance:Double, units:String) {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //2017-04-01T18:05:00.000
        
        let currentDate = Date()
        let currentDateString  = dateFormatter.string(from: currentDate)
        
        let calendar = Calendar.current
        let yearAgoDate = calendar.date(byAdding: .year, value: -1, to: currentDate)
        let yearAgoDateString  = dateFormatter.string(from: yearAgoDate!)
        
        self.getCrimesAlongPath(path: path, startDateTime: yearAgoDateString, endDateTime: currentDateString, tolerance: 1, units: "km")
    }
  
    /// Creates the page that is shown when loaded; contains map and search bars
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrLocation()
        setRouteUI(routeStatus: .notChosenRoute)
        nextDirectionTextView.isEditable = false
    }
    
    /// Sets the current location to the starting location
    /// - Parameter sender: the "mylocation" button clicked
    @IBAction func myLocationUsed(_ sender: UIButton) {
        
        // get my location again
        getCurrLocation()
        let myLocationCoord = locationManager.location!.coordinate
        startLocationTextField.text = "Your location"
        if (locationStart != nil) {
            locationStart.map = nil
        }
        locationStart = GMSMarker(position: myLocationCoord)
        selectedStartLocation = myLocationCoord
        
        // get the center between the destination and your location. If the
        // destination was not yet selected, then just use current location
        let endCoordinates = (locationEnd != nil) ?
                        locationEnd.position :
                        myLocationCoord
        let center = getMidpoint(startCoordinates: myLocationCoord,
                                 endCoordinates: endCoordinates)
        
        // put the marker on the map
        createMarker(marker: locationStart, center: center)
    }
    
    
    /// Gets the user's real current location
    func getCurrLocation() {
        
        // get user auth to collect location data
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
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
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if let routePolyline = overlay as? GMSPolyline {
            if (routePolyline == lastTappedRoutePolyline) {
                routePolyline.strokeWidth /= 2
                return
            }
            if (lastTappedRoutePolyline.path != nil) {
                lastTappedRoutePolyline.strokeWidth /= 2
            }
            routePolyline.strokeWidth *= 2
            lastTappedRoutePolyline = routePolyline
        
            // change displayed distance and duration of tapped path
            distanceLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            timeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            distanceLabel.isHidden = false
            timeLabel.isHidden = false
            distanceLabel.text =
                polylineDict[routePolyline]!.value(forKey: "distance") as? String
            timeLabel.text =
                polylineDict[routePolyline]!.value(forKey: "duration") as? String
                
            chosenRoute = routePolyline.userData as! [String:Any]
           }
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
        if (lastTappedRoutePolyline.path != nil) {
            lastTappedRoutePolyline.strokeWidth /= 2
            lastTappedRoutePolyline.path = nil
        }
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
    
    func setRouteUI(routeStatus:UIRouteState) {
         switch routeStatus {
             case .notChosenRoute:
                startLocationTextField.isHidden = false
                destinationLocationTextField.isHidden = false
                currentToOrigin.isHidden = false
                getPathButton.isHidden = false
                timeLabel.isHidden = true
                distanceLabel.isHidden = true
                
                nextDirectionTextView.isHidden = true
                exitRouteButton.isHidden = true
                directionsListButton.isHidden = true
                
                pathSelectInstructionsLabel.isHidden = true
                selectPathButton.isHidden = true
             case .pathSelection:
                startLocationTextField.isHidden = true
                destinationLocationTextField.isHidden = true
                currentToOrigin.isHidden = true
                getPathButton.isHidden = true
                timeLabel.isHidden = true
                distanceLabel.isHidden = true
                
                nextDirectionTextView.isHidden = true
                exitRouteButton.isHidden = false
                directionsListButton.isHidden = true
                
                pathSelectInstructionsLabel.isHidden = false
                selectPathButton.isHidden = false
             case .onRoute:
                startLocationTextField.isHidden = true
                destinationLocationTextField.isHidden = true
                currentToOrigin.isHidden = true
                getPathButton.isHidden = true
                timeLabel.isHidden = true
                distanceLabel.isHidden = true
                
                nextDirectionTextView.isHidden = false
                exitRouteButton.isHidden = false
                directionsListButton.isHidden = false
                
                pathSelectInstructionsLabel.isHidden = true
                selectPathButton.isHidden = true
         }
    }
    
    func getDirectionsListFromRoute(route:[String:Any]) -> [(String, CLLocationCoordinate2D)]{
        var directionsList = [(description: String, endLocation: CLLocationCoordinate2D)]()
        let legs:[[String:Any]] = (route as NSDictionary).value(forKey: "legs") as! [[String:Any]]
        
        for leg in legs {
            let steps:[[String:Any]] = (leg as NSDictionary).value(forKey: "steps") as! [[String:Any]]
            for step in steps {
                let htmlDirections:String = (step as NSDictionary).value(forKey: "html_instructions") as! String
                
                let distanceInfo:NSDictionary = (step as NSDictionary).value(forKey: "distance") as! NSDictionary
                let distanceDescription:String = distanceInfo.value(forKey: "text") as! String
                
                let endLocationInfo:NSDictionary = (step as NSDictionary).value(forKey: "end_location") as! NSDictionary
                let lat:Double = endLocationInfo.value(forKey: "lat") as! Double
                let lng:Double = endLocationInfo.value(forKey: "lat") as! Double
                let coords = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                
                let directionsDescription = htmlDirections.htmlToString + " for "
                
                directionsList.append((description: directionsDescription + distanceDescription, endLocation: coords))
                
                // build the list of directions for use in the directions list VC
                self.directionsList.append(directionsDescription + distanceDescription)
            }
        }
        
        return directionsList
    }
    
    func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
    // gets the distance between two GPS coords. unit should be "km" for kilometers, anything else defaults to miles.
    // https://www.geodatasource.com/developers/swift
    func getDistanceBetween(startCoordinates: CLLocationCoordinate2D, endCoordinates: CLLocationCoordinate2D, unit: String) -> Double {

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

    // https://www.crimeometer.com/crime-data-api-documentation
    // Ilana's restricted crime-o-meter api key: ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4
    func getCrimesAlongPath(path: GMSPath, startDateTime: String, endDateTime: String, tolerance: Double, units: String) {
        let crimeOMeterAPIKey = "ApFDRiRemN2ONnPPgtemu85l8unixUs94HE7zFf4"
        
        let startCoordinates = path.coordinate(at: 0)
        let endCoordinates = path.coordinate(at: path.count() - 1)
        
        let midpoint = getMidpoint(startCoordinates: startCoordinates, endCoordinates: endCoordinates)
        let radius = getDistanceBetween(startCoordinates: midpoint, endCoordinates: endCoordinates, unit: units)
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
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    if let incidentsArr = json["incidents"] as? Array<Any> {
                        print("NUMINCIDENTS", incidentsArr.count)
                        for incident in incidentsArr {
                            if let incidentDict = incident as? Dictionary<String, Any> {
                                let incidentLatitude = incidentDict["incident_latitude"] as! Double
                                let incidentLongitude = incidentDict["incident_longitude"] as! Double
                                let incidentDescription = incidentDict["incident_offense_detail_description"] as! String
                                let incidentTime = incidentDict["incident_date"] as! String
                                let incidentTitle = incidentDict["incident_offense"] as! String
                                let incidentCoords = CLLocationCoordinate2D(latitude: incidentLatitude, longitude: incidentLongitude)
                                let toleranceDist = CLLocationDistance(self.getMeters(dist: tolerance, units: units))
                                if (GMSGeometryIsLocationOnPathTolerance(incidentCoords, path, true, toleranceDist)) {
                                    // code to save the markers in the tolerance of each path for filtering once the user chooses the path. However, this  doesn't appear to give much benefit to the user (i.e. it seems ok to keep all crimes on the UI), and it takes a long time, so commenting it out for now.
//                                    if (self.markersPerRoute[path.encodedPath()] == nil) {
//                                        self.markersPerRoute[path.encodedPath()] = [incidentDict]
//                                    } else  {
//                                        self.markersPerRoute[path.encodedPath()]!.append(incidentDict)
//                                    }
                                    //instead, just save all the polylines (in drawAllPathsWithCompletion) to delete them all later and the one you picked will be redrawn in a different method
                                   
                                    DispatchQueue.main.async {
                                        let marker = GMSMarker(position: incidentCoords)
                                        marker.title = incidentTitle
                                        marker.snippet = incidentTime + ":" + incidentDescription
                                        marker.snippet = incidentDescription
                                        marker.map = self.googleMaps
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
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if (error != nil) {
                print("error in getting paths!", error?.localizedDescription)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! [[String:Any]]
                    DispatchQueue.main.async {
//                        self.googleMaps.clear()
                        for route in routes {
                            let routeInfo = route as NSDictionary
                            let routeOverviewPolyline:NSDictionary =
                                routeInfo.value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            
                            //need to test if this line can replace completion block but can't do that until we get a new API key
//                            self.getCrimesInPastYear(path: path!, tolerance: 1, units: "km")
                            
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = self.randomColor()
                            polyline.isTappable = true
                            polyline.userData = route
                            
                            // dictionary for time and distance info
                            let leg = (routeInfo.value(forKey: "legs") as! [[String:Any]]).first!
                            var duration =
                                (leg["duration"] as! NSDictionary).value(forKey: "text") as! String
                            let distance =
                                (leg["distance"] as! NSDictionary).value(forKey: "text") as! String
                            
                            // change "hours" to "hrs"
                            if let i = duration.firstIndex(of: "o") {
                                let j = duration.firstIndex(of: "u")!
                                duration.removeSubrange(i ... j)
                            }
                            
                            // save to hashmap to make label displaying faster
                            self.polylineDict[polyline] =
                                ["duration" : duration,
                                 "distance" : distance] as NSDictionary

                            let bounds = GMSCoordinateBounds(path: path!)
                            self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.googleMaps

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
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = profileButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "segueToDirectionsList") {
            let directionsListVC = segue.destination as? DirectionsListViewController
            directionsListVC?.directionsList = self.directionsList
            // have another  line once GPS is set up that sets directionsListVC?.currentDirectionIndex = self.currentDirectionIndex
            // or something like that to pass the current direction the user is on, to highlight the correct direction
        }
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
            selectedStartLocation = placeCoord
            
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
            
            startLocationTextField.text = place.name
            
        case .destinationLocation:
            selectedDestinationLocation = placeCoord
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
            
            destinationLocationTextField.text = place.name
        
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

extension String {
    // https://stackoverflow.com/questions/37048759/swift-display-html-data-in-a-label-or-textview
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension UISearchBar {
    func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
