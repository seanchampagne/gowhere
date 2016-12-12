//
//  Venue.swift
//  gowhere-01
//
//  Created by Sean Champagne on 6/30/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Venue: Object
{
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var latitude: Float = 0
    dynamic var longitude: Float = 0
    dynamic var address: String = ""
    dynamic var image: String = ""
    
    var coordinate: CLLocation
        {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    override static func primaryKey() -> String?
    {
        return "id"
    }
    
}
