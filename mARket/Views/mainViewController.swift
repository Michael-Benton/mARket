//
//  mainViewController.swift
//  mARket
//
//  Created by Michael Benton on 4/16/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftKeychainWrapper

class mainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var distanceSelectorButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var stores = [Store]()
    var storesShown = [Store]()
    var distanceChoosen = Double()
    let manager = CLLocationManager()
    var usersLocation = CLLocation()
    var distanceFromStoreLocation = Double()
    let imageCache = NSCache<AnyObject, AnyObject>()
    let distanceNumbers = ["1","2","3","4","5","6","7","8","9","10"]
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        usersLocation = locations[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStores()
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "SplashBG")!)
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func createDistancePicker() {
        let distancePicker = UIPickerView()
        distancePicker.delegate = self
        showPickerInActionSheet()
    }
    
    func showPickerInActionSheet() {
        
        let title = "Miles"
        let message = "\n\n\n\n\n\n\n\n\n\n";
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet);
        alert.isModalInPopover = true;
        
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame: CGRect = CGRect(x: 40, y: 52, width: 270, height: 100)
        let picker: UIPickerView = UIPickerView(frame: pickerFrame);
 
        //set the pickers datasource and delegate
        picker.delegate = self;
        picker.dataSource = self;
        
        //Add the picker to the alert controller
        alert.view.addSubview(picker);
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame =  CGRect(x: 25, y: 5, width: 270, height: 45)
        let toolView: UIView = UIView(frame: toolFrame);
        
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 4, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame);
        buttonCancel.setTitle("Cancel", for: .normal);
        buttonCancel.setTitleColor(UIColor.blue, for: .normal);
        toolView.addSubview(buttonCancel); //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(mainViewController.cancelSelection(sender:)), for: .touchDown)
        
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 210, y: 4, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame);
        buttonOk.setTitle("Select", for: .normal);
        buttonOk.setTitleColor(UIColor.blue, for: .normal);
        toolView.addSubview(buttonOk); //add to the subview
        
        //Add the tartget. In my case I dynamicly set the target of the select button
        
        buttonOk.addTarget(self, action: #selector(mainViewController.selectSelection(sender:)), for: .touchDown)
        
        //add the toolbar to the alert controller
        alert.view.addSubview(toolView);
        
        present(alert, animated: true, completion: nil);
    }
    
    @objc func cancelSelection(sender: UIButton){
        print("Cancel");
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "token")
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = viewController
    }
    
    
    @objc func selectSelection(sender: UIButton){
        
        var isInArray = false
        
        if storesShown.count != 0{
            for index in self.stores{
                let storeLocation = CLLocation(latitude: index.gps.longitude, longitude: index.gps.latitude)
                
                self.distanceFromStoreLocation = (self.usersLocation.distance(from: storeLocation)).metersToMiles
                
                if(self.distanceFromStoreLocation < self.distanceChoosen){
                    for i in storesShown{
                        if i.name == index.name{
                            isInArray = true
                            break
                        }
                    }
                    if(!isInArray){
                        self.storesShown.append(index)
                    }
                    isInArray = false
                }
                
                if(self.distanceFromStoreLocation > self.distanceChoosen){
                    for (i,element) in storesShown.enumerated(){
                        if element.name == index.name{
                            storesShown.remove(at:i)
                            break
                        }
                    }
                }
            }
        }else{
            for index in self.stores{
                let storeLocation = CLLocation(latitude: index.gps.longitude, longitude: index.gps.latitude)
                
                self.distanceFromStoreLocation = (self.usersLocation.distance(from: storeLocation)).metersToMiles
                
                if(self.distanceFromStoreLocation < self.distanceChoosen){
                    self.storesShown.append(index)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil);
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return distanceNumbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return distanceNumbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        distanceChoosen = Double(row + 1)
    }
    
    func fetchStores() {
        guard let url = URL(string: "http://markitapi.com/stores") else { return }
        
        URLSession.shared.dataTask(with: url){(data,response,error) in
            
            if(error != nil){
                print(error!)
                return
            }
            
            guard let data = data else { return }
            
            do{
                self.stores = try JSONDecoder().decode([Store].self, from: data)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }catch let jsonErr{
                print(jsonErr)
            }
            
            }.resume()
    }
    
    @IBAction func distanceSelector(_ sender: Any) {
        createDistancePicker()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! mainTableViewCell
        
        if stores.count != 0{
            
            let fullAddress = "\(storesShown[indexPath.section].address_info.street), \(storesShown[indexPath.section].address_info.city), \(storesShown[indexPath.section].address_info.state) \(storesShown[indexPath.section].address_info.zip)"
            
            cell.storeNameLabel.text = storesShown[indexPath.section].name
            cell.storeAddress.text = fullAddress
            
            let urlString = storesShown[indexPath.section].logo.url
            let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if let imageFromCache = self.imageCache.object(forKey: urlString as AnyObject) as? UIImage{
                cell.storeThumbnail.image = imageFromCache
            }
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil{
                    print(error as Any)
                }
                
                DispatchQueue.main.async {
                    
                    if let imageToCache = UIImage(data: data!){
                        self.imageCache.setObject(imageToCache, forKey: url as AnyObject)
                        cell.storeThumbnail.image = UIImage(data: data!)
                    }
                }
                
                }.resume()
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return storesShown.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "storeViewController") as! storeViewController
        storeViewController.nameOfStore = storesShown[indexPath.section].name
        storeViewController.title = storesShown[indexPath.section].name
        self.navigationController?.pushViewController(storeViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
