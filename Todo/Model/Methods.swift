//
//  Methods.swift
//  Todo
//  Store reusable methods
//
//  Created by Patrick on 2/23/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

class Helper {
    
    //Mark: - SHow message through Alert
    static func showMessage(title:String,message:String,view:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        //Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func callAlert(stop:Bool,vc:UIViewController,activityIndicator:UIActivityIndicatorView) {
        
        //MARK: - set up indicator
        activityIndicator.center = vc.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray

        if stop {
            
            //stop indicator after view appear
            print("&&&&&&& stop activity Indicator in callAlert()")
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

        } else {
            print("&&&&&&& Start activity Indicator in callAlert()")
            vc.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()

        }
    }

}
