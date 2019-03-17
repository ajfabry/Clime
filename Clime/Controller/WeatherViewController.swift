//
//  WeatherViewController.swift
//  Clime
//
//  Created by AJ Fabry on 3/15/19.
//  Copyright © 2019 Addison Fabry. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation
import URWeatherView

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    let constants = Constants()
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var clothingLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!    
    @IBOutlet weak var mainView: URWeatherView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mainView.initView(mainWeatherImage: #imageLiteral(resourceName: "campus"), backgroundImage: #imageLiteral(resourceName: "brightdesktop"))
        showWeather()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Weather Effects
    
    func showWeather() {    // TODO: - sync effect with weather data
        let weather: URWeatherType = .rain
        self.mainView.startWeatherSceneBulk(weather, debugOption: true, additionalTask: {
            // task what you want to do after showing the weather effect...
        })
    }
    
    func removeWeather() {
        self.mainView.stop()
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
                        
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : constants.APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    // MARK: - Alamofire Networking
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success: got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                
            }
        }
        
    }
    
    // MARK: - JSON Parsing
    
    func updateWeatherData(json: JSON) {
        if let currentTemp = json["list"][0]["main"]["temp"].double {
            print("Current temperature: \(currentTemp)")
            weatherDataModel.currentTemp = Int((currentTemp - 273.15) * 1.8 + 32)
            
            guard var highTemp = json["list"][0]["main"]["temp_max"].double else {fatalError("Weather Data Unavailable")}
            guard var lowTemp = json["list"][0]["main"]["temp_min"].double else {fatalError("Weather Data Unavailable")}
            for index in 0...8 {
                if json["list"][index]["main"]["temp_max"].double! > highTemp {
                    highTemp = json["list"][index]["main"]["temp_max"].double!
                }
                if json["list"][index]["main"]["temp_min"].double! < lowTemp {
                    lowTemp = json["list"][index]["main"]["temp_min"].double!
                }
            }
            weatherDataModel.highTemp = Int((highTemp - 273.15) * 1.8 + 32)
            weatherDataModel.lowTemp = Int((lowTemp - 273.15) * 1.8 + 32)
            
            updateUI()
        }
    }
    
    // MARK: - UI Updating
    
    func updateUI() {
        temperatureLabel.text = "\(weatherDataModel.currentTemp)°"
        highTemperatureLabel.text = "High: \(weatherDataModel.highTemp)°"
        lowTemperatureLabel.text = "Low: \(weatherDataModel.lowTemp)°"
    }

}

