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
//    func draw(into context: CGContext)
}

protocol Renderable {
//    func render(into context: CGContext)
}

struct PlotPoint : Drawable {
    var center: Point
    var radius: Double
    var color: CGColor
    private func makeSquare() -> CGRect {
        let x0 = center.x - radius
        let y0 = center.y - radius
        let origin = CGPoint(x: x0, y: y0) // change this to scale it somehow
        let size = CGSize(width: 2*radius, height: 2*radius)
        return CGRect(origin: origin, size: size)
    }
    
    func draw(into context: CGContext, scaler:(PlotPoint) -> PlotPoint) {
        context.saveGState()
        context.setFillColor(color)
        let scaledPoint = scaler(self)
//        print(scaledPoint)
        context.fillEllipse(in: scaledPoint.makeSquare())
        context.restoreGState()
//        context.arc(at: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
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

func min(_ x: Double, _ y: Double) -> Double {
    if (x < y) {
        return x
    }
    return y
}

func max(_ x: Double, _ y: Double) -> Double {
    if (x > y) {
        return x
    }
    return y
}

struct PlotArea : Renderable {
    static let fontHeight = 20.0
    let lowerLeft: Point
    let upperRight: Point
    let padding: Point
    var dataRect: NSRect {
        let fontHeight = PlotArea.fontHeight
        let width = upperRight.x - lowerLeft.x - fontHeight
        let height = upperRight.y - lowerLeft.y - fontHeight
        return NSRect(x: lowerLeft.x + fontHeight, y: lowerLeft.y + fontHeight, width: width, height: height)
    }
    var xLabelArea: NSRect {
        let fontHeight = PlotArea.fontHeight
        let width = upperRight.x - lowerLeft.x - fontHeight
        let height = fontHeight
        return NSRect(x: lowerLeft.x + fontHeight, y:lowerLeft.y, width: width, height: height)
    }
    
    var yLabelArea: NSRect {
        let fontHeight = PlotArea.fontHeight
        let width = 20.0
        print("upperRight.y = \(upperRight.y), lowerLeft.y = \(lowerLeft.y)")
        let height = upperRight.y - lowerLeft.y - (fontHeight * 4.0)
        return NSRect(x:lowerLeft.x, y:lowerLeft.y + fontHeight, width: width, height: height)
    }
}

struct Point {
    let x: Double
    let y: Double
    
    init(_ x:Double, _ y:Double) {
        self.x = x
        self.y = y
    }
    
    init(_ tuple:(Double, Double)) {
        self.x = tuple.0
        self.y = tuple.1
    }
}

/// Return the minimum and maximum x and y values from an array of PlotPoints.
private func getBounds(from plotPoints:[PlotPoint]) -> (Point, Point){
    var minbounds = (Double.infinity, Double.infinity)
    var maxbounds = (0.0, 0.0)
    for point in plotPoints {
//        print("minbounds = \(minbounds), maxbounds = \(maxbounds)")
        let x = point.center.x
        let y = point.center.y
        minbounds.0 = min(minbounds.0, x)
        minbounds.1 = min(minbounds.1, y)
        maxbounds.0 = max(maxbounds.0, x)
        maxbounds.1 = max(maxbounds.1, y)
        
    }
    return (Point(minbounds), Point(maxbounds))
    
}

struct ScatterPlot : Renderable {
    var plotArea: PlotArea
    var plotPoints: [PlotPoint]
    var minBounds: Point
    var maxBounds: Point
    var xLabel: String
    var yLabel: String
    init(plotArea: PlotArea, plotPoints: [PlotPoint]) {
        self.plotArea = plotArea
        self.plotPoints = plotPoints
        (self.minBounds, self.maxBounds) = getBounds(from: plotPoints)
        xLabel = "X axis"
        yLabel = "Y axis"
    }
    
    private func scale(_ plotPoint: PlotPoint) -> PlotPoint {
        let r = plotPoint.radius
        let boundsRangeX = maxBounds.x - minBounds.x
        let boundsRangeY = maxBounds.y - minBounds.y
        
        let pctX = plotPoint.center.x / boundsRangeX
        let pctY = plotPoint.center.y / boundsRangeY
        
        
        let areaMinX = Double(plotArea.dataRect.minX)
        let areaMaxX = Double(plotArea.dataRect.maxX)
        let areaMinY = Double(plotArea.dataRect.minY)
        let areaMaxY = Double(plotArea.dataRect.maxY)
        
        let areaRangeX = areaMaxX - areaMinX
        let areaRangeY = areaMaxY - areaMinY
        
        let scaledX = pctX * areaRangeX + areaMinX - r
        let scaledY = pctY * areaRangeY + areaMinY - r
        
        return PlotPoint(center: Point(scaledX, scaledY), radius: plotPoint.radius, color: plotPoint.color)
    }

    private mutating func setNewBounds(from plotPoints:[PlotPoint]) {
        let (minboundsFrom, maxboundsFrom) = getBounds(from: plotPoints)
        let minb = (min(minBounds.x, minboundsFrom.x), min(minBounds.y, minboundsFrom.y))
        let maxb = (max(maxBounds.x, maxboundsFrom.x), max(maxBounds.y, maxboundsFrom.y))
        minBounds = Point(minb)
        maxBounds = Point(maxb)
    }
    
    mutating func addPoints(_ points:[Point], color: CGColor = NSColor.black.cgColor, size: Double = 3) {
        let plotPoints = points.map { point in PlotPoint(center: point, radius: size, color: color) }
        self.plotPoints.append(contentsOf: plotPoints)
        setNewBounds(from: plotPoints)
    }
    
    mutating func addPoint(_ point: Point, color: CGColor = NSColor.black.cgColor, size: Double = 3) {
        let plotPoint = PlotPoint(center: point, radius: size, color: color)
        self.plotPoints.append(plotPoint)
        setNewBounds(from: [plotPoint])
    }
    
    func draw(into context:CGContext) {
        for plotPoint in plotPoints {
            plotPoint.draw(into: context, scaler: scale)
        }
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.center;
        let xAttributes: [NSAttributedStringKey : Any] = [
            .paragraphStyle: paraStyle
        ]
        xLabel.draw(in:plotArea.xLabelArea, withAttributes: xAttributes)
        let yAttributes: [NSAttributedStringKey : Any] = [
            .verticalGlyphForm: NSNumber(integerLiteral: 1),
            .paragraphStyle: paraStyle,
                
            
        ]
        
        let trans = NSAffineTransform()
        trans.rotate(byDegrees: 90)
        
        yLabel.draw(in: plotArea.yLabelArea, withAttributes:yAttributes)
    }
}
//var circle = Circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)


class PlotThings: NSView {
    var lotsOfPoints = (1...1000).map { _ -> PlotPoint in
    
        let randX = Double(arc4random() % 10)
        let randY = Double(arc4random() % 10)
        let randR = 1.0
        return PlotPoint(center: Point(randX, randY), radius: randR, color: NSColor.red.cgColor)
    }


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current!.cgContext
        context.saveGState()
//        context.setFillColor(NSColor.blue.cgColor)
        let plotarea = PlotArea(lowerLeft: Point(0, 0), upperRight: Point(300, 300), padding: Point(10, 10))
        
        
        let scatterplot = ScatterPlot(plotArea: plotarea, plotPoints: lotsOfPoints)
        scatterplot.draw(into: context)
//        let circle1 = PlotPoint(center: Point(x:100, y:100), radius: 20, color: NSColor.red.cgColor)
//        let circle2 = PlotPoint(center: Point(x:200, y:200), radius: 10, color: NSColor.blue.cgColor)
//        circle1.draw(into: context)
//        circle2.draw(into: context)
        
//        let smallSquare = NSRect(x:0, y:0, width:10, height:10)
//        context.fillEllipse(in: smallSquare)
        context.restoreGState()
//        circle.draw(into: dirtyRect)
        // Drawing code here.
    }
    
}
