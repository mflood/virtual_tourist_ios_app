//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/27/23.
//

import Foundation

import UIKit
import MapKit
import CoreData


class FlickrPin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var userInfo: [String: Any]?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, userInfo: [String: Any]) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.userInfo = userInfo
    }
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        DataAccessObject.deleteAllPins()
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPhotoPin(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
        
        addPinsToMap()
    }

    @objc func addPhotoPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        guard gestureRecognizer.state != .began else {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let pinCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        print(pinCoordinates.longitude)
        
        let success = DataAccessObject.addNewPin(latitude: pinCoordinates.latitude,
                                   longitude: pinCoordinates.longitude)
        
        if success {
            addPinsToMap()
        }

    }

    func addPinsToMap() {
        
        let allPins = DataAccessObject.selectAllPins()
        
        let newAnnotations = makeAnnotations(pins: allPins)
        
        // clear the current annotations
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
        
        mapView.addAnnotations(newAnnotations)
    }
    
    // Build a list of MKPointAnnotation that will appear on the map
    func makeAnnotations(pins: [Pin]) -> [MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for pin in pins {
            
            print("\(pin.latitude) \(pin.longitude)")
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(pin.title)"
            annotation.subtitle = "\(pin.timestamp)"
            
           
            //if studentLocation.mediaUrl != "" {
            //    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "yellow")
            //    pinView.markerTintColor = .yellow
            //}
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        return annotations
    }
}


extension MapViewController: UIGestureRecognizerDelegate {
    
}



extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
           let identifier = "marker"
           var view: MKMarkerAnnotationView
           
           if let dequeuedView = mapView.dequeueReusableAnnotationView(
                                    withIdentifier: identifier)
                                        as? MKMarkerAnnotationView {
               dequeuedView.annotation = annotation
               view = dequeuedView
               view.markerTintColor = .green
           } else {
               view =
                   MKMarkerAnnotationView(annotation: annotation,
               reuseIdentifier: identifier)
               view.canShowCallout = true
               view.markerTintColor = .green
               view.rightCalloutAccessoryView = UIButton(type: .infoDark)
               
           }
           return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKPointAnnotation {
            print("Showing Pin \(annotation)")
        }
    }

}

