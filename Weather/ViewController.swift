//
//  ViewController.swift
//  Weather
//
//  Created by Charan Chikkam on 06/06/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    let weatherKey = "weather"
    let cityKey = "city"
    @IBOutlet var cityField: UITextField?
    @IBOutlet var searchButton: UIButton?
    @IBOutlet var main: UILabel?
    @IBOutlet var desc: UILabel?
    @IBOutlet var temp: UILabel?
    @IBOutlet var tempMin: UILabel?
    @IBOutlet var tempMax: UILabel?
    @IBOutlet var pressure: UILabel?
    @IBOutlet var humid: UILabel?
    @IBOutlet var error: UILabel?
    let locationManager = CLLocationManager()
    let networkManager = NetworkManager()
    var latitude: String?
    var longitude: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityField?.delegate = self
        hideError()
        setupLocation()
    }
    
    @IBAction func searchButtonClicked() {
        getWeatherDetailsByCity()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        if hsaLocationAccess() {
            getWeatherDetailsByCoords()
        } else {
            getLastCityDetails()
        }
    }
    
    func hsaLocationAccess() -> Bool {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways,
                .authorizedWhenInUse:
            return true
        case .denied,
                .notDetermined,
                .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func getWeatherDetailsByCity() {
        hideError()
        if let city = cityField?.text, !city.isEmpty {
            cityField?.resignFirstResponder()
            searchButton?.isUserInteractionEnabled = false
            networkManager.getWeather(city: city) { [weak self] weather in
                guard let self = self else { return }
                self.searchButton?.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    guard let weather = weather else {
                        self.showError()
                        return
                    }
                    self.loadWeather(weather: weather, city: city)
                    self.saveLastCityDetails(weather: weather, city: city)
                }
            }
        } else {
            showError()
        }
    }
    
    func getWeatherDetailsByCoords() {
        if let latitude = latitude,
           let longitude = longitude {
            networkManager.getWeather(lat: latitude, long: longitude) { [weak self] weather in
                guard let self = self else { return }
                guard let weather = weather else { return }
                DispatchQueue.main.async {
                    self.loadWeather(weather: weather, city: "")
                }
            }
        } else {
            getLastCityDetails()
        }
    }
    
    func saveLastCityDetails(weather: WeatherResp, city: String) {
        do {
            let encoder = JSONEncoder()
            let weatherData = try encoder.encode(weather)
            UserDefaults.standard.set(weatherData, forKey: weatherKey)
            UserDefaults.standard.set(city, forKey: self.cityKey)
        } catch {
            print("Unable to Encode Weather (\(error))")
        }
    }
    
    func getLastCityDetails() {
        if let weatherData = UserDefaults.standard.data(forKey: weatherKey) {
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(WeatherResp.self, from: weatherData)
                let city = UserDefaults.standard.value(forKey: cityKey) as? String
                if let city = city {
                    loadWeather(weather: weather, city: city)
                }
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
    
    func loadWeather(weather: WeatherResp, city: String) {
        main?.text = "\(weather.weather.first?.main ?? "") in \(city)"
        desc?.text = weather.weather.first?.description ?? ""
        temp?.text = "Temp: \(weather.main.temp)"
        tempMin?.text = "Min_Temp: \(weather.main.temp_min)"
        tempMax?.text = "Max_Temp: \(weather.main.temp_max)"
        pressure?.text = "Pressure: \(weather.main.pressure)"
        humid?.text = "Humidity: \(weather.main.humidity)"
    }
    
    func showError() {
        error?.isHidden = false
        error?.text = "Pease enter valid city name"
    }
    
    func hideError() {
        error?.isHidden = true
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getWeatherDetailsByCity()
        return true
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latitude = location.coordinate.latitude.description
            self.longitude = location.coordinate.longitude.description
        }
    }
}
