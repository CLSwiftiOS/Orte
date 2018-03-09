//
//  EditViewController.swift
//  Orte
//
//  Created by Christian Liefeldt on 08.03.18.
//  Copyright © 2018 CL. All rights reserved.
//

import UIKit
import MapKit

class EditViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var locationManager = CLLocationManager()
    let annotation = MKPointAnnotation()
   
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtStadtteil: UITextField!
    @IBOutlet weak var txtStr: UITextField!
    @IBOutlet weak var txtStadt: UITextField!
    @IBOutlet weak var txtPostalCode: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLon: UITextField!
    @IBOutlet weak var txtAlt: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(EditViewController.longpress(gestureReognizer:)))
        uilpgr.minimumPressDuration = 0.01
        mapView.addGestureRecognizer(uilpgr)
        
        if places.count > activePlace {
           
            if let TempOrte = UserDefaults.standard.object(forKey: "places") as? [Dictionary<String, String>]{
                places = TempOrte
                print(places)
                if let TempName = places[activePlace]["name"] {
                    if let lat = places[activePlace]["lat"] {
                        if let lon = places[activePlace]["lon"] {
                            if let latitude = Double(lat) {
                                if let longitude = Double(lon) {
                                    txtName.text = places[activePlace]["name"]
                                    txtStr.text = places[activePlace]["str"]
                                    txtStadtteil.text = places[activePlace]["subLocal"]
                                    txtStadt.text = places[activePlace]["City"]
                                    txtPostalCode.text = places[activePlace]["PLZ"]
                                    txtCountry.text = places[activePlace]["country"]
                                    txtLat.text = lat
                                    txtLon.text = lon
                                    txtAlt.text = places[activePlace]["alt"]
                                    txtTime.text = places[activePlace]["time"]
                                    txtDate.text = places[activePlace]["date"]
                                    let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                                    let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                                    let region = MKCoordinateRegionMake(coordinate, span)
                                    self.mapView.setRegion(region, animated: true)
                                    annotation.coordinate = coordinate
                                    annotation.title = TempName
                                    self.mapView.addAnnotation(annotation)
                                    mapView.showsUserLocation = true
                                }
                            }
                        }
                    }
                }
            } else {
                txtName.text = "Error 23"
            }
        }
    }
    
    @objc func longpress(gestureReognizer: UIGestureRecognizer) {
        if gestureReognizer.state == UIGestureRecognizerState.began {
        performSegue(withIdentifier: "toMapE", sender: nil)
    }
    }
    
    @IBAction func txtEditName(_ sender: Any) {
        
        if txtName.text != "" {
            print(places[activePlace]["name"]!)
            let editName = txtName.text
            places[activePlace].updateValue(editName!, forKey: "name")
            annotation.title = txtName.text
            UserDefaults.standard.set(places, forKey: "places")
            print(places[activePlace]["name"]!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
