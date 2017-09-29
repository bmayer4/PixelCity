//
//  PhotoService.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/29/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Alamofire

class PhotoService {

    static let instance = PhotoService()
    private init() {}
    
    var photos = [Photo]()

    
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 30)).responseJSON { (response) in
            print("here \(String(describing: response.result.value))")
            guard let json = response.result.value as? Dictionary<String, Any> else { return }
            let photosDict = json["photos"] as! Dictionary<String, Any>
            let photoDict = photosDict["photo"] as! [Dictionary<String, Any>]
            
            for photo in photoDict {
                
                //this is what the downloaded flickr url links format is
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                let photoTitle = photo["title"] as? String ?? ""
                
                let photo = Photo(imageUrl: postUrl, title: photoTitle)
                self.photos.append(photo)
                
            }
            completion(true)
            
        }
    }
    

}


