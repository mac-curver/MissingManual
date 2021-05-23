//
//  TestGradient.m
//  GradientTestApplication
//
//  Created by Heinz-Jörg on 23.05.21.
//  Copyright © 2021 Heinz-Jörg. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GradientTestApplication/AppDelegate.h"
#import "TestGradient.h"
#import "MyLog.h"

#define USE_CG_CONTEXT

@implementation TestGradient

- (instancetype) initWithFrame:(NSRect)frameRect {
    // Not called anymore
    if (self = [super initWithFrame:frameRect]) {
        // Initialize self
    }
    return self;
}

- (NSNumber*)convertValue:(double)value {
    if (value < 0) {
        return [NSNumber numberWithDouble:0];
    }
    else if (value > 1) {
        return [NSNumber numberWithDouble:1];
    }
    else {
        return [NSNumber numberWithDouble:value];
    }
    
}

- (void)initWithDelegateValues {
    AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    
    
    _startLocation = appDelegate->location0.doubleValue;
    _endLocation   = appDelegate->location1.doubleValue;
    _kind = Linear;
    _startColor = appDelegate->color0.color;
    _endColor   = appDelegate->color1.color;
}

- (instancetype) initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        //_gradient = [CAGradientLayer layer];
        _startLocation = 0.0;
        _endLocation   = 1.0;
        _startPoint = NSMakePoint(30, 70);
        _endPoint   = NSMakePoint(500, 30.0);
        _kind       = Linear;
        _startColor = NSColor.blueColor;
        _endColor   = NSColor.redColor;

    }
    return self;
}

- (void)circleArround:(NSPoint)point{
    const int Radius = 25;
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:
        NSMakeRect(point.x - Radius/2
                 , point.y - Radius/2
                 , Radius, Radius
        )
    ];
    [path stroke];
}

#ifdef USE_CG_CONTEXT
- (void)gradientWithCGContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
    
    // 2
    [NSGraphicsContext saveGraphicsState];
    
    // 3
    //CGColorSpaceRef colorSpace = NSGraphicsContext.currentContext.graphicsPort;//CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);

    
    // 5
    CGFloat components[8];
    [_startColor getComponents:&components[0]];
    [_endColor   getComponents:&components[4]];

    // 6
    double locations[] = {[defaults doubleForKey:@"lowerValue"]
                        , [defaults doubleForKey:@"upperValue"]
    };
    
    // 7
    CGGradientRef gradient = CGGradientCreateWithColorComponents(
                                     colorSpace, components
                                   , locations, 2
                             );
    
    
    // 9
    
    switch (_kind) {
        case Linear:
            CGContextDrawLinearGradient(context, gradient
                                        , _startPoint, _endPoint, 0
            );
            break;
        case Radial:
            CGContextDrawRadialGradient(context, gradient
                                        , _startPoint, [defaults doubleForKey:@"lowerValue"]
                                        , _endPoint,   [defaults doubleForKey:@"upperValue"]
                                        , 0
            );

            break;
        case Conic:
        default:
            break;
    }
    
    [NSGraphicsContext restoreGraphicsState];

}
#endif

