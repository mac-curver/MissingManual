//
//  TestGradient.m
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GradientTestApplication/AppDelegate.h"
#import "TestGradient.h"
#import "MyLog.h"

//#define USE_CG_CONTEXT                                                          // if not defined uses CA context, but not yet finished

@implementation TestGradient

//CFStringRef const defaultColorSpaceRef = CFSTR("kCGColorSpaceGenericRGBLinear");

+ (NSString*) defaultColorSpace {
    //return CFBridgingRelease(kCGColorSpaceGenericRGBLinear);
    return (__bridge NSString *)kCGColorSpaceGenericRGBLinear;
}


+ (NSArray*) allColorSpaces {
    NSArray  *array = @[
           (NSString *)CFBridgingRelease(kCGColorSpaceGenericGray)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericCMYK)
         , (NSString *)CFBridgingRelease(kCGColorSpaceDisplayP3)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericRGBLinear)
         , (NSString *)CFBridgingRelease(kCGColorSpaceAdobeRGB1998)
         , (NSString *)CFBridgingRelease(kCGColorSpaceSRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericGrayGamma2_2)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericXYZ)
         , (NSString *)CFBridgingRelease(kCGColorSpaceGenericLab)
         , (NSString *)CFBridgingRelease(kCGColorSpaceACESCGLinear)
         , (NSString *)CFBridgingRelease(kCGColorSpaceITUR_709)
         , (NSString *)CFBridgingRelease(kCGColorSpaceITUR_2020)
         , (NSString *)CFBridgingRelease(kCGColorSpaceROMMRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceDCIP3)
         , (NSString *)CFBridgingRelease(kCGColorSpaceExtendedSRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceLinearSRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceExtendedLinearSRGB)
         , (NSString *)CFBridgingRelease(kCGColorSpaceExtendedGray)
         , (NSString *)CFBridgingRelease(kCGColorSpaceLinearGray)
         , (NSString *)CFBridgingRelease(kCGColorSpaceExtendedLinearGray)
    ];
    
    return array;
}

+ (NSDictionary *)gradientDefaults {
    return @{
                @"endLocation"  : @0.8538228264790765
              , @"endRadius"    : @355.5
              , @"kind"         : @0
              , @"lowerValue"   : @37.51571479885057
              , @"startLocation": @0
              , @"startRadius"  : @81
              , @"upperValue"   : @7.219625538793103

            };
};

+ (NSInteger)numberOfKinds {
#ifdef USE_CG_CONTEXT
    return N_GradientKinds-1;
#else
    if (@available(macOS 10.14, *)) {
        return N_GradientKinds;
    }
    else {
        return N_GradientKinds-1;
    }
#endif
}



- (instancetype) initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

        //_gradient = [CAGradientLayer layer];
        _startPoint         = NSMakePoint( 430, 100);
        _endPoint           = NSMakePoint( 500,  30.0);
        _kind               = [defaults integerForKey:@"kind"];
        _startColor         = NSColor.blueColor;
        _endColor           = NSColor.redColor;
        _options            = 0;
        _currentColorSpace  = (__bridge CFStringRef _Nonnull)(TestGradient.defaultColorSpace);
        centerTransform     = [NSAffineTransform transform];
        centerMove          = NSMakePoint(0.0, 0.0);
        initialSize         = self.frame.size;
        _alpha              = 1.0;
        
#ifdef USE_CG_CONTEXT
#else
        
        [self.layer addSublayer:_gradientLayer];
        [self.layer addSublayer:_shape1Layer];
        [self.layer addSublayer:_shape2Layer];

#endif
        
        
    }
    return self;
}


- (instancetype) initWithFrame:(NSRect)frameRect {
    // Not called anymore
    NSAssert(0, @"Strange but not called anymore - use initWithCoder instead");
    if (self = [super initWithFrame:frameRect]) {
        // Initialize self
    }
    return self;
}

- (void)moveContentsTowardsCenter:(CGFloat)dx dy:(CGFloat)dy {
    // Move the points towards center (can get it done inside drawRect as
    // then I would need an inverted NSAffineTransform for the
    // MouseCoordinate and that one did not work on Retina display)
    // how to improve this?

    _startPoint = NSMakePoint(_startPoint.x+dx, _startPoint.y+dy);
    _endPoint   = NSMakePoint(_endPoint.x  +dx, _endPoint.y  +dy);
}

- (void)setFrame:(CGRect)newFrame {
    CGFloat dx = self.frame.size.width;
    CGFloat dy = self.frame.size.height;
    [super setFrame:newFrame];
    
    dx = (newFrame.size.width  - dx)/2;
    dy = (newFrame.size.height - dy)/2;
    [self moveContentsTowardsCenter:dx dy:dy];
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
    
    //_startLocation = appDelegate->location0.doubleValue;
    //_endLocation   = appDelegate->location1.doubleValue;
    _kind = Linear;
    _startColor = appDelegate->color0.color;
    _endColor   = appDelegate->color1.color;
}



- (void)circleArround:(NSPoint)point radius:(double)radius {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:
        NSMakeRect(point.x - radius
                 , point.y - radius
                 , 2*radius, 2*radius
        )
    ];
    [path stroke];
}

