//
//  LHCanvasView.swift
//  Testing
//
//  Created by 許立衡 on 2018/10/26.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

public protocol LHCanvasViewDelegate: AnyObject {
    func lineConfigurator(for canvasView: LHCanvasView) -> LHCanvasView.LineConfigurationHandler?
    func canvasViewDidChange(_ canvasView: LHCanvasView)
}

public protocol LHLineConfigurating {
    func setLineCap(_ cap: CGLineCap)
    func setStrokeColor(_ color: UIColor)
    func setAlpha(_ alpha: CGFloat)
    func setLineJoin(_ join: CGLineJoin)
    func setLineWidth(_ width: CGFloat)
}

extension LHLineConfigurating where Self: CGContext {
    public func setStrokeColor(_ color: UIColor) {
        setStrokeColor(color.cgColor)
    }
}

extension CGContext: LHLineConfigurating { }

open class LHCanvasView: UIView {
    
    private lazy var localUndoManager = UndoManager()
    open weak var delegate: LHCanvasViewDelegate?
    
    override open var undoManager: UndoManager! {
        return localUndoManager
    }
    public typealias LineConfigurationHandler = (LHLineConfigurating) -> Void
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    private var penPoint: CGPoint? {
        didSet {
            guard let startPoint = oldValue, let endPoint = penPoint else { return }
            drawLine(from: startPoint, to: endPoint)
        }
    }
    private var lineConfigurator: LineConfigurationHandler?
    
    private lazy var imageView: UIImageView = {
        let imageView = LHCanvasView.imageViewClass.init()
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        return imageView
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
    }
    
    class var imageViewClass: UIImageView.Type {
        return UIImageView.self
    }
    
    private func initialize() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        addGestureRecognizer(panGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        becomeFirstResponder()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            resignFirstResponder()
        }
    }

    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            lineConfigurator = delegate?.lineConfigurator(for: self)
            undoManager.beginUndoGrouping()
            penPoint = sender.location(in: self)
        case .changed:
            penPoint = sender.location(in: self)
        case .ended:
            penPoint = nil
            undoManager.endUndoGrouping()
            lineConfigurator = nil
            delegate?.canvasViewDidChange(self)
        default:
            break
        }
    }
    
    private func drawLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if let image = image {
            image.draw(in: bounds)
        } else {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(bounds)
        }
        
        context.addLines(between: [startPoint, endPoint])
        
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setAlpha(1)
        context.setLineJoin(.round)
        context.setLineWidth(1)
        
        if let configurator = lineConfigurator {
            configurator(context)
        }
        
        context.strokePath()
        
        replaceImage(with: UIGraphicsGetImageFromCurrentImageContext(), actionName: "Draw Line")
        UIGraphicsEndImageContext()
    }
    
    public func replaceImage(with image: UIImage?, actionName: String?) {
        let oldImage = imageView.image
        imageView.image = image
        
        if let actionName = actionName {
            undoManager.setActionName(actionName)
        }
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage, actionName: nil) }
        if undoManager.isRedoing || undoManager.isUndoing {
            DispatchQueue.main.async {
                self.delegate?.canvasViewDidChange(self)
            }
        }
    }

}
