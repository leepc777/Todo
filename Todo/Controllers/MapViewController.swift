//
//  MapViewController.swift
//  Todo
//
//  Created by sam on 2/14/18.
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
        
        searchBar.keyboardType = UIKeyboardType.alphabet
        searchBar.autocorrectionType = UITextAutocorrectionType.yes

//        print("selectedItem's title is \(selectedItem?.title)")
        
        showLocationOnMap(place:(selectedItem?.title)!)
        
    }

}
    //MARK: - Seach Bar
    extension MapViewController : UISearchBarDelegate {
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
//            searchBar.keyboardType = UIKeyboardType.alphabet
//            searchBar.autocorrectionType = UITextAutocorrectionType.yes
            
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
//            searchBar.keyboardType = UIKeyboardType.alphabet
//            searchBar.autocorrectionType = UITextAutocorrectionType.yes

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
        
        
        
        //MARK: show Locaition on Map : geocoder.geocodeAddressString
        func showLocationOnMap(place:String) {
            
            //set up indicator
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()

            
            geocoder.geocodeAddressString(place) {
                placemarks, error in
                
                // stop indicator after getting Placemarks/error in closure
                print("##########   STOP Indicator in showLoactionOnMap")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        
//                        self.showAlert(title: "Failed to find the location", message: "\(error!)")
                        
                        self.showAlert(title: "The Internet is offline!", message: "Please turn on internet")
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
        
        
        func showAlert (title:String,message:String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (actionHandler) in
                alert.dismiss(animated: true, completion: nil)
                
            }))
            self.present(alert, animated: true, completion: nil)
            print("####   showAlert got called")
        }

    }



// MARK: MapView

extension MapViewController: MKMapViewDelegate {
    
    // MARK: Wire two buttons to the pin to call out
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        print("&&&   mapView viewFor annotation got called,\(pinView)")

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

    
    //Alert view(two bottons) triggered by left callout at Pins
//    @objc func updateAlert (title:String,message:String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//
//        //Cancel button
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//
//        //Update button : to store personal info back to cloud
//        alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { (actionHandler) in
//
//            self.activityIndicator.startAnimating()
//            UIApplication.shared.beginIgnoringInteractionEvents()
//
//
//            alert.dismiss(animated: true, completion: nil)
//            self.dismiss(animated: true, completion: nil)//back to tabview after successful update
//        }))
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
////    deinit {
////        print("&&&&&  AddPinsViewController got deallocated  ")
////    }
//

    
}


