//
//  LHCanvasView.swift
//  Testing
//
//  Created by 許立衡 on 2018/10/26.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHConvenientMethods

private let bundle = Bundle(identifier: "com.narrativesaw.LHSketchKit")!

public protocol LHCanvasViewDelegate: AnyObject {
    func canvasViewDidChange(_ canvasView: LHCanvasView)
}

open class LHCanvasView: UIView {
    
    private lazy var localUndoManager: UndoManager = {
        let manager = UndoManager()
        manager.levelsOfUndo = 100
        return manager
    }()
    open weak var delegate: LHCanvasViewDelegate?
    
    override open var undoManager: UndoManager! {
        return localUndoManager
    }
    
    private lazy var backingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return imageView
    }()
    
    open var image: UIImage? {
        get {
            return backingImageView.image
        }
    }
    
    open var preferredSize: CGSize = .init(width: 1920, height: 1080)
    
    private func initialize() {
        addSubview(backingImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    open func replaceImage(with image: UIImage?, actionName: String? = nil) {
        let oldImage = backingImageView.image
        backingImageView.image = image
        
        if let actionName = actionName {
            undoManager.setActionName(actionName)
        }
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
        DispatchQueue.main.async {
            self.delegate?.canvasViewDidChange(self)
        }
    }

}

extension LHCanvasView: LHBrushable {
    
    public func brushWillDraw(_ brush: LHBrush) {
        let oldImage = backingImageView.image
        undoManager.setActionName(NSLocalizedString("Draw Line", bundle: bundle, comment: ""))
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
        
        UIGraphicsBeginImageContextWithOptions(image?.size ?? preferredSize, true, 1)
    }
    
    public func brush(_ brush: LHBrush, draw lineSegment: LHLineSegment) {
        if let context = UIGraphicsGetCurrentContext() {
            let rect = CGRect(x: 0, y: 0, width: context.width, height: context.height)
            if let image = backingImageView.image {
                image.draw(in: rect)
            } else {
                context.setFillColor(UIColor.white.cgColor)
                context.fill(rect)
            }
            
            let ratio = rect.width / backingImageView.bounds.width
            var configuration = brush.configuration
            configuration.lineWidth /= ratio
            context.configureLine(with: configuration)
            context.scaleBy(x: ratio, y: ratio)
            context.drawLineSegment(lineSegment)
            context.scaleBy(x: 1/ratio, y: 1/ratio)
            
            backingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    public func brushDidDraw(_ brush: LHBrush) {
        UIGraphicsEndImageContext()
        delegate?.canvasViewDidChange(self)
    }
    
}
