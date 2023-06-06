//
//  WeatherResponse.swift
//  Weather
//
//  Created by Charan Chikkam on 06/06/23.
//

import Foundation

struct WeatherResp: Codable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
}
