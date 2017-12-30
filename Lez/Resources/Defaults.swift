//
//  Defaults.swift
//  Lez
//
//  Created by Antonija on 30/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import Foundation

class Defaults {
    
    let defaults = UserDefaults.standard
    static let sharedInstance = Defaults()
    private init() { }
    
    func saveLocation(location: String) {
        defaults.set(location, forKey: "location")
    }
}
