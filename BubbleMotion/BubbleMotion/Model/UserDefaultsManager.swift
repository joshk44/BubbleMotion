//
//  UserDefaultsManager.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 05/12/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class UserDefaultsManager {
    
    private static let loggedUserKey = "loggedUser"
    private static let usersKey = "users"
    private static let historyKey = "history"

    
    static var loggedUserValue: String {
        get {
            let string: String = UserDefaults.standard.string(forKey: loggedUserKey) ?? UIDevice.current.name
            return string
        }
        set {
            UserDefaults.standard.set(newValue, forKey: loggedUserKey)
        }
    }
    
    static var history: [Array<String>]{
        get {
            if (UserDefaults.standard.array(forKey: historyKey) != nil) {
                return (UserDefaults.standard.array(forKey: historyKey) as! [[String]])
            } else {
                return Array<Array<String>>()
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: historyKey)
        }
    }
    
    static func addHistory (array: Array<String>) {
        var arrayOfArrays = history
        arrayOfArrays.append(array)
        history = arrayOfArrays
    }
    
    
    static var users: [Array<String>]{
        get {
            if (UserDefaults.standard.array(forKey: usersKey) != nil) {
                return (UserDefaults.standard.array(forKey: usersKey) as! [[String]])
            } else {
                return Array<Array<String>>()
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: usersKey)
        }
    }
    
    static func addUser (array: Array<String>) {
        var arrayOfArrays = users
        arrayOfArrays.append(array)
        users = arrayOfArrays
    }
}
