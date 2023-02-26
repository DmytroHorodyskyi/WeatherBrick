//
//  Info.swift
//  WeatherBrick
//
//  Created by Dmytro Horodyskyi on 22.02.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit

protocol InfoViewDelegate {
    func closeInfoView()
}

@IBDesignable
class InfoView: UIView {
    
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var infoInternalView: UIView!
    @IBOutlet weak var plantedView: UIView!
    var delegate: InfoViewDelegate?
    
    override init(frame: CGRect) {
        super.init (frame: frame)
        setupViews()
    }
    
    required init?(coder Decoder: NSCoder) {
        super.init (coder: Decoder)
        setupViews()
    }
    
    private func setupViews () {
        let xibView = loadViewFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
        setRoundingView(plantedView)
        setRoundingView(infoInternalView)
        setupSelfView()
        setupHideButton()
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "InfoView", bundle: bundle)
        return nib.instantiate (withOwner: self, options: nil).first! as! UIView
    }
    
    private func setRoundingView(_ view: UIView) {
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
    }
    
    private func setupSelfView() {
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    private func setupHideButton() {
        hideButton.layer.cornerRadius = 20
        hideButton.layer.borderWidth = 1
        hideButton.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    @IBAction func hideButtonAction(_ sender: UIButton) {
        delegate?.closeInfoView()
    }
}
