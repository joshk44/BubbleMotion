//
//  SelectMultiplayer.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 18/08/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import Foundation
import UIKit

class SelectTypeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func startSinglePlayer(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = appDelegate.window!.rootViewController as! UINavigationController
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Gameplay")
        navigationController.pushViewController(viewController!, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            UserDefaultsManager.loggedUserValue = UIDevice.current.name
        }
    }
}

