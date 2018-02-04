//
//  CategoryViewController.swift
//  Todo
//
//  Created by Patrick on 2/3/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
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
