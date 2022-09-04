//
//  DetailsCardVC.swift
//  CountryBook
//
//  Created by Utku Kaan Gülsoy on 1.09.2022.
//

import UIKit
import CoreData
import Foundation
import SVGKit


class DetailsCardVC: UIViewController {
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    var selectedCountryName = ""
    var selectedCountryCode = ""
    var selectedCountryWikiId = ""
    
    let coreDataManager = CoreDataManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedCountryName
        rightBarButtonItem.image = UIImage(systemName: "star")
        if coreDataManager.isExist(countryCode: selectedCountryCode){
            rightBarButtonItem.image = UIImage(systemName: "star.fill")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if coreDataManager.isExist(countryCode: selectedCountryCode){
            rightBarButtonItem.image = UIImage(systemName: "star.fill")
        }
        countryCodeLabel.text = "Country Code: " + selectedCountryCode
        getData()
        
    }
    
    @IBAction func rigthBarButtonPressed(_ sender: UIBarButtonItem) {
        
        if coreDataManager.isExist(countryCode: selectedCountryCode){
            coreDataManager.deleteCountry(countryCode: selectedCountryCode)
            rightBarButtonItem.image = UIImage(systemName: "star")
            
        } else{
            coreDataManager.addCountry(countryCode: selectedCountryCode, countryName: selectedCountryName, countryWikiId: selectedCountryWikiId)
            rightBarButtonItem.image = UIImage(systemName: "star.fill")
            
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://www.wikidata.org/wiki/"+selectedCountryWikiId){
            UIApplication.shared.open(url)
        } else{
            print("Url is not correct.")
        }
    }
    
    func getData()
    {
        let headers = [
            "X-RapidAPI-Key": "bd52224e40msh0e0b445614af118p1f5b5ejsn150f5ae9f77a",
            "X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://wft-geo-db.p.rapidapi.com/v1/geo/countries/"+selectedCountryCode)! as URL,
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
                        DispatchQueue.main.async {
                            if let countryDetails = jsonRes["data"] as? Dictionary<String,Any>
                            {
                                let flagUriTxt = countryDetails["flagImageUri"] as! String
                                let uri = URL(string: flagUriTxt)
                                self.flagImageView.downloadedsvg(from: uri!)
                                
                            }else{
                                print("error when casting response data")
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

extension UIImageView {
    func downloadedsvg(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let receivedicon: SVGKImage = SVGKImage(data: data),
                let image = receivedicon.uiImage
            else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
}
