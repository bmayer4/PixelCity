//
//  Photo.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/28/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

struct Photo {

    public private(set) var imageUrl: String!
    public private(set) var title: String!
    public var photoImage: UIImage?
    
    
    init(imageUrl: String, title: String) {
        self.imageUrl = imageUrl
        self.title = title
    }
    
}

