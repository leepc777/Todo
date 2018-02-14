//
//  AppDelegate.swift
//  Todo
//
//  Created by sam on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
//import RealmSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Add two Bar Buttons to reuse the same Navigation controller
        
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "NavController")
            vc.tabBarItem = UITabBarItem(title: "ToWhere", image: UIImage(named:"car") , tag: 1)
            tabBarController.viewControllers?.append(vc)
        }
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("***** save data to store when applicationWillTerminate ")

        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

