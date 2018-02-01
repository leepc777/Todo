//
//  ToDoListViewController.swift
//  Todo
//
//  Created by Patrick on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
class ToDoListViewController: UITableViewController {


    var itemArray = [Item]()
    
//    let defaults = UserDefaults.standard
    
    //MARK : global variables

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("&&& where is our data",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        
        loadItems()
    }

    // MARK: - Table view DataSource methods

    
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
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK : TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //any updates to properties of elements in itemArray will pass to context. done&title are the properties for Item entity
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        itemArray[indexPath.row].setValue("completed", forKey: "title")
        
    //MARK - delete items.order matters.remove item in context before that item got removed from itemArray
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        
        saveItems() // persist data and reload viewTable
        // refresh table to fix that bug
        print("&& didSelectRowAt got called and itemArray[indexPath.row].done is ",itemArray[indexPath.row].done, indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    

    //MARK - Add New Items
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var texField = UITextField()
        let alert = UIAlertController(title: "Add New ToDo Items", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            texField = alertTextField // pass local textField to outside this closure
        }
        
        //MARK Action for UIAlert,what will ahppen once user clicks the Add Item

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context) //instance a NSmanagedObject,a class
            newItem.title = texField.text!
            newItem.done = false //default is not done.
            self.itemArray.append(newItem)
//            self.tableView.reloadData() //saveItems() includes reloadData()
            self.saveItems() //save changes in context to Persistant Store
        }

        alert.addAction(action) // this will add action button in alert view
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manupulation Methods
    
    // this will commit unsaved changes in context to store
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("$$$ Error saving context,\(error)")
        }
        
        self.tableView.reloadData()
    }
   
    func loadItems() {
        // Item.fetchRequest() was auto created by Swift, it return a NSFetchRequest<Item>, and we need to specify that type when passing it to the constant
        let reqeust : NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(reqeust)
        } catch {
            print("Error fetching data from context :\(error)")
        }
    }
}
