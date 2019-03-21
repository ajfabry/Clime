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
    let UNSPLASH_URL = "https://api.unsplash.com/photos/random/"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var clothingLabel: UILabel!
    @IBOutlet weak var umbrellaLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!    
    @IBOutlet weak var mainView: URWeatherView!
    @IBOutlet weak var background: UIImageView!
    var imageName : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.mainView.initView(mainWeatherImage: #imageLiteral(resourceName: "transparent foreground"), backgroundImage: #imageLiteral(resourceName: "transparent foreground"))
    }
    
    // MARK: - Weather Effects
    
    func showWeather(condition: URWeatherType) {    // TODO: - sync effect with weather data
        let weather: URWeatherType = condition
        self.mainView.startWeatherSceneBulk(weather, debugOption: true, additionalTask: {
            // task what you want to do after showing the weather effect...
            print("showing weather condition \(condition)")
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
                print("Weather data retrieved successfully")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func getPicture(url: String, parameters: [String: String], completion: (_: String) -> Void) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Photo data retrieved successfully")
                let photoJSON : JSON = JSON(response.result.value!)
                self.updatePhotoData(json: photoJSON) {
                    (_: String) in
                    print("photo downloaded?")
                }
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
        
        completion("finished")
    }
    
    // MARK: - JSON Parsing
    
    func updateWeatherData(json: JSON) {
        if let currentTemp = json["list"][0]["main"]["temp"].double {
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
            
            guard let currentCondition = json["list"][0]["weather"][0]["id"].int else {fatalError("Weather Data Unavailable")}
            weatherDataModel.weatherID = currentCondition
            _ = weatherDataModel.updateAnimation(condition: currentCondition)
            
            updateUI()
        }
    }
    
    func updatePhotoData(json: JSON, completion: (_: String) -> Void) {
        let downloadLocation = json["urls"]["regular"].string!
        
        let url = URL(string: downloadLocation)
        let data = try? Data(contentsOf: url!)
        background.image = UIImage(data: data!)
        
        completion("photo data updated!")
    }
    
    // MARK: - UI Updating
    
    func updateUI() {
        print("image query: \(weatherDataModel.imageQuery)")
        let params = ["orientation" : "portrait", "client_id" : constants.accessKey, "query" : weatherDataModel.imageQuery]
        getPicture(url: UNSPLASH_URL, parameters: params) {
            (_: String) in
            print("done")
        }
                
        temperatureLabel.text = "\(weatherDataModel.currentTemp)°"
        highTemperatureLabel.text = "High: \(weatherDataModel.highTemp)°"
        lowTemperatureLabel.text = "Low: \(weatherDataModel.lowTemp)°"
        clothingLabel.text = weatherDataModel.updateClothing(temperature: weatherDataModel.currentTemp)
        umbrellaLabel.text = weatherDataModel.umbrellaRecommended
        showWeather(condition: weatherDataModel.updateAnimation(condition: weatherDataModel.weatherID))
        
    }
}

