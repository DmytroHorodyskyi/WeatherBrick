//
//  WeatherServicce.swift
//  WeatherBrick
//
//  Created by Dmytro Horodyskyi on 24.02.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import Foundation
import UIKit

protocol DataServiceDelegate {
    
    func updateViewForReceived(weather data: WeatherData)
    func updateViewForError()
    func showAlertWith(title: String, message: String)
}

class DataService {
    
    private let appid = "1862f8adffc972f1614b661b86c5c121"
    private let locationService = LocationService.shared
    var delegate: DataServiceDelegate?
    static let shared = DataService()
    
    init() {
        locationService.delegate = self
    }
    
    private func executeDataTask(with url: URL) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showAlertWith(title: "Bad internet connection", message: "Check internet connection")
                    self.delegate?.updateViewForError()
                }
                return
            }
            do {
                guard let data = data else {return}
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.updateViewForReceived(weather: weatherData)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.updateViewForError()
                }
            }
        }
        task.resume()
    }
    
    func updateWeatherInfoByGeolocation() {
        locationService.getCurrentLocation()
    }
    
    func updateWeatherInfo(by city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?" +
                            "q=\(city)&units=metric&appid=\(appid)")
        else {
            DispatchQueue.main.async {
                self.delegate?.showAlertWith(title: "Incorrect city name", message: "Check that the city name is entered correctly")
                self.delegate?.updateViewForError()
            }
            return
        }
        executeDataTask(with: url)
    }
}


extension DataService: LocationServiceDelegate {
    
    func createUrlAndExecuteDataTaskWith(latitude: Double?, longitude: Double? ) {
        guard let latitude = latitude,
              let longitude = longitude,
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?" +
                            "lat=\(latitude)" +
                            "&lon=\(longitude)" +
                            "&units=metric&appid=\(appid)")
        else {return}
        executeDataTask(with: url)
    }
    
    func geolocationError() {
        DispatchQueue.main.async {
            self.delegate?.updateViewForError()
            self.delegate?.showAlertWith(title: "Can't get geolocation", message: "Check if geolocation is enabeled in the application settings")
        }
    }
}
