//
//  ViewController.swift
//  mARket
//
//  Created by Michael Benton on 4/16/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

struct userLoginRequest: Codable {
    let success: Bool
    let token: String
    let status: String
}

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIFont.systemFont(ofSize: 12))
        view.backgroundColor = UIColor.init(patternImage: UIImage(named: "SplashBG")!)
        userNameTextInput.becomeFirstResponder()
        userNameTextInput.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == userNameTextInput){
            passwordTextInput.becomeFirstResponder()
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func forgotPasswordButton(_ sender: Any) {
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let loginUrl = URL(string: "http://markitapi.com/users/login/")
        var request = URLRequest(url: loginUrl!)
        
        let alert = UIAlertController(title: "Incorrect username/password", message: "The username and/or password you entered is incorrect. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let postString = ["username": userNameTextInput.text!,
        "password": passwordTextInput.text!] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        }catch let error{
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this request. Try again.")
                print("error: \(String(describing: error))")
                return
            }
            
            do{
                let json = try JSONDecoder().decode(userLoginRequest.self, from: data!)
                print(json.success)
                
                DispatchQueue.main.async {
                    let mainViewControllerNav = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mainViewControllerNav")
                    self.present(mainViewControllerNav, animated: true, completion: nil)
                }
            }catch let jsonErr{
                print(jsonErr)
                self.present(alert, animated: true, completion: nil)
            }
            
        }.resume()
        
    }
    
    func displayMessage(userMessage: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in
                print("Ok button tapper")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
    }
}

