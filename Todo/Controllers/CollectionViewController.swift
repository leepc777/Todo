//
//  CollectionViewController.swift
//  based on my VirtualTourist
//
//  Created by Patrick on 2/8/18.
//  Copyright © 2018 patrick. All rights reserved.
//
import UIKit
import CoreData
import MapKit


class CollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var photoArray = [Photo]() // array of Photo Class
    var filteredURLs = [PhotoURL]() // store filtered URLs
    var urlArray = [PhotoURL]() // store all downloaded images's URL
    let activityIndicator = UIActivityIndicatorView()

    var selectedItem : Item! {
        didSet {
//            urlArray = PhotoLib.getPhotoURLs(lat: selectedItem.latitude, lon: selectedItem.longitude)
        }
    }
    
    var coordinate : CLLocationCoordinate2D! {
        didSet {
            print("%%%%%%%%%%%%%  Collection View receive coordinate \(coordinate) ")
        }
    }
    
    
    
    //MARK: refresh Collection View with new photos
    @objc func didTapSearchButton(sender: AnyObject){

        print("$$$$$$$$$ search button got tapped,view is \(view) and self.view \(self.view)")

        //MARK: - set up indicator
        print("&&&&&&& Start activity Indicator at Searching")
        Helper.callAlert(stop: false, vc: self, activityIndicator: self.activityIndicator)
        editButtonItem.isEnabled = false

        // dispatch to global queue to stop internet access blocking the app
        DispatchQueue.global(qos: .userInitiated).async {
//        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in

            self.urlArray = PhotoLib.getPhotoURLs(lat: self.coordinate.latitude, lon: self.coordinate.longitude)
            self.removePhotos()
            self.getImgsFromURLs()
            
            
            performUIUpdatesOnMain {
                //stop indicator after view appear
                print("&&&&&&& stop activity Indicator on Main in Searching")
                
                Helper.callAlert(stop: true, vc: self,activityIndicator: self.activityIndicator)
                self.collectionView?.reloadData()
                self.editButtonItem.isEnabled = true
            }
        }
        
        print("$$$$$$$$$ search button got completed,view is \(view) and self.view \(self.view)")

    }

    //MARK: - delete/emtpy stored Photos for selectedItem from context and PhotoArray
    func removePhotos() {
        
        for photo in photoArray {
            context.delete(photo)
        }
        photoArray.removeAll()
    }
    
    
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedItem.title
        //MARK: - set up indicator in ViewDidLoad
        print("&&&&&&& Start activity Indicator in ViewDidLoad")

        Helper.callAlert(stop: false, vc: self, activityIndicator: self.activityIndicator)
        print("$$$$$$$$ viewDidLoad got called.    $$$$$$$$$$$")
        
        //setup up search and edit buttons
        //        navigationItem.rightBarButtonItems = [editButtonItem,editButtonItem]
        let searchImage = UIImage(named: "search")!
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton))
        navigationItem.rightBarButtonItems = [searchButton, editButtonItem]
        
        
        // change the layout of the colleciton view
        let collectionViewWidth = collectionView?.frame.width
        let itemWidth = (collectionViewWidth! - Storyboard.leftAndRightPadding) / Storyboard.numberOfItemsPerRow
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        
        //MARK: Prepare data for collection view.
        // 1. fetch photos from context to photoArray to show stored Photos for the selected items
        fetchPhotos()
        
        // **fix** 2 and 3 can be ignored when photoArray is NO returned empty. Don't need to overwrite local stored photos unless by tapping search-button.
        if photoArray.count == 0 {
            
            // 2. get all URLs for this location(selectedItem)
            urlArray = PhotoLib.getPhotoURLs(lat: coordinate.latitude, lon: coordinate.longitude)
            
            // 3. filter & pick 24 random URLs to download images to photoArray which is data souce for collection view.
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                print("%%%% Dispath getImgsFromURLs() to global Queue")
                self.getImgsFromURLs()
                
                performUIUpdatesOnMain {
                    self.collectionView?.reloadData()
                    //stop indicator after view appear
                    print("##########   Stop Indicator ViewDidLoad")
                    Helper.callAlert(stop: true, vc: self, activityIndicator: self.activityIndicator)
                }
            }
        } else {Helper.callAlert(stop: true, vc: self, activityIndicator: self.activityIndicator)}
        
        print("!!!!! ViewDidLoad compelted, the coordinate of this Pin is \(coordinate.latitude) and \(coordinate.longitude) and the stored photos at this location is \(photoArray.count) and total URLs for this locaiton is \(urlArray.count)" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("$$$$$$$$   viewWillAppear got called  $$$$$$")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("!!!!! ViewDidAppear compelted, the coordinate of this Pin is \(coordinate.latitude) and \(coordinate.longitude) and the stored photos at this location is \(photoArray.count) and total URLs for this locaiton is \(urlArray.count)" )
    }
 

    // MARK: Collection View Data Source , UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("%%%%%%%%%%  numberOfItem got trigger %%%%%%%%%%%%%% ")

        return photoArray.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(data: self.photoArray[indexPath.row].image!)

