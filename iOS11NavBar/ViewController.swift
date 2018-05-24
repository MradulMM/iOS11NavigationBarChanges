//
//  ViewController.swift
//  iOS11NavBar
//
//  Created by Mradul Mathur on 08/04/18.
//  Copyright © 2018 Mradul Mathur. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {
    
    let plistPathInBundle = Bundle.main.path(forResource: "FoodItemList", ofType: "plist") as String!
    var foodItems: [FoodItemsModel] = []
    var filteredFoodItems: [FoodItemsModel] = []
    let searchController = UISearchController(searchResultsController: nil)

    func getDataPlist() {
        // Extract the content of the file as NSData
        let data:Data =  FileManager.default.contents(atPath: plistPathInBundle!)! as Data
        do {
            let plistData = try (PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as! NSMutableArray as! [[String: AnyObject]]).toJSONString().data(using: .utf8)!
            foodItems = try JSONDecoder().decode([FoodItemsModel].self, from: plistData)
        } catch {
            print("Error occured while reading from the plist file")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataPlist()
        // Below code snippet add deafult search controller with navigation bar.....
        
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Food Items"
        definesPresentationContext = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFoodItems.count
        }
        return foodItems.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "foodItemsCell", for: indexPath)
        let foodItemModel: FoodItemsModel
        if isFiltering() {
            foodItemModel = filteredFoodItems[indexPath.row]
        } else {
            foodItemModel = foodItems[indexPath.row]
        }
        cell.textLabel?.text = foodItemModel.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fsrDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "foodDetailVC") as! FoodDetialController
        self.navigationController?.pushViewController(fsrDetailVC, animated: true)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredFoodItems = foodItems.filter({( foodItem : FoodItemsModel) -> Bool in
            return (foodItem.title?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension Collection where Iterator.Element == [String:AnyObject] {
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:AnyObject]],
            let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
            let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
}


