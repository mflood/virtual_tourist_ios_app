//
//  SettingsViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/28/23.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    weak var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleremoveallPinsClicked() {
        
        dataController.deleteAllPins()
        
    }
    
}
