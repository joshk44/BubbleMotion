//
//  RecentsViewController.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 06/12/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import Foundation
import SpriteKit


class RecentsViewController: UIViewController, UITableViewDataSource {
    
    private var data: [[String]] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHistory")! //1.
        var currentData: [String] = data[indexPath.row]
        if ( currentData.count > 0){
            let text = "\(currentData[1])        \(currentData[2])          \(currentData[3])" //2.
            cell.textLabel?.text = text //3.
        } else {
            cell.textLabel?.text = "No hay historial"
        }
        return cell //4.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        table.dataSource = self
        
        for  datas in UserDefaultsManager.history {
            if (datas[0] == UserDefaultsManager.loggedUserValue) {
                data.append(datas)
            }
        }
        
    }
}
