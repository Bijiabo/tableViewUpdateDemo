//
//  MasterViewController.swift
//  tableViewUpdateDemo
//
//  Created by huchunbo on 2017/8/2.
//  Copyright © 2017年 huchunbo. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    let originalList: [String] = ["a", "b", "c", "d", "e", "f", "g"]
    let oldList: [String] = ["b", "c", "e", "g"]
    let newList: [String] = ["a", "b", "d", "f", "g"]
    
    var detailViewController: DetailViewController? = nil
    var objects = [String]()

    var isOldList: Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        // let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(toggleList(_:)))
        
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        objects = oldList
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    */
    func toggleList(_ sender: Any) {
        if isOldList {
            updateTableView(newList: newList, originalList: originalList, list: &objects)
        } else {
            updateTableView(newList: oldList, originalList: originalList, list: &objects)
        }
        
        isOldList = !isOldList
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // let object = objects[indexPath.row] as! NSDate
        let cellData = objects[indexPath.row]
        cell.textLabel!.text = cellData
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func updateTableView(newList: [String], originalList: [String], list: inout [String]) {
        var oldList = objects
        
        func indexInOriginalList(forItem item: String) -> Int? {
            return originalList.index(of: item)
        }
        
        var oldListIndexs: [Int] = [Int]()
        for (index,item) in oldList.enumerated() {
            if let indexInOriginalList = indexInOriginalList(forItem: item) {
                oldListIndexs.append(indexInOriginalList)
            }
        }
        
        var newListIndexs: [Int] = [Int]()
        for (index,item) in newList.enumerated() {
            if let indexInOriginalList = indexInOriginalList(forItem: item) {
                newListIndexs.append(indexInOriginalList)
            }
        }
        
        // here to update table view data source
        // objects = newList
        
        var needRemoveIndexs: [Int] = [Int]() //
        var oldListIndexsAfterRemove: [Int] = [Int]()
        for (index,item) in oldListIndexs.enumerated() {
            if !newListIndexs.contains(item) {
                needRemoveIndexs.append(index)
            } else {
                oldListIndexsAfterRemove.append(item)
            }
        }
        
        // here to remove rows
        tableView.beginUpdates()
        var indexPathArrayToRemove = [IndexPath]()
        for (_, item) in needRemoveIndexs.reversed().enumerated() {
            indexPathArrayToRemove.append(IndexPath(row: item, section: 0))
            list.remove(at: item)
        }
        tableView.deleteRows(at: indexPathArrayToRemove, with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
        
        // 计算需要插入的行
        var needAppendIndexs: [Int] = [Int]()
        for (index,item) in newListIndexs.enumerated() {
            if !oldListIndexsAfterRemove.contains(item) {
                needAppendIndexs.append(item)
            }
        }
        
        // here to insert rows
        
        tableView.beginUpdates()
        var indexPathArrayToInsert = [IndexPath]()
        var insertValues = [String]()
        for (index, item) in needAppendIndexs.enumerated() {
            indexPathArrayToInsert.append(IndexPath(row: newListIndexs.index(of: item)!, section: 0))
            list.insert(originalList[item], at: newListIndexs.index(of: item)!)
            // debug
            insertValues.append(originalList[item])
        }
        tableView.insertRows(at: indexPathArrayToInsert, with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }


}

