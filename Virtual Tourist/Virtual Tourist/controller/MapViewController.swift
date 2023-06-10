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
    var pinUuid: String

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, uuid: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pinUuid = uuid
    }
}

class MapViewController: UIViewController {
    
    weak var dataController: DataController!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPhotoPin(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
        
        restoreMapView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPinsToMap()
    }

    @objc func addPhotoPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        guard gestureRecognizer.state != .began else {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let pinCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
         
        if let newPin = dataController.addNewPin(latitude: pinCoordinates.latitude,
                                                   longitude: pinCoordinates.longitude) {
            let annotation = makeAnnotation(pin: newPin)
            mapView.addAnnotations([annotation])
        }
    }

    
    func saveMapView() {
        let region = mapView.region
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta

        UserDefaults.standard.set(latitude, forKey: "latitude")
        UserDefaults.standard.set(longitude, forKey: "longitude")
        UserDefaults.standard.set(latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(longitudeDelta, forKey: "longitudeDelta")
    }
    
    func restoreMapView() {

        if let latitude = UserDefaults.standard.value(forKey: "latitude") as? CLLocationDegrees,
           let longitude = UserDefaults.standard.value(forKey: "longitude") as? CLLocationDegrees,
           let latitudeDelta = UserDefaults.standard.value(forKey: "latitudeDelta") as? CLLocationDegrees,
           let longitudeDelta = UserDefaults.standard.value(forKey: "longitudeDelta") as? CLLocationDegrees {

            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion(center: center, span: span)

            mapView.setRegion(region, animated: true)
        }
    }
    
    func addPinsToMap() {
        
        let allPins = dataController.selectAllPins()
        
        let newAnnotations = makeAnnotations(pins: allPins)
        
        // clear the current annotations
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
        
        mapView.addAnnotations(newAnnotations)
    }
    
    func makeAnnotation(pin: Pin) -> FlickrPin {

        let lat = CLLocationDegrees(pin.latitude)
        let long = CLLocationDegrees(pin.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let pinTitle = pin.title!
        let pinSubtitle = ("\(pin.timestamp!)")
        let pinUuid = pin.uuid!
        
        let annotation = FlickrPin(coordinate: coordinate, title: pinTitle, subtitle: pinSubtitle, uuid: pinUuid)
        return annotation
    }
    
    // Build a list of MKPointAnnotation that will appear on the map
    func makeAnnotations(pins: [Pin]) -> [FlickrPin] {
        
        var annotations = [FlickrPin]()

        
        for pin in pins {
            
            let annotation = makeAnnotation(pin: pin)
            annotations.append(annotation)
        }
        return annotations
    }
}


extension MapViewController: UIGestureRecognizerDelegate {
    
}



extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapView()
    }
    
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
        if let annotation = view.annotation as? FlickrPin {
         
            guard let pin = dataController.findPin(uuid: annotation.pinUuid) else {
                return
            }
                        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoAlbumViewController {
                // If you have a uuid property on your destination view controller, you can set it here:
                destinationViewController.dataController = dataController
                destinationViewController.pinUuid = pin.uuid

                // Then you push the destination view controller:
                navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
    }

}

