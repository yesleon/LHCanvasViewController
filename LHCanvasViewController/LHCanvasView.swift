//
//  LHCanvasView.swift
//  Testing
//
//  Created by 許立衡 on 2018/10/26.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHConvenientMethods

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
    
    private var currentLocation: CGPoint = .zero
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
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
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let oldImage = imageView.image
        undoManager.setActionName(NSLocalizedString("Draw Line", comment: ""))
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
        
        UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize(width: 1920, height: 1080), true, 1)
        configureLine(with: delegate?.lineConfigurator(for: self))
        penPhase = PenPhase(location: sender.location(in: self), velocity: .zero)
        penPhase = PenPhase(location: sender.location(in: self), velocity: .zero)
        penPhase = nil
        UIGraphicsEndImageContext()
        
        delegate?.canvasViewDidChange(self)
    }

    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let oldImage = imageView.image
            undoManager.setActionName(NSLocalizedString("Draw Line", comment: ""))
            undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
            
            UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize(width: 1920, height: 1080), true, 1)
            configureLine(with: delegate?.lineConfigurator(for: self))
            
            currentLocation = sender.location(in: self)
            
        case .changed:
            penPhase = PenPhase(location: currentLocation, velocity: sender.velocity(in: self))
            currentLocation = sender.location(in: self)
            
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
        context.setLineWidth(5)
        if let configurator = configurator {
            configurator(context)
        }
    }
    
    private func drawLine(from startPhase: PenPhase, to endPhase: PenPhase) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let rect = CGRect(x: 0, y: 0, width: context.width, height: context.height)
        let ratio = rect.width / imageView.bounds.width
        if let image = imageView.image {
            image.draw(in: rect)
        } else {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
        }
        
        let startPoint = startPhase.location * ratio
        let endPoint = endPhase.location * ratio
        let control1 = startPhase.controlPoint(handleLength: CGVector(point: startPhase.velocity).distance() / 250) * ratio
        let control2 = endPhase.controlPoint(handleLength: -CGVector(point: endPhase.velocity).distance() / 250) * ratio
        
        context.move(to: startPoint)
        context.addCurve(to: endPoint, control1: control1, control2: control2)
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
