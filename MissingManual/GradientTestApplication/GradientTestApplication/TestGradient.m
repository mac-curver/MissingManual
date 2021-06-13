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

        NSPoint startPoint  = [defaults pointForKey:@"StartPoint" default:NSMakePoint(10.0, 10.0)];
        NSPoint endPoint    = [defaults pointForKey:@"EndPoint" default:NSMakePoint(500.0, 400.0)];
        //_startPoint  = [defaults pointForKey:@"StartPoint" default:NSMakePoint(10.0, 10.0)];
        //_endPoint    = [defaults pointForKey:@"EndPoint" default:NSMakePoint(500.0, 400.0)];
        _drawingContext     = [defaults integerForKey:@"isNotQuartz"];
        _kind               = [defaults integerForKey:@"kind"];
        _options            = 0;
        _currentColorSpace  = (__bridge CFStringRef _Nonnull)(TestGradient.defaultColorSpaceName);
        
        //centerTransform     = [NSAffineTransform transform];                  // I had issues with Retina display
        _alpha              = 1.0;
        

        
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

        
        _myGravity = kCAGravityTopRight;
        
        
        NSColor *startColor  = [defaults colorForKey:@"StartColor" default:NSColor.redColor];
        NSColor *endColor    = [defaults colorForKey:@"EndColor" default:NSColor.greenColor];

        //_startColor  = [defaults colorForKey:@"StartColor" default:NSColor.redColor];
        //_endColor    = [defaults colorForKey:@"EndColor" default:NSColor.greenColor];

        
        NSArray *colors = @[startColor, endColor];
        _colors = [[NSMutableArray alloc] initWithArray:colors];

        
        NSArray *points = @[[NSValue valueWithPoint:startPoint], [NSValue valueWithPoint:endPoint]];
        _points = [[NSMutableArray alloc] initWithArray:points];

        CAShapeLayer *shape1Layer   = CAShapeLayer.layer;
        shape1Layer.name = @"Shape 1";
        CAShapeLayer *shape2Layer  = CAShapeLayer.layer;
        shape2Layer.name = @"Shape 2";

        _shapeLayers = [[NSMutableArray alloc]init];
        [_shapeLayers addObject:shape1Layer];
        [_shapeLayers addObject:shape2Layer];


        
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
    //self.layer.contentsGravity = kCAGravityTopRight;
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
    
 
    CALayer *blueLayer = CALayer.layer;
    //blueLayer.contentsGravity = kCAGravityTopRight;
    blueLayer.bounds = CGRectMake(0, 0, 100, 100);
    blueLayer.position = CGPointMake(100, 100);
    blueLayer.backgroundColor = NSColor.blueColor.CGColor;
    blueLayer.name = @"Blue";
    [self.layer addSublayer:blueLayer];
      
    
    [self.layer addSublayer:_shapeLayers[0]];
    [self.layer addSublayer:_shapeLayers[1]];


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
    NSPoint startPoint = ((NSValue *)_points[0]).pointValue;
    NSPoint endPoint   = ((NSValue *)_points[1]).pointValue;

    _points[0] = [NSValue valueWithPoint:NSMakePoint(startPoint.x+dx, startPoint.y+dy)];
    _points[1] = [NSValue valueWithPoint:NSMakePoint(endPoint.x  +dx, endPoint.y  +dy)];
}

