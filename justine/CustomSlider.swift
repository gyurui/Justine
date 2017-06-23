//
//  CustomSlider.swift
//  SpeechDemo
//
//  Created by Gabriel Theodoropoulos on 10/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    var sliderIdentifier: Int!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sliderIdentifier = 0        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        sliderIdentifier = 0
    }

}
