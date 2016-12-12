//
//  MapViewController.swift
//  gowhere-01
//
//  Created by Sean Champagne on 9/12/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate

{
    @IBOutlet weak var foodMap: MKMapView!
    @IBOutlet weak var foodTable: UITableView!
    
    var lastLocation: CLLocation?
    var foodVenues: [Venue]?
    
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 8000
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let foodMap = self.foodMap
        {
            foodMap.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.onVenuesUpdated(_:)), name: NSNotification.Name(rawValue: FoodAPI.notifications.venuesUpdated), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let foodTable = self.foodTable
        {
            foodTable.delegate = self
            foodTable.dataSource = self
        }
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
        if let foodMap = self.foodMap
        {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            foodMap.setRegion(region, animated: true)
            refreshVenues(newLocation, getDataFromFoursquare: true)
            foodMap.showsUserLocation = true
        }
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
                RestaurantAPI.sharedFood.getRestaurantsWithLocation(location)
            }
            
            let (start, stop) = calculateCoordinatesWithRegion(location)
            let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
            let realm = try! Realm()
            
            foodVenues = realm.objects(Venue).filter(predicate).sorted
                {
                    location.distance(from: $0.coordinate) < location.distance(from: $1.coordinate)
            }
            
            for venue in foodVenues!
            {
                let annotationFood = RestaurantAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
                foodMap?.addAnnotation(annotationFood)
            }
            foodTable?.reloadData()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        self.view.sendSubview(toBack: mapView)
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil
        }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationIdentifier")
        
        if view == nil
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        }
        view?.canShowCallout = true
        return view
    }

    
    func onVenuesUpdated(_ notification: Foundation.Notification)
    {
        refreshVenues(nil)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodVenues?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cellIdentifier")
        }
        if let venue = foodVenues?[(indexPath as NSIndexPath).row]
        {
            cell!.textLabel?.text = venue.name
            cell!.detailTextLabel?.text = venue.address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let venue = foodVenues?[(indexPath as NSIndexPath).row]
        {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), distanceSpan, distanceSpan)
            foodMap?.setRegion(region, animated: true)
        }
    }
    
    @IBOutlet weak var mapCloseButton: UIButton!
    @IBAction func mapCloseButton(_ sender: UIButton)
    {
           self.dismiss(animated: true, completion: nil)
    }
}
