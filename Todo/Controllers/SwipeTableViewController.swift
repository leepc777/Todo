//
//  SwipeTableViewController.swift
//  Todo
//
//  Created by Patrick on 2/4/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0

    }

    //MARK:  TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("### SwipeVC, Current VC is \(self) to return the SwipeTableCell")

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell

    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("### SwipeVC current VC is \(self) to run editActionsForRowAt ")
            
            self.updateModel(at: indexPath)
                        
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "DeleteIcon")
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        print("### SwipeVC \(self) to delete with extension destrutive")

        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath:IndexPath) {
        //UPdate our data model
        print("### SwipeVC \(self) to update data model")
    }

}


