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




@implementation NSColor (NSColorExtension)


- (BOOL) isLight {
    CGFloat white = 0;
    [self getWhite:&white alpha:NULL];
    return white > 0.5;
}

- (NSColor *) opposite:(double) alpha {
    CGFloat components[4];
    [self getComponents:&components[0]];

    double ignored;
    switch (self.numberOfComponents) {
        case 4:
            return [NSColor
                    colorWithCalibratedRed:
                           (CGFloat)modf(0.5 + components[0], &ignored)
                     green:(CGFloat)modf(0.5 + components[1], &ignored)
                      blue:(CGFloat)modf(0.5 + components[2], &ignored)
                     alpha:alpha
            ];
        case 2:
        default:
            if (components[0] < 0.5) {
                return [NSColor.whiteColor colorWithAlphaComponent:alpha];
            }
            else {
                return [NSColor.blackColor colorWithAlphaComponent:alpha];
            }
    }
 
}



@end

@interface NSArray (PointsCategory)

@property(readonly) NSArray *cgColorRefArray;

@end


@implementation NSArray (PointsCategory)

- (NSPoint) pointAtIndex:(NSUInteger)index {                                    /// used to avoid too many casts
    //return ((NSValue *)[self objectAtIndex:index]).pointValue;
    return ((NSValue *)self[index]).pointValue;
}

- (NSString *) layerNameAtIndex:(NSUInteger)index {                             /// used to avoid too many casts
    return ((CALayer*)self[index]).name;
}

- (NSArray *) cgColorRefArray {
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        [outputArray addObject:(id)((NSColor*)object).CGColor];
    }
    return outputArray;
}

- (NSColor *) colorAtIndex:(NSUInteger)index {                                  /// used to avoid too many casts
    return ((NSColor*)self[index]);
}

+ (NSArray*) arrayByRepeatingObject:(id)obj times:(NSUInteger)times {
    id arr[times];
    for (int i = 0; i < times; ++i) {
        arr[i] = obj;
    }
    return [NSArray arrayWithObjects:arr count:times];
}

+ (NSArray*) arrayByRepeatingBlock:(NSString* (^)(int))callbackBlock times:(NSUInteger)times {
    id arr[times];
    for (int i = 0; i < times; ++i) {
        arr[i] = callbackBlock(i);
    }
    return [NSArray arrayWithObjects:arr count:times];
}

@end

@implementation NSMutableArray (MutablePointsCategory)

- (void) moveAllPointsByX:(CGFloat)dx andY:(CGFloat)dy {
    
    for (int index = 0; index < self.count; index++) {
        NSPoint point = NSMakePoint(  [self pointAtIndex:index].x+dx
                                    , [self pointAtIndex:index].y+dy
                                    );
        self[index] = [NSValue valueWithPoint:point];
    }
    
}

- (void) changeToColorSpace:(NSColorSpace *)newColorSpace {
    /*
    for (__strong NSColor *color in self) {
        color = [color colorUsingColorSpace:newColorSpace];
    }
    */
    for (int index = 0; index < self.count; index++) {
        self[index] = [self[index] colorUsingColorSpace:newColorSpace];
    }

}

@end


@implementation NSString (RepeatCategory)

- (NSString *) repeatStringByNumberOfTimes: (NSUInteger) times {
    return [@"" stringByPaddingToLength:[self length]*times withString:self startingAtIndex:0];
}

@end


@implementation TestGradient

//AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
//[appDelegate->colorSpaceMenu selectItemWithTitle:[_colors colorAtIndex:0].colorSpace.localizedName];

//CFStringRef const defaultColorSpaceRef = CFSTR("kCGColorSpaceGenericRGBLinear");

+ (NSString*) defaultColorSpaceName {
    //return CFBridgingRelease(kCGColorSpaceGenericRGBLinear);
    //return (__bridge NSString*)kCGColorSpaceGenericRGB;
    return NSColorSpace.genericRGBColorSpace.localizedName;
}

