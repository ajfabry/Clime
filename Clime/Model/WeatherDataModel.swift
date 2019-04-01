//
//  WeatherDataModel.swift
//  Clime
//
//  Created by AJ Fabry on 3/16/19.
//  Copyright © 2019 Addison Fabry. All rights reserved.
//

import UIKit

class WeatherDataModel {
    
    var currentTemp : Int = 0
    var highTemp : Int = 0
    var lowTemp : Int = 0
    var weatherID : Int = 0
    var city : String = ""
    var imageQuery : String = ""
    var umbrellaRecommended : String = ""
    
    func updateClothing(temperature: Int) -> String {
        if temperature < 50 {
            return "Heavy coat recommended"
        } else if temperature < 65 {
            return "Light jacket recommended"
        } else {
            return "No jacket recommended"
        }
    }
    
    func updateAnimation(condition: Int) {
        switch (condition) {

        case 0...300 :      // thunderstorm
            imageQuery = "thuderstorm"
            umbrellaRecommended = "Umbrella recommended"

        case 301...500 :    // light rain
            imageQuery = "light rain"
            umbrellaRecommended = "Umbrella recommended"

        case 501...600 :    // shower
            imageQuery = "rain"
            umbrellaRecommended = "Umbrella recommended"

        case 601...700 :    // snow
            imageQuery = "snow"

        case 701...771 :    // fog
            imageQuery = "fog"

        case 772...799 :    // storm
            imageQuery = "storm"
            umbrellaRecommended = "Umbrella recommended"

        case 800 :          // sunny
            imageQuery = "sunny"

        case 801...804 :    // cloudy
            imageQuery = "cloudy"

        case 900...903, 905...1000  :   // storm
            imageQuery = "storm"
            umbrellaRecommended = "Umbrella recommended"

        case 903 :          // snow
            imageQuery = "snow"

        case 904 :          // sunny
            imageQuery = "sunny"

        default :
            imageQuery = "sunny"
        }
    }
}
