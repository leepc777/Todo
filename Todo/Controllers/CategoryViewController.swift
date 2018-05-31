//
//  CategoryViewController.swift
//  Todo
//
//  Created by Patrick on 2/3/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

//import SwipeCellKit

class CategoryViewController: SwipeTableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var isDriving : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        switch navigationController?.tabBarItem.tag {
        case 1? :
            isDriving = true
        default :
            isDriving = false
        }

    }
    
    //MARK: write unsaved changes in context to store before leaving CategoryVC.
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.barTintColor = FlatSkyBlue()
        navigationController?.navigationBar.tintColor = ContrastColorOf(FlatSkyBlue(), returnFlat: true)
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(FlatSkyBlue(), returnFlat: true)]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(FlatSkyBlue(), returnFlat: true)]
        
        print("&&& CategoryVC viewWillAppear,the current TabBar tag is \(navigationController?.tabBarItem.tag)")
        loadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        saveData() //actually AppDelegate will do the saving but we want it save to store when switching between ToDo and Driving mode.
        print(" $$$  Category VC will Disappear")
    }

    //MARK: - Add New Categories
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.keyboardType = UIKeyboardType.alphabet
            alertTextField.autocorrectionType = UITextAutocorrectionType.yes
            alertTextField.placeholder = " Create new Category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat.hexValue()

            self.categoryArray.append(newCategory)
            self.saveData() // store new Category to store and reload TableView
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("&&&& current category array is :\(categoryArray)")
    }
    
    
    //MARK: UnDo deletion
    // current deletion will remove managedobject from context and array. So there is no way I can put it back to context and array unless we create an array to save the deleted items. Or unless we can read out the store to overwrite context and array.
    
    @IBAction func undoDele(_ sender: Any) {
        context.rollback()
        loadData()
        print("*****  trigger context.rollback()")
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name ?? "no Category name added yet"
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color ?? "A9B9FA")
//        cell.backgroundColor = FlatOrange()
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Prepare for Segue , pass Selected Cateory object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! ToDoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow
            else {
                print("error no indexPath")
                return
                
        }
        nextVC.selectedCategory = categoryArray[indexPath.row]
        nextVC.isDriving = isDriving
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveData() {
        do {
        try context.save()
        } catch {
            print("$$$ Error saving context,\(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(with request:NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context :\(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Delete Data by Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(self.categoryArray[indexPath.row])
        self.categoryArray.remove(at: indexPath.row)
        print("&&&&&& current VC is \(self) doing updateModel overrided in CategoryVC")

    }
    
    //MARK: - mark cell
    override func markCell(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        print("&&&&&& current VC is \(self) doing markCell overrided in CategoryVC")

    }
    
}

/*
//MARK: - Swipe Cell Delegate methods
extension CategoryViewController:SwipeTableViewCellDelegate {
    
    //swipe and click icon to delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
//            self.saveData() // move this viewWillDisappear, it will fail after adding extention destrutive style
//            self.loadData() //not need it because editActionsOptionsForRowAt refresh table
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "DeleteIcon")
        
        return [deleteAction]
    }
    
    // to swipe to left to delete without confirmation.
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}

 */
