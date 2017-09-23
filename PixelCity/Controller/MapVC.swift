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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var locationManaager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManaager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        
        guard let coordinate = locationManaager.location?.coordinate else { return }  //so app doesn't crash
        
        //allows you to make a distance length instead of a circular region
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(_ sender: UITapGestureRecognizer) {
        
        removePin()  //clears all pins so only what at a time will be added
        
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "DroppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin() {
        
       mapView.removeAnnotations(mapView.annotations)
        
    }

}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManaager.requestAlwaysAuthorization()  //request authorization whether app is open or not
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //whever we approve authorization
        centerMapOnUserLocation()
    }
}

