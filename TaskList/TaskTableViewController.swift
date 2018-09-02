 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //
 
import UIKit
import CoreData

extension UIColor {

    class func color(withData data:Data) -> UIColor {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIColor
    }

    func encode() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
 }

 protocol SettingsTableViewControllerDelegate: class {
    func setHowShouldBeTasksSorted(indexHowToSort: Int)
    func saveNewCategory(newCategory: Category)
    func updateCategoryInExistingTasks(categoryToDelete: Category, newCategory: Category)

 }

 protocol AddManageTaskViewControllerDelegate: class {
    func addNewTasksToActive(newTask: Task)
    func modifyExistingTask(fromIndexPath: IndexPath, newTask: Task)
    func removeTask(fromIndexPath: IndexPath)

 }

class TaskTableTableViewController: UITableViewController {

    var categoryDic = [String : Category?]()
    var myTasks = [[Task](),[Task()]]
    var sortBy = 0

    private let cellID = "cellID"

    private let addManageTaskViewController = ModCreatetaskViewController()
    private let settingsTableViewController = SettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryDic = Category.loadCategoryFromCoreData()
        if categoryDic.count == 0 {
            saveDefaultCategoryAndTasks()
        }

        myTasks = Task.loadTaskFromCoreData(categoryDictionary: categoryDic)
        sortTasks()
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpNavigationBar()
        sortTasks()
        tableView.reloadData()

    }
  
    public func appendTaskAndSort(section: Int, task: Task) {
        myTasks[section].append(task)
        sortTasks()
    }
    
     
    public func sortTasks()  {
        if sortBy == 0 {
            myTasks[0] = myTasks[0].sorted(by: { $0.taskTitle.lowercased() < $1.taskTitle.lowercased() })
            myTasks[1] = myTasks[1].sorted(by: { $0.taskTitle.lowercased() < $1.taskTitle.lowercased() })
        } else {
            myTasks[0] = myTasks[0].sorted { (item1, item2) -> Bool in
                let t1 = item1.dateToComplete ?? Date(timeIntervalSince1970: 0)
                let t2 = item2.dateToComplete ?? Date(timeIntervalSince1970: 0)
                return t1 < t2
            }
            myTasks[1] = myTasks[1].sorted { (item1, item2) -> Bool in
                let t1 = item1.dateToComplete ?? Date(timeIntervalSince1970: 0)
                let t2 = item2.dateToComplete ?? Date(timeIntervalSince1970: 0)
                return t1 < t2
            }
        }
    }
    
     
    func saveDefaultCategoryAndTasks() {
        var category = Category(nameOfCategory: "Work", ColorOfCategory: .red)
        category.saveCategoryToCoreData()
        categoryDic.updateValue(category, forKey: category.name)
        
        category = Category(nameOfCategory: "Private", ColorOfCategory: .yellow)
        category.saveCategoryToCoreData()
        categoryDic.updateValue(category, forKey: category.name)
        
        category = Category(nameOfCategory: "Hobby", ColorOfCategory: .blue)
        category.saveCategoryToCoreData()
        categoryDic.updateValue(category, forKey: category.name)
        
        category = Category(nameOfCategory: "Family", ColorOfCategory: .green)
        category.saveCategoryToCoreData()
        categoryDic.updateValue(category, forKey: category.name)
        
        let task = Task(taskTitle: "my dummy task", dateWhenShouldDone: nil, category: categoryDic["Work"]!, isItDone: false)
        task.saveTaskToCoreData()
        myTasks[0].append(task)
        sortTasks()
        
    }

    private func setUpNavigationBar() {
        let buttonSettings = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_ic_settings"), style: .plain, target: self, action: #selector(handleActionNavigationButton))
        buttonSettings.tag = 0
        let buttonAddTask = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_ic_add"), style: .plain, target: self, action: #selector(handleActionNavigationButton))
        buttonAddTask.tag = 1
        self.navigationItem.setRightBarButtonItems([buttonAddTask, buttonSettings], animated: false)
        self.title = "Task List"
    }

    @objc private func handleActionNavigationButton(sender: UIButton)  {
        
        var temporaryCategoryArray = [Category]()
        for categoryDictionary in categoryDic {
            if let category = categoryDictionary.value {
            temporaryCategoryArray.append(category)
            }
        }
        if sender.tag == 0 {
            settingsTableViewController.arrayOfCategory = temporaryCategoryArray
            settingsTableViewController.delegate = self
            navigationController?.pushViewController(settingsTableViewController, animated: true)
            
        } else {
            addManageTaskViewController.modifyTask = nil
            addManageTaskViewController.categoryArray = temporaryCategoryArray
            addManageTaskViewController.delegate = self
            navigationController?.pushViewController(addManageTaskViewController, animated: true)
        }
    }
}

