//
//  ViewController.swift
//  Orte
//
//  Created by Christian Liefeldt on 06.03.18.
//  Copyright © 2018 CL. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var name = ""
    var str = ""
    var rdy = Bool()
    var newCoordinate = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var destinationLocation = CLLocationCoordinate2D()
    var sourceLocation = CLLocationCoordinate2D()
    @IBOutlet weak var mapView: MKMapView!
    
    @objc func longpress(gestureReognizer: UIGestureRecognizer){
        if gestureReognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureReognizer.location(in: self.mapView)
            newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            var city = ""
            var stadtTeil = ""
            var postalCode = ""
            var country = ""
            let date = Date()
            let calender = Calendar.current
            let hour = calender.component(.hour, from: date)
            let minute = calender.component(.minute, from: date)
            let sekunde = calender.component(.second, from: date)
            let timeNow = "\(hour)" + ":\(minute)" + ":\(sekunde)"
            let Tag = calender.component(.day, from: date)
            let Monat = calender.component(.month, from: date)
            let Jahr = calender.component(.year, from: date)
            let alt = String(Int((locationManager.location?.altitude)!))
            let dateNow = "\(Tag)" + ".\(Monat)" + ".\(Jahr)"
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print("Error CLGeocoder func longpress")
                } else {
                    if let placemark = placemarks?[0] {
                        if placemark.thoroughfare != nil {
                            self.str = self.str + placemark.thoroughfare! + " "
                        }
                        
                        if placemark.subThoroughfare != nil{
                            self.str = self.str + placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.subLocality != nil {
                            stadtTeil = placemark.subLocality!
                        } else {
                            stadtTeil = " nil Stadtteil"
                        }
                        
                        if placemark.subAdministrativeArea != nil {
                            city = placemark.subAdministrativeArea!
                        } else {
                            city = "nil city"
                        }
                        
                        if placemark.postalCode != nil{
                            postalCode = placemark.postalCode!
                        } else {
                            postalCode = "nil postalCode"
                        }
                        
                        if placemark.country != nil {
                            country = placemark.country!
                        } else {
                            country = "nil country"
                        }
                    }
                }
                self.setRoute()
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.newCoordinate
                annotation.title = self.str
                self.mapView.addAnnotation(annotation)
                self.showInputDialog()
                if self.rdy == true {
                    places.append(["name": self.name, "str": self.str, "subLocal": stadtTeil, "City": city, "alt": alt, "lat": String(self.newCoordinate.latitude), "lon": String(self.newCoordinate.longitude), "PLZ": postalCode, "country": country, "date": dateNow, "time": timeNow + " (HH:MM:SS)"])
                    UserDefaults.standard.set(places, forKey: "places")
                }
            }
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print(places)
    }
    
    func setRoute () {
        self.mapView.removeOverlays(mapView.overlays)
        sourceLocation = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        destinationLocation = CLLocationCoordinate2D(latitude: self.newCoordinate.latitude, longitude: self.newCoordinate.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)" + " setRoute!!")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rdy = false
        mapView.delegate = self
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureReognizer:)))
        uilpgr.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(uilpgr)
        if activePlace != -1 {
            if places.count > activePlace {
                if let TempName = places[activePlace]["name"] {
                    if let lat = places[activePlace]["lat"] {
                        if let lon = places[activePlace]["lon"] {
                            if let latitude = Double(lat) {
                                if let longitude = Double(lon) {
                                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                                    let region = MKCoordinateRegionMake(coordinate, span)
                                    self.mapView.setRegion(region, animated: true)
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    annotation.title = TempName
                                    self.mapView.addAnnotation(annotation)
                                    mapView.showsUserLocation = true
                                    destinationLocation = coordinate
                                    print(destinationLocation)
                                    //setRoute()     muss noch überprüft werden
                                }
                            }
                        }
                    }
                }
            }
        } else {
            setGPS()
        }
    }
    
    func setGPS() {
        let lat = (locationManager.location?.coordinate.latitude)!
        let lon = (locationManager.location?.coordinate.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    
    func showInputDialog() {
        rdy = true
        let alertController = UIAlertController(title: "Name", message: "Wie möchtest du den Ort nennen?", preferredStyle: .alert)
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .destructive) { (_) in
            if alertController.textFields?[0].text != nil {
                self.name = (alertController.textFields?[0].text)!
                //let email = alertController.textFields?[1].text
            } else {
                self.name = self.str
            }
            
            let Temp = (places.count - 1)
            places[Temp].updateValue(self.name, forKey: "name")
            UserDefaults.standard.set(places, forKey: "places")
        }
        
        //the cancel action doing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            let Temp = (places.count - 1)
            places.remove(at: Temp)
            UserDefaults.standard.set(places, forKey: "places")
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Ortname"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true 
    }
}

