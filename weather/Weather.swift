//
//  Weather.swift
//  weather
//
//  Created by James Saeed on 13/01/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

class Weather {
    
    var city: String!
    var temp: Int?
    var condition: String?
    var weekCondition: [String]!
    var time: String?
    var sunrise: String?
    var sunset: String?
    var humidity: Int?
    var wind: Int?
    
    init(_ city: String){
        self.city = city
        self.weekCondition = [String]()
    }
}
