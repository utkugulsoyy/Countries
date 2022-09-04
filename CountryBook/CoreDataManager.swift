//
//  CoreDataManager.swift
//  CountryBook
//
//  Created by Utku Kaan Gülsoy on 4.09.2022.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func isExist(countryCode: String) -> Bool{
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountries")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                if let code = result.value(forKey: "code") as? String {
                    if code == countryCode{
                        return true
                    }
                }
            }
            
        } catch{
            print("fetch error")
        }
        return false
    }
    
    func deleteCountry(countryCode: String){
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountries")
        
        fetchRequest.predicate = NSPredicate(format: "code = %@", countryCode)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if (result.value(forKey: "code") != nil) {
                        context.delete(result)
                        do{
                            try context.save()
                            
                        }catch{
                            print("deleting error")
                        }
                    }
                }
            }
        } catch{
            print("delete error")
        }
        
    }
    
    func addCountry(countryCode: String, countryName: String, countryWikiId: String){
        let context = appDelegate.persistentContainer.viewContext
        let newCountry = NSEntityDescription.insertNewObject(forEntityName: "SavedCountries", into: context)
        newCountry.setValue(countryCode, forKey: "code")
        newCountry.setValue(countryName, forKey: "name" )
        newCountry.setValue(countryWikiId, forKey: "wikiId")
        
        do{
            try context.save()
        } catch{
            print("saving error!")
        }
    }
    
}
