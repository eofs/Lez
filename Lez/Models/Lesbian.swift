//
//  User.swift
//  Lez
//
//  Created by Antonija on 09/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import Foundation
import GooglePlaces
import GooglePlacePicker
import GoogleMaps

struct Lesbian: Codable {
    var name: String!
    var email: String!
    var age: Int!
    var location: String!
    var profileImageURL: String?
    
    init(name: String, email: String, age: Int, location: String) {
        self.name = name
        self.email = email
        self.age = age
        self.location = location
    }
    
    init(name: String, email: String, age: Int, location: String, profileImageURL: String) {
        self.name = name
        self.email = email
        self.age = age
        self.location = location
        self.profileImageURL = profileImageURL
    }
}
