//
//  NetworkManager.swift
//  Weather
//
//  Created by Charan Chikkam on 06/06/23.
//

import Foundation

class NetworkManager {
    
    let apiKey = "738d3bdd68e5d4cfae739f11b19fae6e"
    
    enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }

    enum HttpMethod: String {
        case get
        case post
        var method: String { rawValue.uppercased() }
    }

    func getWeather(city: String, completion: @escaping (WeatherResp?)->()) {
        guard let url = URL(string:"http://api.openweathermap.org/data/2.5/weather?q=\(city),uk&APPID=\(apiKey)") else { return }
        request(fromURL: url) { (result: Result<WeatherResp, Error>) in
            switch result {
            case .success(let weather):
                completion(weather)
            case .failure(_):
                completion(nil)
            }
         }
    }
    
    func getWeather(lat: String, long: String, completion: @escaping (WeatherResp?)->()) {
        guard let url = URL(string:"http://api.agromonitoring.com/agro/1.0/weather?lat=\(lat)&lon=\(long)&appid=\(apiKey)") else { return }
        request(fromURL: url) { (result: Result<WeatherResp, Error>) in
            switch result {
            case .success(let weather):
                completion(weather)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod = .get, completion: @escaping (Result<T, Error>) -> Void) {
        let completionOnMain: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.method

        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionOnMain(.failure(error))
                return
            }
            guard let urlResponse = response as? HTTPURLResponse else { return completionOnMain(.failure(ManagerErrors.invalidResponse)) }
            if !(200..<300).contains(urlResponse.statusCode) {
                return completionOnMain(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
            }
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(T.self, from: data)
                completionOnMain(.success(weather))
            } catch {
                completionOnMain(.failure(error))
            }
        }
        urlSession.resume()
    }
}
