//
//  LHCircleView.swift
//  LHCanvasViewController
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

@IBDesignable
class LHCircleView: UIView {
    
    @IBInspectable
    var color: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var circleSize: CGSize = CGSize(width: 10, height: 10) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func initialize() {
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addEllipse(in: CGRect(x: (bounds.width - circleSize.width) / 2, y: (bounds.height - circleSize.height) / 2, width: circleSize.width, height: circleSize.height))
        context.setFillColor(color.cgColor)
        context.fillPath()
    }

}
