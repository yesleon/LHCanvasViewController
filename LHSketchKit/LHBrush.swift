//
//  LHBrush.swift
//  LHSketchKit
//
//  Created by 許立衡 on 2018/11/2.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHConvenientMethods

public protocol LHBrushable: AnyObject {
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer)
    func brushWillDraw(_ brush: LHBrush)
    func brush(_ brush: LHBrush, drawLineFrom startPhase: LHBrush.Phase, to endPhase: LHBrush.Phase)
    func brushDidDraw(_ brush: LHBrush)
}

public class LHBrush: NSObject {
    
    public struct Configuration {
        public var lineCap: CGLineCap
        public var strokeColor: UIColor
        public var alpha: CGFloat
        public var lineWidth: CGFloat
    }
    
    public struct Phase {
        public var location: CGPoint
        public var velocity: CGPoint
        
        public func controlPoint(handleLength: CGFloat) -> CGPoint {
            let handleAngle = CGVector(point: velocity).angle()
            let handle = CGVector(angle: handleAngle) * handleLength
            return location.applying(handle)
        }
    }
    
    public var configuration = Configuration(lineCap: .round, strokeColor: .black, alpha: 1, lineWidth: 5)
    private var currentLocation: CGPoint = .zero
    private var phase: Phase? {
        didSet {
            guard let canvas = canvas else { return }
            if let endPhase = phase {
                if let startPhase = oldValue {
                    canvas.brush(self, drawLineFrom: startPhase, to: endPhase)
                } else {
                    canvas.brushWillDraw(self)
                }
            } else {
                canvas.brushDidDraw(self)
            }
        }
    }
    
    public weak var canvas: LHBrushable? {
        didSet {
            if let canvas = canvas {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
                panGesture.maximumNumberOfTouches = 1
                panGesture.delaysTouchesBegan = false
                panGesture.delaysTouchesEnded = false
                canvas.addGestureRecognizer(panGesture)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
                canvas.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        phase = Phase(location: sender.location(in: view), velocity: .zero)
        phase = Phase(location: sender.location(in: view), velocity: .zero)
        phase = nil
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        switch sender.state {
        case .began:
            currentLocation = sender.location(in: view)
            phase = Phase(location: currentLocation, velocity: sender.velocity(in: view))
            
        case .changed:
            phase = Phase(location: currentLocation, velocity: sender.velocity(in: view))
            currentLocation = sender.location(in: view)
            
        case .ended, .cancelled:
            phase = nil
            
        default:
            break
        }
    }
    
}
