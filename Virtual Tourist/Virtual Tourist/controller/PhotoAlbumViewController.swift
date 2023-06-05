//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import UIKit
import MapKit

struct AlbumImage {
    let image: UIImage
    let isPlaceHolder: Bool
}

class PhotoAlbumViewController: UIViewController {

    var images: [AlbumImage] = []
    
    let placeHolderImage =  UIImage(named: "AppIcon")!
    let errorImage = UIImage(named: "downlodErrorImage")
    
    var pinUuid: String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smallMapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isDownloading: Bool = false

    var flickrPin: Pin? {
        let context = persistentContainer.viewContext
        return DataAccessObject.findPin(uuid: pinUuid, context: context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.register(FlickrImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: FlickrImageCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        if let pin = flickrPin {
            // Create a map bar at the top featuring the pin
            centerMapOnLocation(latitude: pin.latitude,
                                longitude: pin.longitude)
            addPinToMap(latitude: pin.latitude, longitude: pin.longitude)
            
            if !pin.hasDownloaded {
                // photos have not been loaded yet....
                queryForImages()
            } else {
                loadAvailablePhotos()
                downloadEmptyPhotos()
            }
        }
    }

    @IBAction func handleNewCollectionButtonClicked(_ sender: Any) {
        queryForImages()
    }
    
    func queryForImages() {
        
        guard self.isDownloading == false else {
            print("Download in progress....")
            return
        }
        
        guard let pin = flickrPin else {
            return
        }
        
        self.images = []
        self.collectionView.reloadData()
        
        DataAccessObject.deletePhotos(forPinUuid: pinUuid)
        
        
        self.isDownloading = true
        
        self.collectionView.isHidden = true
        self.noImagesLabel.isHidden = true
        self.activityIndicator.startAnimating()
        
        
        
        var pageNumber = pin.flickr_download_page_number
        let numPages = pin.flickr_num_pages
        pageNumber += 1
        
        if pageNumber > numPages {
            pageNumber = 1
        }
        
        FlickrApiClient.searchPhotos(lat: pin.latitude,
                                     lon: pin.longitude,
                                     page: pageNumber,
                                     callback: handleSearchResults)
    }
    
    func handleSearchResults(photoSearchResult: PhotoSearchResult?, errorString: String?) {
        
        self.activityIndicator.stopAnimating()
        self.isDownloading = false
        
        if let result = photoSearchResult {
            DataAccessObject.updatePinData(pinUuid: pinUuid,
                                           result: result,
                                           callback: handlePinUpdated)
        } else {
            self.noImagesLabel.text = errorString ?? "Error loading images"
            self.noImagesLabel.isHidden = false
            print(errorString)
        }
    }
    
    func loadAvailablePhotos() {
                
        guard let pin = flickrPin else {
            return
        }
        
        self.images = []
        
        if let photos = pin.photos {
            if photos.count == 0 {
                self.noImagesLabel.text = "No Images"
                self.noImagesLabel.isHidden = false
                self.collectionView.isHidden = true
                return
            }
            photos.forEach {(photoObject) in
                if let photo = photoObject as? Photo {
                    if let imageData = photo.imageData {
                        let image = UIImage(data: imageData)!
                        let albumImage = AlbumImage(image: image, isPlaceHolder: false)
                        self.images.append(albumImage)
                    } else {
                        let albumImage = AlbumImage(image: placeHolderImage, isPlaceHolder: true)
                        self.images.append(albumImage)
                    }
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func downloadEmptyPhotos() {
        
        guard let pin = flickrPin else {
            return
        }
        
        if let photos = pin.photos {
            photos.forEach {(photoObject) in
                if let photo = photoObject as? Photo {
                    
                    guard photo.imageData == nil else {
                        return
                    }

                    let photoRequest = FlickrPhotoRequest(farm: "\(photo.flickr_farm)",
                                                              server: photo.flickr_server!,
                                                              id: photo.flickr_id!,
                                                              secret: photo.flickr_secret!)
                        
                    FlickrApiClient.downloadPhoto(photoRequest: photoRequest, callback: handlePhotoDownloadResponse)

                }
            }
        }
        self.collectionView.reloadData()
    }
    
    
    func handlePinUpdated() {
    
        loadAvailablePhotos()
        downloadEmptyPhotos()

        if images.count == 0 {
            self.noImagesLabel.isHidden = false
            self.noImagesLabel.text = "No Images"
        } else {
            self.collectionView.isHidden = false
        }
    }
    
    func handlePhotoDownloadResponse(flickrPhotoRequrest: FlickrPhotoRequest, imageData: Data?, errorString: String?) {
        
        if let _ = errorString {
            return
        }
        
        guard let imageData = imageData else {
            return
        }
        
        DataAccessObject.setPhotoImageData(id: flickrPhotoRequrest.id, imageData: imageData)
        loadAvailablePhotos()
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
}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrImageCollectionViewCell.identifier, for: indexPath) as! FlickrImageCollectionViewCell
        
        let albumImage = images[indexPath.row]
        cell.configure(with: albumImage.image, subtitle: "")
        
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let albumImage = images[indexPath.item]
        
        if !albumImage.isPlaceHolder {
            let imageViewController = ImageViewController(image: albumImage.image)
            
            self.navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
}

