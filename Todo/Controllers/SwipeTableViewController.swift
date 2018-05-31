//
//  SwipeTableViewController.swift
//  Todo
//
//  Created by Patrick on 2/4/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none

    }

    //MARK:  TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("### SwipeVC, Current VC is \(self) to return the SwipeTableCell at indexPath:\(indexPath)")

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell

    }
    
    //MARK: editActionForRowAt from Chemleon framework to add multiple actions user can take when swipe
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("### SwipeVC current VC is \(self) to run editActionsForRowAt , action is \(action)")
            
            self.updateModel(at: indexPath)
                        
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "DeleteIcon")
        
        let markAction = SwipeAction(style: .default, title: "Marked") { (action, indexPath) in
            print("%%% SwipeVC, current VC is \(self) running editActionsForRowAt from Chemeleon at indexPath:\(indexPath),action is \(action)")
            self.markCell(at: indexPath)
        
        }
        
        markAction.image = UIImage(named:"check")
        markAction.backgroundColor = FlatBlue()
        return [deleteAction,markAction]
    }
    
    
    // To return a SwipeTableOption to configure the actions created.
    // when sliding the cell to left, delegate will run this function editActionsOptionsForRowAt
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        print("### SwipeVC \(self) run editActinOptionsForRowAt at indexPath:\(indexPath)")

        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath:IndexPath) {
        //UPdate our data model
        print("### SwipeVC \(self) to update data model")
    }

    func markCell(at indexPath:IndexPath) {
        // toggle mark for cell
        print("*** SwipeVC \(self) to mark the cell")
    }
}


