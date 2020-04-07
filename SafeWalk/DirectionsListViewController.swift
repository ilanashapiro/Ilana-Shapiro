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
    @IBAction func onReload(_ sender: Any) {
        tableView.reloadData()
        var num = 0
        for direction in directionsList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "directionsTableViewCell", for: IndexPath(row: num, section: 0)) as! DirectionsTableViewCell
            print(cell.directionsLabel.text)
            num += 1
        }
    }
    var directionsList = ["Hello", "one", "two", "three"] //[String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
//        tableView.register(DirectionsTableViewCell.self, forCellReuseIdentifier: "directionsTableViewCell")
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(directionsList.count)
        return directionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directionsTableViewCell", for: indexPath) as! DirectionsTableViewCell
        let direction = directionsList[indexPath.row]
        cell.directionsLabel.text = direction
        //        print(cell.directionsLabel.text)
        return cell
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
