//
//  LoginViewController.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 17/08/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userTextView: UITextField!
    
    @IBOutlet weak var passwordTextView: UITextField!
    
    
    @IBOutlet weak var background: GradientView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextView.delegate = self
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
         if (UserDefaultsManager.loggedUserValue != UIDevice.current.name) {
            loggued()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func login(_ sender: Any) {
        if ((self.userTextView.text?.isEmpty)!) {
            showError (error: "Falta el nombre! 💔")
            
        } else if ((self.passwordTextView.text?.isEmpty)!) {
            showError (error: "Falta la contraseña! 🔐")
            
        } else {
            let users = UserDefaultsManager.users
            for user in users {
                if (user[0] == self.userTextView.text && user[1] == self.passwordTextView.text) {
                    UserDefaultsManager.loggedUserValue = self.userTextView.text ?? UIDevice.current.name
                    loggued()
                    break
                }
            }
            if (UserDefaultsManager.loggedUserValue == UIDevice.current.name) {
                showError (error: "Usuario no existente! :/")
            }
        }
    }
    
    func loggued (){
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let navigationController = appDelegate.window!.rootViewController as! UINavigationController
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectType")
            navigationController.pushViewController(viewController!, animated: false)
        }
    }
    
    
    @IBAction func newUser(_ sender: UIButton) {
        if ((self.userTextView.text?.isEmpty)!) {
            showError (error: "Falta el nombre! 💔")
            
        } else if ((self.passwordTextView.text?.isEmpty)!) {
            showError (error: "Falta la contraseña! 🔐")
            
        } else {
            UserDefaultsManager.addUser(array: [self.userTextView.text!, self.passwordTextView.text!])
            UserDefaultsManager.loggedUserValue = self.userTextView.text ?? UIDevice.current.name
            loggued()
        }
    }
    
    func showError (error: String) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController(title: "Error 😭", message: error, preferredStyle: UIAlertController.Style.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            
            let navigationController = appDelegate.window!.rootViewController as! UINavigationController
            let activeViewCont = navigationController.visibleViewController
            activeViewCont?.present(alert, animated: true, completion: nil)
        }
    }
}
