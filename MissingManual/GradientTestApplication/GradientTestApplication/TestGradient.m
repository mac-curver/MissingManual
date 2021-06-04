//
//  TestGradient.m
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  changed by LegoEsprit on 29.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GradientTestApplication/AppDelegate.h"
#import "TestGradient.h"
#import "MyLog.h"

//#define USE_CG_CONTEXT                                                          // if not defined uses CA context, but not yet finished


NS_ASSUME_NONNULL_BEGIN

@interface NSColor (NSColorExtension)

- (NSColor *) inverted;

@end

NS_ASSUME_NONNULL_END

@implementation NSColor (NSColorExtension)

- (NSColor *) inverted {
    NSColorSpaceName colorSpaceName = self.colorSpaceName;
    if (colorSpaceName == NSCalibratedRGBColorSpace
     || colorSpaceName == NSDeviceRGBColorSpace
    ) {
              return [NSColor colorWithCalibratedRed:(1.0 - self.redComponent)
                                           green:(1.0 - self.greenComponent)
                                            blue:(1.0 - self.blueComponent)
                                           alpha:self.alphaComponent
                  ];
    }
    else {
        return [NSColor blackColor];
    }
    
}

@end


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
    // defaults read de.LegoEsprit.GradientTestApplication2
    return @{
                @"endLocation"  : @0.8538228264790765
              , @"endRadius"    : @355.5
              , @"kind"         : @0
              , @"startLocation": @0
              , @"startRadius"  : @81

            };
};

- (NSInteger)numberOfKinds {
    switch (_drawingContext) {
        case CoreAnimation:
            if (@available(macOS 10.14, *)) {
                return N_GradientKinds;
            }
            else {
                return N_GradientKinds-1;
            }
        case Quartz:
        default:
            return N_GradientKinds-1;
    }
}



- (void)addSubLayers {
    [self.layer addSublayer:CAGradientLayer.layer];
    [self.layer addSublayer:CAShapeLayer.layer];
    [self.layer addSublayer:CAShapeLayer.layer];
}

- (instancetype) initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

        _startPoint         = NSMakePoint( 430, 100);
        _endPoint           = NSMakePoint( 500,  30.0);
        _drawingContext     = [defaults integerForKey:@"isNotQuartz"];
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
      
        
        [self addSubLayers];
     

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
    
    _drawingContext = Quartz;
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
                NSAssert(false, @"Invalid NSBezierPathElement");
                break;
        }
    }
    return cgPath;
}


- (void)addCircle:(NSPoint)point color:(NSColor*)color atSubLayer:(CAShapeLayer *)subLayer {
    const double Radius = 25;
    
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    if (shapeLayer) {
        if (subLayer) {
            [self.layer replaceSublayer:subLayer with:shapeLayer];
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
        shapeLayer.strokeColor = color.CGColor;
        shapeLayer.fillColor = NULL;
        shapeLayer.lineWidth = 1;
    }
}


- (void)drawQuartzContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
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
}

- (void)drawCoreAnimation {
    // Works, but crashes from time to time; CA not ARC compliant?

    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
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
    
    [self addCircle:_startPoint color:[_startColor inverted] atSubLayer:self.layer.sublayers[1]];
    [self addCircle:_endPoint   color:[_endColor inverted]   atSubLayer:self.layer.sublayers[2]];
}

- (void)drawRect:(NSRect)dirtyRect {

    //[centerTransform set];
    switch (_drawingContext) {
        case CoreAnimation:
            [self drawCoreAnimation];
            break;
        case Quartz:
        default:
            [self drawQuartzContext];
            break;
    }
    
    //[xform invert];
    //[xform concat];

}

- (IBAction)updateContext:(NSPopUpButton *)sender {
    _drawingContext = sender.indexOfSelectedItem;
    switch (_drawingContext) {
        case CoreAnimation:
            [self addSubLayers];
            break;
        case Quartz:
        default:
            self.layer.sublayers = nil;
            break;
    }
    [self setNeedsDisplay:YES];
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
    //NSAffineTransform *xForm = [NSAffineTransform transform];
    //[xForm appendTransform:centerTransform];
    //[xForm invert];
    //NSPoint mouseLoc = [xForm transformPoint:point];
    //return mouseLoc;
    return point;
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



- (NSString *)generateQuartzCode {
    NSString *text;

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
            text = [NSString stringWithFormat:
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
            text = [NSString stringWithFormat:
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

- (nonnull NSString *)code {
    switch (_drawingContext) {
        case Quartz:
            return [self generateQuartzCode];
        default:
            return [NSString stringWithFormat:@"Not yet supported"];
    }
}




@end
