//
//  ListViewController.swift
//  CountryBook
//
//  Created by Utku Kaan Gülsoy on 1.09.2022.
//

import UIKit
import Foundation
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var countryInfos = [String:[String]]()
    
    var chosenCountryName = ""
    var chosenCountryCode = ""
    var chosenCountryWikiId = ""
    
    var savedCountryCodes = [String]()
    var coreDataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        let countryNames = Array(countryInfos.keys)
        let currentCountryCode = countryInfos[countryNames[indexPath.row]]![0]
        if coreDataManager.isExist(countryCode: currentCountryCode){
            content.image = UIImage(systemName: "star.fill")
        }else{
            content.image = UIImage(systemName: "star")
        }
        content.text = countryNames[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCountryName = Array(countryInfos.keys)[indexPath.row]
        chosenCountryCode = countryInfos[chosenCountryName]![0]
        chosenCountryWikiId = countryInfos[chosenCountryName]![1]
        performSegue(withIdentifier: "toDetailsCardVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsCardVC"{
            let destinationVC = segue.destination as! DetailsCardVC
            destinationVC.selectedCountryName = chosenCountryName
            destinationVC.selectedCountryCode = chosenCountryCode
            destinationVC.selectedCountryWikiId = chosenCountryWikiId
        }
        
    }
    
    func getData()
    {
        let headers = [
            "X-RapidAPI-Key": "bd52224e40msh0e0b445614af118p1f5b5ejsn150f5ae9f77a",
            "X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                if data != nil
                {
                    do{
                        let jsonRes = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                        DispatchQueue.main.async { [self] in
                            if let countries = jsonRes["data"] as?[Dictionary<String,Any>]
                            {
                                for i in 0..<10
                                {
                                    let country = countries[i]
                                    countryInfos[country["name"] as! String] = [country["code"] as! String, country["wikiDataId"] as! String]
                                    
                                }
                                
                                self.tableView.reloadData()
                                
                            }else{
                                print("error when creating table")
                            }
                            
                        }
                    } catch{
                        print("data is null")
                    }
                }
            }
        })
        
        dataTask.resume()
    }
        
}
