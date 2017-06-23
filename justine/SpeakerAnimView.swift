//
//  SpeakerAnimation.swift
//  justine
//
//  Created by Fanni Kovács on 2017. 06. 23..
//  Copyright © 2017. oncehack. All rights reserved.
//

import UIKit

class SpeakerAnimView: UIView, CAAnimationDelegate {
    var imageView = UIImageView()
    var starterImages: [UIImage] = []
    var loopedImages: [UIImage] = []
    var endAnimImages: [UIImage] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.layoutIfNeeded()
        self.backgroundColor = UIColor.clear
        
        for i in 1...29 {
            starterImages.append(UIImage(named: "justin-voiceover-animation00"+String(format: "%02d", i))!)
        }
        
        for i in 30...78 {
            loopedImages.append(UIImage(named: "justin-voiceover-animation00"+String(format: "%02d", i))!)
        }
        
        for i in 79...98 {
            endAnimImages.append(UIImage(named: "justin-voiceover-animation00\(i)")!)
        }
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        imageView.image = UIImage(named: "justin-voiceover-animation0001")
        
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y:view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func startAnimation() {
        self.imageView.animationImages = self.starterImages
        self.imageView.animationDuration = 0.5
        self.imageView.animationRepeatCount = 1
        self.imageView.startAnimating()
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loopAnimation), userInfo: nil, repeats: false)
    }
    
    func loopAnimation() {
        self.imageView.animationImages = self.loopedImages
        self.imageView.animationDuration = 2.0
        self.imageView.animationRepeatCount = 100
        self.imageView.startAnimating()
    }
    
    func stopAnimation() {
        self.imageView.animationImages = endAnimImages
        self.imageView.animationDuration = 0.5
        self.imageView.animationRepeatCount = 1
        self.imageView.startAnimating()
    }
    
}
