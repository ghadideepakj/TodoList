//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Veekay Infotech on 05/06/22.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

@available(iOS 13.0, *)
class CategoryViewController:UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
//    var categoryArray = [Category]()
    
    //Core data
    var categoryArray = [CategoryTable]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var categoriesTableView: UITableView!
    
    
    let categoryFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Category.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(categoryFilePath ?? "")
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.separatorStyle = .none
        
        loadCategories()
        
    }
    
    //MARK:- Table datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        let category1 = categoryArray[indexPath.row]
        cell.textLabel?.text = category1.name
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: UIColor(hexString: category1.color) , returnFlat: true)
        cell.backgroundColor = UIColor(hexString: category1.color)
        cell.delegate = self
        return cell
    }
    
    //MARK:- Table view Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        categoriesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //Segues methods:-
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        if let indexpath = categoriesTableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexpath.row]
        }
        
    }
    

    //MARK:- Data Manupulation methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var addCategoryTextFiled = UITextField()
        
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = CategoryTable(context: self.context)
            newCategory.name = addCategoryTextFiled.text ?? ""
            newCategory.color = UIColor.randomFlat()?.hexValue()
            self.categoryArray.append(newCategory)
            
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Insert new Category"
            addCategoryTextFiled = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func save(category: CategoryTable? = nil){
        
        do{
        try context.save()
        }catch{
            print("Error saving Category:\(error)")
        }
        categoriesTableView.reloadData()
    }
    
    func loadCategories (with request: NSFetchRequest<CategoryTable> = CategoryTable.fetchRequest()){

        do{
        categoryArray = try context.fetch(request)
        }catch{
            print("Error fetching Category list: \(error)")
        }
        categoriesTableView.reloadData()
    }
    
}

@available(iOS 13.0, *)
extension CategoryViewController: SwipeTableViewCellDelegate{

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            if self.categoryArray.count > 0{
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete_icon")

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

}
