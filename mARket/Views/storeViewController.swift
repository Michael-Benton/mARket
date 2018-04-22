//
//  storeViewController.swift
//  mARket
//
//  Created by Michael Benton on 4/17/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

class storeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var nameOfStore = String()
    var objects = [Object]()
    var data = Data()
    var itemImageUrl = String()
    
    func fetchStores() {
        let urlString = "http://markitapi.com/objects/\(nameOfStore)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) else { return }

        URLSession.shared.dataTask(with: url){(data,response,error) in

            if(error != nil){
                print(error!)
                return
            }

            guard let data = data else { return }

            do{
                self.objects = try JSONDecoder().decode([Object].self, from: data)

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }

            }catch let jsonErr{
                print(jsonErr)
            }

            }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeItemsCollectionViewCell", for: indexPath) as! storeItemsCollectionViewCell
        if let price = objects[indexPath.item].price{
            cell.priceLabel.text = "$\(price)"
        }else{
            cell.priceLabel.text = ""
        }

        do{
            data = try Data(contentsOf: URL(string: objects[indexPath.item].thumbnail.url)!)
        }catch{
            print("Unable to parse image data")
        }
        
        cell.backgroundColor = UIColor.white
        cell.itemNameLabel.text = objects[indexPath.item].name
        cell.itemImageView.image = UIImage(data: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemDetailsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "storeItemViewController") as! storeItemViewController
        itemDetailsViewController.itemName = objects[indexPath.item].name
        itemDetailsViewController.storeName = objects[indexPath.item].storename
        itemDetailsViewController.storeUrlString = objects[indexPath.item].url!
        
        if let price = objects[indexPath.item].price{
            itemDetailsViewController.itemPrice = "$\(price)"
        }else{
            itemDetailsViewController.itemPrice = ""
        }
        
        itemDetailsViewController.title = objects[indexPath.item].name
        itemDetailsViewController.itemImageUrlString = objects[indexPath.item].thumbnail.url
        self.navigationController?.pushViewController(itemDetailsViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStores()
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "SplashBG")!)
        
    }

}
