//
//  DataModels.swift
//  WeatherBrick
//
//  Created by Dmytro Horodyskyi on 23.02.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import Foundation

struct WeatherCondition: Codable {
    var id: Int
    var description: String
}

struct Wind: Codable {
    var speed = 0.0
}

struct Main: Codable {
    var temp = 0.0
}

struct SysLocation: Codable {
    var country = ""
    func countryName(from countryCode: String) -> String {
        if let name = (Locale(identifier: "en_US") as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
}

struct WeatherData: Codable {
    
    var weather: [WeatherCondition] = []
    var main: Main = Main()
    var wind: Wind = Wind()
    var sys: SysLocation = SysLocation()
    var name: String = ""
}
