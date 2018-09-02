//
//  Categories+CoreDataProperties.swift
//  
//
//  Created by Luís Esteves on 02/09/2018.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var color: NSObject?
    @NSManaged public var nameCategory: String?

}
