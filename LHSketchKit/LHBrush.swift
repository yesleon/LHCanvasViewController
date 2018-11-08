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
    func brush(_ brush: LHBrush, draw lineSegment: LHLineSegment)
    func brushDidDraw(_ brush: LHBrush)
}

public class LHBrush: NSObject {
    
    public var configuration = LHLineConfiguration(lineCap: .round, strokeColor: .black, alpha: 1, lineWidth: 5)
    private var currentLocation: CGPoint = .zero
    private var phase: LHLinePhase? {
        didSet {
            guard let canvas = canvas else { return }
            if let endPhase = phase {
                if let startPhase = oldValue {
                    canvas.brush(self, draw: .init(startPhase: startPhase, endPhase: endPhase))
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
        
        phase = LHLinePhase(location: sender.location(in: view), velocity: .zero)
        phase = LHLinePhase(location: sender.location(in: view), velocity: .zero)
        phase = nil
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        switch sender.state {
        case .began:
            currentLocation = sender.location(in: view)
            phase = LHLinePhase(location: currentLocation, velocity: sender.velocity(in: view))
            
        case .changed:
            phase = LHLinePhase(location: currentLocation, velocity: sender.velocity(in: view))
            currentLocation = sender.location(in: view)
            
        case .ended, .cancelled:
            phase = nil
            
        default:
            break
        }
    }
    
}
