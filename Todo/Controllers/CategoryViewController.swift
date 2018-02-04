//
//  CategoryViewController.swift
//  Todo
//
//  Created by Patrick on 2/3/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.rowHeight = 80.0

    }
    
    //MARK: write unsaved changes in context to store before leaving CategoryVC.
    override func viewWillDisappear(_ animated: Bool) {
        saveData()
    }

    //MARK: - Add New Categories
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = " Create new Category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            self.categoryArray.append(newCategory)
            self.saveData() // store new Category to store and reload TableView
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("&&&& current category array is :\(categoryArray)")
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.delegate = self
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! ToDoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow
            else {
                print("error no indexPath")
                return
                
        }
        nextVC.selectedCategory = categoryArray[indexPath.row]
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
    
}

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

