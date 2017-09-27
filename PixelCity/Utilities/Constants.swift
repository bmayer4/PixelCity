//
//  Constants.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/26/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import Foundation

let API_KEY = "2dd5e6dda437959d1f7e671ff13042af"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


