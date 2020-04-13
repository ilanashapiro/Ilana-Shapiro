//
//  DirectionsListViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 4/6/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit

class DirectionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var directionsList =  [(description: String, endLocation: Any)]()
    var currentDirectionIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(directionsList.count)
        return directionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directionsTableViewCell", for: indexPath) as! DirectionsTableViewCell
        let direction = directionsList[indexPath.row].description
        cell.directionsLabel.text = direction
        
        //set the current direction tableviewcell to yellow
       //it's always 0 for now but should be passed in from MapsVC and then updated as needed when GPS is implemented
       //section is always 0 in IndexPath (we don't have multiple sections)
        if (indexPath.row == currentDirectionIndex) {
            cell.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1)
        }
        
        return cell
    }
    
    func updateCurrentDirection() {
        // TODO: fill this in with updating the direction based on GPS
        // once this is filled in (updating the current direction index in relation to the directions array),
        // make the previously current direction cell clear background and make the new current direction cell yellow
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