- (void)setFrame:(CGRect)newFrame {
    CGFloat dx = self.frame.size.width;
    CGFloat dy = self.frame.size.height;
    [super setFrame:newFrame];
    //NSLog(@"%f", self.window.backingScaleFactor);
    
    
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

    NSInteger numberOfComponents = ((NSColor*)_colors[0]).numberOfComponents;
    CGFloat *components = malloc(sizeof(CGFloat)*2*numberOfComponents);
    [_colors[0] getComponents:&components[0]];
    [_colors[1] getComponents:&components[numberOfComponents]];

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
                , ((NSValue *)_points[0]).pointValue
                , [defaults doubleForKey:@"startRadius"]
                , ((NSValue *)_points[1]).pointValue
                , [defaults doubleForKey:@"endRadius"]
                , _options
            );

            break;
        case Linear:
            CGContextDrawLinearGradient(
                  context, gradient
                , ((NSValue *)_points[0]).pointValue
                , ((NSValue *)_points[0]).pointValue, _options
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


- (CAShapeLayer *)createCircleShape:(NSPoint) point
                              color:(NSColor *)color
                               name:(NSString *)name
{
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    if (shapeLayer) {
        const double Radius = 25;
        // It seams to be faster to create a new sublayer and then to exchange it
        shapeLayer.bounds   = CGRectMake(0, 0, Radius, Radius);
        shapeLayer.position = point;
        
        CGPathRef cgPath = CGPathCreateWithEllipseInRect(shapeLayer.bounds, NULL);
        shapeLayer.path = cgPath;
        shapeLayer.strokeColor = [color opposite:_alpha].CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineDashPattern = @[@5, @5];
        shapeLayer.lineDashPhase = _alpha*100;
        shapeLayer.name = name;
    }
    return shapeLayer;
}

- (void)createCircle:(int)index {
    CAShapeLayer *shapeLayer = [self createCircleShape:((NSValue *)_points[index]).pointValue
                                                 color:_colors[index]
                                                  name:((CALayer*)_shapeLayers[index]).name
                                ];
    if (shapeLayer) {
        [self.layer replaceSublayer:_shapeLayers[index] with:shapeLayer];
        _shapeLayers[index] = shapeLayer;
    }
}


- (void)createCircle2 {
    CAShapeLayer *shapeLayer = [self createCircleShape:((NSValue *)_points[1]).pointValue
                                                 color:_colors[1]
                                                  name:((CALayer*)_shapeLayers[1]).name
                                ];
    if (shapeLayer) {
        [self.layer replaceSublayer:_shapeLayers[1] with:shapeLayer];
        _shapeLayers[1] = shapeLayer;
    }
}


- (void)drawQuartzContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    [self gradientWithCGContext];
    
    [[NSColor.blackColor colorWithAlphaComponent:_alpha] set];
    
    switch (_kind) {
        case Radial:
            [self circleArround:((NSValue *)_points[0]).pointValue radius:[defaults doubleForKey:@"startRadius"]];
            [self circleArround:((NSValue *)_points[1]).pointValue radius:[defaults doubleForKey:@"endRadius"]];
            break;
        default:
            [self circleArround:((NSValue *)_points[0]).pointValue radius:10.0];
            [self circleArround:((NSValue *)_points[1]).pointValue radius:10.0];
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
                                    ((NSValue *)_points[0]).pointValue.x/self.bounds.size.width
                                  , ((NSValue *)_points[0]).pointValue.y/self.bounds.size.height
                               );
    gradientLayer.endPoint   = NSMakePoint(
                                    ((NSValue *)_points[1]).pointValue.x/self.bounds.size.width
                                  , ((NSValue *)_points[1]).pointValue.y/self.bounds.size.height
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
    
    // Must be NSArray of CGColorRef!
    gradientLayer.colors = @[  (id)((NSColor*)_colors[0]).CGColor
                             , (id)((NSColor*)_colors[1]).CGColor
                            ];
    [self.layer replaceSublayer:_gradientLayer with:gradientLayer];
    _gradientLayer = gradientLayer;
    
    [self createCircle:0];
    [self createCircle2];
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
    _colors[0] = sender.color;
    [self setNeedsDisplay:true];
}

- (IBAction)updateEndColor:(NSColorWell *)sender {
    _colors[1] = sender.color;
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

- (int)findElement:(NSPoint)targetPoint {
    if (
        [self manhattanDistanceFrom:targetPoint to:((NSValue *)_points[0]).pointValue]
      < [self manhattanDistanceFrom:targetPoint to:((NSValue *)_points[1]).pointValue]
    )
        return 0;
    else
        return 1;
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
    //static NSPoint *pointPtr;
    static int index = 0;

    NSPoint mouseLoc = [self inverseTransformPoint:[sender locationInView:self]];


    switch (sender.state) {
        case NSGestureRecognizerStateBegan:
            // Identify the point to be dragged
            index = [self findElement:mouseLoc];
            _alpha = 1.0;
            // fallthrough
        case NSGestureRecognizerStateChanged:
            _points[index] = [NSValue valueWithPoint:mouseLoc];
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
    [_colors[0] getComponents:&components[0]];
    [_colors[1] getComponents:&components[4]];
    
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
                     , ((NSValue *)_points[0]).pointValue.x, ((NSValue *)_points[0]).pointValue.y
                     , ((NSValue *)_points[1]).pointValue.x, ((NSValue *)_points[1]).pointValue.y
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
                     , ((NSValue *)_points[0]).pointValue.x, ((NSValue *)_points[0]).pointValue.y, startRadius
                     , ((NSValue *)_points[1]).pointValue.x, ((NSValue *)_points[1]).pointValue.y, endRadius
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

    [defaults setColor:_colors[0]  forKey:@"StartColor"];
    [defaults setColor:_colors[1]  forKey:@"EndColor"];
    
    [defaults setPoint:((NSValue *)_points[0]).pointValue forKey:@"StartPoint"];
    [defaults setPoint:((NSValue *)_points[1]).pointValue forKey:@"EndPoint"];

}



@end