//        cell.imageView.image = UIImage(named: "finn") //finn is local image

        
        print("%%%%%%%%%%  cellForItemAt got trigger %%%%%%%%%%%%%% ")

        return cell
        
    }

    
    
    //MARK: - Editing Mode setup , disable search button in Editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("#### setEditing was called")

        if editing == true {
            navigationItem.rightBarButtonItem?.isEnabled = false
            print("#### editing is true. setEditing was called")
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
    }
    
    //MARK: - Collection delegate method, delete photo in Editing mode. open photo in Not-Editing mode
    var selectedImage: UIImage!
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
        context.delete(photoArray[indexPath.row])
        photoArray.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        } else {
            selectedImage = UIImage(data: photoArray[indexPath.row].image!)
            performSegue(withIdentifier: "goToPhoto", sender: nil)
        }
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhoto" {
            
            let detailVC = segue.destination as! DetailViewController
            detailVC.image = selectedImage
        }
    }

    
    
    //MARK: - Model Manupulation Methods

    // Read data from store to photoArray,default is reading out All Items belonging to same Category selectedItem
    //MARK: Fetch Photos
    func fetchPhotos(with request:NSFetchRequest<Photo> = Photo.fetchRequest(), predicate:NSPredicate?=nil) {
        
        let pinPredicate = NSPredicate(format: "parentPin == %@", selectedItem!)
        
        
        //optional binding to handle nil at predicate
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pinPredicate,predicate])
        }
        else {
            request.predicate = pinPredicate
        }
        
        do {
            photoArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context :\(error)")
        }
        
        collectionView?.reloadData()
    }

    

//MARK:  fitler the URLs and call PhotoLib Class to download images.Then store to Context and photoArray
/*
1. if there No photos stored in Core Data for this pin, download UPTO 24 random photos from Flickr.
2. if there is Zero photo for this Pin from Flickr. Show Aler View to info user no photos are avabile.
3. if there is less than 24 photos avabile from Flickr. Then download all those photos.
*/

    func getImgsFromURLs() {
        print("&&&&&&& getImgsFromURLs got called")
        
        let urlArrayCount = urlArray.count
        
        if photoArray.count == 0 {
            print("!!!!!!no photos in Context for this Pin, so we can get Flickr photos ")
            
            if urlArrayCount == 0 {
                Helper.showMessage(title: "Flickr doesn't have photos for this location", message: "Pick another Location", view: self)
                print("@@@@@@@@@@  can't find any pictures at this Pin")
            } else {
                
                // set the max number of photos showing in the collecition view as 24
                let numberofShowingPhotos = urlArray.count<24 ? urlArray.count:24
                print ("@@@@@@@@@   Flickr has \(urlArray.count) pictures for this location")
                for index in 0 ..< numberofShowingPhotos {
                    let randomIndex = Int(arc4random()) % urlArrayCount
                    let randomURL = urlArray[randomIndex] // randomURL is PhotoURL Class type,contains iD/URL
                    //                    print("@@@@@@   randomURL at index:\(index) is \(randomURL)")
                    
                    // Locally store returned Online Image data to Photo entity
                    let newPhoto = Photo(context: self.context)
                    newPhoto.image = PhotoLib.getDataFromURL(urlString: randomURL.url_m)
                    newPhoto.id = randomURL.id
                    newPhoto.parentPin = self.selectedItem
                    
                    // Build photoArray for Collection View Data Source
                    self.photoArray.append(newPhoto)
                    self.filteredURLs.append(randomURL)
                }
            }
            
        } else {print("##### Found stored Photos for this location . NO need to download")}
        
    }
    
}