extension TaskTableTableViewController: SettingsTableViewControllerDelegate, AddManageTaskViewControllerDelegate {
    func setHowShouldBeTasksSorted(indexHowToSort: Int) {
        sortBy = indexHowToSort
    }
    
     
    func saveNewCategory(newCategory: Category) {
        newCategory.saveCategoryToCoreData()
        categoryDic.updateValue(newCategory, forKey: newCategory.name)
    }
    
     
    func updateCategoryInExistingTasks(categoryToDelete: Category, newCategory: Category) {
        categoryToDelete.modifyCategory(newCategory: newCategory)

         
         
        for rightArray in myTasks {
            for task in rightArray {
                let task = task
                if task.category?.name == categoryToDelete.name {
                    task.category = newCategory
                    task.modifyTask(newTask: task)
                }
            }
        }
         
        categoryDic = Category.loadCategoryFromCoreData()
        myTasks = Task.loadTaskFromCoreData(categoryDictionary: categoryDic)
    }
    
    func addNewTasksToActive(newTask: Task) {
        myTasks[0].append(newTask)
    }
    
    func modifyExistingTask(fromIndexPath: IndexPath, newTask: Task) {
        myTasks[fromIndexPath.section][fromIndexPath.row] = newTask
    }
    
    func removeTask(fromIndexPath: IndexPath) {
        myTasks[fromIndexPath.section].remove(at: fromIndexPath.row)
    }
    
    
}



 
extension TaskTableTableViewController {
    
     
    override internal func numberOfSections(in tableView: UITableView) -> Int {
        return  myTasks.count
    }
    
    override internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTasks[section].count
    }
    
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         
        addManageTaskViewController.modifyTask = nil
        var temporaryCategoryArray = [Category]()
        for categoryDictionary in categoryDic {
            if let category = categoryDictionary.value {
                temporaryCategoryArray.append(category)
            }
        }
        addManageTaskViewController.indexPathOfmodifyTask = indexPath
        addManageTaskViewController.modifyTask = myTasks[indexPath.section][indexPath.row]
        addManageTaskViewController.categoryArray = temporaryCategoryArray
        addManageTaskViewController.delegate = self
        navigationController?.pushViewController(addManageTaskViewController, animated: true)
        
    }
    
     
    override internal func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
     
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
            if indexPath.section == 0 {
                self.myTasks[0][indexPath.row].isItDone = true
                self.myTasks[0][indexPath.row].modifyTask(newTask: self.myTasks[0][indexPath.row])
                self.appendTaskAndSort(section: 1, task: self.myTasks[0][indexPath.row])
                self.myTasks[0].remove(at: indexPath.row)
            } else  {
                self.myTasks[1][indexPath.row].isItDone = false
                self.myTasks[1][indexPath.row].modifyTask(newTask: self.self.myTasks[1][indexPath.row])
                self.appendTaskAndSort(section: 0, task: self.myTasks[1][indexPath.row])
                self.myTasks[1].remove(at: indexPath.row)
            }
            self.sortTasks()
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = .green
        return action
    }
    
     
    override internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
     
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.myTasks[indexPath.section][indexPath.row].deleteTaskCoreData()
            self.myTasks[indexPath.section].remove(at: indexPath.row)
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = .red
        return action
    }
    

    
    override internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TaskTableViewCell
        cell.setCell(taskToShow: myTasks[indexPath.section][indexPath.row])
        return cell
    }
    
    
}
