//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    var flickrPin: Pin!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smallMapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var pinPhotos: [Photo] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.register(FlickrImageCollectionViewCell.self, forCellWithReuseIdentifier: FlickrImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        loadPinInfo()
        
        centerMapOnLocation(latitude: flickrPin.latitude, longitude: flickrPin.longitude)
        addPinToMap(latitude: flickrPin.latitude, longitude: flickrPin.longitude)
        
        
        queryForImages()
        
    }

    @IBAction func handleNewCollectionButtonClicked(_ sender: Any) {
        print("clicked")
    }
    
    func queryForImages() {
        
        if flickrPin.flickr_total_photos == -1 {
            // first time
            FlickrApiClient.searchPhotos(lat: flickrPin.latitude, lon: flickrPin.longitude, callback: handleSearchResults)
        }
        
    }
    
    func handleSearchResults(photoSearchResult: PhotoSearchResult?, errorString: String?) {
        if let result = photoSearchResult {
            DataAccessObject.updatePinData(pin: flickrPin, result: result, callback: handlePinUpdated)
        }
    }
    
    func handlePinUpdated() {
        
        print(flickrPin)
        self.collectionView.reloadData()
    }
    
    func clearCollection() {
        
    }
    
    func reloadCollection() {
        
    }
    
    func centerMapOnLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        smallMapView.setRegion(coordinateRegion, animated: true)
    }

    func addPinToMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        smallMapView.addAnnotation(annotation)
    }
    
    func loadPinInfo() {

        print(flickrPin.uuid!)
        print(flickrPin.title!)
        print(flickrPin.latitude)
        print(flickrPin.longitude)
    }
}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.flickrPin.photos?.count {
            return count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrImageCollectionViewCell.identifier, for: indexPath) as! FlickrImageCollectionViewCell
        
        
        if let photo = flickrPin.photos?[indexPath.row] as? Photo {
            let subtitle = photo.flickr_owner ?? "unknown"
            let image = UIImage(named: "AppIcon")
            cell.configure(with: image!, subtitle: subtitle)
           
        }
        
        return cell
       


    }
    
    
    
    
}

