//
//  ToDoListViewController.swift
//  Todo
//
//  Created by Patrick on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

//    var itemArray = ["Find Mike","Buy Eggos","Destory fire Demogorgon"]

    // change from array of string to array of an object
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newItem0 = Item()
        newItem0.title = "Find Mike"
        itemArray.append(newItem0)

        var newItem1 = Item()
        newItem1.title = "Buy Eggos"
        itemArray.append(newItem1)

        var newItem2 = Item()
        newItem2.title = "Destory fire Demogorgon"
        itemArray.append(newItem2)
//
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem2)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)
//        itemArray.append(newItem1)

        
//        itemArray = defaults.array(forKey: "ToDoListArray") as! [String]
//        if let itemArray = defaults.array(forKey: "ToDoListArray") as? [String] {
//        if let itemArray = defaults.object(forKey: "ToDoListArray") as? [String] {

        if let itemArray = defaults.array(forKey: "ToDoListArray") as? [Item] {

        self.itemArray = itemArray
        }
    }

    // MARK: - Table view DataSource methods

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("$$$ numberOfRows got called")

        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)

        print("$$$ cellForRowAtIndexPath got called at the indexPath :",indexPath.row,itemArray[indexPath.row].done )
        // Configure the cell...
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        
        //showing checkmark of the cell based on the "done" property of itemArray's element . here uses ternary operator
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK : TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK: Toggle check-mark of the row when user tapping that row. Also store that information backto arrayItem .
        
        //toggle and update the .done property of the coresponding itemArray.row when tapping the row
//        itemArray[indexPath.row].done = itemArray[indexPath.row].done ? false : true
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done 

        
        //MARK : how to show check-mark when user tapping the row ?
        //toggle checkmark of the specific row that the user taps
//        tableView.cellForRow(at: indexPath)?.accessoryType = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark ? .none : .checkmark

        // refresh table to fix that bug
        print("&& didSelectRowAt got called and itemArray[indexPath.row].done is ",itemArray[indexPath.row].done, indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()

    }
    

    //MARK - Alert View : Add New Items through Alert View
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
//            print("trigger aler action after tapping action button \(texField.text)")
            
            /* textField.text actually would't never = nil. The default would be "" if user didn't put in any. So we can safely force unwrp. We can add more checking code to prevent the action from going forwards
             
             nil coalescing operator
             An operator (??) placed between two values, a ?? b, that unwraps an optional a if it contains a value, or returns a default value b if a is nil. ( if a is nil, then default value is b)
             
         */

//            self.itemArray.append(texField.text!)
//            self.itemArray.append(texField.text ?? "Default Value")
            
            var newItem = Item()
            newItem.title = texField.text!
            self.itemArray.append(newItem)
            //store new item to userDefaults, both setValue() and set() work.
//            self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        

//            print(self.itemArray)
            self.tableView.reloadData()
        }

        alert.addAction(action) // this will add action button in alert view
        present(alert, animated: true, completion: nil)
    }
    
   
}
