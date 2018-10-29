//
//  LHSliderViewController.swift
//  LHCanvasViewController
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

class LHSliderViewController: UIViewController {
    
    private let slider: UISlider
    private let rightLabel: UILabel
    private let handler: (Float) -> Void
    
    convenience init(min: Float, max: Float, current: Float, barButtonItem: UIBarButtonItem, handler: @escaping (Float) -> Void) {
        self.init(min: min, max: max, current: current, handler: handler)
        popoverPresentationController?.barButtonItem = barButtonItem
    }
    
    init(min: Float, max: Float, current: Float, handler: @escaping (Float) -> Void) {
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = current
        self.slider = slider
        
        self.handler = handler
        
        let rightLabel = UILabel()
        rightLabel.text = "\(Int(current))"
        rightLabel.textAlignment = .center
        rightLabel.addConstraint(.init(item: rightLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 44))
        self.rightLabel = rightLabel
        
        super.init(nibName: nil, bundle: nil)
        
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        modalPresentationStyle = .popover
        if let popoverController = popoverPresentationController {
            popoverController.delegate = self
        }
        preferredContentSize = CGSize(width: 250, height: 44)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let stackView = UIStackView(arrangedSubviews: [slider, rightLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.frame = view.bounds.insetBy(dx: 8, dy: 0)
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(stackView)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        rightLabel.text = "\(Int(sender.value))"
        handler(sender.value)
    }

}

extension LHSliderViewController: UIPopoverPresentationControllerDelegate {
    
    open func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
