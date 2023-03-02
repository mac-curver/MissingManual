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
    /// Enum for gradient kind
    ///
    /// Allows selection for linear, radial and for core animation in case
    /// the system supports it conic gradient.
    enum GradientKind: NSInteger {
        /// Selection of a linear gradient.
          Linear
        /// Selection of a radial gradient (quite different in different
        /// contexts).
        , Radial
        /// This selects the conic gradient, in case it is available.
        , Conic
        /// The Number of different gradient kinds (linear, ...).
        , N_GradientKinds
    };
    
    /// Enum for Drawing context
    ///
    /// Currently quartz and core animation are supported.
    enum DrawingContext: NSInteger {
          Quartz
        , CoreAnimation
        , N_DrawingContexts
    };
    
#ifdef USE_AFFINE

    CATransform3D                                   caTransform;
    
#endif
}

@property(assign) bool                              didFinishLaunching;         ///< Activates center movement

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



/// Update gradient kind from segmented control
///
/// Called whenever the segmented control has been changed.
/// - Parameters:
///   - sender: The connected control.
///   
/// > Sideeffect: Changes self.kind
- (IBAction)updateKind:(NSSegmentedControl *)sender;                            ///< linear, radial,... segmented control was changed

/// Action when gradient start location was changed
///
/// Start location 0...1 of the gradient was changed.
/// Just redraws the gradient.
- (IBAction)sliderStartLocation:(NSSlider *)sender;                             ///< start location 0...1 of the gradient was changed

/// Action when gradient end location was changed
///
/// End location 0...1 of the gradient was changed.
/// Just redraws the gradient.
- (IBAction)sliderEndLocation:(NSSlider *)sender;                               ///< end location 0...1 of the gradient was changed

/// Action when start radius was changed
///
/// Just redraws the gradient.
- (IBAction)updateStartRadius:(NSTextField *)sender;                            ///< change of start radius

/// Action when end radius was changed
///
/// Just redraws the gradient.
- (IBAction)updateEndRadius:(NSTextField *)sender;                              ///< change of end radius

/// Action when start radius stepper was changed
///
/// Just redraws the gradient. Stepper and corresponding text field are
/// connected via binding.
- (IBAction)stepperStartRadius:(NSStepper *)sender;                             ///< connected via binding

/// Action when start radius stepper was changed
///
/// Just redraws the gradient. Stepper and corresponding text field are
/// connected via binding.
- (IBAction)stepperEndRadius:(NSStepper *)sender;                               ///< connected via binding

/// Action when start over checkbox has been pressed
///
/// > Sideeffect: Changes self.options
- (IBAction)setStartOver:(NSButton *)sender;                                    ///< checkbox for Quartz changes options property

/// Action when end over checkbox has been pressed
///
/// > Sideeffect: Changes self.options
- (IBAction)setEndOver:(NSButton *)sender;                                      ///< checkbox for Quartz changes options property

/// Pan gesture action used to move the gradient positions
- (IBAction)myPanGesture:(NSPanGestureRecognizer *)sender;                      ///< moves start and end point

/// Click gesture action used to reset alpha to 1 to make the positions visible
- (IBAction)myClickGesture:(NSClickGestureRecognizer *)sender;                  

/// Not used currently
- (IBAction)myPressAndHoldGesture:(NSPressGestureRecognizer *)sender;

/// List of all color spaces
///
/// Contrary to expectation this returns all color name spaces. To retrieve
/// the names use ``allColorSpaceNames``.
///
/// - Returns: All color spaces in a NSArray
+ (NSArray *)allColorSpaces;

/// Action when context is being changed
///
/// This method should be called from delegate.
///
/// > Sideeffect: Changes self.options, self.kind, self.wantsLayer and
/// self.layer.sublayers
- (void)updateContext:(NSPopUpButton *)sender;

/// Action when color change is done
///
/// Redraws the contents.
- (void)selectColorSpace:(NSColorSpace *)colorSpace;

/// Update start respectively end color.
///
/// Used when color well change for the n th color.
///
/// - Parameters:
///     - color: New color to be taken
///     - index: The color index to be changed (0 == start, 1 == end)
/// - Returns: index of colorSpace if changed or -1 if color space
/// did not change.
///
/// > Example:
///     NSInteger cSIndex = [testGradientView updateColor:sender.color at:0];
- (NSInteger)updateColor:(NSColor *)color at:(NSInteger) index;

/// Get the number of gradient kinds
///
/// - Returns: 2 or 3 if Conic is supported
- (NSInteger)numberOfKinds;

/// Generates and returns the gradient objective-C code.
///
/// Use this method to generate the code for the clip board.
- (NSString *)code;

/// Store all values into the user defaults
- (void)storeDefaults;                                                          ///< store other values into shared user defaults

/// Retrieve the color with index from the color array
///
/// - Parameters:
///     - index: Index into the array
/// - Returns: The color at index.
- (nonnull NSColor *)colorAtIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
