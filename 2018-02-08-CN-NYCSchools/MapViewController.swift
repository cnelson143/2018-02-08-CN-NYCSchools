//
//  MapViewController.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/15/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    var name : String = ""
    var lattitude : String = ""
    var longitude : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.mapType = MKMapType(rawValue: UInt(UserDefaults.standard.integer(forKey: "MapViewController-MapType")))!
        
        self.mapTypeSegmentedControl.selectedSegmentIndex = Int(self.mapView.mapType.rawValue);

        let lattitude : CLLocationDegrees = Double(self.lattitude)!
        let longitude : CLLocationDegrees = Double(self.longitude)!
        let location : CLLocation = CLLocation.init(latitude: lattitude, longitude: longitude)

        self.addPinWithTitle(title: self.name, location: location)
        
        self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func directionsButtonPressed(_ sender: Any)
    {
        let lattitude : CLLocationDegrees = Double(self.lattitude)!
        let longitude : CLLocationDegrees = Double(self.longitude)!

        var mapType = "h"
        if(self.mapView.mapType == .standard)
        {
            mapType = "m"
        }
        else if(self.mapView.mapType == .satellite)
        {
            mapType = "k"
        }
        else if(self.mapView.mapType == .hybrid)
        {
            mapType = "h"
        }
        
        let locationText = String.init(format:"http://maps.apple.com/?daddr=%f,%f+saddr=%f,%f+dirflg=d+t=%@", arguments: [lattitude, longitude, lattitude, longitude, mapType])
        UIApplication.shared.open(URL.init(string: locationText)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func addPinWithTitle(title : String, location : CLLocation)
    {
        let mapPin = MKPointAnnotation.init()
        mapPin.title = title
        mapPin.coordinate = location.coordinate
        
        self.mapView.addAnnotation(mapPin)
    }
    
    @IBAction func mapTypeSegmentedControlValueChanged(_ sender: UISegmentedControl)
    {
        if(sender.selectedSegmentIndex == 0)
        {
            self.mapView.mapType = .standard
        }
        else if(sender.selectedSegmentIndex == 1)
        {
            self.mapView.mapType = .satellite
        }
        else if(sender.selectedSegmentIndex == 2)
        {
            self.mapView.mapType = .hybrid
        }
        
        UserDefaults.standard.set(Int(self.mapView.mapType.rawValue), forKey: "MapViewController-MapType")
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
