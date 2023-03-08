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
    private let normalStoneImage = UIImage(named: "image_stone_normal")
    private let wetStoneImage = UIImage(named: "image_stone_wet" )
    private let snowStoneImage = UIImage(named: "image_stone_snow" )
    private let crackedStoneImage = UIImage(named: "image_stone_cracks")
    private let withoutStoneImage = UIImage(named: "image_without_stone")
    private var brickImageCenter = CGPoint()
    private let dataService = DataService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataService.delegate = self
        dataService.updateWeatherInfoByGeolocation()
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
            brickImageView.image = wetStoneImage
        case 600..<700:
            brickImageView.image = snowStoneImage
        case 700..<800:
            brickImageView.image = normalStoneImage
            brickImageView.alpha = 0.2
            if temp >= 25 {
                brickImageView.image = crackedStoneImage
            }
        default:
            brickImageView.image = normalStoneImage
            if temp >= 25 {
                brickImageView.image = crackedStoneImage
            }
        }
    }
    
    private func hideMainElements(_ hide: Bool) {
        brickImageView.isHidden = hide
        temperatureLabel.isHidden = hide
        degreesLabel.isHidden = hide
        locationStackView.isHidden = hide
        conditionOutsideLabel.isHidden = hide
        infoButton.isHidden = hide
    }
    
    private func showSearchView(_ show: Bool) {
        hideMainElements(show)
        searchLocationTextField.isHidden = !show
        searchLocationButton.isHidden = !show
        backFromSearchLoactionButton.isHidden = !show
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
    
    private func searchLocation() {
        guard let city = searchLocationTextField.text, city != ""
        else {return}
            dataService.updateWeatherInfo(by: city)
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
            dataService.updateWeatherInfoByGeolocation()
        default:
            break
        }
    }
    
    @IBAction func currentLocationButtonAction(_ sender: UIButton) {
        dataService.updateWeatherInfoByGeolocation()
    }
    
    
    @IBAction func magnifyingGlassButtonAction(_ sender: UIButton) {
        showSearchView(true)
    }
    
    @IBAction func searchLocationButtonAction(_ sender: UIButton) {
        searchLocation()
        searchLocationTextField.text = ""
        showSearchView(false)
        searchLocationTextField.resignFirstResponder()
    }
    
    @IBAction func backFroamSearchLocationButtonAction(_ sender: UIButton) {
        showSearchView(false)
        searchLocationTextField.resignFirstResponder()
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        infoView.isHidden = false
        hideMainElements(true)
    }
}


extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocation()
        return false
    }
}

extension MainViewController: InfoViewDelegate {
    
    func closeInfoView() {
        infoView.isHidden = true
        hideMainElements(false)
    }
}

extension MainViewController: DataServiceDelegate {
    
    func updateViewForReceived(weather data: WeatherData) {
        brickImageView.layer.removeAllAnimations()
        setBrickImageView(by: data.weather[0].id, temp: data.main.temp)
        temperatureLabel.text = String(Int(data.main.temp))
        conditionOutsideLabel.text = data.weather[0].description
        locationLabel.text = data.name + ", " + data.sys.countryName(from: data.sys.country)
        if data.wind.speed > 4 {
            setDeflectBrickImageView()
        }
    }
    
    func updateViewForError() {
        brickImageView.layer.removeAllAnimations()
        brickImageView.image = withoutStoneImage
        temperatureLabel.text = "--"
        conditionOutsideLabel.text = ""
        locationLabel.text = ""
    }
    
    func showAlertWith(title: String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}



