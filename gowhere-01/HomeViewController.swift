//
//  HomeViewController.swift
//  gowhere-01
//
//  Created by Sean Champagne on 7/1/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{

    var lastLocation: CLLocation?
    var venues: [Venue]?
    var foodVenues: [Venue]?
    var goBar: Venue?
    var goFood: Venue?
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 8000

    
    @IBOutlet weak var gowhereLabel: UILabel!
    @IBOutlet weak var imageTextLabel: UILabel!
    @IBOutlet weak var homeImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        goButton.colorMe(10, color: UIColor.white)
        goEatButton.colorMe(10, color: UIColor.white)
        gowhereLabel.alpha = 0
        goButton.alpha = 0
        goEatButton.alpha = 0
        homeImage.alpha = 0
        imageTextLabel.alpha = 0
        gowhereLabel.fadeIn()
        goButton.fadeInLater()
        goEatButton.fadeInLater()
        homeImage.fadeIn()
        imageTextLabel.fadeIn()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if locationManager == nil
        {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 800
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldlocation: CLLocation)
    {
        refreshVenues(newLocation, getDataFromFoursquare: true)
       refreshFoodVenues(newLocation, getDataFromFoursquare: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
        
        let alert = UIAlertController(title: "Offline Mode", message: "It appears you do not have proper connection to access wonderful bars or restaurants near you.  Please connect to WiFi and restart the app to find a random bar or restaurant. Cheers!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        goButton.alpha = 0
        goEatButton.alpha = 0
        
        
    }

    func refreshVenues(_ location: CLLocation?, getDataFromFoursquare: Bool = false)
    {
        if location != nil
        {
            lastLocation = location
        }
        if let location = lastLocation
        {
            if getDataFromFoursquare == true
            {
                BarAPI.shared.getBarsWithLocation(location)
            }
            
            let (start, stop) = calculateCoordinatesWithRegion(location)
            let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
            let realm = try! Realm()
            
            venues = realm.objects(Venue).filter(predicate).sorted
                {
                    location.distance(from: $0.coordinate) < location.distance(from: $1.coordinate)
            }
        }
    }
    
    func refreshFoodVenues(_ location: CLLocation?, getDataFromFoursquare: Bool = false)
    {
        if location != nil
        {
            lastLocation = location
        }
        if let location = lastLocation
        {
            if getDataFromFoursquare == true
            {
                RestaurantAPI.sharedFood.getRestaurantsWithLocation(location)
            }
            
            let (start, stop) = calculateCoordinatesWithRegion(location)
            let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
            let realm = try! Realm()
            
            foodVenues = realm.objects(Venue).filter(predicate).sorted
                {
                    location.distance(from: $0.coordinate) < location.distance(from: $1.coordinate)
            }
        }
    }
    

    func go()
    {
        if foodVenues?.count != 0
        {
            foodVenues?.count == 0
        }
        
        BarAPI.shared.getBarsWithLocation(lastLocation!)

        //randomizer
        if venues?.count == 0
        {
            refreshVenues(lastLocation, getDataFromFoursquare: true)
        }
        let randomInt = Int(arc4random_uniform(UInt32((venues?.count)!)))
        var randomIndex = venues?.startIndex.advanced(by: randomInt)
        print(randomIndex)
        if randomIndex < venues?.count
        {
            print(randomIndex)
            randomIndex = venues?.startIndex.advanced(by: randomInt)
        }
        else
        {
                let failureAlert = UIAlertController(title: "Error!", message: "An error occurred while obtaining a bar new you!", preferredStyle: UIAlertControllerStyle.alert)
                
                failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(failureAlert, animated: true, completion: nil)
        }
        let goBar = venues![randomIndex!]
        print(goBar)
        self.goBar = goBar
    }
    
    func goEat()
    {
        if venues?.count != 0
        {
            venues?.count == 0
        }
        RestaurantAPI.sharedFood.getRestaurantsWithLocation(lastLocation!)
        
        //randomizer
        if foodVenues?.count == 0
        {
            refreshFoodVenues(lastLocation, getDataFromFoursquare: true)
        }
        let randomInt = Int(arc4random_uniform(UInt32((foodVenues?.count)!)))
        var randomIndex = foodVenues?.startIndex.advanced(by: randomInt)
        print(randomIndex)
        if randomIndex < foodVenues?.count
        {
            print(randomIndex)
            randomIndex = foodVenues?.startIndex.advanced(by: randomInt)
        }
        else
        {
            let failureAlert = UIAlertController(title: "Error!", message: "An error occurred while obtaining a bar new you!", preferredStyle: UIAlertControllerStyle.alert)
            
            failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(failureAlert, animated: true, completion: nil)
        }
        let goEat = foodVenues![randomIndex!]
        print(goEat)
        self.goFood = goEat
    }
    
    func calculateCoordinatesWithRegion(_ location: CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D)
    {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
        
        var start: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var stop: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        start.latitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        stop.latitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
        stop.longitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
        
        return (start, stop)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GoViewController"
        {
            guard let GoViewController = segue.destination as? GoViewController else
            {
                return
            }
            GoViewController.goBar = self.goBar
        }
        
        if segue.identifier == "FoodViewController"
        {
            guard let FoodViewController = segue.destination as? FoodViewController else
            {
                return
            }
            FoodViewController.goFood = self.goFood
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func goButton(_ sender: AnyObject)
    {
        go()
        let alert = UIView()
        alert.colorMe(10, color: UIColor.white)
    }
    
    @IBOutlet weak var goEatButton: UIButton!
    @IBAction func goEatButton(_ sender: UIButton)
    {
        goEat()
        let foodAlert = UIView()
        foodAlert.colorMe(10, color: UIColor.white)
    }
    
}

