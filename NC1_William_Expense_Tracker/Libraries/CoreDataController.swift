//
//  CoreDataController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 28/04/22.
//

import Foundation
import CoreData

class CoreDataController{
    func insertToCoreData(delegate: AppDelegate, entityName: String, value: [String], key:[String]){
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {return}
        let entityData = NSManagedObject(entity: entity, insertInto: context)
        for index in 0...value.count-1{
            entityData.setValue(value[index], forKey: key[index])
        }
        
        do{
            try context.save()
        }catch{
            print("Error saving data")
        }
    }
    
    func selectAllCoreData(delegate: AppDelegate, entityName: String) -> [NSManagedObject]{
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]
        return result
    }
    
    func selectOneWhereCoreData(delegate: AppDelegate, entityName: String, toPredicate: String, predicateValue:String) -> [NSManagedObject]{
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicateCoreData = NSPredicate(format: "\(toPredicate) = %@", predicateValue)
        fetchRequest.predicate = predicateCoreData
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]

        return result
    }
    
    func selectMultipleWhereAndCoreData(delegate: AppDelegate, entityName: String, toPredicate: [String], predicateValue: [String]) -> [NSManagedObject]{
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var predicateCoreData: [NSPredicate] = []
        for index in 0...toPredicate.count-1{
            predicateCoreData.append(NSPredicate(format: "\(toPredicate[index]) = %@", predicateValue[index]))
        }
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateCoreData)

        
        fetchRequest.predicate = predicateCompound
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]
        
        return result
    }
    func selectMultipleWhereOrCoreData(delegate: AppDelegate, entityName: String, toPredicate: [String], predicateValue: [String]) -> [NSManagedObject]{
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var predicateCoreData: [NSPredicate] = []
        for index in 0...toPredicate.count-1{
            predicateCoreData.append(NSPredicate(format: "\(toPredicate[index]) = %@", predicateValue[index]))
        }
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: predicateCoreData)

        
        fetchRequest.predicate = predicateCompound
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]
        
        return result
    }
    
    func updateMultipleWhereAndCoreData(delegate: AppDelegate, entityName: String, toPredicate: [String], predicateValue: [String], valueToChange: String, value: String){
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var predicateCoreData: [NSPredicate] = []
        for index in 0...toPredicate.count-1{
            predicateCoreData.append(NSPredicate(format: "\(toPredicate[index]) = %@", predicateValue[index]))
        }
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateCoreData)

        
        fetchRequest.predicate = predicateCompound
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]
        if result.count != 0{
            result.first?.setValue(value, forKey: valueToChange)
        }
    }
    
    func deleteData(delegate: AppDelegate, entityName: String, toPredicate: [String], predicateValue: [String]){
        let appDelegate = delegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var predicateCoreData: [NSPredicate] = []
        for index in 0...toPredicate.count-1{
            predicateCoreData.append(NSPredicate(format: "\(toPredicate[index]) = %@", predicateValue[index]))
        }
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateCoreData)

        
        fetchRequest.predicate = predicateCompound
        let result = try! context.fetch(fetchRequest)
        for items in result{
            context.delete(items as! NSManagedObject)
        }
        
        do{
            try context.save()
        }catch{
            print("Failed to delete data")
        }
        
    }
    
    
}