+ (NSArray *) allColorSpaces {
    return [NSColorSpace availableColorSpacesWithModel:NSColorSpaceModelUnknown]; // Contrary to expectation this returns all color name spaces
}


+ (NSArray*) allColorSpaceNames {
    NSMutableArray  *array = [NSMutableArray arrayWithCapacity:60];
       /*
           (NSString *)CFBridgingRelease(kCGColorSpaceGenericRGB)               // CG colorspaces
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
        */
    for (NSColorSpace *colorSpace in [self allColorSpaces]) {
        [array addObject:colorSpace.localizedName];
    }
    
    return array;
}

+ (NSDictionary *) gradientDefaults {
    // defaults read de.LegoEsprit.GradientTestApplication
    
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

- (NSInteger) numberOfKinds {
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




 
- (instancetype) initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        
        _didFinishLaunching         = false;
        
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

        _drawingContext     = [defaults integerForKey:@"isNotQuartz"];
        _kind               = [defaults integerForKey:@"kind"];
        _options            = 0;

#ifdef USE_AFFINE
        
        _centerTransform    = [NSAffineTransform transform];
        
        caTransform         = CATransform3DMakeTranslation(0.0, 0.0, 0.0);
        
#endif
        _alpha              = 1.0;
        

        _gradientLayer = CAGradientLayer.layer;
        _gradientLayer.name = @"Gradient";

        
        _myGravity = kCAGravityTopRight;
        
        
        NSColor *startColor  = [defaults colorForKey:@"StartColor" default:NSColor.redColor];
        NSColor *endColor    = [defaults colorForKey:@"EndColor"   default:NSColor.greenColor];
        NSArray *colors = @[startColor, endColor];
        _colors = [[NSMutableArray alloc] initWithArray:colors];

        NSPoint startPoint  = [defaults pointForKey:@"StartPoint" default:NSMakePoint(10.0, 10.0)];
        NSPoint endPoint    = [defaults pointForKey:@"EndPoint"   default:NSMakePoint(500.0, 400.0)];
        NSArray *points = @[[NSValue valueWithPoint:startPoint], [NSValue valueWithPoint:endPoint]];
        _points = [[NSMutableArray alloc] initWithArray:points];
        
        CAShapeLayer *shape1Layer   = CAShapeLayer.layer;
        shape1Layer.name = @"Circle 1";
        CAShapeLayer *shape2Layer  = CAShapeLayer.layer;
        shape2Layer.name = @"Circle 2";

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

- (instancetype) initWithFrame:(NSRect)frameRect {
    // Not called anymore
    NSAssert(0, @"Strange but not called anymore - use initWithCoder instead");
    if (self = [super initWithFrame:frameRect]) {
        // Initialize self
    }
    return self;
}

- (void) addSubLayers {
    
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
    
    /*
     // Just a test layer (tried to test the gravity, but no impact)
    CALayer *blueLayer = CALayer.layer;
    //blueLayer.contentsGravity = kCAGravityTopRight;
    blueLayer.bounds = CGRectMake(0, 0, 100, 100);
    blueLayer.position = CGPointMake(100, 100);
    blueLayer.backgroundColor = NSColor.blueColor.CGColor;
    blueLayer.name = @"Blue";
    [self.layer addSublayer:blueLayer];
    */
    
    [self.layer addSublayer:_shapeLayers[0]];
    [self.layer addSublayer:_shapeLayers[1]];


}




/// Since gravity does not work, we shift all points towards the center
/// when resizing the window
- (void) setFrame:(CGRect)newFrame {
    CGFloat dx = self.frame.size.width;
    CGFloat dy = self.frame.size.height;

    [super setFrame:newFrame];
    dx = (newFrame.size.width  - dx)/2;                                         /// Distance to new center
    dy = (newFrame.size.height - dy)/2;

#ifdef USE_AFFINE
    
    [_centerTransform translateXBy:dx yBy:dy];
     caTransform = CATransform3DTranslate(caTransform, dx, dy, 0.0);

#else
    if (_didFinishLaunching) [_points moveAllPointsByX:dx andY:dy];
    
#endif
    
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


- (void) circleArround:(NSPoint)point radius:(double)radius {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:
        NSMakeRect(point.x - radius
                 , point.y - radius
                 , 2*radius, 2*radius
        )
    ];
    [path stroke];
}


- (void) gradientWithCGContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;

    [NSGraphicsContext saveGraphicsState];

    CGColorSpaceRef colorSpace = [_colors colorAtIndex:0].colorSpace.CGColorSpace;


    NSInteger numberOfComponents = [_colors colorAtIndex:0].numberOfComponents;
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
                , ((NSValue *)_points[1]).pointValue
                , _options
            );
            break;
        case Conic:                                                             // not supported in quartz
        default:
            break;
    }
    [NSGraphicsContext restoreGraphicsState];
    free(components);
    CGGradientRelease(gradient);
}


