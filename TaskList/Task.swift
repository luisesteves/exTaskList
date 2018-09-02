 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //

import UIKit
import CoreData


class Task {
    var taskTitle: String!
    var dateToComplete: Date?
    var category: Category?
    var isItDone: Bool!
    
    init() {
        self.taskTitle = ""
        self.dateToComplete = nil
        self.category = nil
        self.isItDone = false
    }
    
    init(taskTitle: String, dateWhenShouldDone: Date?, category: Category?, isItDone: Bool!) {
        self.taskTitle = taskTitle
        self.dateToComplete = dateWhenShouldDone
        self.category = category
        self.isItDone = isItDone
    }
    
    class func loadTaskFromCoreData(categoryDictionary: [String : Category?]) -> [[Task]] {
        
        var listOfTasks = [[Task](),[Task]()]

        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    var temporaryTaskTitle = ""
                    var temporaryIsItDone = false
                    var temporaryDate: Date?
                    var temporaryCategory: Category?
                    
                    if let title = result.value(forKey: "taskTitle") as? String {
                        temporaryTaskTitle = title
                    }
                    if let isItDone = result.value(forKey: "isItDone") as? Bool {
                        temporaryIsItDone = isItDone
                    }
                    if let dateString = result.value(forKey: "dateString") as? String {
                        temporaryDate = Task.dateShouldBeDoneFromString(dateString: dateString)
                    }
                    if let categoryName = result.value(forKey: "categoryName") as? String {
                        temporaryCategory = categoryDictionary[categoryName] ?? nil 
                    }
                    let task = Task(taskTitle: temporaryTaskTitle, dateWhenShouldDone: temporaryDate, category: temporaryCategory, isItDone: temporaryIsItDone)
                    if task.isItDone == false {
                        listOfTasks[0].append(task)
                    } else {
                        listOfTasks[1].append(task)
                    }
                }
                
            } else {

            }
        } catch  {

        }
    return listOfTasks
    }
    
    static func dateShouldBeDoneToString(date: Date?) -> String {
        if let tempDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
            return dateFormatter.string(from: tempDate)
        } else {
            return ""
        }
    }
    
    
    class func dateShouldBeDoneFromString(dateString: String?) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        if let tempDateString = dateString {
            if let date = dateFormatter.date(from: tempDateString) {
                return date
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
    
     
    func isExist() -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch  {

        }
        return false
    }
    
     
    func deleteTaskCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false

            request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "taskTitle") as? String) != nil {
                        context.delete(result)
                    }
                    do {
                        try context.save()
                        
                    }
                    catch {

                    }
                }
            } else {

            }
        } catch  {

        }
    }
    
    
     
    func modifyTask(newTask: Task) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)

        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                
                let result = results[0] as! NSManagedObject
                    result.setValue(newTask.isItDone, forKey: "isItDone")
                    result.setValue(newTask.taskTitle, forKey: "taskTitle")
                    result.setValue(Task.dateShouldBeDoneToString(date: newTask.dateToComplete), forKey: "dateString")
                    result.setValue(newTask.category?.name, forKey: "categoryName")
                
                do {
                    try context.save()
                }
                catch {

                }
                
            } else {

            }
        } catch  {
            
        }
        
        self.taskTitle = newTask.taskTitle
        self.dateToComplete = newTask.dateToComplete
        self.category = newTask.category
        self.isItDone = newTask.isItDone
        
    }
    
     
    func saveTaskToCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Tasks", into: context)
        newTask.setValue(self.taskTitle, forKey: "taskTitle")
        newTask.setValue(Task.dateShouldBeDoneToString(date: self.dateToComplete), forKey: "dateString")
        newTask.setValue(self.category?.name, forKey: "categoryName")
        newTask.setValue(self.isItDone, forKey: "isItDone")
        do {
            try context.save()
        } catch  {
            fatalError("Failure save Context: \(error)")
        }
        context.refreshAllObjects()
    }
    
}

