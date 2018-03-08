//
//  KWGoogleLikeSpinner.swift
//  KWGoogleLikeSpinner
//
//  Created by Konrad Winkowski on 11/30/16.
//  Copyright © 2016 Konrad Winkowski. All rights reserved.
//

import UIKit

@IBDesignable
final class KWGoogleLikeSpinner: UIView {
    
    private let STROKE_ANIMATION_KEY = "stoke_animation"
    private let ROTATION_ANIMATION_KEY = "rotation_animation"
    
    @IBInspectable var strokeWidth : CGFloat = 2.0
    @IBInspectable var strokeDuration : CGFloat = 0.8
    @IBInspectable var strokeEnd : CGFloat = 0.8
    
    @IBInspectable var startAngle : CGFloat = 120.0
    
    private var strokeEndAnimation: CAAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(strokeDuration)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = CFTimeInterval(strokeDuration * 1.25)
        group.repeatCount = MAXFLOAT
        group.animations = [animation]
        
        return group
    }
    
    private var strokeStartAnimation: CAAnimation {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(strokeDuration)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = CFTimeInterval(strokeDuration * 1.25)
        group.repeatCount = MAXFLOAT
        group.animations = [animation]
        
        return group
    }
    
    private var rotationAnimation: CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = CFTimeInterval(strokeDuration * 2)
        animation.repeatCount = MAXFLOAT
        return animation
    }
    
    // change these values for your own custom colors //
    var colors = [UIColor(hexString: "1abc9c"), UIColor(hexString: "3498db"), UIColor(hexString: "9b59b6"), UIColor(hexString: "f1c40f"), UIColor(hexString: "e67e22"), UIColor(hexString: "e74c3c")]{
        didSet {
            internalInit()
        }
    }
    
    private var outsideLine : CAShapeLayer = CAShapeLayer()
    private var timer: Timer?
    
    override var isHidden: Bool{
        get {
            return super.isHidden
        }
        set(v){
            super.isHidden = v
        
            outsideLine.isHidden = super.isHidden
            
            if (super.isHidden){
                alpha = 0.0
                stopAnimating()
            }
            else{
                alpha = 1.0
                startAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        internalInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutCircles()
    }
    
    private func layoutCircles() {
        
        let inset : CGFloat = 0.0
        
        outsideLine.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width - inset, height: self.bounds.size.height - inset)
        
        outsideLine.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
        
        let outsidePath = UIBezierPath.init(ovalIn: CGRect(x: outsideLine.bounds.origin.x, y: outsideLine.bounds.origin.y, width: outsideLine.bounds.size.width - inset, height: outsideLine.bounds.size.height - inset))
        
        outsideLine.path = outsidePath.cgPath

    }
    
    private func startAnimating(){
        self.stopAnimating()
        
        addStrokeAnimation()
        addRotationAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(strokeDuration * 1.25), repeats: true, block: { [weak self] (timer) in
            self?.changeLineColor()
        })
    }
    
    private func stopAnimating(){
        timer?.invalidate()
        timer = nil
        outsideLine.removeAllAnimations()
    }
    
    private func addStrokeAnimation() {
        outsideLine.add(strokeEndAnimation, forKey: "stroke_end_animation")
        outsideLine.add(strokeStartAnimation, forKey: "stroke_start_animation")
    }
    
    private func addRotationAnimation() {
        outsideLine.add(rotationAnimation, forKey: ROTATION_ANIMATION_KEY)
    }
    
    private func changeLineColor() {
        var colorIndex = colors.index(of: UIColor.init(cgColor: outsideLine.strokeColor!))
        
        if colorIndex == nil || colorIndex == colors.count - 1 {
            colorIndex = 0
        } else {
            colorIndex = colorIndex! + 1
        }
        
        outsideLine.strokeColor = colors[colorIndex!].cgColor
    }
    
    private func internalInit() {
        self.backgroundColor = UIColor.clear
        
        let scale = UIScreen.main.scale
        
        self.outsideLine.rasterizationScale = scale
        
        self.outsideLine.shouldRasterize = true
        
        self.layoutCircles()
        
        self.outsideLine.fillColor = UIColor.clear.cgColor
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.outsideLine.strokeColor = colors.first?.cgColor
        self.outsideLine.strokeStart = 0.0
        self.outsideLine.strokeEnd = 1.0
        
        self.outsideLine.lineWidth = strokeWidth
        
        self.outsideLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.outsideLine.lineCap = kCALineCapRound
        
        self.layer.addSublayer(self.outsideLine)
                
        self.outsideLine.isHidden = true;
        
        self.outsideLine.transform = CATransform3DMakeRotation(CGFloat(startAngle), 0.0, 0.0, 1.0)
    }

}

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