- (CGMutablePathRef) cgPathFromPath:(NSBezierPath *)path {
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
    CGPathRelease(cgPath);
    return cgPath;
}


- (CAShapeLayer *) createCircleShape:(NSPoint) point
                               color:(NSColor *)color
                                name:(NSString *)name
{
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    if (shapeLayer) {
        const double Radius = 25;
        // It seams to be faster/more efficient to create a new sublayer and
        // then to exchange it
        shapeLayer.bounds   = CGRectMake(0, 0, Radius, Radius);
        shapeLayer.position = point;
        
#ifdef USE_AFFINE

        shapeLayer.transform = caTransform;
        
#endif
        
        CGPathRef cgPath = CGPathCreateWithEllipseInRect(shapeLayer.bounds, NULL);
        shapeLayer.path = cgPath;
        shapeLayer.strokeColor = [color opposite:_alpha].CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineDashPattern = @[@5, @5];
        shapeLayer.lineDashPhase = _alpha*100;
        shapeLayer.name = name;
        CGPathRelease(cgPath);                                                  // cgPath must be released
    }
    return shapeLayer;
}

- (void)createCircle:(int)index {
    CAShapeLayer *shapeLayer = [self createCircleShape:[_points pointAtIndex:index]
                                                 color:_colors[index]
                                                  name:[_shapeLayers layerNameAtIndex:index]
                                ];
    if (shapeLayer) {
        [self.layer replaceSublayer:_shapeLayers[index] with:shapeLayer];
        _shapeLayers[index] = shapeLayer;
    }
}




- (void) drawQuartzContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    //NSLog(@"1");
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



- (void) drawCoreAnimation {
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
    
#ifdef USE_AFFINE

    NSPoint startPoint = NSMakePoint(
         [_centerTransform transformPoint:[_points pointAtIndex:0]].x/self.bounds.size.width
       , [_centerTransform transformPoint:[_points pointAtIndex:0]].y/self.bounds.size.height
    );
    
    NSPoint endPoint = NSMakePoint(
         [_centerTransform transformPoint:[_points pointAtIndex:1]].x/self.bounds.size.width
       , [_centerTransform transformPoint:[_points pointAtIndex:1]].y/self.bounds.size.height
    );
#else
    
    NSPoint startPoint = NSMakePoint(
                             [_points pointAtIndex:0].x/self.bounds.size.width
                           , [_points pointAtIndex:0].y/self.bounds.size.height
                         );
    NSPoint endPoint   = NSMakePoint(
                             [_points pointAtIndex:1].x/self.bounds.size.width
                           , [_points pointAtIndex:1].y/self.bounds.size.height
                         );

#endif

    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint   = endPoint;


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
    gradientLayer.colors = _colors.cgColorRefArray;

    [self.layer replaceSublayer:_gradientLayer with:gradientLayer];
    _gradientLayer = gradientLayer;
    
    [self createCircle:0];
    [self createCircle:1];
}




