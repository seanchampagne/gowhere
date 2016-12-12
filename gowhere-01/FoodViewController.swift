//
//  FoodViewController.swift
//  gowhere-01
//
//  Created by Sean Champagne on 9/12/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import QuadratTouch

class FoodViewController: UIViewController, UITableViewDelegate
{

    @IBOutlet weak var gowhereFoodLabel: UILabel!
    @IBOutlet weak var goHereFoodLabel: UILabel!
    @IBOutlet weak var RestaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    @IBOutlet weak var nearbyRestaurantsButton: UIButton!
    @IBOutlet weak var goAgainRestaurantButton: UIButton!
    
    var goFood: Venue?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        goAgainRestaurantButton.colorMe(10, color: UIColor.white)
        setupFood()
        RestaurantNameLabel.alpha = 0
        restaurantAddressLabel.alpha = 0
        nearbyRestaurantsButton.alpha = 0
        gowhereFoodLabel.alpha = 0
        goAgainRestaurantButton.alpha = 0
        goHereFoodLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        RestaurantNameLabel.fadeIn()
        restaurantAddressLabel.fadeIn()
        nearbyRestaurantsButton.fadeIn()
        gowhereFoodLabel.fadeIn()
        goHereFoodLabel.fadeIn()
        goAgainRestaurantButton.fadeInLater()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFood()
    {
        if let food = self.goFood
        {
            self.RestaurantNameLabel.text = food.name
            self.restaurantAddressLabel.text = food.address
        }
    }
    
    @IBAction func goAgainRestaurantButton(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }


}
