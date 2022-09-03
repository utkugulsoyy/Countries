//
//  SavedViewController.swift
//  CountryBook
//
//  Created by Utku Kaan Gülsoy on 1.09.2022.
//

import UIKit
import CoreData

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var savedCountryNames = [String]()
    var savedCountryCodes = [String]()
    var chosenCountryCode = ""
    var chosenCountryName = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getCoreData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCoreData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedCountryNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = savedCountryNames[indexPath.row]
        content.image = UIImage(systemName: "star.fill")
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCountryCode = savedCountryCodes[indexPath.row]
        chosenCountryName = savedCountryNames[indexPath.row]
        performSegue(withIdentifier: "toDetailsCardVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsCardVC"{
            let destinationVC = segue.destination as! DetailsCardVC
            
            destinationVC.selectedCountryCode = chosenCountryCode
            destinationVC.selectedCountryName = chosenCountryName
            
        }
        
    }
    
    
    func getCoreData(){
        savedCountryNames.removeAll()
        savedCountryCodes.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountries")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String {
                    savedCountryNames.append(name)
                }
                
                if let code = result.value(forKey: "code") as? String {
                    savedCountryCodes.append(code)
                }
                
                tableView.reloadData()
                
            }
            tableView.reloadData()
            
        } catch{
            print("fetch error")
        }
    }
    
    
}
