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
    
    func updateViewForRecivedData(id: Int, description: String, temp: Double, windSpeed: Double, country: String, city: String)
    func updateViewForError()
    func showBadInternetConnectionAlert()
    func showIncorrectCityNameAlert()
}

class DataService {
    
    private let appid = "1862f8adffc972f1614b661b86c5c121"
    private let locationService = LocationService.shared
    var delegate: DataServiceDelegate?
    static let shared = DataService()
    
    init(){
        locationService.delegate = self
    }
    
    private func executeDataTask(with url: URL) {
        print("executeDataTask", url)
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    print(error!.localizedDescription)
                    self.delegate?.showBadInternetConnectionAlert()
                    self.delegate?.updateViewForError()
                }
                return
            }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    print(weatherData)
                    self.delegate?.updateViewForRecivedData(id: weatherData.weather[0].id,
                                                            description: weatherData.weather[0].description,
                                                            temp: weatherData.main.temp,
                                                            windSpeed: weatherData.wind.speed,
                                                            country: weatherData.sys.countryName(from: weatherData.sys.country),
                                                            city: weatherData.name)
                }
            } catch {
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.delegate?.showIncorrectCityNameAlert()
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
                self.delegate?.showIncorrectCityNameAlert()
                self.delegate?.updateViewForError()
            }
            print("Incorrect URL")
            return
        }
        executeDataTask(with: url)
    }
}


extension DataService: LocationServiceDelegate {
    
    func createUrlAndExecuteDataTaskWith(latitude: Double?, longitude: Double? ) {
        guard let latitude = latitude,
              let longitude = longitude
        else {
            print("Cannot get coordinates")
            return
        }
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?" +
                            "lat=\(latitude)" +
                            "&lon=\(longitude)" +
                            "&units=metric&appid=\(appid)")
        else {
            print("Incorrect URL")
            return
        }
        executeDataTask(with: url)
    }
}
