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
            contrincantName.text = "Waiting for bubbles..."
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
                self.contrincantName.text =  "No device connected"
            }
        })
    }
    
}

extension MultiplayerViewController : CommunicationServiceDelegate {
    
    func connectedDevicesChanged(manager: CommunicationService, connectedDevices: [String]) {
        updateContrincantName (contrincants: connectedDevices)
    }
    
    
}
