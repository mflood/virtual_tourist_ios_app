//
//  SettingsViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/28/23.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleremoveallPinsClicked() {
        
        DataAccessObject.deleteAllPins()
        
    }
    
}
