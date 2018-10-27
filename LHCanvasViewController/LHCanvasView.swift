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
    
    struct PenPhase {
        var location: CGPoint
        var velocity: CGPoint
        
        func controlPoint(handleLength: CGFloat) -> CGPoint {
            let handleAngle = CGVector(point: velocity).angle()
            let handle = CGVector(angle: handleAngle) * handleLength
            return location.applying(handle)
        }
    }
    
    private var oldLocation: CGPoint = .zero
    private var penPhase: PenPhase? {
        didSet {
            guard let startPhase = oldValue, let endPhase = penPhase else { return }
            drawLine(from: startPhase, to: endPhase)
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = LHCanvasView.imageViewClass.init()
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        return imageView
    }()
    
    open var image: UIImage? {
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
            let oldImage = imageView.image
            undoManager.setActionName("Draw Line")
            undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
            configureLine(with: delegate?.lineConfigurator(for: self))
            oldLocation = sender.location(in: self)
            
        case .changed:
            penPhase = PenPhase(location: oldLocation, velocity: sender.velocity(in: self))
            oldLocation = sender.location(in: self)
            
        case .ended:
            penPhase = nil
            
            UIGraphicsEndImageContext()
            
            delegate?.canvasViewDidChange(self)
            
        default:
            break
        }
    }
    
    private func configureLine(with configurator: LineConfigurationHandler?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setAlpha(1)
        context.setLineJoin(.round)
        context.setLineWidth(1)
        if let configurator = configurator {
            configurator(context)
        }
    }
    
    private func drawLine(from startPhase: PenPhase, to endPhase: PenPhase) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if let image = imageView.image {
            image.draw(in: bounds)
        } else {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(bounds)
        }
        
        context.move(to: startPhase.location)
        let ratio: CGFloat = 250
        let control1 = startPhase.controlPoint(handleLength: CGVector(point: startPhase.velocity).distance() / ratio)
        let control2 = endPhase.controlPoint(handleLength: -CGVector(point: endPhase.velocity).distance() / ratio)
        
        context.addCurve(to: endPhase.location, control1: control1, control2: control2)
        context.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    open func replaceImage(with image: UIImage?, actionName: String? = nil) {
        let oldImage = imageView.image
        imageView.image = image
        
        if let actionName = actionName {
            undoManager.setActionName(actionName)
        }
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
        DispatchQueue.main.async {
            self.delegate?.canvasViewDidChange(self)
        }
    }

}

extension CGPoint {
    
    func vector(to point: CGPoint) -> CGVector {
        return CGVector(dx: point.x - x, dy: point.y - y)
    }
    
    func applying(_ vector: CGVector) -> CGPoint {
        return CGPoint(x: x + vector.dx, y: y + vector.dy)
    }
    
}

extension CGVector {
    
    static func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
    
    func distance() -> CGFloat {
        return ((dx * dx) + (dy * dy)).squareRoot()
    }
    
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
    
    init(angle: CGFloat) {
        self.init(dx: cos(angle), dy: sin(angle))
    }
    
    init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    
}
