//
//  LHLine.swift
//  LHSketchKit
//
//  Created by 許立衡 on 2018/11/8.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation
import LHConvenientMethods

public struct LHLineConfiguration {
    public var lineCap: CGLineCap
    public var strokeColor: UIColor
    public var alpha: CGFloat
    public var lineWidth: CGFloat
}

public struct LHLinePhase {
    public var location: CGPoint
    public var velocity: CGPoint
    
    public func controlPoint(handleLength: CGFloat) -> CGPoint {
        let handleAngle = CGVector(point: velocity).angle()
        let handle = CGVector(angle: handleAngle) * handleLength
        return location.applying(handle)
    }
}

public struct LHLineSegment {
    public var startPhase: LHLinePhase
    public var endPhase: LHLinePhase
}

extension CGContext {
    
    internal func drawLineSegment(_ lineSegment: LHLineSegment) {
        let startPhase = lineSegment.startPhase
        let endPhase = lineSegment.endPhase
        let startPoint = startPhase.location
        let endPoint = endPhase.location
        let control1 = startPhase.controlPoint(handleLength: CGVector(point: startPhase.velocity).distance() / 250)
        let control2 = endPhase.controlPoint(handleLength: -CGVector(point: endPhase.velocity).distance() / 250)
        
        move(to: startPoint)
        addCurve(to: endPoint, control1: control1, control2: control2)
        strokePath()
    }
    
    internal func configureLine(with configuration: LHLineConfiguration) {
        setLineCap(configuration.lineCap)
        setStrokeColor(configuration.strokeColor.cgColor)
        setAlpha(configuration.alpha)
        setLineJoin(.round)
        setLineWidth(configuration.lineWidth)
    }
    
}
