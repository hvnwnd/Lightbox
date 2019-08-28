//
//  CircleView.swift
//  RDV
//
//  Created by Bin Chen on 07/11/2018.
//  Copyright © 2018 TELEFUN. All rights reserved.
//

import UIKit
import QuartzCore

class CircleView: UIView {

    var pathLayer: CAShapeLayer!
    var backgroundLayer: CAShapeLayer!
    var shouldRemove: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bgLayer = CAShapeLayer()
        bgLayer.lineWidth = 4.0
        bgLayer.strokeColor = UIColor.white.cgColor
        bgLayer.lineJoin = CAShapeLayerLineJoin.bevel
        bgLayer.fillColor = nil
        bgLayer.path = self.roundPath().cgPath
        self.layer.addSublayer(bgLayer)
        backgroundLayer = bgLayer
        
        let layer = CAShapeLayer()
        layer.lineWidth = 4.0
        layer.backgroundColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = nil
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.path = self.roundPath().cgPath
        pathLayer = layer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        let bgLayer = CAShapeLayer()
        bgLayer.lineWidth = 4.0
        bgLayer.strokeColor = UIColor.white.cgColor
        bgLayer.lineJoin = CAShapeLayerLineJoin.bevel
        bgLayer.fillColor = nil
        bgLayer.path = self.roundPath().cgPath
        self.layer.addSublayer(bgLayer)
        backgroundLayer = bgLayer
        
        let layer = CAShapeLayer()
        layer.lineWidth = 4.0
        layer.backgroundColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = nil
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.path = self.roundPath().cgPath
        pathLayer = layer
    }
    
    private func roundPath() -> UIBezierPath {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = CGFloat(-Double.pi / 2)
        let endAngle = CGFloat(Double.pi / 2 * 3)
        return UIBezierPath(arcCenter: centerPoint,
                            radius: bounds.midX - 1.0,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true)
    }
    
    func go(from: CGFloat, to: CGFloat, animated: Bool) {
        if from == 0 {
            reset()
        }
        
        layer.addSublayer(pathLayer)
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.delegate = self
        pathAnimation.duration = animated ? 0.3 : 0.05
        pathAnimation.fromValue = from
        pathAnimation.toValue = to
        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        pathAnimation.isRemovedOnCompletion = false

        pathLayer.add(pathAnimation, forKey: "stroke")
//        print("\(from) \(to)")
    }
    
    private func reset() {
        pathLayer.removeAnimation(forKey: "stroke")
        layer.sublayers?.forEach({ layer in
            if layer != self.backgroundLayer {
                layer.removeFromSuperlayer()
            }
        })
    }
}

extension CircleView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}