- (CGMutablePathRef)cgPathFromPath:(NSBezierPath *)path {
    CGMutablePathRef cgPath = CGPathCreateMutable();
    NSInteger n = [path elementCount];
    
    for (NSInteger i = 0; i < n; i++) {
        NSPoint ps[3];
        switch ([path elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement: {
                CGPathMoveToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSLineToBezierPathElement: {
                CGPathAddLineToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSCurveToBezierPathElement: {
                CGPathAddCurveToPoint(cgPath, NULL, ps[0].x, ps[0].y, ps[1].x, ps[1].y, ps[2].x, ps[2].y);
                break;
            }
            case NSClosePathBezierPathElement: {
                CGPathCloseSubpath(cgPath);
                break;
            }
            default: NSAssert(0, @"Invalid NSBezierPathElement");
        }
    }
    return cgPath;
}


- (void)addCircle:(NSPoint)point :(int)layerIndex {
    const double Radius = 25;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    if (self.layer.sublayers[layerIndex]) {
        [self.layer replaceSublayer:self.layer.sublayers[layerIndex] with:shapeLayer];
    }
    else {
        [self.layer addSublayer:shapeLayer];
    }
    
    CGPathRef cgPath = CGPathCreateWithEllipseInRect(
                           CGRectMake(  point.x-Radius/2
                                      , point.y-Radius/2
                                      , Radius, Radius)
                         , NULL
                       );
    
    shapeLayer.path = cgPath;
    shapeLayer.strokeColor = NSColor.greenColor.CGColor;
    shapeLayer.fillColor = NULL;
    shapeLayer.lineWidth = 1;
}

- (void)drawRect:(NSRect)dirtyRect {
    
#ifdef USE_CG_CONTEXT
    
    [self gradientWithCGContext];
    [NSColor.blackColor set];
    [self circleArround:_startPoint];
    [self circleArround:_endPoint];
    
#else
    

    // Works
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.bounds;
    NSLog(@"%f %f", _startLocation, _endLocation);
    gradient.locations = @[[NSNumber numberWithDouble:_startLocation]
                         , [NSNumber numberWithDouble:_endLocation]];
    gradient.startPoint = NSMakePoint(_startPoint.x/self.bounds.size.width
                                     ,_startPoint.y/self.bounds.size.height
    );
    gradient.endPoint   = NSMakePoint(_endPoint.x/self.bounds.size.width
                                     ,_endPoint.y/self.bounds.size.height
    );
     
    switch (_kind) {
        case Linear:
            gradient.type       = kCAGradientLayerAxial;
            break;
        case Radial:
            gradient.type       = kCAGradientLayerRadial;
            break;
        default:
            //gradient.type     = kCAGradientLayerConic;
            break;
    }
     
    gradient.colors = @[(id)_startColor.CGColor, (id)_endColor.CGColor];
    
    if (self.layer.sublayers[0]) {
        [self.layer replaceSublayer:self.layer.sublayers[0] with:gradient];
    }
    else {
        [self.layer insertSublayer:gradient atIndex:0];
    }
   
    [self addCircle:_startPoint :1];
    [self addCircle:_endPoint   :2];

#endif
    
}

- (IBAction)updateKind:(NSSegmentedControl *)sender {
    _kind = sender.selectedSegment;
    
    [self setNeedsDisplay:YES];
}

- (IBAction)updateStartColor:(NSColorWell *)sender {
    _startColor = sender.color;
    [self setNeedsDisplay:true];
}

- (IBAction)updateEndColor:(NSColorWell *)sender {
    _endColor = sender.color;
    [self setNeedsDisplay:YES];
}

- (IBAction)updateStartLocation:(NSTextField *)sender {
    _startLocation = sender.doubleValue;
    NSLog(@"%f", sender.doubleValue);
    NSLog(@"%f", _startLocation);
    [self setNeedsDisplay:YES];
}

- (IBAction)updateEndLocation:(NSTextField *)sender {
    _endLocation = sender.doubleValue;
    [self setNeedsDisplay:YES];
}

- (IBAction)sliderStartLocation:(NSSlider *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction)sliderEndLocation:(NSSlider *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction)updateStartRadius:(NSTextField *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction)updateEndRadius:(NSTextField *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction)stepperStartRadius:(NSStepper *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction)stepperEndRadius:(NSStepper *)sender {
    [self setNeedsDisplay:YES];
}



- (double) manhattanDistanceFrom:(NSPoint)from to:(NSPoint)to {
    return (fabs(from.x - to.x) + fabs(from.y - to.y));
}

- (NSPoint *)closer:(NSPoint)targetPoint {
    if (
        [self manhattanDistanceFrom:targetPoint to:_startPoint]
      < [self manhattanDistanceFrom:targetPoint to:_endPoint]
    )
        return &_startPoint;
    else
        return &_endPoint;

}

- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender {
    static NSPoint *pointPtr;
    switch (sender.state) {
        case NSGestureRecognizerStateBegan:
            // Identify the point to be dragged
            pointPtr = [self closer:[sender locationInView:self]];
            // fallthrough
        case NSGestureRecognizerStateChanged:
            *pointPtr = [sender locationInView:self];
            [self setNeedsDisplay:YES];
            break;
        default:
            break;
    }
}

@end
