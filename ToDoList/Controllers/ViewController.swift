//
//  ViewController.swift
//  ToDoList
//
//  Created by Veekay Infotech on 26/05/22.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

@available(iOS 13.0, *)
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var itemsArray = [Items]()
    
    var selectedCategory : CategoryTable?{
        didSet{
            loadItems()
        }
    }
    
    //User Defaults can't save custome Data
    //var userDefaults1 = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var listTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listTableview.delegate = self
        listTableview.dataSource = self
        
        listTableview.separatorStyle = .none
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let hexColor = UIColor(hexString: selectedCategory?.color)
        navigationController?.navigationBar.backgroundColor = hexColor
        searchBar.tintColor = hexColor
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor:  hexColor!, returnFlat: true)]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = listTableview.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath) as! SwipeTableViewCell
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        if let color = UIColor(hexString: selectedCategory?.color)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row) / CGFloat(itemsArray.count))){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
        }
        
        cell.accessoryType = item.done ? .checkmark : .none
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //To update entries in Database
        //itemsArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //To delete record in Database         (Order of statements also matter)
        //context.delete(itemsArray[indexPath.row])
        //itemsArray.remove(at: indexPath.row)
        
        
        //itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        saveItems()
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        listTableview.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        
        var addItemTextfiled = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "Message", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Items(context: self.context)
            newItem.title = addItemTextfiled.text ?? ""
            newItem.done = false
            //newItem.color = UIColor.randomFlat()?.hexValue()
            newItem.parentCategory = self.selectedCategory
            self.itemsArray.append(newItem)

            self.saveItems()
            
            //User Defaults can't save custome Data
            //self.userDefaults1.set(self.itemsArray, forKey: "ToDoListItems")
            
        }
        alert.addTextField { (alertTextfiled) in
            alertTextfiled.placeholder = "Create new item"
            addItemTextfiled = alertTextfiled
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Manupulation methods
    
    func saveItems() {

        do{
            try context.save()
        }catch{
            print("Data saving error: \(error)")
        }
        listTableview.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest(), predicate : NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do{
            itemsArray = try context.fetch(request)
        }catch{
            print("Error fetching data: \(error)")
        }
        if let listTableview = listTableview{
            listTableview.reloadData()
        }

    }
}

//MARK:- Seach bar methods
@available(iOS 13.0, *)
extension ViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Items> = Items.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)

    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

@available(iOS 13.0, *)
extension ViewController: SwipeTableViewCellDelegate{

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            if self.itemsArray.count > 0{
            self.context.delete(self.itemsArray[indexPath.row])
            self.itemsArray.remove(at: indexPath.row)
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
