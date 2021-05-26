//
//  TestGradient.h
//  GradientTestApplication
//
//  Created by LegoEsprit on 23.05.21.
//  Copyright © 2021 LegoEsprit. All rights reserved.
//
//  This SW displays a 2 point linear or radial gradient that can be manipulted
//  by the mouse and entry of some parameters.
//  The final code can be retrieved by the edit menu item: CopyGradientCode
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN



@interface TestGradient: NSView {
    
    //CFStringRef const defaultColorSpaceRef;
    
    enum GradientKind: NSInteger {
          Linear
        , Radial
        , Conic
    } GradientKind;
    
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

@property(assign) enum GradientKind        kind;
@property(weak, nonatomic) NSTimer        *fadeOutTimer;


@property(class, readonly, strong)          NSString *defaultColorSpace;
@property(class, readonly, weak, nonatomic) NSArray *allColorSpaces;
@property(class, readonly, weak, nonatomic) NSDictionary *gradientDefaults;



//@property(assign) CAGradientLayer       *gradient;



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


- (NSString *)code;


//[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];


@end

NS_ASSUME_NONNULL_END
