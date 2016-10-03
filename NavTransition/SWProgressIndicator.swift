//
//  SWDraw.swift
//  Tabbed Application Example
//
//  Created by Jonathan Yu on 6/29/15.
//  Copyright (c) 2015 Jonathan Yu. All rights reserved.
//

import UIKit

class SWProgressIndicator: UIView {
    
    let pi: Float = 3.14159265359
    var progress: Float = 0.00
    var color: CGColor = UIColor(red: 0.188235, green: 0.513726, blue: 0.984314, alpha: 1.0).CGColor
    
    // Draw circular progress indicator
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 8.0)
        CGContextSetStrokeColorWithColor(context, color)
        let rectangle = CGRectMake(7, 5, 300, 300)
        var angle = CGFloat(2.00 * progress * pi)
        CGContextAddArc(context, 150, 150, 140, 0.0, angle, 0)
        CGContextStrokePath(context)
    }
    
}