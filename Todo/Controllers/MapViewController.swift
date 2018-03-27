//
//  MapViewController.swift
//  Todo
//
//  Created by Patrick on 2/14/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import MapKit
import CoreLocation



class MapViewController: UIViewController  {
    
    @IBOutlet weak var searchBar: UISearchBar!


    @IBOutlet weak var mapView: MKMapView!
    
    var geocoder = CLGeocoder()
    var activityIndicator = UIActivityIndicatorView()
    var selectedPin:MKPlacemark? = nil
    var coordinate : CLLocationCoordinate2D!
    let reachability = Reachability()!

    var selectedCategory : Category? {
        
        didSet{
        }
        
    }

    var selectedItem : Item? {
        
        didSet{
        }
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        mapView.delegate = self
        
        title = selectedItem?.title
        
        //set Keybaord type for search bar
        searchBar.keyboardType = UIKeyboardType.alphabet
        searchBar.autocorrectionType = UITextAutocorrectionType.yes

//        print("selectedItem's title is \(selectedItem?.title)")
        
        showLocationOnMap(place:(selectedItem?.title)!)
        
    }
    
    
    //MARK: set Reachability in ViewWillAppear and ViewDidDisappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            //            displayError("Reachable via WiFi")
            print("%%%   Reachable via WiFi")
        case .cellular:
            print("%%%   Reachable via Cellular")
        case .none:
            print("%%%   Network not reachable")
            Helper.showMessage(title: "Network not reachable", message: "Please make sure Internet is on", view: self)
            //            displayError("Network not reachable")
        }
    }


}
    //MARK: - Seach Bar
    extension MapViewController : UISearchBarDelegate {
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            if searchBar.text == "" {
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                
                //search location
                showLocationOnMap(place: searchBar.text!)
            }
        }

    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            //        print("@@@ serachBar textDidChange func got call and text is\(searchBar.text)")
            
            if searchBar.text?.count == 0 {
                //        if searchBar.text == "" {
                
                
                DispatchQueue.main.async { //
                    searchBar.resignFirstResponder()
                }
                
            }
            else {

//                showLocationOnMap(place: searchText)
                print("!!! searchBarSearchButtonClicked got call ")
                
            }
        }
    }



// MARK: MapView

extension MapViewController: MKMapViewDelegate {
    
    //MARK: show Locaition on Map : geocoder.geocodeAddressString
    func showLocationOnMap(place:String) {
        
        //set up indicator
        Helper.callAlert(stop: false, vc: self, activityIndicator: self.activityIndicator)
        
        geocoder.geocodeAddressString(place) {
            placemarks, error in
            
            // stop indicator after getting Placemarks/error in closure
            print("##########   STOP Indicator in showLoactionOnMap")
            Helper.callAlert(stop: true, vc: self, activityIndicator: self.activityIndicator)
            
            
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    
                    Helper.showMessage(title: "The Internet is offline!", message: "You need internet to show it on MAP", view: self)
                    return
            }
            print("%%%%  CLGeocoder() return the placemarks: \(placemarks),\(location)")
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            var annotations : [MKPointAnnotation] = []
            let annotation = MKPointAnnotation()
            
            //convert CLPlacemark to MKPlacemark
            self.selectedPin = MKPlacemark(placemark: placemarks.first!)
            let mapItem = MKMapItem(placemark: self.selectedPin!)
            //                let urlString = String(describing: mapItem.url)
            
            annotation.coordinate = location.coordinate
            annotation.title = mapItem.name
            annotation.subtitle = "Tap Car to Show Navigation"
            annotations.append(annotation)
            
            
            
            self.mapView.addAnnotations(annotations)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.view.endEditing(true) //close keyboard
            
        }
    }

    // MARK: Wire two buttons to the pin to call out
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//        print("&&&   mapView viewFor annotation got called,\(pinView)")

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.orange
            pinView!.canShowCallout = true
            
            
            //Setup up two buttons
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "car"), for: [])
            button.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
            pinView?.leftCalloutAccessoryView = button

        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("&&&   mapView annotationView view got called")
        
        if control == view.rightCalloutAccessoryView {
            print("$$$   control is at right")
            
            if let coordinate = view.annotation?.coordinate {
                self.coordinate = coordinate
                performSegue(withIdentifier: "goToCollection", sender: self)
            }
            
        }
        
        if control == view.leftCalloutAccessoryView {
            print("$$$   control is at left")
            getDirections()
        }
        
    }
    
    //MARK: Prepare for Segue, pass selectedPin and coordinate to Collection View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! CollectionViewController
        nextVC.selectedItem = selectedItem
        nextVC.coordinate = coordinate
    }
    //MARK: call GPS function
    @objc func getDirections(){
        print("%%%   %%%% getDirections got called, selectedPin is \(selectedPin)")
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }

    
}

