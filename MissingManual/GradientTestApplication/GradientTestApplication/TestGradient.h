//
//  TestGradient.h
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
//  This SW displays a 2 point linear or radial gradient that can be manipulated
//  by the mouse and entry of some parameters.
//  The final code can be retrieved by the edit menu item: CopyGradientCode
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN



@interface TestGradient: NSView {
    
    
    enum GradientKind: NSInteger {
          Linear
        , Radial
        , Conic
        , N_GradientKinds
    } GradientKind;
    
    enum DrawingContext: NSInteger {
          Quartz
        , CoreAnimation
        , N_DrawingContexts
    } DrawingContext;
    
    NSAffineTransform      *centerTransform;
    NSPoint                 centerMove;
    CGSize                  initialSize;

}


@property(assign) NSColor                 *startColor;                          // Gradient start color
@property(assign) NSColor                 *endColor;                            // Gradient end color
@property(assign) double                   startLocation;
@property(assign) double                   endLocation;
@property(assign) NSPoint                  startPoint;
@property(assign) NSPoint                  endPoint;
@property(assign) CGGradientDrawingOptions options;
@property(assign) CFStringRef              currentColorSpace;
@property(assign) double                   alpha;

@property(assign) enum DrawingContext      drawingContext;

@property(nonatomic, getter=numberOfKinds)
                       NSInteger           numbberOfKinds;
@property(assign) enum GradientKind        kind;

@property(weak, nonatomic) NSTimer        *fadeOutTimer;


@property(class, readonly, strong)          NSString *defaultColorSpace;
@property(class, readonly, weak, nonatomic) NSArray *allColorSpaces;
@property(class, readonly, weak, nonatomic) NSDictionary *gradientDefaults;



//@property(assign) CAGradientLayer *gradientLayer;
//@property(assign) CAShapeLayer *shape1Layer;
//@property(assign) CAShapeLayer *shape2Layer;


- (IBAction)updateContext:(NSPopUpButton *)sender;
- (IBAction)updateKind:(NSSegmentedControl *)sender;
- (IBAction)updateStartColor:(NSColorWell *)sender;
- (IBAction)updateEndColor:(NSColorWell *)sender;
- (IBAction)sliderStartLocation:(NSSlider *)sender;
- (IBAction)sliderEndLocation:(NSSlider *)sender;

- (IBAction)updateStartRadius:(NSTextField *)sender;
- (IBAction)updateEndRadius:(NSTextField *)sender;
- (IBAction)stepperStartRadius:(NSStepper *)sender;
- (IBAction)stepperEndRadius:(NSStepper *)sender;

- (IBAction)setStartOver:(NSButton *)sender;
- (IBAction)setEndOver:(NSButton *)sender;

- (IBAction)selectColorSpace:(NSPopUpButton *)sender;

- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender;

- (NSInteger)numberOfKinds;
- (NSString *)code;


//[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];


@end

NS_ASSUME_NONNULL_END
