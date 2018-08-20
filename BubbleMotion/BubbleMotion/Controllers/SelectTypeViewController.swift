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
    }
    
    @IBAction func startSinglePlayer(_ sender: Any) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Gameplay")
        self.present (loginViewController!, animated: true)
    }
    
    @IBAction func startMultiplayer(_ sender: Any) {
    }
}

