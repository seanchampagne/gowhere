//
//  ViewController.swift
//  gowhere-01
//
//  Created by Sean Champagne on 6/30/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet var mapView:MKMapView?
    @IBOutlet var tableView:UITableView?
    
    var lastLocation: CLLocation?
    var venues: [Venue]?
    
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 8000

    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let mapView = self.mapView
        {
            mapView.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onVenuesUpdated(_:)), name: NSNotification.Name(rawValue: API.notifications.venuesUpdated), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let tableView = self.tableView
        {
            tableView.delegate = self
            tableView.dataSource = self
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
        if let mapView = self.mapView
        {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            mapView.setRegion(region, animated: true)
            refreshVenues(newLocation, getDataFromFoursquare: true)
            mapView.showsUserLocation = true
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
                BarAPI.shared.getBarsWithLocation(location)
            }
            
        let (start, stop) = calculateCoordinatesWithRegion(location)
        let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
        let realm = try! Realm()
            
        venues = realm.objects(Venue).filter(predicate).sorted
            {
                location.distance(from: $0.coordinate) < location.distance(from: $1.coordinate)
        }
        
        for venue in venues!
        {
            let annotationBar = BarAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
            mapView?.addAnnotation(annotationBar)
        }
            tableView?.reloadData()
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
        return venues?.count ?? 0
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
        if let venue = venues?[(indexPath as NSIndexPath).row]
        {
            cell!.textLabel?.text = venue.name
            cell!.detailTextLabel?.text = venue.address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let venue = venues?[(indexPath as NSIndexPath).row]
        {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), distanceSpan, distanceSpan)
            mapView?.setRegion(region, animated: true)
        }
    }

    @IBAction func closeAllBarsButton(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}

