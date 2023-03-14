//
//  TestGradient.m
//  GradientTestApplication
//
//  changed by LegoEsprit on 02.02.23 Quarz circle animated with dash pattern
//  changed by LegoEsprit on 29.05.21.
//  Created by LegoEsprit on 23.05.21.
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
    CGFloat components[self.numberOfComponents];
    [self getComponents:&components[0]];

    double ignored;
    switch (self.numberOfComponents) {
        case 5:
            // cyan, magenta, yellow, black, and alpha
            return [NSColor colorWithDeviceCyan:
                             (CGFloat)modf(0.5 + components[0], &ignored)
                     magenta:(CGFloat)modf(0.5 + components[1], &ignored)
                      yellow:(CGFloat)modf(0.5 + components[2], &ignored)
                       black:(CGFloat)modf(0.5 + components[3], &ignored)
                       alpha:alpha
                   ];
        case 4:
            return [NSColor
                    colorWithCalibratedRed:
                           (CGFloat)modf(0.5 + components[0], &ignored)
                     green:(CGFloat)modf(0.5 + components[1], &ignored)
                      blue:(CGFloat)modf(0.5 + components[2], &ignored)
                     alpha:alpha
                    ];
        case 3:
        case 2:
        default:
            if ([self isLight]) {
                return [NSColor.blackColor colorWithAlphaComponent:alpha];
            }
            else {
                return [NSColor.whiteColor colorWithAlphaComponent:alpha];
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
//[appDelegate->colorSpaceMenu selectItemWithTitle:[self.colors colorAtIndex:0].colorSpace.localizedName];

//CFStringRef const defaultColorSpaceRef = CFSTR("kCGColorSpaceGenericRGBLinear");

+ (NSString*) defaultColorSpaceName {
    //return CFBridgingRelease(kCGColorSpaceGenericRGBLinear);
    //return (__bridge NSString*)kCGColorSpaceGenericRGB;
    return NSColorSpace.genericRGBColorSpace.localizedName;
}


+ (NSArray *)allColorSpaces {
    return [NSColorSpace availableColorSpacesWithModel:NSColorSpaceModelUnknown];
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
    switch (self.drawingContext) {
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
        
        self.didFinishLaunching         = false;
        
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

        self.drawingContext     = [defaults integerForKey:@"isNotQuartz"];
        self.kind               = [defaults integerForKey:@"kind"];
        self.options            = 0;

#ifdef USE_AFFINE
        
        self.centerTransform    = [NSAffineTransform transform];
        
        caTransform         = CATransform3DMakeTranslation(0.0, 0.0, 0.0);
        
#endif
        self.alpha              = 1.0;
        

        self.gradientLayer = CAGradientLayer.layer;
        self.gradientLayer.name = @"Gradient";

        
        self.myGravity = kCAGravityTopRight;
        
        
        NSColor *startColor  = [defaults colorForKey:@"StartColor" default:NSColor.redColor];
        NSColor *endColor    = [defaults colorForKey:@"EndColor"   default:NSColor.greenColor];
        NSArray *colors = @[startColor, endColor];
        self.colors = [[NSMutableArray alloc] initWithArray:colors];

        NSPoint startPoint  = [defaults pointForKey:@"StartPoint" default:NSMakePoint(10.0, 10.0)];
        NSPoint endPoint    = [defaults pointForKey:@"EndPoint"   default:NSMakePoint(500.0, 400.0)];
        NSArray *points = @[[NSValue valueWithPoint:startPoint], [NSValue valueWithPoint:endPoint]];
        self.points = [[NSMutableArray alloc] initWithArray:points];
        
        CAShapeLayer *shape1Layer   = CAShapeLayer.layer;
        shape1Layer.name = @"Circle 1";
        CAShapeLayer *shape2Layer  = CAShapeLayer.layer;
        shape2Layer.name = @"Circle 2";

        self.shapeLayers = [[NSMutableArray alloc]init];
        [self.shapeLayers addObject:shape1Layer];
        [self.shapeLayers addObject:shape2Layer];


        
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
    NSAssert(0, @"Uses initWithCoder instead as called from IB");
    if (self = [super initWithFrame:frameRect]) {
        // Initialize self
    }
    return self;
}

- (void) addSubLayers {
    
    [self.layer addSublayer:self.gradientLayer];
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
    
    [self.layer addSublayer:self.shapeLayers[0]];
    [self.layer addSublayer:self.shapeLayers[1]];


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
    
    [self.centerTransform translateXBy:dx yBy:dy];
     caTransform = CATransform3DTranslate(caTransform, dx, dy, 0.0);

#else
    if (self.didFinishLaunching) [self.points moveAllPointsByX:dx andY:dy];
    
#endif
    
}


/*
- (void)initWithDelegateValues {
    AppDelegate *appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    
    self.drawingContext = Quartz;
    self.kind = Linear;
    self.startColor = appDelegate->color0.color;
    self.endColor   = appDelegate->color1.color;
}
*/


- (void) circleArround:(NSPoint)point radius:(double)radius color:(NSColor*)color {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:
        NSMakeRect(point.x - radius
                 , point.y - radius
                 , 2*radius, 2*radius
        )
    ];
    [[color opposite:self.alpha] set];

    CGFloat dash_pattern[] = {5.0, 5.0};
    NSInteger count = sizeof(dash_pattern)/sizeof(dash_pattern[0]);
    [path setLineDash:(CGFloat*)dash_pattern count:count phase:self.alpha*100];

    [path stroke];
}


- (void) gradientWithCGContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;

    [NSGraphicsContext saveGraphicsState];

    CGColorSpaceRef colorSpace = [self.colors colorAtIndex:0].colorSpace.CGColorSpace;


    NSInteger numberOfComponents = [self.colors colorAtIndex:0].numberOfComponents;
    CGFloat *components = malloc(sizeof(CGFloat)*2*numberOfComponents);
    [self.colors[0] getComponents:&components[0]];
    [self.colors[1] getComponents:&components[numberOfComponents]];

    double locations[] = {[defaults doubleForKey:@"startLocation"]
                        , [defaults doubleForKey:@"endLocation"]
    };

    CGGradientRef gradient = CGGradientCreateWithColorComponents(
                                     colorSpace, components
                                   , locations, 2
                             );

    switch (self.kind) {
        case Radial:
            CGContextDrawRadialGradient(
                  context, gradient
                , ((NSValue *)self.points[0]).pointValue
                , [defaults doubleForKey:@"startRadius"]
                , ((NSValue *)self.points[1]).pointValue
                , [defaults doubleForKey:@"endRadius"]
                , self.options
            );

            break;
        case Linear:
            CGContextDrawLinearGradient(
                  context, gradient
                , ((NSValue *)self.points[0]).pointValue
                , ((NSValue *)self.points[1]).pointValue
                , self.options
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
        shapeLayer.strokeColor = [color opposite:self.alpha].CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineDashPattern = @[@5, @5];
        shapeLayer.lineDashPhase = self.alpha*100;
        shapeLayer.name = name;
        CGPathRelease(cgPath);                                                  // cgPath must be released
    }
    return shapeLayer;
}

- (void)createCircle:(int)index {
    CAShapeLayer *shapeLayer = [self createCircleShape:[self.points pointAtIndex:index]
                                                 color:self.colors[index]
                                                  name:[self.shapeLayers layerNameAtIndex:index]
                                ];
    if (shapeLayer) {
        [self.layer replaceSublayer:self.shapeLayers[index] with:shapeLayer];
        self.shapeLayers[index] = shapeLayer;
    }
}




- (void) drawQuartzContext {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    [self gradientWithCGContext];
    
    switch (self.kind) {
        case Radial:
            [self circleArround:((NSValue *)self.points[0]).pointValue radius:[defaults doubleForKey:@"startRadius"] color:self.colors[0]];
            [self circleArround:((NSValue *)self.points[1]).pointValue radius:[defaults doubleForKey:@"endRadius"] color:self.colors[1]];
            break;
        default:
            [self circleArround:((NSValue *)self.points[0]).pointValue radius:10.0 color:self.colors[0]];
            [self circleArround:((NSValue *)self.points[1]).pointValue radius:10.0 color:self.colors[1]];
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
         [self.centerTransform transformPoint:[self.points pointAtIndex:0]].x/self.bounds.size.width
       , [self.centerTransform transformPoint:[self.points pointAtIndex:0]].y/self.bounds.size.height
    );
    
    NSPoint endPoint = NSMakePoint(
         [self.centerTransform transformPoint:[self.points pointAtIndex:1]].x/self.bounds.size.width
       , [self.centerTransform transformPoint:[self.points pointAtIndex:1]].y/self.bounds.size.height
    );
#else
    
    NSPoint startPoint = NSMakePoint(
                             [self.points pointAtIndex:0].x/self.bounds.size.width
                           , [self.points pointAtIndex:0].y/self.bounds.size.height
                         );
    NSPoint endPoint   = NSMakePoint(
                             [self.points pointAtIndex:1].x/self.bounds.size.width
                           , [self.points pointAtIndex:1].y/self.bounds.size.height
                         );

#endif

    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint   = endPoint;


    switch (self.kind) {
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
    gradientLayer.colors = self.colors.cgColorRefArray;

    [self.layer replaceSublayer:self.gradientLayer with:gradientLayer];
    self.gradientLayer = gradientLayer;
    
    [self createCircle:0];
    [self createCircle:1];
}




- (void) drawRect:(NSRect)dirtyRect {

    switch (self.drawingContext) {
        case CoreAnimation:
            [self drawCoreAnimation];
            break;
        case Quartz:
        default:
#ifdef USE_AFFINE
            [self.centerTransform concat];
#endif
            [self drawQuartzContext];
            break;
    }

}



- (void) updateContext:(NSPopUpButton *)sender {
    self.drawingContext = sender.indexOfSelectedItem;
    switch (self.drawingContext) {
        case CoreAnimation:
            self.wantsLayer = TRUE;
            break;
        case Quartz:
        default:
            if (self.kind == Conic) {
                self.kind = Linear;                                             // Conic not supported in quartz
            }
            self.wantsLayer = FALSE;
            self.layer.sublayers = nil;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (IBAction) updateKind:(NSSegmentedControl *)sender {
    self.kind = sender.selectedSegment;
    [self setNeedsDisplay:YES];
}

- (NSInteger) updateColor:(nonnull NSColor *)color at:(NSInteger)index {
    NSInteger colorSpaceIndex = -1;                                             /// no color space index change
    NSColorSpace *originalColorSpace = [self.colors colorAtIndex:index].colorSpace;
    self.colors[index] = color;                                                 /// set the new color
    NSColorSpace *colorSpace = [self.colors colorAtIndex:index].colorSpace;
    if (colorSpace != originalColorSpace) {
        [self.colors changeToColorSpace:colorSpace];                            /// change all colors to use the same color space

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
            self.options |= kCGGradientDrawsBeforeStartLocation;
            break;
        default:
            self.options &= ~kCGGradientDrawsBeforeStartLocation;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (IBAction) setEndOver:(NSButton *)sender {
    switch (sender.state) {
        case NSControlStateValueOn:
            self.options |= kCGGradientDrawsAfterEndLocation;
            break;
        default:
            self.options &= ~kCGGradientDrawsAfterEndLocation;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void) selectColorSpace:(NSColorSpace *)colorSpace {
    [self.colors changeToColorSpace:colorSpace];

    [self setNeedsDisplay:YES];
}



- (double) manhattanDistanceFrom:(NSPoint)from to:(NSPoint)to {
    return (fabs(from.x - to.x) + fabs(from.y - to.y));
}

- (int) findElement:(NSPoint)targetPoint {
    if (
        [self manhattanDistanceFrom:targetPoint to:((NSValue *)self.points[0]).pointValue]
      < [self manhattanDistanceFrom:targetPoint to:((NSValue *)self.points[1]).pointValue]
    )
        return 0;
    else
        return 1;
}

- (NSPoint) inverseTransformPoint:(NSPoint)point {

    #ifdef USE_AFFINE
        
        NSAffineTransform *xForm = [self.centerTransform copy];
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

    return self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
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
            self.alpha = 1.0;
            // fallthrough
        case NSGestureRecognizerStateChanged:
            self.points[index] = [NSValue valueWithPoint:mouseLoc];
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
    self.alpha = 1.0;
    [self fadeCirclesOut];
}


- (IBAction) myPressAndHoldGesture:(NSPressGestureRecognizer *)sender {
    //[self checkHitLayer:sender];
}




- (NSString *) componentsString {
    NSUInteger numberOfComponents = [self.colors colorAtIndex:0].numberOfComponents;
    CGFloat components[2*numberOfComponents], *ptr;
    ptr = components;
    [self.colors[0] getComponents:&components[0]];
    [self.colors[1] getComponents:&components[numberOfComponents]];
    
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

    switch (self.kind) {
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
                     , CFBridgingRelease(CGColorSpaceCopyName([self.colors colorAtIndex:0].colorSpace.CGColorSpace))
                     , [self componentsString]
                     , locations[0], locations[1]
                     , [self.points pointAtIndex:0].x, [self.points pointAtIndex:0].y
                     , [self.points pointAtIndex:1].x, [self.points pointAtIndex:1].y
                     , self.options
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
                     , CFBridgingRelease(CGColorSpaceCopyName([self.colors colorAtIndex:0].colorSpace.CGColorSpace))
                     , [self componentsString]
                     , locations[0], locations[1]
                     , [self.points pointAtIndex:0].x, [self.points pointAtIndex:0].y, startRadius
                     , [self.points pointAtIndex:1].x, [self.points pointAtIndex:1].y, endRadius
                     , self.options
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
    switch (self.kind) {
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
            , [self.points pointAtIndex:0].x/self.bounds.size.width, [self.points pointAtIndex:0].y/self.bounds.size.height
            , [self.points pointAtIndex:1].x/self.bounds.size.width, [self.points pointAtIndex:1].y/self.bounds.size.height
            , gradientTypeAsString
            , CFBridgingRelease(CGColorSpaceCopyName([self.colors colorAtIndex:0].colorSpace.CGColorSpace))
            , [self colorComponent:self.colors[0] prefixedBy:@"start"]
            , [self colorComponent:self.colors[1] prefixedBy:@"end"]

            ];

}


- (nonnull NSString *) code {
    switch (self.drawingContext) {
        case Quartz:
            return [self generateQuartzCode];
        default:
            return [self generateCoreAnimationCode];
    }
}

- (void) storeDefaults {
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    
    //PrintComponents(self.startColor)

    [defaults setColor:self.colors[0]  forKey:@"StartColor"];
    [defaults setColor:self.colors[1]  forKey:@"EndColor"];
    
    [defaults setPoint:[self.points pointAtIndex:0] forKey:@"StartPoint"];
    [defaults setPoint:[self.points pointAtIndex:1] forKey:@"EndPoint"];

}


- (nonnull NSColor *) colorAtIndex:(NSInteger)index {
    return self.colors[index];
}


@end
