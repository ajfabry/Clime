//
//  WeatherDataModel.swift
//  Clime
//
//  Created by AJ Fabry on 3/16/19.
//  Copyright © 2019 Addison Fabry. All rights reserved.
//

import UIKit
import URWeatherView

class WeatherDataModel {
    
    var currentTemp : Int = 0
    var highTemp : Int = 0
    var lowTemp : Int = 0
    var weatherID : Int = 0
    var city : String = ""
    
    func updateClothing(temperature: Int) -> String {
        if temperature < 50 {
            return "Heavy coat recommended"
        } else if temperature < 65 {
            return "Light jacket recommended"
        } else {
            return "No jacket recommended"
        }
    }
    
    func updateAnimation(condition: Int) -> URWeatherType {
        switch (condition) {
            
        case 0...300 :      // thunderstorm
            return .lightning
            
        case 301...500 :    // light rain
            return .rain
            
        case 501...600 :    // shower
            return .rain
            
        case 601...700 :    // snow
            return .snow
            
        case 701...771 :    // fog
            return .smoke
            
        case 772...799 :    // storm
            return .lightning
            
        case 800 :          // sunny
            return .shiny
            
        case 801...804 :    // cloudy
            return .cloudy
            
        case 900...903, 905...1000  :   // storm
            return .lightning
            
        case 903 :          // snow
            return .snow
            
        case 904 :          // sunny
            return .shiny
            
        default :
            return .none
        }
    }
}
