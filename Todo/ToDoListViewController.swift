//
//  ToDoListViewController.swift
//  Todo
//
//  Created by Patrick on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        itemArray = defaults.array(forKey: "ToDoListArray") as! [String]
        if let itemArray = defaults.array(forKey: "ToDoListArray") as? [String] {
        self.itemArray = itemArray
        }
    }

    var itemArray = ["Find Mike","Buy Eggos","Destory fire Demogorgon"]

    let defaults = UserDefaults.standard
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print (itemArray[indexPath.row])
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {

        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK - Add New Items through Alert View
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var texField = UITextField()
        let alert = UIAlertController(title: "Add New ToDo Items", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
//            print(alertTextField.text)
//            print("trigger alert.addTextField")
            texField = alertTextField // pass local textField to outside this closure
        }
        
        //MARK Action for AlerView
        //use completionHanddler to include codes will be executed after clicking the action button
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //action after tapping the Add button
            print("trigger aler action after tapping action button \(texField.text)")
            
            /* textField.text actually would't never = nil. The default would be "" if user didn't put in any. So we can safely force unwrp. We can add more checking code to prevent the action from going forwards
             
             nil coalescing operator
             An operator (??) placed between two values, a ?? b, that unwraps an optional a if it contains a value, or returns a default value b if a is nil. ( if a is nil, then default value is b)
             
         */
            self.itemArray.append(texField.text!)
//            self.itemArray.append(texField.text ?? "Default Value")
            self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
//            print(self.itemArray)
            self.tableView.reloadData()
        }

        alert.addAction(action) // this will add action button in alert view
        present(alert, animated: true, completion: nil)
    }
    
   
}
