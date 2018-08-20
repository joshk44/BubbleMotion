//
//  LoginViewController.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 17/08/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextView: UITextField!
    
    @IBOutlet weak var passwordTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
    }
    
    @IBAction func newUser(_ sender: UIButton) {
    }
    
    @IBAction func justPlay(_ sender: UIButton) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectType")
        self.present (loginViewController!, animated: true)
    }
    
    
}
