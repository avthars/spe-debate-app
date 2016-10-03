//
//  GraphView.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/13/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

// http://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1
// http://www.raywenderlich.com/90693/modern-core-graphics-with-swift-part-2

/***********************************************************************

GraphView draws a line graph that displays sets of data based on the
user's selection.

***********************************************************************/

import UIKit

class GraphView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    override func drawRect(rect: CGRect) {
        
        // view dimensions
        let width = rect.width
        let height = rect.height
        let margin:CGFloat = 20.0
        let topBorder:CGFloat = 45
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        
        
        /* MARK - Draw graph background */
        
        // set up graph background clipping area
        var path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        // prepare gradient components
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        // create and draw gradient
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        var startPoint = CGPoint.zeroPoint
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
        
        
        /* MARK - Graph methods */
        
        //calculate the x point
        
        var columnXPoint = { (column: Int) -> CGFloat in
            // Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((data[0].count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        
        let maxValue = { () -> Int in
            var x: Int = maxElement(data[0])
            for lineData in data {
                x = max(x, maxElement(lineData))
            }
            return x
        }
        
        var columnYPoint = { (graphPoint: Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue()) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        
        /* MARK - Line plot */
        
        for (var i = 0; i < data.count; i++) {
            
            var lineData = data[i]
            
            // check if data exists and is selected to be displayed
            if (lineData.count > 0 && displayData[i] == true) {
                
                // draw the line graph
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                // set up the points line and move to start point
                var graphPath = UIBezierPath()
                graphPath.moveToPoint(CGPoint(x:columnXPoint(0),
                    y:columnYPoint(lineData[0])))
                
                // add and connect points for each array element
                for (var i = 1; i < lineData.count; i++) {
                    let nextPoint = CGPoint(x:columnXPoint(i),
                        y:columnYPoint(lineData[i]))
                    graphPath.addLineToPoint(nextPoint)
                }
                
                /* MARK - Create gradient for line plot */
                
                /*
                // save the state of the context
                CGContextSaveGState(context)
                
                // make a copy of the path
                var clippingPath = graphPath.copy() as! UIBezierPath
                
                // add lines to the copied path to complete the clip area
                clippingPath.addLineToPoint(CGPoint(
                x: columnXPoint(graphPoints.count - 1),
                y:height))
                clippingPath.addLineToPoint(CGPoint(
                x:columnXPoint(0),
                y:height))
                clippingPath.closePath()
                
                // add the clipping path to the context
                clippingPath.addClip()
                
                //        // check clipping path - temporary code
                //        UIColor.greenColor().setFill()
                //        let rectPath = UIBezierPath(rect: self.bounds)
                //        rectPath.fill()
                
                let highestYPoint = columnYPoint(maxValue)
                startPoint = CGPoint(x:margin, y: highestYPoint)
                endPoint = CGPoint(x:margin, y:self.bounds.height)
                
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
                CGContextRestoreGState(context)
                */
                
                // draw the line on top of the clipped gradient
                graphPath.lineWidth = 2.0
                graphPath.stroke()
                
                // draw circles for each point
                for i in 0..<lineData.count {
                    var point = CGPoint(x:columnXPoint(i), y:columnYPoint(lineData[i]))
                    point.x -= 5.0/2
                    point.y -= 5.0/2
                    
                    let circle = UIBezierPath(ovalInRect:
                        CGRect(origin: point,
                            size: CGSize(width: 5.0, height: 5.0)))
                    circle.fill()
                }
            }
            
        }
        
        
        /* MARK - Draw horizontal lines */
        
        var linePath = UIBezierPath()
        
        for (var i = 0; i <= 4; i++) {
            linePath.moveToPoint(CGPoint(x:margin, y: topBorder.advancedBy((CGFloat(i)/4.00)*graphHeight)))
            linePath.addLineToPoint(CGPoint(x: width - margin,
                y:topBorder.advancedBy((CGFloat(i)/4.00)*graphHeight)))
        }
        
        let color = UIColor(white: 1.0, alpha: 0.5)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
}
