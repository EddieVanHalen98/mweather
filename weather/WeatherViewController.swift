//
//  WeatherViewController.swift
//  weather
//
//  Created by James Saeed on 13/01/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    // Values taken from previous view controller
    var selectedCity: String?
    var usingCelsius: Bool?
    
    var weather: Weather!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather = Weather()
        
        hideUI()
        getWeather()
    }
    
    /*
     Grabs the weather data for the selected city and matches it to the weather object
     */
    private func getWeather() {
        let url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22" + selectedCity!.replacingOccurrences(of: " ", with: "%20") + "%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
        
        Alamofire.request(url).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let jsonResult = json["query"]["results"]["channel"]
                
                if let city = jsonResult["location"]["city"].string { self.weather.city = city }
                if let temp = jsonResult["item"]["condition"]["temp"].string { self.weather.temp = Int(temp) }
                if let condition = jsonResult["item"]["condition"]["text"].string { self.weather.condition = condition }
                if let wind = jsonResult["wind"]["speed"].string { self.weather.wind = Int(wind) }
                if let humidity = jsonResult["atmosphere"]["humidity"].string { self.weather.humidity = Int(humidity) }
                if let sunrise = jsonResult["astronomy"]["sunrise"].string { self.weather.sunrise = sunrise }
                if let sunset = jsonResult["astronomy"]["sunset"].string { self.weather.sunset = sunset }
                if let time = jsonResult["lastBuildDate"].string { self.weather.time = time }
                
                for day in 0...5 {
                    if let weekCondition = jsonResult["item"]["forecast"][day]["text"].string {
                        self.weather.weekCondition.append(weekCondition)
                    }
                }
                self.updateUI()
            }
            self.showUI()
        }
    }
    
    /*
     The starting point for the UI
     */
    private func hideUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.cityLabel.alpha = 0
        self.tempLabel.alpha = 0
        self.detailLabel.alpha = 0
        cityLabel.transform = CGAffineTransform(translationX: 0, y: 128)
        tempLabel.transform = CGAffineTransform(translationX: 0, y: 128)
    }
    
    /*
     Matches the data from the weather object to the UI
     */
    private func updateUI() {
        if let city = weather.city {
            cityLabel.text = city
        }
        if let temp = weather.temp {
            tempLabel.text = "\(usingCelsius! ? fahrenheitToCelsius(temp) : temp)° \(usingCelsius! ? "C" : "F")"
        }
        if let condition = weather.condition {
            setBackground(with: condition)
            detailLabel.text = getFullAnalysis()
        }
    }
    
    /*
     Uses the data from the weather object to generate a full analysis in the detailed view
     */
    private func getFullAnalysis() -> String {
        var analysis = (getConditionAnalysis() + "\n\n")
        analysis += (getWindAnalysis() + "\n\n")
        analysis += (getHumidityAnalysis() + "\n\n")
        analysis += "Over the week the forecast is mainly \(self.weather.weekCondition!.mode!.lowercased())"
        
        return analysis
    }
    
    /*
     Generates the condition analysis for the full analysis
     */
    private func getConditionAnalysis() -> String {
        let city = weather.city!
        let condition = weather.condition!.contains("Showers") ? "rain" : weather.condition!.lowercased()
        let correctedCondition = (condition.contains("rain") || condition.contains("snow") || condition.contains("thunder"))
            ? condition + "ing" : condition
        let temp = usingCelsius! ? fahrenheitToCelsius(weather.temp!) : weather.temp!
        let tempWords = getTempAnalysis()
        
        return "Today in \(city) it is \(correctedCondition), and \(tempWords) at \(temp)° \(usingCelsius! ? "C" : "F")"
    }
    
    /*
     Generates the temperature analysis for the full analysis
     */
    private func getTempAnalysis() -> String {
        let temp = weather.temp!
        
        if temp < 21 { return "insanely cold" }
        else if temp >= 22 && temp < 32 { return "very cold" }
        else if temp >= 32 && temp < 46 { return "a little cold" }
        else if temp >= 47 && temp < 60 { return "cool" }
        else if temp >= 61 && temp < 71 { return "a little hot" }
        else if temp >= 72 && temp < 90 { return "really hot" }
        else { return "insanely hot" }
    }
    
    /*
     Generates the wind analysis for the full analysis
     */
    private func getWindAnalysis() -> String {
        let wind = weather.wind!
        
        if wind < 1 { return "The air is calm right now" }
        else if wind >= 1 && wind < 5 { return "The air is light at the minute" }
        else if wind >= 5 && wind < 11 { return "There's a light breeze in the air" }
        else if wind >= 11 && wind < 19 { return "There's a quite a bit of wind today" }
        else if wind >= 19 && wind < 28 { return "It's fairly windy out" }
        else if wind >= 28 && wind < 47 { return "The wind is pretty strong today" }
        else if wind >= 48 && wind < 60 { return "There is high wind, be cautious" }
        else { return "The wind is extremely severe, be cautious" }
    }
    
    /*
     Generates the humidity analysis for the full analysis
     */
    private func getHumidityAnalysis() -> String {
        let humidity = weather.humidity!
        
        if humidity < 41 { return "You may feel dry today with the humidity being pretty low" }
        else if humidity >= 41 && humidity < 75 { return "The humidity is at a comfortable level" }
        else { return "You may feel a bit clammy today with the humidity being fairly high" }
    }
    
    /*
     Changes the background image with a fade effect
     */
    private func setBackground(with condition: String) {
        UIView.transition(with: self.background,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.background.image = self.getBackground()
                            },
                          completion: nil)
    }
    
    /*
     Determines the background based on the weather condition
     */
    private func getBackground() -> UIImage {
        let condition = weather.condition!
        
        if condition.contains("Showers") || condition.contains("Rain") || condition.contains("Thunder") {
            return #imageLiteral(resourceName: "Rain")
        }
        else if condition.contains("Sunny") {
            return #imageLiteral(resourceName: "Sunny")
        } else if condition.contains("Snow") {
            return #imageLiteral(resourceName: "Snow")
        }  else if isNight() {
            return #imageLiteral(resourceName: "Night")
        } else {
            return #imageLiteral(resourceName: "Cloudy")
        }
    }
    
    /*
     Determines whether it is night or not based on the current time, and time of sunrise/sunset
     */
    private func isNight() -> Bool {
        let time = calcMilitaryHour(downSizeFullTime(weather.time!))
        let sunrise = calcMilitaryHour(weather.sunrise!)
        let sunset = calcMilitaryHour(weather.sunset!)
        
        return (time < sunrise || time > sunset)
    }
    
    /*
     Shows the main weather UI
     */
    private func showUI() {
        UIView.animate(withDuration: 1.5) {
            self.cityLabel.alpha = 1
            self.tempLabel.alpha = 1
            
            self.cityLabel.transform = CGAffineTransform.identity
            self.tempLabel.transform = CGAffineTransform.identity
        }
    }
    
    /*
     Goes back to the cities list upon a swipe to the right
     */
    @IBAction func closeWeather(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /*
     Shows the detailed UI upon a swipe up
     */
    @IBAction func showDetail(_ sender: Any) {
        UIView.animate(withDuration: 1.2, delay: 0, options: [], animations: {
            self.tempLabel.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.size.height + 160)
            self.tempLabel.alpha = 0
            
            self.cityLabel.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.size.height + 160)
        }, completion: { finished in
            UIView.animate(withDuration: 0.4) {
                self.detailLabel.alpha = 1
            }
        })
    }
    
    /*
     Closes the detailed UI upon a swipe down
     */
    @IBAction func closeDetail(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.detailLabel.alpha = 0
        }
            UIView.animate(withDuration: 1.2) {
                self.detailLabel.alpha = 0
                
                self.tempLabel.transform = CGAffineTransform.identity
                self.tempLabel.alpha = 1
                
                self.cityLabel.transform = CGAffineTransform.identity
            }
    }
    
    /*
     Downsizes a full blown date given by Yahoo e.g. to 5:21 pm
     */
    private func downSizeFullTime(_ time: String) -> String {
        let i = time[...time.index(time.endIndex, offsetBy: -5)]
        let j = i[i.index(i.endIndex, offsetBy: -8)...]
        
        return String(j)
    }
    
    /*
     Takes standard time into just the hour in military format e.g. 5:21 pm would return 17
     */
    private func calcMilitaryHour(_ time: String) -> Int {
        let hour = Int(time.split(separator: ":")[0])
        let period = time.split(separator: " ")[1]
        
        return (period.lowercased() == "am" || hour == 12) ? hour! : hour! + 12
    }
    
    /*
     Converts a fahrenheit value to celsius using the standard formula
     */
    private func fahrenheitToCelsius(_ temp: Int) -> Int {
        let celsius: Int = Int(round((Double(temp) - 32) * (5/9)).cleanValue)!
        return celsius
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

/*
 Extensions
 */

extension Double {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Array where Element: Hashable {
    var mode: Element? {
        return self.reduce([Element: Int]()) {
            var counts = $0
            counts[$1] = ($0[$1] ?? 0) + 1
            return counts
            }.max { $0.1 < $1.1 }?.0
    }
}
