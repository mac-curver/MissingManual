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
#import "UserDefaultExtension.h"
#import "MyLog.h"


NS_ASSUME_NONNULL_BEGIN

@interface NSColor (NSColorExtension)

- (NSColor *)complement:(double) alpha;
- (NSColor *)opposite:(double) alpha;
- (BOOL)isLight;

@end

NS_ASSUME_NONNULL_END

@implementation NSColor (NSColorExtension)


- (BOOL)isLight {
    CGFloat white = 0;
    [self getWhite:&white alpha:nil];
    return white > 0.5;
}

- (NSColor *)opposite:(double) alpha {
    double ignored;
    return [NSColor colorWithCalibratedRed:(CGFloat)modf(0.5 + self.redComponent   , &ignored)
                                     green:(CGFloat)modf(0.5 + self.greenComponent , &ignored)
                                      blue:(CGFloat)modf(0.5 + self.blueComponent  , &ignored)
                                     alpha:alpha
            ];
}


- (NSColor *)complement:(double) alpha {
    NSColorSpaceName colorSpaceName = self.colorSpaceName;
    if (colorSpaceName == NSCalibratedRGBColorSpace
     || colorSpaceName == NSDeviceRGBColorSpace
    ) {
         return [NSColor colorWithCalibratedRed:(1.0 - self.redComponent)
                                      green:(1.0 - self.greenComponent)
                                       blue:(1.0 - self.blueComponent)
                                      alpha:alpha
                 ];
    }
    else {
        // Avoid crash, when not in RGB-Color space
        // May be we should use a different algo here
        return [NSColor.blackColor colorWithAlphaComponent:alpha];
    }
    
}

@end


@implementation TestGradient



//CFStringRef const defaultColorSpaceRef = CFSTR("kCGColorSpaceGenericRGBLinear");

+ (NSString*) defaultColorSpaceName {
    //return CFBridgingRelease(kCGColorSpaceGenericRGBLinear);
    return (__bridge NSString*)kCGColorSpaceGenericRGB;
}


+ (NSArray*) allColorSpaceNames {
    NSArray  *array = @[
           (NSString *)CFBridgingRelease(kCGColorSpaceGenericRGB)
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
                  @"endLocation"        : @1.0
                , @"endRadius"          : @200.0
                , @"kind"               : @0
                , @"startLocation"      : @0
                , @"startRadius"        : @50
                , @"isNotQuartz"        : @0
                , @"StartColor.alpha"   : @1.0                                  /// Does not work, probably /" too many
                , @"StartColor.red"     : @1.0
                , @"StartColor.green"   : @0.0
                , @"StartColor.blue"    : @0.0
                , @"StartPoint.x"       : @-4.19921875                          /// Does not work, probably /" too many
                , @"StartPoint.y"       : @0.9609375
                , @"EndColor.alpha"     : @1.0
                , @"EndColor.red"       : @0.0
                , @"EndColor.green"     : @1.0
                , @"EndColor.blue"      : @0.0
                , @"EndPoint.x"         : @690.609375
                , @"EndPoint.y"         : @334.48046875

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




 
- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
        //AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;

        _startPoint         = [defaults pointForKey:@"StartPoint" default:NSMakePoint(10.0, 10.0)];
        _endPoint           = [defaults pointForKey:@"EndPoint" default:NSMakePoint(500.0, 400.0)];
        _drawingContext     = [defaults integerForKey:@"isNotQuartz"];
        _kind               = [defaults integerForKey:@"kind"];
        _options            = 0;
        _currentColorSpace  = (__bridge CFStringRef _Nonnull)(TestGradient.defaultColorSpaceName);
        
        //centerTransform     = [NSAffineTransform transform];                  // I had issues with Retina display
        _alpha              = 1.0;
        
        _startColor         = [defaults colorForKey:@"StartColor" default:NSColor.redColor];
        _endColor           = [defaults colorForKey:@"EndColor" default:NSColor.greenColor];

        
        /*
         // copied from documentation
         @property (class, strong, readonly) NSColorSpace *sRGBColorSpace NS_AVAILABLE_MAC(10_5);
         @property (class, strong, readonly) NSColorSpace *genericGamma22GrayColorSpace NS_AVAILABLE_MAC(10_6);             // The grayscale color space with gamma 2.2, compatible with sRGB
         
         @property (class, strong, readonly) NSColorSpace *extendedSRGBColorSpace NS_AVAILABLE_MAC(10_12);                  // sRGB compatible color space that allows specifying components beyond the range of [0.0, 1.0]
         @property (class, strong, readonly) NSColorSpace *extendedGenericGamma22GrayColorSpace NS_AVAILABLE_MAC(10_12);    // sRGB compatible gray color space that allows specifying components beyond the range of [0.0, 1.0]
         
         @property (class, strong, readonly) NSColorSpace *displayP3ColorSpace NS_AVAILABLE_MAC(10_12);     // Standard DCI-P3 primaries, a D65 white point, and the same gamma curve as the sRGB IEC61966-2.1 color space
         
         @property (class, strong, readonly) NSColorSpace *adobeRGB1998ColorSpace NS_AVAILABLE_MAC(10_5);
         
         @property (class, strong, readonly) NSColorSpace *genericRGBColorSpace;        // NSColorSpace corresponding to Cocoa color space name NSCalibratedRGBColorSpace
         @property (class, strong, readonly) NSColorSpace *genericGrayColorSpace;       // NSColorSpace corresponding to Cocoa color space name NSCalibratedWhiteColorSpace
         @property (class, strong, readonly) NSColorSpace *genericCMYKColorSpace;
         @property (class, strong, readonly) NSColorSpace *deviceRGBColorSpace;         // NSColorSpace corresponding to Cocoa color space name NSDeviceRGBColorSpace
         @property (class, strong, readonly) NSColorSpace *deviceGrayColorSpace;        // NSColorSpace corresponding to Cocoa color space name NSDeviceWhiteColorSpace
         @property (class, strong, readonly) NSColorSpace *deviceCMYKColorSpace;        // NSColorSpace corresponding to Cocoa color space name NSDeviceCMYKColorSpace

         */

        _gradientLayer = CAGradientLayer.layer;
        _gradientLayer.name = @"Gradient";

        _shape1Layer   = CAShapeLayer.layer;
        _shape1Layer.name = @"Shape 1";
        _shape2Layer   = CAShapeLayer.layer;
        _shape2Layer.name = @"Shape 2";
        
        _myGravity = kCAGravityTopRight;
        
        NSTrackingArea *area = [[NSTrackingArea alloc]
                                initWithRect:self.bounds
                                     options:
                                          NSTrackingMouseMoved                  // within view
                                        | NSTrackingActiveInKeyWindow           // only if responder
                                        | NSTrackingInVisibleRect               // automatic size update
                                       owner:self
                                    userInfo:nil
                                ];
        [self addTrackingArea:area];

    }
    return self;
}

