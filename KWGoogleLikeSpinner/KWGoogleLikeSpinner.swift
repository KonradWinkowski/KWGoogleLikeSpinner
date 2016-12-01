//
//  KWGoogleLikeSpinner.swift
//  KWGoogleLikeSpinner
//
//  Created by Konrad Winkowski on 11/30/16.
//  Copyright © 2016 Konrad Winkowski. All rights reserved.
//

import UIKit

@IBDesignable
class KWGoogleLikeSpinner: UIView, CAAnimationDelegate {
    
    let STROKE_ANIMATION_KEY = "stoke_animation"
    let ROTATION_ANIMATION_KEY = "rotation_animation"
    
    @IBInspectable var strokeWidth : CGFloat = 2.0
    @IBInspectable var strokeDuration : CGFloat = 0.8
    @IBInspectable var strokeEnd : CGFloat = 0.8
    
    @IBInspectable var rotationDuration : CGFloat = 1.0
    
    @IBInspectable var startAngle : CGFloat = 120.0
    
    // change these values for your own custom colors //
    var colors = [UIColor(hexString: "EC644B"), UIColor(hexString: "BE90D4"), UIColor(hexString: "446CB3"), UIColor(hexString: "90C695"), UIColor(hexString: "F5D76E"), UIColor(hexString: "EB9532")]{
        didSet {
            internalInit()
        }
    }
    
    var outsideLine : CAShapeLayer = CAShapeLayer()
    
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
    
    func layoutCircles() {
        
        let inset : CGFloat = 0.0
        
        outsideLine.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width - inset, height: self.bounds.size.height - inset)
        
        outsideLine.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
        
        let outsidePath = UIBezierPath.init(ovalIn: CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width - inset, height: self.bounds.size.height - inset))
        
        outsideLine.path = outsidePath.cgPath
        
        transform = CGAffineTransform(rotationAngle: CGFloat(Double(startAngle) / 180.0 * M_PI))
    }
    
    func startAnimating(){
        self.stopAnimating()
        
        addStrokeAnimation()
        addRotationAnimation()
    }
    
    func stopAnimating(){
        outsideLine.removeAllAnimations()
    }
    
    func addStrokeAnimation() {
        outsideLine.add(strokeAnimation(), forKey: STROKE_ANIMATION_KEY)
    }
    
    func addRotationAnimation() {
        outsideLine.add(rotationAnimation(), forKey: ROTATION_ANIMATION_KEY)
    }
    
    func changeLineColor() {
        var colorIndex = colors.index(of: UIColor.init(cgColor: outsideLine.strokeColor!))
        
        if colorIndex == nil || colorIndex == colors.count - 1 {
            colorIndex = 0
        } else {
            colorIndex = colorIndex! + 1
        }
        
        outsideLine.strokeColor = colors[colorIndex!].cgColor
    }
    
    fileprivate func rotationAnimation() -> CABasicAnimation{
        let animation = CABasicAnimation.init(keyPath: "transform.rotation")
        animation.toValue = M_PI * 2
        animation.duration = CFTimeInterval(rotationDuration)
        animation.repeatCount = FLT_MAX
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)
        
        return animation
    }
    
    fileprivate func strokeAnimation() -> CABasicAnimation{
        let animation = CABasicAnimation.init(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = strokeEnd
        animation.duration = CFTimeInterval(strokeDuration)
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.delegate = self
        animation.setValue(STROKE_ANIMATION_KEY, forKey: "animation_key")
        
        return animation
    }
    
    fileprivate func internalInit(){
        self.backgroundColor = UIColor.clear
        
        let scale = UIScreen.main.scale
        
        self.outsideLine.rasterizationScale = scale
        
        self.outsideLine.shouldRasterize = true
        
        self.layoutCircles()
        
        self.outsideLine.fillColor = UIColor.clear.cgColor
        
        self.outsideLine.strokeColor = colors.first?.cgColor
        
        self.outsideLine.lineWidth = strokeWidth;
        
        self.outsideLine.strokeEnd = 0.0;
        self.outsideLine.strokeStart = 0.0;
        
        self.outsideLine.lineCap = kCALineCapRound;
        
        self.layer.addSublayer(self.outsideLine)
        
        self.outsideLine.isHidden = true;
    }
    
    //MARK - Animation Delegate 
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && anim.value(forKey: "animation_key") as! String == STROKE_ANIMATION_KEY {
            changeLineColor()
            
            let deadlineTime = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
                self?.addStrokeAnimation()
            })
        }
    }

}

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
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
