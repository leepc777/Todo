//
//  ToDoListViewController.swift
//  Todo
//
//  Created by Patrick on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
class ToDoListViewController: SwipeTableViewController {
    @IBOutlet weak var itemSearchBar: UISearchBar!
    
/*
 after set selectedCategory in prepare for segue in CategoryVC, load all Items from context to itemArray and reload ViewTable. this insure we only fetch after getting new data.we ogriginal did it in ViewDidLoad
*/
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        
        didSet{
            loadItems()
        }
    }
    
//    let defaults = UserDefaults.standard
    
    //MARK : global variables

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemSearchBar.delegate = self
        print("&&& where is our data",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

//        tableView.rowHeight = 80.0
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
//        print("***** save data to store when viewWillDisappear in ToDolist")
//        saveItems() // ok to save it whenever VC close, but AppDelegate will save the unsaved changes in context to store before App closing. So this step is not necessary.
    }
    
    // MARK: - Table view DataSource methods

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("$$$ ToDoList numberOfRows got called")

        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        print("$$$ ToDoList cellForRowAtIndexPath got called at the indexPath :",indexPath.row,itemArray[indexPath.row].done )
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell...
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK : TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //MARK: update TableView. any updates to properties of elements in itemArray will pass to context. done&title are the properties for Item entity
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        
        saveItems() // persist data and reload viewTable
        // refresh table to fix that bug
        print("&& didSelectRowAt in \(self)got called and itemArray[indexPath.row].done is ",itemArray[indexPath.row].done, indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    

    //MARK: - Add New Items throught Alert View
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDo Items", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //MARK Action for UIAlert,what will ahppen once user clicks the Add Item

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context) //instance a NSmanagedObject,a class
            newItem.parentCategory = self.selectedCategory
            newItem.title = textField.text!
            newItem.done = false //default is not done.
            self.itemArray.append(newItem)
//            self.tableView.reloadData() //saveItems() includes reloadData()
            self.saveItems() //save changes in context to Persistant Store
        }

        alert.addAction(action) // this will add action button in alert view
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Undo ( context.rollback() )
    
    @IBAction func undoDele(_ sender: Any) {
        context.rollback()
        loadItems()
    }
    
    //MARK: - Model Manupulation Methods
    
    //write unsaved changes from context to store
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("$$$ Error saving context,\(error)")
        }
        
        self.tableView.reloadData()
    }
   
    
    // Read data from store to itemArray,default inputs is reading out All Item type
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate?=nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
        
        
        //optional binding to handle nil at predicate
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,predicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context :\(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Delete Data by Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        print("current VC is \(self) doing updateModel overrided in ToDoListVC")
        self.context.delete(self.itemArray[indexPath.row])
        self.itemArray.remove(at: indexPath.row)
        
    }

    
}

//MARK: - Seach Bar and filter FetchRequest
extension ToDoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),NSSortDescriptor(key: "done", ascending: true)]
        print("!!! searchBarSearchButtonClicked got call and request is \(request)")

        loadItems(with: request, predicate:predicate)
    
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            loadItems()
        }


//        tableView.reloadData() //moved to loadItems()
//        print("%%% search text is :\(searchBar.text)")
        
    }
 

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("@@@ serachBar textDidChange func got call and text is\(searchBar.text)")
        if searchBar.text?.count == 0 {
//        if searchBar.text == "" {

            loadItems() //restore to the original table vew
            
            DispatchQueue.main.async { //
               searchBar.resignFirstResponder()
            }
            



        }
//        else {
//            let request : NSFetchRequest<Item> = Item.fetchRequest()
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),NSSortDescriptor(key: "done", ascending: true)]
//            loadItems(with: request)
//
//        }
    }
}
