//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import UIKit

class PhotoAlbumViewController: UIViewController {

    var flickrPinUuid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadPinInfo()
    }
    
    func loadPinInfo() {
        let pins = DataAccessObject.findPin(uuid: flickrPinUuid)
        guard pins.count != 0 else {
            return
        }
        
        let foundPin = pins[0]
        print(foundPin.uuid!)
        print(foundPin.title!)
        print(foundPin.latitude)
        print(foundPin.longitude)
    }


}

