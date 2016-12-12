//
//  RestaurantAPI.swift
//  gowhere-01
//
//  Created by Sean Champagne on 9/12/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import Foundation
import QuadratTouch
import MapKit
import RealmSwift

struct FoodAPI
{
    struct notifications
    {
        static let venuesUpdated = "venues updated"
    }
}

class RestaurantAPI
{

    static let sharedFood = RestaurantAPI()
    var sessionFood: Session?
    
    
//    init()
//    {
//        let foursquareTokens = Client(clientID: "TCCGTATXXTM2DC0DYWHPHUDSDJVJ4T5CXLKM1O4MK0JMOQ2J", clientSecret: "421ACM1O4PFLEJ3HTDLNUWPCSSSXXF5GIOVW2PJEC0PZFP0A", redirectURL: "")
//        
//        let configuration = Configuration(client: foursquareTokens)
//        Session.setupSharedSessionWithConfiguration(configuration)
//        self.sessionFood = Session.sharedSession()
//    }
    
    func getRestaurantsWithLocation(_ location: CLLocation)
    {
        self.sessionFood = Session.sharedSession()
        
        if let sessionFood = self.sessionFood
        {
 
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4d4b7105d754a06374d81259"]
            parameters += [Parameter.radius: "8000"]
            parameters += [Parameter.limit: "50"]
            
            let searchTask = sessionFood.venues.search(parameters)
            {
                (result) -> Void in
                
                if let response = result.response
                {
                    if let venues = response["venues"] as? [[String : AnyObject]]
                    {
                        autoreleasepool
                            {
                                let realm = try! Realm()
                                realm.beginWrite()
                                for venue:[String : AnyObject] in venues
                                {
                                    let venueObject: Venue = Venue()
                                    if let id = venue["id"] as? String
                                    {
                                        venueObject.id = id
                                    }
                                    if let name = venue["name"] as? String
                                    {
                                        venueObject.name = name
                                    }
                                    if let location = venue["location"] as? [String : AnyObject]
                                    {
                                        if let longitude = location["lng"] as? Float
                                        {
                                            venueObject.longitude = longitude
                                        }
                                        if let latitude = location["lat"] as? Float
                                        {
                                            venueObject.latitude = latitude
                                        }
                                        if let formattedAddress = location["formattedAddress"] as? [String]
                                        {
                                            venueObject.address = formattedAddress.joined(separator: " ")
                                        }
                                    }
                                    realm.add(venueObject, update: true)
                                }
                                do
                                {
                                    try realm.commitWrite()
                                }
                                catch (let e)
                                {
                                    print("Error: \(e)")
                                }
                        }
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: FoodAPI.notifications.venuesUpdated), object: nil, userInfo: nil)
                    }
                }
            }
            searchTask.start()
        }
    }
}