- (void)addSubLayers {
    
    [self.layer addSublayer:_gradientLayer];
    /*
     kCAGravityCenter
     kCAGravityTop
     kCAGravityBottom
     kCAGravityLeft
     kCAGravityRight
     kCAGravityTopLeft
     kCAGravityTopRight
     kCAGravityBottomLeft
     kCAGravityBottomRight
     kCAGravityResize
     kCAGravityResizeAspect
     kCAGravityResizeAspectFill
     */
    self.layer.contentsGravity = kCAGravityTopRight;
    
    CALayer *blueLayer = CALayer.layer;
    blueLayer.contentsGravity = kCAGravityTopRight;
    blueLayer.frame = CGRectMake(100, 100, 100, 100);
    blueLayer.backgroundColor = NSColor.blueColor.CGColor;
    blueLayer.name = @"Blue";
    [self.layer addSublayer:blueLayer];
    
    CALayer *redLayer = CALayer.layer;
    redLayer.contentsGravity = _myGravity;
    redLayer.frame = CGRectMake(200, 200, 100, 100);
    redLayer.backgroundColor = NSColor.redColor.CGColor;
    redLayer.name = @"Red";
    [self.layer addSublayer:redLayer];
    
    CALayer *yellowLayer = CALayer.layer;
    yellowLayer.contentsGravity = _myGravity;
    yellowLayer.frame = CGRectMake(300, 300, 100, 100);
    yellowLayer.backgroundColor = NSColor.yellowColor.CGColor;
    yellowLayer.name = @"Yellow";
    [self.layer addSublayer:yellowLayer];
    
    CALayer *greenLayer = CALayer.layer;
    greenLayer.contentsGravity = _myGravity;
    greenLayer.frame = CGRectMake(400, 400, 100, 100);
    greenLayer.backgroundColor = NSColor.greenColor.CGColor;
    greenLayer.name = @"Green";
    [self.layer addSublayer:greenLayer];
    
    [self.layer addSublayer:_shape1Layer];
    [self.layer addSublayer:_shape2Layer];


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
    //NSLog(@"%f", self.window.backingScaleFactor);
    
    //self.trackingAreas[0] = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved | NSTrackingActiveInKeyWindow owner:self userInfo:nil];

    
    switch (_drawingContext) {
        case Quartz:
            dx = (newFrame.size.width  - dx)/2;
            dy = (newFrame.size.height - dy)/2;
            [self moveContentsTowardsCenter:dx dy:dy];
            //[centerTransform translateXBy:dx * self.window.backingScaleFactor
            //                          yBy:dy * self.window.backingScaleFactor];
            break;
        default:
            break;
    }

    
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

/*
- (void)initWithDelegateValues {
    AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    
    _drawingContext = Quartz;
    _kind = Linear;
    _startColor = appDelegate->color0.color;
    _endColor   = appDelegate->color1.color;
}
*/


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

    NSInteger numberOfComponents = _startColor.numberOfComponents;
    CGFloat *components = malloc(sizeof(CGFloat)*2*numberOfComponents);
    [_startColor getComponents:&components[0]];
    [_endColor   getComponents:&components[numberOfComponents]];

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
        case Linear:
            CGContextDrawLinearGradient(
                  context, gradient
                , _startPoint, _endPoint, _options
            );
            break;
        case Conic:                                                             // not supported in quartz
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


- (CAShapeLayer *)addCircle:(NSPoint)point color:(NSColor*)color
                 atSubLayer:(CAShapeLayer *)subLayer {
    const double Radius = 25;
    
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    if (shapeLayer) {
        /*
        */

        
        shapeLayer.bounds   = CGRectMake(0, 0, Radius, Radius);
        //shapeLayer.position = CGPointMake(point.x-Radius/2, point.y-Radius/2);
        shapeLayer.position = CGPointMake(point.x, point.y);

        CGPathRef cgPath = CGPathCreateWithEllipseInRect(shapeLayer.bounds, NULL);
        shapeLayer.path = cgPath;
        shapeLayer.strokeColor = [color colorWithAlphaComponent:_alpha].CGColor;
        shapeLayer.fillColor = nil;//color.CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineDashPattern = @[@5, @5];
        shapeLayer.lineDashPhase = _alpha*100;
        shapeLayer.name = subLayer.name;
        
        [self.layer replaceSublayer:subLayer with:shapeLayer];
    }
    return shapeLayer;
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
    if (!self.layer.sublayers.count) {
        [self addSubLayers];
    }
    
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
    [self.layer replaceSublayer:_gradientLayer with:gradientLayer];
    _gradientLayer = gradientLayer;
    
    //_shape1Layer = [self addCircle:_startPoint color:[_startColor opposite:_alpha] atSubLayer:_shape1Layer];
    //_shape2Layer = [self addCircle:_endPoint   color:[_endColor   opposite:_alpha] atSubLayer:_shape2Layer];
    _shape1Layer = [self addCircle:_startPoint color:NSColor.redColor   atSubLayer:_shape1Layer];
    _shape2Layer = [self addCircle:_endPoint   color:NSColor.greenColor atSubLayer:_shape2Layer];
}




- (void)drawRect:(NSRect)dirtyRect {

    //[centerTransform set];                                                    // not working with Retina ?!
    switch (_drawingContext) {
        case CoreAnimation:
            [self drawCoreAnimation];
            break;
        case Quartz:
        default:
            [self drawQuartzContext];
            break;
    }
    
    //[centerTransform invert];
    //[centerTransform concat];
}



- (void)updateContext:(NSPopUpButton *)sender {
    _drawingContext = sender.indexOfSelectedItem;
    switch (_drawingContext) {
        case CoreAnimation:
            self.wantsLayer = TRUE;
            //[self addSubLayers];
            break;
        case Quartz:
        default:
            self.wantsLayer = FALSE;
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

//pointInWindow = [self convertPoint:[sender locationInView:self] toView:nil];
- (void) checkHitLayer:(NSPoint)pointInWindow {
    static int count = 0;
    CALayer *hitLayer = [self.layer hitTest:pointInWindow];
    if (hitLayer) {
        NSLog(@"%@ %d", hitLayer.name, count);
    }
    else {
        NSLog(@"No Layer %d", count);
    }
    count++;
}

- (void)mouseMoved:(NSEvent *)event {
    static int count = 0;
    NSPoint pv = event.locationInWindow;
    CALayer *hitLayer = [self.layer hitTest:pv];
    if (hitLayer) {
        NSLog(@"%@ %d", hitLayer.name, count);
    }
    else {
        NSLog(@"No Layer %d", count);
    }
    count++;
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



- (IBAction)myClickGesture:(NSClickGestureRecognizer *)sender {
    //[self checkHitLayer:sender];

    _alpha = 1.0;
    [self fadeCirclesOut];
}


- (IBAction)myPressAndHoldGesture:(NSPressGestureRecognizer *)sender {
    //[self checkHitLayer:sender];
}




- (NSString *)generateQuartzCode {
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
            text = [NSMutableString stringWithFormat:
                    @""
                    "// Not supported in Quartz\n"
                    ];
            break;
    }
    return text;
}

- (NSString *)generateCoreAnimationCode {
    NSString *text;
    text = [NSString stringWithFormat:@"// Not yet supported\n"];
    
#ifdef FUTURE

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
            text = [NSString stringWithFormat:
                    @""
                    "// Not supported in Quartz\n"
                    ];
            break;
    }
#endif
    return text;
}


- (nonnull NSString *)code {
    switch (_drawingContext) {
        case Quartz:
            return [self generateQuartzCode];
        default:
            return [self generateCoreAnimationCode];
    }
}

- (void)storeDefaults {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    //PrintComponents(_startColor)

    [defaults setColor:_startColor forKey:@"StartColor"];
    [defaults setColor:_endColor   forKey:@"EndColor"];
    
    [defaults setPoint:_startPoint forKey:@"StartPoint"];
    [defaults setPoint:_endPoint   forKey:@"EndPoint"];

}



@end
