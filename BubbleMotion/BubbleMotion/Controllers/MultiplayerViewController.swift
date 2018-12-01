//
//  MultiplayerViewController.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 11/09/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import Foundation
import UIKit

class MultiplayerViewController: UIViewController {
    
    @IBOutlet weak var contrincantName: UITextView!
    private var comunicationService: CommunicationService!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        comunicationService = appDelegate.comunicationService
        let contrincant = comunicationService.contrincant
        if (contrincant.isEmpty) {
            contrincantName.text = "Esperando burbujas..."
        } else {
            contrincantName.text = contrincant
        }
        
        comunicationService.delegate = self
    }
    
    @IBAction func performPlay(_ sender: Any) {
        comunicationService.sendInvitationToPlay()
    }
    
    func updateContrincantName (contrincants: [String]) {
        DispatchQueue.main.async(execute: {
            if (contrincants.count > 0) {
                self.contrincantName.text =  contrincants[0]
            } else {
                self.contrincantName.text =  "Parece que no hay burbujas cerca..."
            }
        })
    }
    
}

extension MultiplayerViewController : CommunicationServiceDelegate {

    
    func connectedDevicesChanged(manager: CommunicationService, connectedDevices: [String]) {
        updateContrincantName (contrincants: connectedDevices)
    }
    
    func startMatch () {
        DispatchQueue.main.async {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Gameplay")
        self.present (loginViewController!, animated: true)
        }
    }
    
    func bombReceived(bomb: GameState) {
    }
    
    func finishMatch (points: Int) {
    }

}
