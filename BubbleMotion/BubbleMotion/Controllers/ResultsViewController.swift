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
    var contrincantName: String = ""
    
    @IBOutlet weak var matchResult: UILabel!
    @IBOutlet weak var myPointsResult: UILabel!
    @IBOutlet weak var contrincantPointsResult: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchResult.text = (myPoints >= contrincantPoints) ? "Ganaste!!" : "Perdiste 😰"
        myPointsResult.text = "Tus puntos: \(myPoints)"
        contrincantPointsResult.text = "Contrincante: \(contrincantPoints)"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let currentUser: String = UserDefaultsManager.loggedUserValue
        UserDefaultsManager.addHistory(array: [currentUser, contrincantName, "\(contrincantPoints)", "\(myPoints)"])
    }
    
    @IBAction func backToHome(_ sender: Any) {
        navigateToRootAndRemoveResults ()
        print (UserDefaultsManager.history[0][2])
    }
    

    
    func navigateToRootAndRemoveResults () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = appDelegate.window!.rootViewController as! UINavigationController
        var stack = navigationController.viewControllers
        // let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectType")
        var i = 0
        for views in stack {
            if ( views is ResultsViewController ) {
                stack.remove(at: i)
            } else {
                i = i + 1
            }
        }
        navigationController.setViewControllers(stack, animated: false)
        print ("Count backToHome: \(navigationController.viewControllers.count)")
        
        navigationController.popToRootViewController(animated: false)
    }
}

