//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import QuartzCore


class MainViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var brickImageView: UIImageView!
    @IBOutlet var brickImageGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var conditionOutsideLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var backFromSearchLoactionButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoView: InfoView!
    private var brickImageCenter = CGPoint()
    private var selectedCity: String? = nil
    private let dataService = DataService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataService.delegate = self
        reloadWeather()
        infoView.delegate = self
        setupInfoButton()
        brickImageCenter = brickImageView.center
    }
    
    private func setupInfoButton() {
        infoButton.clipsToBounds = true
        infoButton.layer.cornerRadius = 20
        infoButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let colorTop =  UIColor(red: 241/255, green: 158/255, blue: 106/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 232/255, green: 102/255, blue: 56/255, alpha: 1).cgColor
        let gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [0.0, 1.0]
        gradient.frame = infoButton.bounds
        infoButton.layer.insertSublayer(gradient, at:0)
    }
    
    private func setBrickImageView(by id: Int, temp: Double) {
        brickImageView.alpha = 1
        switch id {
        case 200..<600:
            brickImageView.image = UIImage(named: "image_stone_wet" )
        case 600..<700:
            brickImageView.image = UIImage(named: "image_stone_snow" )
        case 700..<800:
            brickImageView.image = UIImage(named: "image_stone_normal")
            brickImageView.alpha = 0.2
            if temp >= 25 {
                brickImageView.image = UIImage(named: "image_stone_cracks")
            }
        default:
            brickImageView.image = UIImage(named: "image_stone_normal")
            if temp >= 25 {
                brickImageView.image = UIImage(named: "image_stone_cracks")
            }
        }
    }
    
    private func mainElements(shouldHide: Bool) {
        brickImageView.isHidden = shouldHide
        temperatureLabel.isHidden = shouldHide
        degreesLabel.isHidden = shouldHide
        locationStackView.isHidden = shouldHide
        conditionOutsideLabel.isHidden = shouldHide
        infoButton.isHidden = shouldHide
    }
    
    private func searchLocationElements(shouldHide: Bool) {
        searchLocationTextField.isHidden = shouldHide
        searchLocationButton.isHidden = shouldHide
        backFromSearchLoactionButton.isHidden = shouldHide
    }
    
    private func setDeflectBrickImageView() {
        let amplitude = 15.0
        let period = 0.5
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = period
        animation.fromValue = -amplitude
        animation.toValue = amplitude
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        brickImageView.layer.add(animation, forKey: "swingAnimation")
    }
    
    private func reloadWeather() {
        if let city = selectedCity {
            self.dataService.updateWeatherInfo(by: city)
        } else {
            self.dataService.updateWeatherInfoByGeolocation()
        }
    }
    
    private func searchLocation() {
        let city: String = searchLocationTextField.text ?? ""
        if city != "" {
            selectedCity = city
            dataService.updateWeatherInfo(by: city)
        } else {
            dataService.updateWeatherInfoByGeolocation()
            selectedCity = nil
        }
    }
    
    @IBAction func brickImageGestureRecognize(_ sender: UIPanGestureRecognizer) {
        brickImageView.layer.removeAllAnimations()
        let translation = sender.translation(in: brickImageView.superview)
        switch brickImageGestureRecognizer.state {
        case .began, .changed:
            activityIndicator.startAnimating()
            let newCenter = CGPoint(x: brickImageView.center.x, y: brickImageView.center.y + translation.y)
            if brickImageCenter.y + 35 > newCenter.y && brickImageCenter.y <= newCenter.y {
                brickImageView.center = newCenter
            }
            sender.setTranslation(CGPoint.zero, in: brickImageView.superview)
        case .ended:
            activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.2) {
                self.brickImageView.center = self.brickImageCenter
            }
            reloadWeather()
        default:
            break
        }
    }
    
    @IBAction func currentLocationButtonAction(_ sender: UIButton) {
        selectedCity = nil
        dataService.updateWeatherInfoByGeolocation()
    }
    
    
    @IBAction func magnifyingGlassButtonAction(_ sender: UIButton) {
        searchLocationElements(shouldHide: false)
        mainElements(shouldHide: true)
    }
    
    @IBAction func searchLocationButtonAction(_ sender: UIButton) {
        searchLocation()
        searchLocationElements(shouldHide: true)
        mainElements(shouldHide: false)
        searchLocationTextField.resignFirstResponder()
    }
    
    @IBAction func backFroamSearchLocationButtonAction(_ sender: UIButton) {
        searchLocationElements(shouldHide: true)
        mainElements(shouldHide: false)
        searchLocationTextField.resignFirstResponder()
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        infoView.isHidden = false
        mainElements(shouldHide: true)
    }
}


extension MainViewController: UITextFieldDelegate, InfoViewDelegate, DataServiceDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocation()
        return false
    }
    
    func closeInfoView() {
        infoView.isHidden = true
        mainElements(shouldHide: false)
    }
    
    func updateViewForRecivedData(id: Int, description: String, temp: Double, windSpeed: Double, country: String, city: String) {
        brickImageView.layer.removeAllAnimations()
        setBrickImageView(by: id, temp: temp)
        temperatureLabel.text = String(Int(temp))
        conditionOutsideLabel.text = description
        locationLabel.text = city + ", " + country
        if windSpeed > 4 {
            setDeflectBrickImageView()
        }
    }
    
    func updateViewForError() {
        brickImageView.layer.removeAllAnimations()
        brickImageView.image = UIImage(named: "image_without_stone" )
        temperatureLabel.text = "--"
        conditionOutsideLabel.text = ""
        locationLabel.text = ""
    }
    
    func showBadInternetConnectionAlert() {
        let alertController = UIAlertController(title: "Bad internet connection", message: "Check internet connection", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    func showIncorrectCityNameAlert() {
        let alertController = UIAlertController(title: "Incorrect city name", message: "Check that the city name is entered correctly", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}


