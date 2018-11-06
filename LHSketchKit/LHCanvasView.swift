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
    
    private lazy var localUndoManager = UndoManager()
    open weak var delegate: LHCanvasViewDelegate?
    
    override open var undoManager: UndoManager! {
        return localUndoManager
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = LHCanvasView.imageViewClass.init()
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return imageView
    }()
    
    open var image: UIImage? {
        get {
            return imageView.image
        }
    }
    
    open var preferredSize: CGSize = .init(width: 1920, height: 1080)
    
    class var imageViewClass: UIImageView.Type {
        return UIImageView.self
    }
    
    private func initialize() {
        addSubview(imageView)
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
    
    private func configureLine(in context: CGContext, with configuration: LHBrush.Configuration) {
        context.setLineCap(configuration.lineCap)
        context.setStrokeColor(configuration.strokeColor.cgColor)
        context.setAlpha(configuration.alpha)
        context.setLineJoin(.round)
        context.setLineWidth(configuration.lineWidth)
    }

    private func drawLine(from startPhase: LHBrush.Phase, to endPhase: LHBrush.Phase) {
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

extension LHCanvasView: LHBrushable {
    
    public func brushWillDraw(_ brush: LHBrush) {
        let oldImage = imageView.image
        undoManager.setActionName(NSLocalizedString("Draw Line", bundle: bundle, comment: ""))
        undoManager.registerUndo(withTarget: self) { $0.replaceImage(with: oldImage) }
        
        UIGraphicsBeginImageContextWithOptions(image?.size ?? preferredSize, true, 1)
        if let context = UIGraphicsGetCurrentContext() {
            configureLine(in: context, with: brush.configuration)
        }
    }
    
    public func brush(_ brush: LHBrush, drawLineFrom startPhase: LHBrush.Phase, to endPhase: LHBrush.Phase) {
        drawLine(from: startPhase, to: endPhase)
    }
    
    public func brushDidDraw(_ brush: LHBrush) {
        UIGraphicsEndImageContext()
        delegate?.canvasViewDidChange(self)
    }
    
}
