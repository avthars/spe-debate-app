//
//  RectProgressBar.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/7/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit

class RectProgressBar: UIView {

    var progress: Float = 0.00
    var color: CGColor = UIColor(red: 0.188235, green: 0.513726, blue: 0.984314, alpha: 1.0).CGColor
    var width = CGFloat(400)
    var screenWidth = CGFloat(375)
    
    // Draw circular progress indicator
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, width)
        CGContextSetStrokeColorWithColor(context, color)
        let rectangle = CGRectMake(-200, 0, screenWidth * CGFloat(progress), 180)
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
        
    }
}
