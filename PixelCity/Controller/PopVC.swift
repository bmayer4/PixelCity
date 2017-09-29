//
//  PopVC.swift
//  PixelCity
//
//  Created by Brett Mayer on 9/27/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Alamofire

class PopVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    
    var photo: Photo!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageTitle.text = photo.title
        popImageView.image = photo.photoImage
        
        addDoubleTap()

    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped(_ tap: UITapGestureRecognizer) {
        print(tap.numberOfTapsRequired)
        dismiss(animated: true, completion: nil)
    }
    
    
}
