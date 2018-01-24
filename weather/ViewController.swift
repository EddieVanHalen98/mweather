//
//  ViewController.swift
//  weather
//
//  Created by James Saeed on 12/01/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cities = ["London", "New York", "Chicago", "Dubai", "Amsterdam", "New Delhi",
                  "San Francisco", "Barcelona", "Tokyo", "Paris"]
    var usingCelsius: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        loadCities()
        determineTempUnit()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 18.0)
        cell.textLabel?.text = cities[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cities.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            saveCities()
        }
    }
    
    private func determineTempUnit() {
        if let loadedUsingCelsius = UserDefaults.standard.object(forKey: "unit") as? Bool {
            usingCelsius = loadedUsingCelsius
        } else {
            let locale = Locale.current.regionCode ?? ""
            usingCelsius = locale == "US" ? false : true
        }
    }
    
    private func loadCities() {
        if let loadedCities = UserDefaults.standard.object(forKey: "cities") as? [String] {
            cities = loadedCities
            self.tableView.reloadData()
        }
    }
    
    private func saveCities() {
        UserDefaults.standard.set(cities, forKey: "cities")
    }
    
    private func hasConnection() -> Bool {
        return true
    }
    
    @IBAction func addCity(_ sender: Any) {
        let alertController = UIAlertController(title: "Add City", message: "Add a city to your favourites", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter City Name"
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let city = alertController.textFields?[0].text {
                self.cities.append(city)
                self.tableView.reloadData()
                self.saveCities()
            }
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        let message = "\nThis app navigates in swipes! Swipe right to go back to the cities list, swipe up for more weather information and swipe down to go back to minimal!\n\nDid I get the temperature unit wrong? Feel free to change it below!"
        
        let alertController = UIAlertController(title: "Help", message: message, preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: "Change to °\(usingCelsius ? "F" : "C")", style: .default) { _ in
            UserDefaults.standard.set(!self.usingCelsius, forKey: "unit")
            self.usingCelsius = !self.usingCelsius
        }
        alertController.addAction(changeAction)
        
        let feedbackAction = UIAlertAction(title: "Send Feedback", style: .default) { _ in
            // TODO
        }
        alertController.addAction(feedbackAction)
        
        let moreAction = UIAlertAction(title: "More From Me", style: .default) { _ in
            if let url = URL(string: "http://www.evh98.com") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        alertController.addAction(moreAction)
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            if hasConnection() {
                let controller = segue.destination as! WeatherViewController
                controller.selectedCity = cities[indexPath.row]
                controller.usingCelsius = self.usingCelsius
            } else {
                let alertController = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Close", style: .cancel) { _ in }
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
