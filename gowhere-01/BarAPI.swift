//
//  BarAPI.swift
//  gowhere-01
//
//  Created by Sean Champagne on 6/30/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import Foundation
import QuadratTouch
import MapKit
import RealmSwift

struct API
{
    struct notifications
    {
        static let venuesUpdated = "venues updated"
    }
}

class BarAPI
{
    static let shared = BarAPI()
    var session: Session?
    
    init()
    {
        let foursquareTokens = Client(clientID: "TCCGTATXXTM2DC0DYWHPHUDSDJVJ4T5CXLKM1O4MK0JMOQ2J", clientSecret: "421ACM1O4PFLEJ3HTDLNUWPCSSSXXF5GIOVW2PJEC0PZFP0A", redirectURL: "")
        
        let configuration = Configuration(client: foursquareTokens)
        Session.setupSharedSessionWithConfiguration(configuration)
        self.session = Session.sharedSession()
    }
    
    func getBarsWithLocation(_ location: CLLocation)
    {
        if let session = self.session
        {
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d116941735"]
            parameters += [Parameter.radius: "8000"]
            parameters += [Parameter.limit: "50"]
            
        let searchTask = session.venues.search(parameters)
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
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: API.notifications.venuesUpdated), object: nil, userInfo: nil)
                }
            }
        }
            searchTask.start()
    }
    }
}


extension CLLocation
{
    func parameters() -> Parameters
    {
        let ll = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}
