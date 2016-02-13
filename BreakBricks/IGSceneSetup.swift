//
//  IGSceneSetup.swift
//  BreakBricks
//
//  Created by Rich Rosiak on 2/12/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation

@objc class IGSceneSetup : NSObject {
    
    var cloudScalingFactor : CGFloat = 1.0
    
    var firstSceneBackgroundScalingFactor : CGFloat = 1.0
    
    var cloudyBackgroundScalingFactor : CGFloat = 1.0
    
    var brickImageName : String = ""
    
    var ballScalingFactor : CGFloat = 1.0
    
    var paddleScalingFactor : CGFloat = 1.0
    
    var ballSpeedScalingFactor : CGFloat = 1.0
    
    var tankBackgroundImageName : String = "art.scnassets/tanks_backgrnd.jpg"
    
    var tankBackScalingFactor : CGFloat = 1.0
}