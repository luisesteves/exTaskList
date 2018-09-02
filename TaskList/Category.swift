//
//  File.swift
//  TaskList
//
//  Created by Luís Esteves on 02/09/2018.
//  Copyright © 2018 Michal Miko. All rights reserved.
//

import UIKit
import CoreData

class Category {
    var name: String!
    var color: UIColor!
    
    init(nameOfCategory: String, ColorOfCategory: UIColor) {
        name = nameOfCategory
        color = ColorOfCategory
    }

    class func loadCategoryFromCoreData() -> [String : Category?] {
        
        var categoryDictionary = [String : Category]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        request.returnsObjectsAsFaults = false
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    var temporaryNameOfCategories: String!
                    var temporaryColorOfCategories: UIColor!
                    
                    if let nameCategory = result.value(forKey: "nameCategory") as? String {
                        temporaryNameOfCategories = nameCategory
                    }
                    if let colorData = result.value(forKey: "color") as? Data {
                        let color = UIColor.color(withData: colorData)
                        temporaryColorOfCategories = color
                        
                    }
                    
                    categoryDictionary.updateValue(Category(nameOfCategory: temporaryNameOfCategories, ColorOfCategory: temporaryColorOfCategories), forKey: temporaryNameOfCategories)
                }
                
            } else {

            }
        } catch  {

        }
        
        return categoryDictionary
        
    }

    func saveCategoryToCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: context)
        newTask.setValue(self.name, forKey: "nameCategory")
        let colorData = self.color.encode()
        newTask.setValue(colorData, forKey: "color")
        
        do {
            try context.save()
        } catch  {
            fatalError("Failure save Context: \(error)")
        }
        context.refreshAllObjects()
    }
    
    func modifyCategory(newCategory: Category) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "nameCategory == %@", self.name)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                
                let result = results[0] as! NSManagedObject
                result.setValue(newCategory.name, forKey: "nameCategory")
                let colorData = newCategory.color.encode()
                result.setValue(colorData, forKey: "color")
                do {
                    try context.save()
                }
                catch {

                }
                
            } else {

            }
        } catch  {
            
        }
        self.name = newCategory.name
        self.color = newCategory.color
    }

    
    
}
