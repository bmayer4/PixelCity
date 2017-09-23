//
//  DroppablePin.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/22/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import MapKit

//custom pins need to inherit from these classes
class DroppablePin: NSObject, MKAnnotation {
    
    //dynamic variables are able to be modified the way we need to to create the MK annotations
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()  //for NSObject
    }
    
}
