//
//  ToDoListViewController.swift
//  Todo
//
//  Created by Patrick on 1/24/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
class ToDoListViewController: SwipeTableViewController {
    @IBOutlet weak var itemSearchBar: UISearchBar!
    
/*
 after set selectedCategory in prepare for segue in CategoryVC, load all Items which has the same Category in context to itemArray and reload ViewTable. We can also do it in ViewDidLoad
*/
    var isDriving : Bool? {
        didSet {
            print("@@@@@@@@@@@@  Driving Mode ? \(isDriving) $$$$$$$$$$$ ")
        }
    }

    var itemArray = [Item]()
    var selectedCategory : Category? {
        
        didSet{
            loadItems()
        }
        
    }
    
    
    //MARK : global variables

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("&&&&&&& the current Tab in Item list is \(navigationController?.tabBarItem.tag) \(tabBarItem.tag)")

        itemSearchBar.delegate = self
        
        //this will carash because navigationController is not avaiable when viewDIdLoad
        
//        if let colorOfCategory = UIColor(hexString:(selectedCategory?.color)!) {
//
//            title = selectedCategory!.name
//
//            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller doesn't exist")}
//
//            navBar.barTintColor = colorOfCategory
//            navBar.tintColor = colorOfCategory
//            searchBar.barTintColor = colorOfCategory
//
//        }

        
        print("&&& where is our data",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }

    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorOfCategory = UIColor(hexString:(selectedCategory?.color)!) else {fatalError("colorOfCategory is NIL")}
//            let colorOfCategory = FlatSkyBlue()
            title = selectedCategory!.name
            navColor(with: colorOfCategory)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        print("***** save data to store when viewWillDisappear in ToDolist")
        //        saveItems() // ok to save it whenever VC close, but AppDelegate will save the unsaved changes in context to store before App closing. So this step is not necessary.
        
//        navColor(with: FlatSkyBlue())
    }
    

    
    //MARK: - setup color for Navigation Bar
    func navColor(with colorOfCategory:UIColor) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller doesn't exist")}
        
        navBar.barTintColor = colorOfCategory
        navBar.tintColor = ContrastColorOf(colorOfCategory, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(colorOfCategory, returnFlat: true)]
        searchBar.barTintColor = colorOfCategory

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
        let colorOfCategory = UIColor(hexString: (selectedCategory?.color)!)
//        cell.backgroundColor = FlatSkyBlue().darken(byPercentage:
        cell.backgroundColor = colorOfCategory?.darken(byPercentage:
        CGFloat(indexPath.row)/CGFloat(itemArray.count)/CGFloat(4))
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
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
        
        //setup alerView
        let alert = UIAlertController(title: "Add New ToDo Items", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            alertTextField.keyboardType = UIKeyboardType.alphabet
            alertTextField.autocorrectionType = UITextAutocorrectionType.yes

            textField = alertTextField
        }
        
        //MARK Action for UIAlert,what will ahppen once user clicks Add Item

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context) //instance a NSmanagedObject,a class
            
            newItem.parentCategory = self.selectedCategory
            newItem.title = textField.text!
            newItem.done = false //default is not done.
            
            self.itemArray.append(newItem)
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
   
    
    // Read data from store to itemArray,default inputs is reading out All Items belonging to same selectedCategory
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate?=nil) {
        
        //  item has parentCategory property which is a Cateory Type
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
        
        let categoryPredicate = NSPredicate(format: "parentCategory == %@", selectedCategory!)

        
        
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

        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            loadItems()
        }

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
        else {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),NSSortDescriptor(key: "done", ascending: true)]
            print("!!! searchBarSearchButtonClicked got call and request is \(request)")
            
            loadItems(with: request, predicate:predicate)
            
        }
        
    }
}
