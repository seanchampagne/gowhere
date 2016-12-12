//
//  GoViewController.swift
//  gowhere-01
//
//  Created by Sean Champagne on 7/1/16.
//  Copyright © 2016 Sean Champagne. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import QuadratTouch

class GoViewController: UIViewController, UITableViewDelegate
{
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var barAddressLabel: UILabel!
    @IBOutlet weak var gowhereLabel: UILabel!
    @IBOutlet weak var nearbyBarsLabel: UIButton!
    @IBOutlet weak var goHereLabel: UILabel!
    
    var goBar: Venue?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        goAgainButton.colorMe(10, color: UIColor.white)
        setup()
        barNameLabel.alpha = 0
        barAddressLabel.alpha = 0
        nearbyBarsLabel.alpha = 0
        gowhereLabel.alpha = 0
        goAgainButton.alpha = 0
        goHereLabel.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        barNameLabel.fadeIn()
        barAddressLabel.fadeIn()
        nearbyBarsLabel.fadeIn()
        gowhereLabel.fadeIn()
        goHereLabel.fadeIn()
        goAgainButton.fadeInLater()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setup()
    {
        if let bar = self.goBar
        {
            self.barNameLabel.text = bar.name
            self.barAddressLabel.text = bar.address
        }
    }

    @IBOutlet weak var goAgainButton: UIButton!
    @IBAction func goAgainButton(_ sender: AnyObject)
    {

       self.dismiss(animated: true, completion: nil)
    }
}
extension UIView
{
    func colorMe(_ radius:CGFloat, color:UIColor = UIColor.clear) -> UIView
    {
        let colorView: UIView = self
        colorView.layer.cornerRadius = CGFloat(radius)
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = color.cgColor
        colorView.clipsToBounds = true
        return colorView
    }
    func fadeIn(_ duration: TimeInterval = 3.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in})
    {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations:
            {
            self.alpha = 1.0
            }, completion: completion)
    }
    func fadeInLater(_ duration: TimeInterval = 3.0, delay: TimeInterval = 2.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in})
    {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations:
            {
                self.alpha = 1.0
            }, completion: completion)
    }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in})
    {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations:
            {
            self.alpha = 0.0
            }, completion: completion)
    }
}
