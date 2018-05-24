//
//  PlotThings.swift
//  LinePlot
//
//  Created by Seth Bromberger on 2018-05-23.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

import Cocoa

let twoPi = CGFloat.pi * 2

protocol Renderer {
    /// Moves the pen to `position` without drawing anything.
    func move(to position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func line(to position: CGPoint)
    
    /// Draws the fragment of the circle centered at `c` having the given
    /// `radius`, that lies between `startAngle` and `endAngle`, measured in
    /// radians.
    func arc(at center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
}

protocol Drawable {
    func draw(into context: CGContext)
}

protocol Renderable {
    func render(into context: CGContext)
}

struct Circle : Drawable {
    private func makeSquare() -> CGRect {
        let x0 = center.x - radius
        let y0 = center.y - radius
        return CGRect(x:x0, y:y0, width: 2*radius, height: 2*radius)
    }
    
    func draw(into context: CGContext) {
        context.fillEllipse(in: makeSquare())
//        context.arc(at: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
    var center: Point
    var radius: Double
}

//struct Axes : Drawable {
//    var xmin: CGFloat
//    var xmax: CGFloat
//    var ymin: CGFloat
//    var ymax: CGFloat
//
//    func draw(into renderer: Renderer) {
//        let xAxisMin = CGPoint(x: xmin, y: ymax)
//        let xAxisMax = CGPoint(x: xmax, y: ymax)
//        let yAxisMax = CGPoint(x: xmin,
//                               y: ymin)
//        renderer.move(to: xAxisMax)
//        renderer.line(to: xAxisMin)
//        renderer.line(to: yAxisMax)
//
//
//    }
//}

struct PlotArea : Renderable {
    var xPadding: Double
    var yPadding: Double
    
    func render(into context: CGContext) -> NSRect {
        return NSRect(x: context. )
    }
}
struct Point {
    let x: Double
    let y: Double
}

//var circle = Circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)

class PlotThings: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current!.cgContext
        context.saveGState()
//        context.setFillColor(NSColor.blue.cgColor)
        let circle = Circle(center: Point(x:0, y:0), radius: 20)
        circle.draw(into: context)
//        let smallSquare = NSRect(x:0, y:0, width:10, height:10)
//        context.fillEllipse(in: smallSquare)
        context.restoreGState()
//        circle.draw(into: dirtyRect)
        // Drawing code here.
    }
    
}
