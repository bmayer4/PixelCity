//
//  MapVC.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/22/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    
    //Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    //to create a collection view programatically, you need a collection view flow layout
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if let collectionView = collectionView {
            pullUpView.addSubview(collectionView)
        }
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown(_:)))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        
        pullUpViewHeight.constant = 300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown(_ swipe: UISwipeGestureRecognizer) {
        cancelAllSessions()
        if swipe.direction == .down {
            pullUpViewHeight.constant = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()  //make an instance of it here
        spinner?.center = CGPoint(x: (screenSize.width  / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        spinner?.startAnimating()
        
        if let spinner = spinner {
            collectionView?.addSubview(spinner)
        }
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        progressLbl?.textAlignment = .center
        
        if let progressLbl = progressLbl {
            collectionView?.addSubview(progressLbl)
        }
    }
    
    func removeProgressLabel() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }

    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DroppablePin")
        if annotation is MKUserLocation {  //this prevents pin from being added to users location (blue dot)
            return nil
        }
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.6705882353, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        
        guard let coordinate = locationManager.location?.coordinate else { return }  //so app doesn't crash
        
        //allows you to make a distance length instead of a circular region
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(_ sender: UITapGestureRecognizer) {
        
        removePin()  //clears all pins so only what at a time will be added
        removeSpinner()  //removing spinner only if there is a spinner
        removeProgressLabel()
        cancelAllSessions()  //don't want multiple sessions running
        imageArray = []  //clear them out
        imageUrlArray = []  //clear them out
        collectionView?.reloadData()
        
        animateViewUp()
        addSpinner()
        addProgressLabel()
        addSwipe()
        
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "DroppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            print(self.imageUrlArray)
            
            if finished {
                self.retrieveImages(completion: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin() {
        
       mapView.removeAnnotations(mapView.annotations)
        
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String, Any> else { return }
            let photosDict = json["photos"] as! Dictionary<String, Any>
            let photoDict = photosDict["photo"] as! [Dictionary<String, Any>]
            for photo in photoDict {
                
                //this is what the downloaded flickr url links format is
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            
            completion(true)
        }
    }
    
    func retrieveImages(completion: @escaping (_ status: Bool) -> ()) {
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                
                //pulls out the image value from the response
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 images downloaded"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    completion(true)
                }
            })
        }
 
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //we want to cancel every instance of sessionDataTask and downloadData
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }

}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()  //request authorization whether app is open or not
        } else {
            return
        }
    }
    
    //called whenever we approve authorization, or when app first loads always. documentation is wrong..
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("this is being called")
        centerMapOnUserLocation()
    }
}


extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
}

