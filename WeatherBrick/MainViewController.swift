//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import QuartzCore


class MainViewController: UIViewController {
    
    @IBOutlet weak var brickImageView: UIImageView!
    @IBOutlet var brickImageGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var conditionOutsideLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoView: InfoView!
    private var lastSelectedCity = UserDefaults.standard.string(forKey: "City")
    private var lastSelectedCountry = UserDefaults.standard.string(forKey: "Country")
    private var dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationLabel.text = (lastSelectedCity ?? "---") + ", " + (lastSelectedCountry ?? "---")
        dataService.delegate = self
        infoView.delegate = self
        setupInfoButton()
        reloadWeather()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchLocation()
        super.touchesBegan (touches, with: event)
        view.endEditing (true)
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
    
    private func remember(city: String, country: String) {
        lastSelectedCity = city
        UserDefaults.standard.set(city, forKey: "City")
        lastSelectedCountry = city
        UserDefaults.standard.set(country, forKey: "Country")
    }
    
    private func reloadWeather() {
        if let city = self.lastSelectedCity {
            self.dataService.updateWeatherInfo(by: city)
        } else {
            self.dataService.updateWeatherInfoByGeolocation()
        }
    }
    
    private func searchLocation() {
        if let city = searchLocationTextField.text {
            if city != "" {
                dataService.updateWeatherInfo(by: city)
            }
        }
        searchLocationTextField.isHidden = true
        mainElements(shouldHide: false)
    }
    
    @IBAction func brickImageGestureRecognize(_ sender: UIPanGestureRecognizer) {
        let translation = brickImageGestureRecognizer.translation(in: brickImageView.superview)
        let defaultBrickImageViewHeight = CGFloat(brickImageView.image?.size.height ?? 0)
        switch brickImageGestureRecognizer.state {
        case .began, .changed:
            let scale = 1 + translation.y / 100
            let height = brickImageView.frame.height * scale
            if height < defaultBrickImageViewHeight + 70 && height > defaultBrickImageViewHeight   {
                brickImageView.transform = brickImageView.transform.scaledBy(x: 1, y: scale)
            }
            brickImageGestureRecognizer.setTranslation(CGPoint.zero, in: brickImageView.superview)
        case .ended:
            UIView.animate(withDuration: 0.2) {
                self.brickImageView.transform = CGAffineTransform.identity
            }
            reloadWeather()
        default:
            break
        }
    }
    
    @IBAction func currentLocationButtonAction(_ sender: UIButton) {
        dataService.updateWeatherInfoByGeolocation()
    }
    
    @IBAction func searchLocationButtonAction(_ sender: UIButton) {
        searchLocationTextField.isHidden = false
        mainElements(shouldHide: true)
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        infoView.isHidden = false
        mainElements(shouldHide: true)
    }
}


extension MainViewController: UITextFieldDelegate, InfoViewDelegate, DataServiceDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocation()
        textField.resignFirstResponder()
        return false
    }
    
    func closeInfoView() {
        infoView.isHidden = true
        mainElements(shouldHide: false)
    }
    
    func updateViewForRecivedData(id: Int, description: String, temp: Double, windSpeed: Double, country: String, city: String) {
        remember(city: city, country: country)
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
        conditionOutsideLabel.text = "-------"
        locationLabel.text = "-----, -----"
    }
}


