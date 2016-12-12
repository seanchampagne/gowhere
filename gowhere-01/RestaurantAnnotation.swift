//
//  RestaurantAnnotation.swift
//  gowhere-01
//
//  Created by Sean Champagne on 9/12/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit

import Foundation
import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation
{
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}