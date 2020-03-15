//
//  EmergencyContactViewController.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 2/29/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit
import Firebase

protocol EmergencyContactViewControllerDelegate: class {
    func updateEmergencyContact(_ controller: EmergencyContactViewController, name: String!, number: String!)
}
class EmergencyContactViewController: UIViewController {
    var db:Firestore!
    weak var delegate: EmergencyContactViewControllerDelegate?
    
    @IBOutlet weak var emergencyContactNameTextField: UITextField!
    @IBOutlet weak var emergencyContactNumberTextField: UITextField!
    
    // Action gets carried out when the user submits the change emergency contact request. The validity of the data is checked (e.g. the phone number must be a 10-digit number), and then the data is updated in Firebase and sent back to the Profile VC to update the UI without an extra database query
    @IBAction func changeContactAction(_ sender: Any) {
        
        //check if the text fields have text
        if(emergencyContactNameTextField.text == nil || emergencyContactNameTextField.text == "" || emergencyContactNumberTextField.text == "" || emergencyContactNumberTextField.text == nil) {
            let alert = UIAlertController(title: "Error!", message: "You must enter both a name and number for your emergency contact", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // check if the number is 10 digits and purely numeric
        else if emergencyContactNumberTextField.text!.count != 10 || !emergencyContactNumberTextField.text!.isNumeric {
            let alert = UIAlertController(title: "Error!", message: "Enter the number in the format 0000000000 (note that the country code defaults to 1 as only US-based calling is currently supported)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let name = emergencyContactNameTextField.text!
        let number = emergencyContactNumberTextField.text!
        
        let emergencyContactData: [String: Any] = [
            "name": name,
            "number": number,
        ]
        
        
        // update Firebase and Profile VC
        updateEmergencyContactData(data: emergencyContactData)
        delegate?.updateEmergencyContact(self, name: name, number: number)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         db = Firestore.firestore()
    }
    
    func updateEmergencyContactData(data: [String: Any]) {
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(data, merge: true) { err in
            if let err = err {
                print("Error updating emergency contact in database: \(err)")
                let alert = UIAlertController(title: "Error updating emergency contact in database: \(err)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("Document successfully written!")
            }
        }
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

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
