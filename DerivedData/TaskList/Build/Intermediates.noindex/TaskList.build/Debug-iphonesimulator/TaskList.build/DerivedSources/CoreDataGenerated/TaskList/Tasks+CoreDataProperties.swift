//
//  Tasks+CoreDataProperties.swift
//  
//
//  Created by Luís Esteves on 02/09/2018.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Tasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tasks> {
        return NSFetchRequest<Tasks>(entityName: "Tasks")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var dateString: String?
    @NSManaged public var isItDone: Bool
    @NSManaged public var taskTitle: String?

}
