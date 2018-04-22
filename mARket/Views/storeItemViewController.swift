//
//  storeItemViewController.swift
//  mARket
//
//  Created by Michael Benton on 4/17/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

var urlStringForItemDownload = String()

class storeItemViewController: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    var itemPrice = String()
    var itemName = String()
    var itemImageUrlString = String()
    var data = Data()
    var storeName = String()
    var storeUrlString = String()
    var storeUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameLabel.text = itemName
        itemPriceLabel.text = itemPrice
        view.backgroundColor = UIColor(patternImage: UIImage(named: "SplashBG")!)
        storeUrl = URL(fileURLWithPath: storeUrlString)
        do{
            data = try Data(contentsOf: URL(string: itemImageUrlString)!)
        }catch{
            print("Unable to parse image data")
        }
        
        itemImageView.image = UIImage(data: data)
    }
    
    @IBAction func buyItNowButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://bestbuy.com")!, options: [:], completionHandler: nil)
    }

    @IBAction func arButtonPressed(_ sender: Any) {
        let url = URL(string: "http://markitapi.com/objects/\(storeName)/\(itemName).tar.gz")!
        urlStringForItemDownload = itemName
        let task = DownloadManager.shared.activate().downloadTask(with: url)
        task.resume()
        
        let sceneViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "sceneViewController") as! sceneViewController
        self.navigationController?.pushViewController(sceneViewController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
