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
import ChameleonFramework

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
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var umbrellaView: UIView!
    @IBOutlet weak var clothingView: UIView!
    var imageName : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temperatureView.layer.cornerRadius = 10
        temperatureView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        umbrellaView.layer.cornerRadius = 10
        umbrellaView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        clothingView.layer.cornerRadius = 10
        clothingView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        
        // set initial view positions off screen
        UIView.animate(withDuration: 0) {
            self.temperatureView.transform = CGAffineTransform(translationX: -350, y: 0)
            self.umbrellaView.transform = CGAffineTransform(translationX: -350, y: 0)
            self.clothingView.transform = CGAffineTransform(translationX: -350, y: 0)
        }
        
        // spring views into position
        UIView.animate(withDuration: 1.0, delay: 1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.temperatureView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        UIView.animate(withDuration: 1.0, delay: 1.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.umbrellaView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        UIView.animate(withDuration: 1.0, delay: 1.8, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.clothingView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
        self.view.bringSubviewToFront(clothingLabel)
//        clothingLabel.layer.zPosition = 1
        clothingLabel.text = weatherDataModel.updateClothing(temperature: weatherDataModel.currentTemp)
        print(clothingLabel.text!)
        umbrellaLabel.text = weatherDataModel.umbrellaRecommended
//        updateTextColor()
    }
    
    func updateTextColor() {
        print("Waiting to update text color")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.temperatureLabel.textColor = ContrastColorOf(AverageColorFromImage(self.background.image!), returnFlat: true)
            self.highTemperatureLabel.textColor = ContrastColorOf(AverageColorFromImage(self.background.image!), returnFlat: true)
            self.lowTemperatureLabel.textColor = ContrastColorOf(AverageColorFromImage(self.background.image!), returnFlat: true)
            self.clothingLabel.textColor = ContrastColorOf(AverageColorFromImage(self.background.image!), returnFlat: true)
            self.umbrellaLabel.textColor = ContrastColorOf(AverageColorFromImage(self.background.image!), returnFlat: true)
            
            print("updated text color!")
        })
    }
}

