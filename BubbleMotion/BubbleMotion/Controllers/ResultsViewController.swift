//
//  ResultsViewController.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 13/10/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {
    
    var myPoints: Int = 0
    var contrincantPoints: Int = 0
    
    
    @IBOutlet weak var matchResult: UILabel!
    @IBOutlet weak var myPointsResult: UILabel!
    @IBOutlet weak var contrincantPointsResult: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchResult.text = (myPoints >= contrincantPoints) ? "YOU WIN" : "YOU LOSE"
        myPointsResult.text = "Your points: \(myPoints)"
        contrincantPointsResult.text = "Contrincant points: \(contrincantPoints)"

    }

    @IBAction func backToHome(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Multiplayer")
        self.present (viewController!, animated: true)
    }
}
