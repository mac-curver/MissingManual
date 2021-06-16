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

//#define USE_AFFINE                                                            // no positive impact, but more complicated

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN


@interface TestGradient: NSView {
    
    enum GradientKind: NSInteger {
          Linear
        , Radial
        , Conic
        , N_GradientKinds
    };
    
    enum DrawingContext: NSInteger {
          Quartz
        , CoreAnimation
        , N_DrawingContexts
    };
    
#ifdef USE_AFFINE

    CATransform3D                                   caTransform;
    
#endif
}

@property(assign) bool                              didFinishLaunching;         ///< activates center movement

@property(assign) double                            alpha;                      ///< used to fade out the circles
@property(strong, atomic) NSMutableArray           *colors;                     ///< all colors used
@property(strong, atomic) NSMutableArray           *points;                     ///< all points
@property(strong, atomic) NSMutableArray           *shapeLayers;                ///< all circle sublayers
@property(strong, atomic) NSMutableArray           *locations;                  ///< gradient locations 0...1

@property(strong, atomic) CALayerContentsGravity    myGravity;                  ///< use same value for all layers, but no impact?

#ifdef USE_AFFINE

@property(strong, atomic) NSAffineTransform        *centerTransform;            ///< Works now, but no improvement (see above)

#endif


@property(assign) CGGradientDrawingOptions          options;                    ///< options for quartz gradient

@property(assign) enum DrawingContext               drawingContext;             ///< Quartz <-> CoreAnimation

@property(assign) enum GradientKind                 kind;                       ///< Linear, radial, conic?

@property(weak, nonatomic) NSTimer                 *fadeOutTimer;               ///< timer to fade out the circles


@property(class, readonly, strong) NSString        *defaultColorSpaceName;      ///< color space NSString enum
@property(class, readonly, weak, nonatomic) NSArray *allColorSpaceNames;        ///< all NSString enums from documentation
@property(class, readonly, weak, nonatomic) NSDictionary *gradientDefaults;     ///< all user defaults



@property(strong, atomic) CAGradientLayer          *gradientLayer;              ///< in case of core animation the gradient




- (IBAction)updateKind:(NSSegmentedControl *)sender;                            ///< linear, radial,... segmented control was changed
- (IBAction)sliderStartLocation:(NSSlider *)sender;                             ///< start location 0...1 of the gradient was changed
- (IBAction)sliderEndLocation:(NSSlider *)sender;                               ///< end location 0...1 of the gradient was changed

- (IBAction)updateStartRadius:(NSTextField *)sender;                            ///< change of start radius
- (IBAction)updateEndRadius:(NSTextField *)sender;                              ///< change of end radius
- (IBAction)stepperStartRadius:(NSStepper *)sender;                             ///< connected via binding
- (IBAction)stepperEndRadius:(NSStepper *)sender;                               ///< connected via binding

- (IBAction)setStartOver:(NSButton *)sender;                                    ///< checkbox for Quartz changes options property
- (IBAction)setEndOver:(NSButton *)sender;                                      ///< checkbox for Quartz changes options property


- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender;                      ///< moves start and end point
- (IBAction)myClickGesture:(NSClickGestureRecognizer *)sender;                  ///< resets alpha to 1
- (IBAction)myPressAndHoldGesture:(NSPressGestureRecognizer *)sender;

+ (NSArray *)allColorSpaces;                                                    ///< list of all color spaces

- (void)updateContext:(NSPopUpButton *)sender;                                  ///< called from delegate
- (void)selectColorSpace:(NSColorSpace *)colorSpace;
- (NSInteger)updateColor:(NSColor *)color at:(NSInteger) index;                 ///< color well change for the n th color; returns index of colorSpace if changed or -1 if color space did not change
- (NSInteger)numberOfKinds;                                                     ///< 2 or 3 if Conic is supported
- (NSString *)code;                                                             ///< objective-C code for the clip board
- (void)storeDefaults;                                                          ///< store other values into shared user defaults
- (nonnull NSColor *)colorAtIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