- (void) drawRect:(NSRect)dirtyRect {

    switch (_drawingContext) {
        case CoreAnimation:
            [self drawCoreAnimation];
            break;
        case Quartz:
        default:
#ifdef USE_AFFINE
            [_centerTransform concat];
#endif
            [self drawQuartzContext];
            break;
    }

}



- (void) updateContext:(NSPopUpButton *)sender {
    _drawingContext = sender.indexOfSelectedItem;
    switch (_drawingContext) {
        case CoreAnimation:
            self.wantsLayer = TRUE;
            break;
        case Quartz:
        default:
            self.wantsLayer = FALSE;
            self.layer.sublayers = nil;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (IBAction) updateKind:(NSSegmentedControl *)sender {
    _kind = sender.selectedSegment;
    [self setNeedsDisplay:YES];
}

- (NSInteger) updateColor:(nonnull NSColor *)color at:(NSInteger)index {
    NSInteger colorSpaceIndex = -1;                                             /// no color space index change
    NSColorSpace *originalColorSpace = [_colors colorAtIndex:index].colorSpace;
    _colors[index] = color;                                                     /// set the new color
    NSColorSpace *colorSpace = [_colors colorAtIndex:index].colorSpace;
    if (colorSpace != originalColorSpace) {
        [_colors changeToColorSpace:colorSpace];                                /// change all colors to use the same color space

        /// attention: localizedName for color not localized!
        /// Therefore we must use index here!
        colorSpaceIndex = [TestGradient.allColorSpaces indexOfObject:colorSpace];
    }
    
    [self setNeedsDisplay:true];
    return colorSpaceIndex;
}



- (IBAction) sliderStartLocation:(NSSlider *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) sliderEndLocation:(NSSlider *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) updateStartRadius:(NSTextField *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) updateEndRadius:(NSTextField *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) stepperStartRadius:(NSStepper *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) stepperEndRadius:(NSStepper *)sender {
    [self setNeedsDisplay:YES];
}

- (IBAction) setStartOver:(NSButton *)sender {
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

- (IBAction) setEndOver:(NSButton *)sender {
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

- (void) selectColorSpace:(NSColorSpace *)colorSpace {
    //AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    [_colors changeToColorSpace:colorSpace];
    //appDelegate->color0.color = _colors[0];
    //appDelegate->color1.color = _colors[1];

    [self setNeedsDisplay:YES];
}



- (double) manhattanDistanceFrom:(NSPoint)from to:(NSPoint)to {
    return (fabs(from.x - to.x) + fabs(from.y - to.y));
}

- (int) findElement:(NSPoint)targetPoint {
    if (
        [self manhattanDistanceFrom:targetPoint to:((NSValue *)_points[0]).pointValue]
      < [self manhattanDistanceFrom:targetPoint to:((NSValue *)_points[1]).pointValue]
    )
        return 0;
    else
        return 1;
}

- (NSPoint) inverseTransformPoint:(NSPoint)point {

    #ifdef USE_AFFINE
        
        NSAffineTransform *xForm = [_centerTransform copy];
        [xForm invert];
        NSPoint mouseLoc = [xForm transformPoint:point];
        return mouseLoc;
        
    #else
        
        return point;
       
    #endif
    
}

- (NSTimer * _Nonnull) fadeCirclesOut {
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



- (void) mouseMoved:(NSEvent *)event {                                          /// Requires tracking rect
    static int count = 0;
    /*
    NSPoint pv = event.locationInWindow;

    CALayer *hitLayer = [self.layer hitTest:pv];

    if (hitLayer) {
        NSLog(@"%@ %d", hitLayer.name, count);
    }
    else {
        NSLog(@"No Layer %d", count);
    }
     */
     
    count++;
}

- (IBAction) myPanGesture:(NSPanGestureRecognizer *)sender {
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



- (IBAction) myClickGesture:(NSClickGestureRecognizer *)sender {
    _alpha = 1.0;
    [self fadeCirclesOut];
}


- (IBAction) myPressAndHoldGesture:(NSPressGestureRecognizer *)sender {
    //[self checkHitLayer:sender];
}




- (NSString *) componentsString {
    NSUInteger numberOfComponents = [_colors colorAtIndex:0].numberOfComponents;
    CGFloat components[8], *ptr;
    ptr = components;
    [_colors[0] getComponents:&components[0]];
    [_colors[1] getComponents:&components[numberOfComponents]];
    
    NSArray  *dataArray = [NSArray arrayByRepeatingBlock:
                           ^(int i) {
                             return [NSString stringWithFormat:@"%f", ptr[i]];
                           }
                           times:numberOfComponents*2
                         ];
    NSString *dataFormat = [dataArray componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"(const CGFloat[]){%@}", dataFormat];
    
}

- (NSString *) generateQuartzCode {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    double locations[] = {[defaults doubleForKey:@"startLocation"]
        , [defaults doubleForKey:@"endLocation"]
    };
    
    double startRadius = [defaults doubleForKey:@"startRadius"];
    double endRadius   = [defaults doubleForKey:@"endRadius"];

    switch (_kind) {
        case Linear:
            return [NSString stringWithFormat:
                     @""
                     "CGColorSpaceRef cgColorSpace = CGColorSpaceCreateWithName(%@);\n"
                     "CGGradientRef gradient = CGGradientCreateWithColorComponents(\n"
                     "    cgColorSpace\n"
                     "  , %@\n"
                     "  , (const CGFloat[]){%f, %f}, 2\n"
                     ");\n"
                     "CGContextDrawLinearGradient(\n"
                     "    NSGraphicsContext.currentContext.graphicsPort\n"
                     "  , gradient\n"
                     "  , NSMakePoint(%f, %f), NSMakePoint(%f, %f), %d\n"
                     ");\n"
                     "CGColorSpaceRelease(cgColorSpace);\n"
                     "CGGradientRelease(gradient);\n"
                     , CFBridgingRelease(CGColorSpaceCopyName([_colors colorAtIndex:0].colorSpace.CGColorSpace))
                     , [self componentsString]
                     , locations[0], locations[1]
                     , [_points pointAtIndex:0].x, [_points pointAtIndex:0].y
                     , [_points pointAtIndex:1].x, [_points pointAtIndex:1].y
                     , _options
                     ];
            break;
        case Radial:
            return [NSString stringWithFormat:
                     @""
                     "CGColorSpaceRef cgColorSpace = CGColorSpaceCreateWithName(%@);\n"
                     "CGGradientRef gradient = CGGradientCreateWithColorComponents(\n"
                     "    cgColorSpace\n"
                     "  , %@\n"
                     "  , (const CGFloat[]){%f, %f}, 2\n"
                     ");\n"
                     "CGContextDrawRadialGradient(\n"
                     "    NSGraphicsContext.currentContext.graphicsPort\n"
                     "  , gradient\n"
                     "  , NSMakePoint(%f, %f), %f\n"
                     "  , NSMakePoint(%f, %f), %f\n"
                     "  , %d\n"
                     ");\n"
                     "CGColorSpaceRelease(cgColorSpace);\n"
                     "CGGradientRelease(gradient);\n"
                     , CFBridgingRelease(CGColorSpaceCopyName([_colors colorAtIndex:0].colorSpace.CGColorSpace))
                     , [self componentsString]
                     , locations[0], locations[1]
                     , [_points pointAtIndex:0].x, [_points pointAtIndex:0].y, startRadius
                     , [_points pointAtIndex:1].x, [_points pointAtIndex:1].y, endRadius
                     , _options
                     ];
            break;
            
        case Conic:
        default:
            return @"// Not supported in Quartz\n";
            break;
    }
    return @"";
}

- (NSString *) colorComponent:(NSColor *)color prefixedBy:(NSString *)prefix {
    
    NSInteger numberOfComponents = color.numberOfComponents;
    CGFloat components[8], *ptr;
    ptr = components;
    [color getComponents:components];
    
    NSArray  *dataArray = [NSArray arrayByRepeatingBlock:
                             ^(int i) {
                               return [NSString stringWithFormat:@"%f", ptr[i]];
                             }
                             times:numberOfComponents
                           ];

    return [NSString stringWithFormat:@""
            "    const CGFloat %@Components[] = {%@};\n"
            "    NSColor *%@Color = [NSColor colorWithColorSpace:cs "
                        "components:%@Components count:%ld];"
             , prefix
             , [dataArray componentsJoinedByString:@", "]
             , prefix, prefix
             , numberOfComponents
            ];
}

- (NSString *) generateCoreAnimationCode {
    
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    double locations[] = {
          [defaults doubleForKey:@"startLocation"]
        , [defaults doubleForKey:@"endLocation"]
    };
    
    NSString *gradientTypeAsString;
    switch (_kind) {
        case Conic:
            gradientTypeAsString = @"kCAGradientLayerConic";
            break;
        case Radial:
            gradientTypeAsString = @"kCAGradientLayerRadial";
            break;
        case Linear:
        default:
            gradientTypeAsString = @"kCAGradientLayerAxial";
            break;
    }


    return [NSString stringWithFormat:
            @""
            "self.wantsLayer = YES;\n"
            "CAGradientLayer *gradientLayer = CAGradientLayer.layer;\n"
            "gradientLayer.frame = self.bounds;\n"
            "gradientLayer.locations = @[@%f, @%f];\n"
            "gradientLayer.startPoint = NSMakePoint(%f, %f);\n"
            "gradientLayer.endPoint   = NSMakePoint(%f, %f);\n"
            "gradientLayer.type = %@;\n"
            "CGColorSpaceRef cgColorSpace = CGColorSpaceCreateWithName(%@);\n"
            "NSColorSpace *cs = [[NSColorSpace alloc]\n"
            "     initWithCGColorSpace:cgColorSpace\n"
            "];\n"
            "%@\n"
            "%@\n"
            "gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];\n"
            "[self.layer addSublayer:gradientLayer];\n"
            "CGColorSpaceRelease(cgColorSpace);\n"
            
            , locations[0]
            , locations[1]
            , [_points pointAtIndex:0].x/self.bounds.size.width, [_points pointAtIndex:0].y/self.bounds.size.height
            , [_points pointAtIndex:1].x/self.bounds.size.width, [_points pointAtIndex:1].y/self.bounds.size.height
            , gradientTypeAsString
            , CFBridgingRelease(CGColorSpaceCopyName([_colors colorAtIndex:0].colorSpace.CGColorSpace))
            , [self colorComponent:_colors[0] prefixedBy:@"start"]
            , [self colorComponent:_colors[1] prefixedBy:@"end"]

            ];

}


- (nonnull NSString *) code {
    switch (_drawingContext) {
        case Quartz:
            return [self generateQuartzCode];
        default:
            return [self generateCoreAnimationCode];
    }
}

- (void) storeDefaults {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    //PrintComponents(_startColor)

    [defaults setColor:_colors[0]  forKey:@"StartColor"];
    [defaults setColor:_colors[1]  forKey:@"EndColor"];
    
    [defaults setPoint:[_points pointAtIndex:0] forKey:@"StartPoint"];
    [defaults setPoint:[_points pointAtIndex:1] forKey:@"EndPoint"];

}


- (nonnull NSColor *) colorAtIndex:(NSInteger)index {
    return _colors[index];
}


@end
