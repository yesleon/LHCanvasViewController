//
//  LHSlider.swift
//  LHCanvasViewController
//
//  Created by 許立衡 on 2018/10/30.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

class LHSlider: UISlider {
    
    typealias Handler = (LHSlider) -> Void
    
    var handler: Handler?

    convenience init(handler: @escaping Handler) {
        self.init(frame: .zero)
        self.handler = handler
        addTarget(self, action: #selector(valueDidChange), for: .valueChanged)
    }
    
    @objc private func valueDidChange() {
        handler?(self)
    }
    
}