#ifdef USE_CG_CONTEXT
- (void)gradientWithCGContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
    
    [NSGraphicsContext saveGraphicsState];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(_currentColorSpace);

    CGFloat components[8];
    [_startColor getComponents:&components[0]];
    [_endColor   getComponents:&components[4]];

    double locations[] = {[defaults doubleForKey:@"startLocation"]
                        , [defaults doubleForKey:@"endLocation"]
    };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(
                                     colorSpace, components
                                   , locations, 2
                             );
    
    
    switch (_kind) {
        case Radial:
            CGContextDrawRadialGradient(
                  context, gradient
                , _startPoint, [defaults doubleForKey:@"startRadius"]
                , _endPoint,   [defaults doubleForKey:@"endRadius"]
                , _options
            );

            break;
        case Conic:                                                             // not supported in quartz
        case Linear:
            CGContextDrawLinearGradient(
                  context, gradient
                , _startPoint, _endPoint, _options
            );
            break;
        default:
            break;
    }
    
    [NSGraphicsContext restoreGraphicsState];

}
#endif

#ifdef USE_CG_CONTEXT
#else
- (CGMutablePathRef)cgPathFromPath:(NSBezierPath *)path {
    CGMutablePathRef cgPath = CGPathCreateMutable();
    
    for (NSInteger i = 0; i < [path elementCount]; i++) {
        NSPoint ps[3];
        switch ([path elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement:
                CGPathMoveToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            case NSLineToBezierPathElement:
                CGPathAddLineToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            case NSCurveToBezierPathElement:
                CGPathAddCurveToPoint(cgPath, NULL, ps[0].x, ps[0].y
                                      , ps[1].x, ps[1].y, ps[2].x, ps[2].y
                );
                break;
            case NSClosePathBezierPathElement:
                CGPathCloseSubpath(cgPath);
                break;
            default:
                NSAssert(0, @"Invalid NSBezierPathElement");
                break;
        }
    }
    return cgPath;
}


- (void)addCircle:(NSPoint)point atSubLayer:(CAShapeLayer *)subLayer {
    const double Radius = 25;
    
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    if (shapeLayer) {
        if (subLayer) {
            [self.layer replaceSublayer:subLayer
                                   with:shapeLayer];
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
}

#endif

- (void)drawRect:(NSRect)dirtyRect {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

    //[centerTransform set];
    
#ifdef USE_CG_CONTEXT
    
    [self gradientWithCGContext];

    [[NSColor.blackColor colorWithAlphaComponent:_alpha] set];
    
    switch (_kind) {
        case Radial:
            [self circleArround:_startPoint radius:[defaults doubleForKey:@"startRadius"]];
            [self circleArround:_endPoint   radius:[defaults doubleForKey:@"endRadius"]];
            break;
        default:
            [self circleArround:_startPoint radius:10.0];
            [self circleArround:_endPoint   radius:10.0];
            break;
    }


#else
    

    // Works, but crashes from time to time; CA not ARC compliant?
    CAGradientLayer *gradientLayer = CAGradientLayer.layer;
    
    gradientLayer.frame = self.bounds;
    gradientLayer.locations = @[
         [NSNumber numberWithDouble:[defaults doubleForKey:@"startLocation"]]
       , [NSNumber numberWithDouble:[defaults doubleForKey:@"endLocation"]]
    ];
    
    gradientLayer.startPoint = NSMakePoint(
                                       _startPoint.x/self.bounds.size.width
                                     , _startPoint.y/self.bounds.size.height
                               );
    gradientLayer.endPoint   = NSMakePoint(
                                       _endPoint.x/self.bounds.size.width
                                     , _endPoint.y/self.bounds.size.height
                               );
     
    switch (_kind) {
        case Conic:
            if (@available(macOS 10.14, *)) {
                gradientLayer.type = kCAGradientLayerConic;
            } else {
                // Fallback on earlier versions
            }
            break;
        case Radial:
            gradientLayer.type = kCAGradientLayerRadial;
            break;
        case Linear:
        default:
            gradientLayer.type = kCAGradientLayerAxial;
            break;
    }
     
    gradientLayer.colors = @[(id)_startColor.CGColor, (id)_endColor.CGColor];
    
    if (self.layer.sublayers[0]) {
        [self.layer replaceSublayer:self.layer.sublayers[0] with:gradientLayer];
    }
    else {
        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
   
    [self addCircle:_startPoint atSubLayer:self.layer.sublayers[1]];
    [self addCircle:_endPoint   atSubLayer:self.layer.sublayers[2]];

#endif
    
    //[xform invert];
    //[xform concat];

    
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

- (IBAction)setStartOver:(NSButton *)sender {
    switch (sender.state) {
        case NSControlStateValueOn:
            _options |= kCGGradientDrawsBeforeStartLocation;
            break;
        default:
            _options &= ~kCGGradientDrawsBeforeStartLocation;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (IBAction)setEndOver:(NSButton *)sender {
    switch (sender.state) {
        case NSControlStateValueOn:
            _options |= kCGGradientDrawsAfterEndLocation;
            break;
        default:
            _options &= ~kCGGradientDrawsAfterEndLocation;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (IBAction)selectColorSpace:(NSPopUpButton *)sender {
    _currentColorSpace = (__bridge CFStringRef _Nonnull)(sender.selectedItem.title);
    [self setNeedsDisplay:YES];
}



- (double) manhattanDistanceFrom:(NSPoint)from to:(NSPoint)to {
    return (fabs(from.x - to.x) + fabs(from.y - to.y));
}

- (NSPoint *)findElement:(NSPoint)targetPoint {
    if (
        [self manhattanDistanceFrom:targetPoint to:_startPoint]
      < [self manhattanDistanceFrom:targetPoint to:_endPoint]
    )
        return &_startPoint;
    else
        return &_endPoint;
}

- (NSPoint)inverseTransformPoint:(NSPoint)point {
    NSAffineTransform *xForm = [NSAffineTransform transform];
    [xForm appendTransform:centerTransform];
    [xForm invert];
    NSPoint mouseLoc = [xForm transformPoint:point];
    return mouseLoc;
}

- (NSTimer * _Nonnull)fadeCirclesOut {
    // how to do this with animation or ca animation?
    if (self.fadeOutTimer.isValid) [self.fadeOutTimer invalidate];

    return _fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                    repeats:YES
                                      block:(void (^)(NSTimer *timer)) ^{
                                          self.alpha -= 0.01;
                                          if (self.alpha < 0) {
                                              [self.fadeOutTimer invalidate];
                                              self.fadeOutTimer = NULL;
                                          }
                                          [self setNeedsDisplay:YES];
                                      }
                            ];
}

- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender {
    static NSPoint *pointPtr;

    NSPoint mouseLoc = [self inverseTransformPoint:[sender locationInView:self]];

    switch (sender.state) {
        case NSGestureRecognizerStateBegan:
            // Identify the point to be dragged
            pointPtr = [self findElement:mouseLoc];
            _alpha = 1.0;
            // fallthrough
        case NSGestureRecognizerStateChanged:
            *pointPtr = mouseLoc;
            [self setNeedsDisplay:YES];
            if (self.fadeOutTimer.isValid) {
                [self.fadeOutTimer invalidate];
                self.fadeOutTimer = NULL;
            }
            break;
        case NSGestureRecognizerStateEnded:
            [self fadeCirclesOut];
            break;
        default:
            break;
    }
}



- (nonnull NSString *)code {
    NSMutableString *text;
    
    CGFloat components[8];
    [_startColor getComponents:&components[0]];
    [_endColor   getComponents:&components[4]];
    
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    double locations[] = {[defaults doubleForKey:@"startLocation"]
        , [defaults doubleForKey:@"endLocation"]
    };
    
    double startRadius = [defaults doubleForKey:@"startRadius"];
    double endRadius   = [defaults doubleForKey:@"endRadius"];



    switch (_kind) {
        case Linear:
            text = [NSMutableString stringWithFormat:
                   @""
                    "CGGradientRef gradient = CGGradientCreateWithColorComponents(\n"
                    "    CGColorSpaceCreateWithName(%@)\n"
                    "  , (const CGFloat[]){  %f, %f, %f, %f\n"
                    "                      , %f, %f, %f, %f}\n"
                    "  , (const CGFloat[]){%f, %f}, 2\n"
                    ");\n"
                    "CGContextDrawLinearGradient(\n"
                    "    NSGraphicsContext.currentContext.graphicsPort\n"
                    "  , gradient\n"
                    "  , NSMakePoint(%f, %f), NSMakePoint(%f, %f), %d\n"
                    ");"
                    , _currentColorSpace
                    , components[0], components[1], components[2], components[3]
                    , components[4], components[5], components[6], components[7]
                    , locations[0], locations[1]
                    , _startPoint.x, _startPoint.y
                    , _endPoint.x, _endPoint.y
                    , _options
                    ];
            break;
        case Radial:
            text = [NSMutableString stringWithFormat:
                    @""
                    "CGGradientRef gradient = CGGradientCreateWithColorComponents(\n"
                    "    CGColorSpaceCreateWithName(%@)\n"
                    "  , (const CGFloat[]){  %f, %f, %f, %f\n"
                    "                      , %f, %f, %f, %f}\n"
                    "  , (const CGFloat[]){%f, %f}, 2\n"
                    ");\n"
                    "CGContextDrawRadialGradient(\n"
                    "    NSGraphicsContext.currentContext.graphicsPort\n"
                    "  , gradient\n"
                    "  , NSMakePoint(%f, %f), %f\n"
                    "  , NSMakePoint(%f, %f), %f\n"
                    "  , %d\n"
                    ");"
                    , _currentColorSpace
                    , components[0], components[1], components[2], components[3]
                    , components[4], components[5], components[6], components[7]
                    , locations[0], locations[1]
                    , _startPoint.x, _startPoint.y, startRadius
                    , _endPoint.x, _endPoint.y, endRadius
                    , _options
                    ];
            break;
        case Conic:
            
        default:
            break;
    }

    return text;
}




@end
