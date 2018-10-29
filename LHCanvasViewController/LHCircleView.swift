//
//  LHCircleView.swift
//  LHCanvasViewController
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

class LHCircleView: UIView {
    
    let color: UIColor
    
    init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.color = .black
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addEllipse(in: rect)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }

}
